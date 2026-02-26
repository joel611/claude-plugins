#!/usr/bin/env bash
# Framework Detection Helper
# Detects web framework and provides port configuration guidance

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

FRAMEWORK=""
CONFIG_FILE=""
PORT_PATTERN=""

echo ""
echo "=== Framework Detection ==="
echo ""

# Detect Vite
if [[ -f "vite.config.ts" ]] || [[ -f "vite.config.js" ]]; then
    FRAMEWORK="Vite"
    if [[ -f "vite.config.ts" ]]; then
        CONFIG_FILE="vite.config.ts"
    else
        CONFIG_FILE="vite.config.js"
    fi
    PORT_PATTERN="server: { port: Number(process.env.PORT) || 5001 }"

    echo -e "${GREEN}✓${NC} Detected framework: ${FRAMEWORK}"
    echo ""
    echo "Port Configuration:"
    echo "  1. Add to ${CONFIG_FILE}:"
    echo -e "     ${BLUE}export default defineConfig({${NC}"
    echo -e "     ${BLUE}  server: {${NC}"
    echo -e "     ${BLUE}    port: Number(process.env.PORT) || 5001,${NC}"
    echo -e "     ${BLUE}  },${NC}"
    echo -e "     ${BLUE}});${NC}"
    echo ""
    echo "  2. Remove hardcoded port from package.json:"
    echo -e "     ${YELLOW}Before:${NC} \"dev\": \"vite dev --port 5001\""
    echo -e "     ${GREEN}After:${NC}  \"dev\": \"vite dev\""
    echo ""

# Detect Next.js
elif [[ -f "next.config.js" ]] || [[ -f "next.config.ts" ]] || [[ -f "next.config.mjs" ]]; then
    FRAMEWORK="Next.js"
    if [[ -f "next.config.ts" ]]; then
        CONFIG_FILE="next.config.ts"
    elif [[ -f "next.config.mjs" ]]; then
        CONFIG_FILE="next.config.mjs"
    else
        CONFIG_FILE="next.config.js"
    fi
    PORT_PATTERN="Reads PORT automatically"

    echo -e "${GREEN}✓${NC} Detected framework: ${FRAMEWORK}"
    echo ""
    echo "Port Configuration:"
    echo "  Next.js reads PORT environment variable automatically."
    echo ""
    echo "  1. Ensure package.json dev script doesn't hardcode port:"
    echo -e "     ${YELLOW}Avoid:${NC} \"dev\": \"next dev -p 3000\""
    echo -e "     ${GREEN}Use:${NC}   \"dev\": \"next dev\""
    echo ""
    echo "  2. PORT in .env.local will be used automatically"
    echo ""

# Detect Express/Node.js
elif [[ -f "src/server.ts" ]] || [[ -f "src/server.js" ]] || [[ -f "server.ts" ]] || [[ -f "server.js" ]]; then
    FRAMEWORK="Express/Node.js"
    if [[ -f "src/server.ts" ]]; then
        CONFIG_FILE="src/server.ts"
    elif [[ -f "src/server.js" ]]; then
        CONFIG_FILE="src/server.js"
    elif [[ -f "server.ts" ]]; then
        CONFIG_FILE="server.ts"
    else
        CONFIG_FILE="server.js"
    fi
    PORT_PATTERN="const PORT = Number(process.env.PORT) || 3000"

    echo -e "${GREEN}✓${NC} Detected framework: ${FRAMEWORK}"
    echo ""
    echo "Port Configuration:"
    echo "  Update ${CONFIG_FILE}:"
    echo -e "     ${BLUE}const PORT = Number(process.env.PORT) || 3000;${NC}"
    echo -e "     ${BLUE}app.listen(PORT, () => {${NC}"
    echo -e "     ${BLUE}  console.log(\`Server running on port \${PORT}\`);${NC}"
    echo -e "     ${BLUE}});${NC}"
    echo ""

# Detect Elysia/Bun
elif grep -q "elysia" package.json 2>/dev/null; then
    FRAMEWORK="Elysia (Bun)"
    CONFIG_FILE="src/index.ts (or equivalent)"
    PORT_PATTERN="const PORT = Number(process.env.PORT) || 3000"

    echo -e "${GREEN}✓${NC} Detected framework: ${FRAMEWORK}"
    echo ""
    echo "Port Configuration:"
    echo "  Update your server entry point:"
    echo -e "     ${BLUE}const PORT = Number(process.env.PORT) || 3000;${NC}"
    echo -e "     ${BLUE}app.listen(PORT, () => {${NC}"
    echo -e "     ${BLUE}  console.log(\`Server running on port \${PORT}\`);${NC}"
    echo -e "     ${BLUE}});${NC}"
    echo ""

else
    FRAMEWORK="Unknown"
    echo -e "${YELLOW}⚠${NC} Could not detect framework"
    echo ""
    echo "General Port Configuration:"
    echo "  1. Find your server entry point (index.ts, server.ts, etc.)"
    echo "  2. Replace hardcoded port with environment variable:"
    echo -e "     ${BLUE}const PORT = Number(process.env.PORT) || YOUR_DEFAULT_PORT;${NC}"
    echo "  3. Ensure .env.local is loaded before server starts"
    echo ""
fi

# Output machine-readable format for scripts
cat > /tmp/framework-detection.json <<EOF
{
  "framework": "${FRAMEWORK}",
  "config_file": "${CONFIG_FILE}",
  "port_pattern": "${PORT_PATTERN}"
}
EOF

echo "Framework detection complete."
echo ""
