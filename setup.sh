#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# ClawdDev Kit Setup Script
# ═══════════════════════════════════════════════════════════════════════════════
#
# This script automatically detects your platform and installs the appropriate
# ClawdDev Kit files for Clawdbot capability development.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/your-repo/clawd-dev-kit/main/setup.sh | bash
#
# Or with custom install directory:
#   CLAWD_DEV_KIT_DIR=~/my-clawd-kit curl -sL ... | bash
#
# ═══════════════════════════════════════════════════════════════════════════════

set -e

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "           🚀 ClawdDev Kit Setup"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────────────
# PLATFORM DETECTION
# ─────────────────────────────────────────────────────────────────────────────────

detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        echo "✅ Detected: macOS"
    elif grep -q Microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl2"
        echo "✅ Detected: WSL2 (Windows Subsystem for Linux)"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="wsl2"  # Use WSL2 config for native Linux too
        echo "✅ Detected: Linux (using WSL2 configuration)"
    else
        echo "❓ Unknown platform. Please choose:"
        echo "   1) macOS"
        echo "   2) WSL2 / Linux"
        read -p "Choice [1/2]: " choice
        case $choice in
            1) PLATFORM="macos" ;;
            2) PLATFORM="wsl2" ;;
            *)
                echo "❌ Invalid choice. Exiting."
                exit 1
                ;;
        esac
    fi
}

detect_platform

# ─────────────────────────────────────────────────────────────────────────────────
# INSTALLATION DIRECTORY
# ─────────────────────────────────────────────────────────────────────────────────

INSTALL_DIR="${CLAWD_DEV_KIT_DIR:-$HOME/clawd-dev-kit}"

echo "📁 Installing to: $INSTALL_DIR"
echo ""

# Create directory structure
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/capabilities"

# ─────────────────────────────────────────────────────────────────────────────────
# REPOSITORY URL
# ─────────────────────────────────────────────────────────────────────────────────

# Change this to your actual repository URL
REPO_RAW="${CLAWD_REPO_URL:-https://raw.githubusercontent.com/siphio/clawd-dev-kit/main}"

# ─────────────────────────────────────────────────────────────────────────────────
# DOWNLOAD CORE FILES
# ─────────────────────────────────────────────────────────────────────────────────

echo "⬇️  Downloading core commands..."

download_file() {
    local url="$1"
    local dest="$2"

    if command -v curl &> /dev/null; then
        curl -sL "$url" -o "$dest" 2>/dev/null
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$dest" 2>/dev/null
    else
        echo "❌ Neither curl nor wget found. Please install one."
        exit 1
    fi

    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "   ✓ $(basename "$dest")"
    else
        echo "   ✗ Failed: $(basename "$dest")"
    fi
}

# Core commands (platform-agnostic)
download_file "$REPO_RAW/core/clawd-global-rules.md" "$INSTALL_DIR/clawd-global-rules.md"
download_file "$REPO_RAW/core/clawd-create-prd.md" "$INSTALL_DIR/clawd-create-prd.md"
download_file "$REPO_RAW/core/clawd-prime.md" "$INSTALL_DIR/clawd-prime.md"
download_file "$REPO_RAW/core/clawd-plan-phase.md" "$INSTALL_DIR/clawd-plan-phase.md"
download_file "$REPO_RAW/core/clawd-execute-phase.md" "$INSTALL_DIR/clawd-execute-phase.md"

# ─────────────────────────────────────────────────────────────────────────────────
# DOWNLOAD PLATFORM-SPECIFIC FILES
# ─────────────────────────────────────────────────────────────────────────────────

echo ""
echo "⬇️  Downloading $PLATFORM-specific commands..."

download_file "$REPO_RAW/$PLATFORM/clawd-validate-phase.md" "$INSTALL_DIR/clawd-validate-phase.md"
download_file "$REPO_RAW/$PLATFORM/clawd-deploy.md" "$INSTALL_DIR/clawd-deploy.md"
download_file "$REPO_RAW/$PLATFORM/clawd-rollback.md" "$INSTALL_DIR/clawd-rollback.md"

# ─────────────────────────────────────────────────────────────────────────────────
# DOWNLOAD CONFIGURATION TEMPLATE
# ─────────────────────────────────────────────────────────────────────────────────

echo ""
echo "⬇️  Downloading configuration template..."

download_file "$REPO_RAW/.env.example" "$INSTALL_DIR/.env.example"

# ─────────────────────────────────────────────────────────────────────────────────
# CREATE .env FILE
# ─────────────────────────────────────────────────────────────────────────────────

if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    echo "📝 Created .env file from template"
else
    echo "ℹ️  .env file already exists - not overwriting"
fi

# ─────────────────────────────────────────────────────────────────────────────────
# CREATE .gitignore
# ─────────────────────────────────────────────────────────────────────────────────

cat > "$INSTALL_DIR/.gitignore" << 'EOF'
# Sensitive files - never commit
.env
*.pem
*.key
id_*

# Local development
capabilities/*/context.md
capabilities/*/execution-report.md
capabilities/*/validation-report.md

# OS files
.DS_Store
Thumbs.db

# Editor files
*.swp
*.swo
*~
.idea/
.vscode/
EOF

echo "📝 Created .gitignore"

# ─────────────────────────────────────────────────────────────────────────────────
# CREATE README
# ─────────────────────────────────────────────────────────────────────────────────

cat > "$INSTALL_DIR/README.md" << 'EOF'
# ClawdDev Kit

A systematic, human-in-the-loop development framework for building Clawdbot capabilities.

## Quick Start

1. **Configure your environment:**
   ```bash
   # Edit .env with your Mac Mini SSH details
   nano ~/clawd-dev-kit/.env
   ```

2. **Create a new capability:**
   ```bash
   /clawd-create-prd my-capability-name
   ```

3. **Follow the workflow:**
   - `/clawd-prime <capability>` - Load context
   - `/clawd-plan-phase <capability>` - Create implementation plan
   - `/clawd-execute-phase <capability>` - Implement the plan
   - `/clawd-validate-phase <capability>` - Test thoroughly
   - `/clawd-deploy <capability>` - Deploy to production

## Commands

| Command | Purpose |
|---------|---------|
| `clawd-global-rules.md` | Development conventions (read first!) |
| `clawd-create-prd.md` | Create Product Requirements Document |
| `clawd-prime.md` | Load context and research technologies |
| `clawd-plan-phase.md` | Create detailed implementation plan |
| `clawd-execute-phase.md` | Execute the implementation |
| `clawd-validate-phase.md` | Comprehensive testing |
| `clawd-deploy.md` | Deploy to Mac Mini |
| `clawd-rollback.md` | Rollback if issues occur |

## Configuration

Edit `.env` with your settings:
- `CLAWD_MINI_HOST` - Your Mac Mini hostname/IP
- `CLAWD_MINI_USER` - Your username on the Mini
- `CLAWD_MINI_SSH_KEY` - Path to SSH private key
- `CLAWD_MINI_WORKSPACE` - Production workspace path

## Documentation

See `clawd-global-rules.md` for comprehensive conventions and patterns.
EOF

echo "📝 Created README.md"

# ─────────────────────────────────────────────────────────────────────────────────
# VERIFY INSTALLATION
# ─────────────────────────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    Installation Complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📁 Installed to: $INSTALL_DIR"
echo ""
echo "📋 Files installed:"
ls -la "$INSTALL_DIR"/*.md 2>/dev/null | awk '{print "   " $NF}' | sed 's|.*/||'
echo ""

# ─────────────────────────────────────────────────────────────────────────────────
# NEXT STEPS
# ─────────────────────────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════════════"
echo "                       Next Steps"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. 📝 Configure your environment:"
echo "   nano $INSTALL_DIR/.env"
echo ""
echo "2. 🔑 Set up SSH keys to your Mac Mini:"
echo "   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_clawd_mini"
echo "   ssh-copy-id -i ~/.ssh/id_ed25519_clawd_mini.pub user@your-mini.local"
echo ""
echo "3. 🤖 Install Clawdbot locally for testing:"
echo "   npm install -g clawdbot"
echo "   clawdbot onboard"
echo ""
echo "4. 📚 Read the global rules:"
echo "   cat $INSTALL_DIR/clawd-global-rules.md"
echo ""
echo "5. 🚀 Create your first capability:"
echo "   /clawd-create-prd my-first-capability"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────────────
# OPTIONAL: SYMLINK TO CLAUDE COMMANDS
# ─────────────────────────────────────────────────────────────────────────────────

echo "💡 To use with Claude Code, you can symlink to your project:"
echo "   ln -s $INSTALL_DIR/*.md /path/to/your/project/.claude/commands/"
echo ""
echo "Or reference directly in your CLAUDE.md:"
echo "   See ~/clawd-dev-kit/ for Clawdbot capability development commands."
echo ""
