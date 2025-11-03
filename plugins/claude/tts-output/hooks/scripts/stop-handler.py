#!/usr/bin/env python3
"""
Stop hook handler for TTS output plugin.
Speaks Claude's response summary using macOS 'say' command.
"""

import sys
import json
import subprocess
import re
import os
from pathlib import Path


def load_config():
    """Load TTS configuration from environment variables."""
    # Default debug log location: same directory as this script
    script_dir = Path(__file__).parent
    default_log_path = str(script_dir / "tts-debug.log")

    return {
        "enabled": os.environ.get("TTS_ENABLED", "true").lower() in ("true", "1", "yes"),
        "voice": os.environ.get("TTS_VOICE", "Samantha"),
        "speed": int(os.environ.get("TTS_SPEED", "200")),
        "debug": os.environ.get("TTS_DEBUG", "false").lower() in ("true", "1", "yes"),
        "debug_log": os.environ.get("TTS_DEBUG_LOG", default_log_path)
    }


def log_debug(message, log_file):
    """Write debug message to log file with timestamp."""
    try:
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(log_file, 'a') as f:
            f.write(f"[{timestamp}] {message}\n")
    except Exception:
        # Fail silently - don't disrupt the hook
        pass


def extract_tts_summary(text):
    """Extract TTS summary from HTML comment in text."""
    # Look for <!-- TTS-SUMMARY: ... -->
    pattern = r'<!--\s*TTS-SUMMARY:\s*(.+?)\s*-->'
    match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)

    if match:
        return match.group(1).strip()

    return None


def extract_fallback_summary(text, max_sentences=2):
    """Extract first N sentences as fallback summary."""
    # Remove HTML comments
    text = re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)

    # Remove markdown code blocks
    text = re.sub(r'```.*?```', '', text, flags=re.DOTALL)

    # Remove inline code
    text = re.sub(r'`[^`]+`', '', text)

    # Split into sentences (simple approach)
    sentences = re.split(r'(?<=[.!?])\s+', text.strip())

    # Take first N non-empty sentences
    summary_sentences = [s for s in sentences[:max_sentences] if s.strip()]

    if summary_sentences:
        return ' '.join(summary_sentences)

    return None


def read_last_assistant_message(transcript_path):
    """
    Read the JSONL transcript file and extract the last assistant message's text content.

    Returns:
        tuple: (text_content, message_count) where text_content is the combined text
               from all text blocks in the last assistant message, or None if not found.
    """
    try:
        # Expand user path if needed
        transcript_path = os.path.expanduser(transcript_path)

        if not os.path.exists(transcript_path):
            return None, 0

        last_assistant_text = None
        message_count = 0

        # Read JSONL file line by line
        with open(transcript_path, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                try:
                    data = json.loads(line)
                    message_count += 1

                    # Check if this is an assistant message
                    if 'message' in data and data['message'].get('role') == 'assistant':
                        content = data['message'].get('content', [])

                        # Extract all text blocks
                        text_blocks = [
                            block.get('text', '')
                            for block in content
                            if block.get('type') == 'text'
                        ]

                        # Join text blocks
                        if text_blocks:
                            last_assistant_text = '\n'.join(text_blocks)

                except json.JSONDecodeError:
                    # Skip malformed lines
                    continue

        return last_assistant_text, message_count

    except Exception as e:
        print(f"TTS Error reading transcript: {e}", file=sys.stderr)
        return None, 0


def speak_text(text, voice, speed):
    """Speak text using macOS 'say' command."""
    try:
        # Check if 'say' command exists (macOS only)
        result = subprocess.run(
            ['which', 'say'],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            print("TTS: 'say' command not available (non-macOS system)", file=sys.stderr)
            return False

        # Call 'say' command
        subprocess.run(
            ['say', '-v', voice, '-r', str(speed), text],
            check=True
        )
        return True

    except subprocess.CalledProcessError as e:
        print(f"TTS Error: Failed to speak text: {e}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"TTS Error: {e}", file=sys.stderr)
        return False


def main():
    """Main handler for Stop hook."""
    try:
        # Load configuration
        config = load_config()

        # Check if TTS is enabled
        if not config.get("enabled", True):
            return

        # Read JSON input from stdin
        input_data = sys.stdin.read()

        # If no input, nothing to process
        if not input_data.strip():
            return

        # Try to parse as JSON
        try:
            hook_data = json.loads(input_data)
        except json.JSONDecodeError:
            # Not valid JSON - skip execution
            if config.get("debug", False):
                debug_log = config.get("debug_log", "/tmp/tts-output-debug.log")
                log_debug("TTS-DEBUG: Invalid JSON input, skipping execution", debug_log)
            return

        # Only process if this is Stop hook data with transcript_path
        if not isinstance(hook_data, dict) or 'transcript_path' not in hook_data:
            if config.get("debug", False):
                debug_log = config.get("debug_log", "/tmp/tts-output-debug.log")
                log_debug("TTS-DEBUG: No transcript_path in input, skipping execution", debug_log)
            return

        transcript_path = hook_data['transcript_path']

        # Debug log transcript processing
        if config.get("debug", False):
            debug_log = config.get("debug_log", "/tmp/tts-output-debug.log")
            log_debug(f"TTS-DEBUG: Reading transcript from: {transcript_path}", debug_log)

        # Read the last assistant message from transcript
        response_text, message_count = read_last_assistant_message(transcript_path)

        # Debug log results
        if config.get("debug", False):
            debug_log = config.get("debug_log", "/tmp/tts-output-debug.log")
            if response_text:
                log_debug(
                    f"TTS-DEBUG: Found {message_count} messages in transcript, "
                    f"extracted {len(response_text)} chars from last assistant message",
                    debug_log
                )
            else:
                log_debug(
                    f"TTS-DEBUG: No assistant message found in transcript ({message_count} total messages)",
                    debug_log
                )

        # If no text found, skip execution
        if not response_text:
            return

        # Extract TTS summary
        summary = extract_tts_summary(response_text)

        # Fallback to first sentences if no summary comment found
        if not summary:
            summary = extract_fallback_summary(response_text)

        # If we have something to speak, do it
        if summary:
            voice = config.get("voice", "Samantha")
            speed = config.get("speed", 200)

            # Debug logging if enabled
            if config.get("debug", False):
                debug_log = config.get("debug_log", "/tmp/tts-output-debug.log")
                log_debug(
                    f"TTS-DEBUG: Speaking with voice='{voice}' speed={speed}: \"{summary}\"",
                    debug_log
                )

            speak_text(summary, voice, speed)

    except Exception as e:
        # Fail silently - don't disrupt Claude Code
        print(f"TTS Plugin Error: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
