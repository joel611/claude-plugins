#!/bin/bash

# SessionStart hook for TTS output plugin
# This script injects a system prompt to request TTS summaries

cat <<'EOF'
IMPORTANT: The TTS output plugin is active. At the end of each final response, include an HTML comment with a brief summary for text-to-speech output:

<!-- TTS-SUMMARY: 1-2 sentence summary of your response -->

The summary should:
- Be concise (1-2 sentences maximum)
- Capture the key point or result of your response
- Be natural and speakable (avoid technical jargon when possible)
- Focus on what you accomplished or the main takeaway

Example:
<!-- TTS-SUMMARY: I've successfully implemented the authentication feature and all tests are passing. -->
EOF
