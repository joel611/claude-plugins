# TTS Output Plugin

A Claude Code plugin that provides text-to-speech output for Claude's responses using macOS `say` command.

## Features

- 🔊 Automatic text-to-speech for Claude's final responses
- 📝 AI-generated summaries optimized for speech
- 🎚️ Customizable voice, speed, and enable/disable controls
- 🍎 Native macOS integration using the `say` command
- 🔇 Silent fallback on non-macOS systems

## Installation

Install from the marketplace:

```bash
/plugin install tts-output@claude-marketplace
```

The plugin will automatically:
- Register `SessionStart` hook to request TTS summaries from Claude
- Register `Stop` hook to speak responses when Claude finishes

## How It Works

1. **Session Start**: When Claude Code starts, a system prompt is injected asking Claude to include a brief summary at the end of responses in an HTML comment:
   ```html
   <!-- TTS-SUMMARY: Brief 1-2 sentence summary -->
   ```

2. **Stop Hook**: When Claude finishes responding, the plugin:
   - Extracts the TTS summary from the response
   - Falls back to first 2 sentences if no summary present
   - Speaks the summary using macOS `say` command (if enabled)

3. **Smart Summaries**: Claude generates concise, speakable summaries that capture the key points without technical jargon.

## Configuration

The plugin is configured using environment variables. You can set these in your shell profile or Claude Code settings.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TTS_ENABLED` | `true` | Enable/disable TTS output (`true`, `false`, `1`, `0`, `yes`, `no`) |
| `TTS_VOICE` | `Samantha` | Voice name for macOS `say` command |
| `TTS_SPEED` | `200` | Speech rate in words per minute (180-220 is typical) |
| `TTS_DEBUG` | `false` | Enable debug logging to file |
| `TTS_DEBUG_LOG` | `{plugin}/hooks/scripts/tts-debug.log` | Path to debug log file |

### Setting Environment Variables

**In your shell profile** (e.g., `~/.zshrc` or `~/.bash_profile`):
```bash
export TTS_ENABLED=true
export TTS_VOICE=Alex
export TTS_SPEED=190
export TTS_DEBUG=false
```

**For Claude Code** (in settings or before launching):
```bash
TTS_VOICE=Victoria TTS_SPEED=210 claude
```

### Available Voices

**Popular voices:**
- Samantha (default) - Natural female voice
- Alex - Clear male voice
- Victoria - British female voice
- Fiona - Scottish female voice
- Daniel - British male voice

Run `say -v ?` in Terminal to see all available voices.

### Debug Mode

Enable debug mode to troubleshoot TTS issues:

```bash
export TTS_DEBUG=true
```

By default, the debug log is written to `tts-debug.log` in the plugin's `hooks/scripts/` directory. You can customize the location:

```bash
export TTS_DEBUG_LOG=/custom/path/tts-debug.log
```

View the debug log:
```bash
# Default location (in plugin directory)
tail -f ~/.claude/plugins/tts-output/hooks/scripts/tts-debug.log

# Or custom location
tail -f $TTS_DEBUG_LOG
```

The debug log shows:
- Timestamp of each TTS event
- Voice and speed settings used
- Exact text being spoken

## Requirements

- **macOS**: The plugin uses the macOS `say` command
- **Python 3**: Required for the Stop hook handler
- **Claude Code**: Plugin system with hook support

On non-macOS systems, the plugin will fail silently without disrupting Claude Code.

## Project Structure

```
tts-output/
├── .claude-plugin/
│   └── plugin.json                # Plugin metadata
├── hooks/
│   ├── hooks.json                 # Hook configuration (auto-registered)
│   └── scripts/
│       ├── session-start.sh       # SessionStart hook (inject prompt)
│       ├── stop-handler.py        # Stop hook (speak response)
│       └── tts-debug.log          # Debug log (created when TTS_DEBUG=true)
└── README.md                      # This file
```

## Troubleshooting

### TTS not working
- **Enable debug mode** to see what's happening: `export TTS_DEBUG=true`
- Check the debug log: `tail -f ~/.claude/plugins/tts-output/hooks/scripts/tts-debug.log`
- Check macOS `say` command works: `say "test"` in Terminal
- Verify Python 3 is installed: `python3 --version`
- Check plugin is installed: `/plugin list`
- Verify TTS is enabled: `echo $TTS_ENABLED` (should be empty or `true`)

### No audio output
- Check system volume and audio output device
- Test with Terminal: `say -v Samantha "test"`
- Enable debug mode to verify text is being extracted correctly

### Voice not found
- List available voices: `say -v ?`
- Some voices require download from System Settings > Accessibility > Spoken Content > Voices
- Check debug log to see which voice is being used

## Privacy & Performance

- All processing happens locally on your machine
- No data is sent to external services
- The `say` command is a native macOS utility
- Minimal performance impact (runs after Claude finishes)

## License

Part of the claude-marketplace repository.

## Author

Joel Chan (joel611@live.hk)

## Version

1.0.0
