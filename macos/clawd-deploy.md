---
description: Deploy workspace/ folder to production Mac Mini
argument-hint: [capability-name]
---

# Deploy Clawdbot Capability (macOS)

You are deploying the **`workspace/` folder** from your project to production on the Mac Mini.

## The Flow: workspace/ → Production

```
YOUR PROJECT                         MAC MINI (Production)
─────────────────────────           ─────────────────────────
./workspace/                   ──►  ~/clawd/
├── IDENTITY.md               SSH   ├── IDENTITY.md
├── SOUL.md                    +    ├── SOUL.md
├── TOOLS.md                  SCP   ├── TOOLS.md
├── AGENTS.md                       ├── AGENTS.md
├── MEMORY.md                       ├── MEMORY.md
├── USER.md                         ├── USER.md
├── memory/                         ├── memory/
├── skills/                         └── skills/
└── media/

     SOURCE                              PRODUCTION
     (your project)                      (live Clawdbot)
```

---

## Pre-Deployment Checklist

### 1. Verify Validation Passed

```bash
echo "⚠️  IMPORTANT: Have you run /clawd-validate-phase and passed all tests?"
echo ""
echo "Only deploy after successful validation!"
echo ""
read -p "Validation passed? (yes/no): " CONFIRMED

if [ "$CONFIRMED" != "yes" ]; then
    echo "❌ Deployment cancelled. Run /clawd-validate-phase first."
    exit 1
fi
```

### 2. Load Environment Variables

```bash
# Load deployment config from .env
if [ -f ./.env ]; then
    source ./.env
    echo "✅ Loaded .env configuration"
else
    echo "❌ Missing .env file."
    echo ""
    echo "Create from .env.example:"
    echo "  cp .env.example .env"
    echo ""
    echo "Then edit with your Mac Mini details:"
    echo "  CLAWD_MINI_HOST=your-macmini.local"
    echo "  CLAWD_MINI_USER=your-username"
    echo "  CLAWD_MINI_SSH_KEY=~/.ssh/id_ed25519"
    exit 1
fi

# Required variables
: "${CLAWD_MINI_HOST:?Missing CLAWD_MINI_HOST in .env}"
: "${CLAWD_MINI_USER:?Missing CLAWD_MINI_USER in .env}"
: "${CLAWD_MINI_SSH_KEY:?Missing CLAWD_MINI_SSH_KEY in .env}"
CLAWD_MINI_WORKSPACE="${CLAWD_MINI_WORKSPACE:-~/clawd}"

echo "📍 Target: $CLAWD_MINI_USER@$CLAWD_MINI_HOST:$CLAWD_MINI_WORKSPACE"
```

### 3. Verify workspace/ exists

```bash
if [ ! -d ./workspace ]; then
    echo "❌ No workspace/ folder found."
    echo "   Run /clawd-execute-phase first."
    exit 1
fi

if [ ! -f ./workspace/SOUL.md ]; then
    echo "❌ workspace/SOUL.md not found."
    echo "   Run /clawd-execute-phase first."
    exit 1
fi

echo "✅ workspace/ folder verified"
```

### 4. Connectivity Pre-Check (Tailscale Recommended)

```bash
echo "🔌 Pre-deployment connectivity check..."

# Test ping first
if ping -c 1 -W 3 "$CLAWD_MINI_HOST" >/dev/null 2>&1; then
    echo "✅ Host $CLAWD_MINI_HOST is reachable"
else
    echo "❌ Cannot reach $CLAWD_MINI_HOST"
    echo ""
    echo "Tailscale Troubleshooting:"
    echo "  1. Check status on both machines: tailscale status"
    echo "  2. Ensure both are logged in and online"
    echo "  3. Verify CLAWD_MINI_HOST is your Tailscale node name"
    echo "  4. Try: tailscale ping $CLAWD_MINI_HOST"
    exit 1
fi

# Test SSH with auto host-key cleanup
echo "🔑 Testing SSH connection..."

if ! ssh -i "$CLAWD_MINI_SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" "echo 'Connection successful'" 2>/dev/null; then

    echo "⚠️  SSH failed. Attempting host key cleanup..."
    ssh-keygen -R "$CLAWD_MINI_HOST" 2>/dev/null || true

    if ! ssh -i "$CLAWD_MINI_SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes \
        -o StrictHostKeyChecking=accept-new \
        "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" "echo 'Connection successful'" 2>/dev/null; then
        echo "❌ Cannot connect to Mac Mini."
        echo ""
        echo "Tailscale Troubleshooting:"
        echo "  1. On dev machine: tailscale status"
        echo "  2. On Mac Mini: tailscale status"
        echo "  3. Ensure both show 'online'"
        echo "  4. Check: $CLAWD_MINI_HOST"
        exit 1
    fi
fi

echo "✅ SSH connection verified"
```

---

## Step 1: Create Safety Backup on Mini

```bash
echo "📦 Creating safety backup on Mac Mini..."

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_TAG="pre-deploy-$TIMESTAMP"

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << ENDSSH
    cd $CLAWD_MINI_WORKSPACE

    # Create backup directory
    mkdir -p .backups/$BACKUP_TAG

    # Backup current state
    cp SOUL.md .backups/$BACKUP_TAG/ 2>/dev/null || true
    cp TOOLS.md .backups/$BACKUP_TAG/ 2>/dev/null || true
    cp IDENTITY.md .backups/$BACKUP_TAG/ 2>/dev/null || true
    cp AGENTS.md .backups/$BACKUP_TAG/ 2>/dev/null || true

    if [ -d skills ]; then
        cp -r skills .backups/$BACKUP_TAG/
    fi

    echo "Backup tag: $BACKUP_TAG"
ENDSSH

echo "✅ Safety backup created: $BACKUP_TAG"
echo "   Use /clawd-rollback $BACKUP_TAG to restore if needed"
```

---

## Step 2: Stop Production Daemon

```bash
echo "⏸️  Stopping production daemon..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << 'ENDSSH'
    launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null || true
    echo "Daemon stopped"
ENDSSH

echo "✅ Production daemon stopped"
```

---

## Step 3: Deploy workspace/ to Production

```bash
echo "🚀 Deploying workspace/ to production..."

# Copy entire workspace folder contents
scp -i "$CLAWD_MINI_SSH_KEY" -r ./workspace/* \
    "$CLAWD_MINI_USER@$CLAWD_MINI_HOST:$CLAWD_MINI_WORKSPACE/"

echo "✅ workspace/ deployed to $CLAWD_MINI_HOST:$CLAWD_MINI_WORKSPACE/"
```

---

## Step 4: Install Skill Dependencies

```bash
echo "📦 Installing skill dependencies on Mac Mini..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << 'ENDSSH'
    cd ~/clawd/skills

    # Find all skills with package.json and install deps
    INSTALLED=0
    for skill_dir in */; do
        if [ -f "$skill_dir/package.json" ]; then
            echo "Installing dependencies for: $skill_dir"
            cd "$skill_dir"
            npm install --production 2>/dev/null || {
                echo "⚠️  npm install failed for $skill_dir"
            }
            cd ..
            INSTALLED=$((INSTALLED + 1))
        fi
    done

    if [ $INSTALLED -eq 0 ]; then
        echo "No skills with package.json found (skills may use built-in modules only)"
    else
        echo "✅ Installed dependencies for $INSTALLED skill(s)"
    fi
ENDSSH

echo "✅ Skill dependencies installed"
```

### Install Dependencies from SKILL.md Metadata

```bash
echo "📦 Installing dependencies from SKILL.md metadata..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << 'ENDSSH'
    cd ~/clawd/skills

    for skill_dir in */; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            echo "Processing: $skill_name"

            # Extract python packages from metadata
            PYTHON_PKGS=$(grep -A20 'requires:' "$skill_dir/SKILL.md" | grep -A5 'python:' | grep -o '"[^"]*"' | tr -d '"' 2>/dev/null || true)
            if [ -n "$PYTHON_PKGS" ]; then
                echo "  Installing python packages..."
                for pkg in $PYTHON_PKGS; do
                    pip3 install "$pkg" --quiet 2>/dev/null || echo "    ⚠️ Failed: $pkg"
                done
            fi

            # Extract system binaries from metadata
            SYSTEM_BINS=$(grep -A20 'requires:' "$skill_dir/SKILL.md" | grep -A5 'system:' | grep -o '"[^"]*"' | tr -d '"' 2>/dev/null || true)
            MISSING_BINS=""
            for bin in $SYSTEM_BINS; do
                if ! command -v "$bin" >/dev/null 2>&1; then
                    MISSING_BINS="$MISSING_BINS $bin"
                fi
            done

            if [ -n "$MISSING_BINS" ]; then
                echo "  Installing system binaries:$MISSING_BINS"
                for bin in $MISSING_BINS; do
                    brew install "$bin" 2>/dev/null || echo "    ⚠️ Install manually: brew install $bin"
                done
            fi
        fi
    done

    # Check common required binaries
    MISSING=""
    command -v node >/dev/null || MISSING="$MISSING node"
    command -v npm >/dev/null || MISSING="$MISSING npm"

    if [ -n "$MISSING" ]; then
        echo "⚠️  Missing core binaries:$MISSING"
    else
        echo "✅ All dependencies installed"
    fi
ENDSSH
```

---

## Step 5: Start Production Daemon

```bash
echo "▶️  Starting production daemon..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << 'ENDSSH'
    # Start the daemon
    launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
    sleep 3

    # Verify it's running
    if launchctl list | grep -q "com.clawdbot.gateway"; then
        echo "✅ Daemon started successfully"
    else
        echo "❌ Daemon failed to start"
        exit 1
    fi
ENDSSH

echo "✅ Production daemon started"
```

---

## Step 6: Verify Deployment

```bash
echo "🏥 Verifying deployment..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << 'ENDSSH'
    echo "--- Health Check ---"
    clawdbot health

    echo ""
    echo "--- Quick Capability Test ---"
    clawdbot agent --message "What capabilities do you have?" --thinking low
ENDSSH
```

---

## Step 7: Deployment Complete

```bash
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🚀 DEPLOYMENT COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Deployed: ./workspace/"
echo "Target:   $CLAWD_MINI_USER@$CLAWD_MINI_HOST:$CLAWD_MINI_WORKSPACE/"
echo "Backup:   $BACKUP_TAG"
echo ""
echo "The capability is now LIVE on your Mac Mini!"
echo ""
echo "To rollback if needed:"
echo "  /clawd-rollback $BACKUP_TAG"
echo ""
echo "To check status:"
echo "  ssh -i $CLAWD_MINI_SSH_KEY $CLAWD_MINI_USER@$CLAWD_MINI_HOST 'clawdbot health'"
echo ""
```

---

## Quick Reference

```bash
# Deploy to production
/clawd-deploy

# What it does:
# 1. Loads .env config (SSH details)
# 2. Creates safety backup on Mac Mini
# 3. Stops production daemon
# 4. Copies entire workspace/ folder to ~/clawd/ on Mini
# 5. Installs skill dependencies (npm install for each skill)
# 6. Checks required binaries are available
# 7. Starts production daemon
# 8. Verifies deployment

# The key insight:
# workspace/ IS your Clawdbot
# Just copy it to production and restart the daemon

# Required .env:
# CLAWD_MINI_HOST=your-macmini.local
# CLAWD_MINI_USER=your-username
# CLAWD_MINI_SSH_KEY=~/.ssh/id_ed25519
# CLAWD_MINI_WORKSPACE=~/clawd  (optional, defaults to ~/clawd)
```
