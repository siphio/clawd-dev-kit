---
description: Rollback a production deployment on Mac Mini
argument-hint: [backup-tag]
---

# Rollback Clawdbot Deployment (macOS)

You are rolling back a production deployment on the Mac Mini to a previous state.

## Usage

```bash
# List available backups
/clawd-rollback list

# Rollback to a specific backup
/clawd-rollback pre-deploy-20240127_120000

# Rollback to the most recent backup
/clawd-rollback last
```

---

## Pre-Rollback

### Load Environment Variables

```bash
if [ -f ./.env ]; then
    source ./.env
    echo "✅ Loaded .env configuration"
else
    echo "❌ Missing .env file."
    exit 1
fi

: "${CLAWD_MINI_HOST:?Missing CLAWD_MINI_HOST}"
: "${CLAWD_MINI_USER:?Missing CLAWD_MINI_USER}"
: "${CLAWD_MINI_SSH_KEY:?Missing CLAWD_MINI_SSH_KEY}"
CLAWD_MINI_WORKSPACE="${CLAWD_MINI_WORKSPACE:-~/clawd}"
```

---

## Option 1: List Available Backups

If argument is `list`:

```bash
echo "📋 Available backups on Mac Mini:"
echo ""

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << ENDSSH
    cd $CLAWD_MINI_WORKSPACE/.backups 2>/dev/null || {
        echo "No backups found at $CLAWD_MINI_WORKSPACE/.backups/"
        exit 0
    }

    echo "Backup Tag                    | Date Created"
    echo "------------------------------+------------------"

    for dir in */; do
        if [ -d "\$dir" ]; then
            TAG=\${dir%/}
            DATE=\$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "\$dir" 2>/dev/null || echo "unknown")
            printf "%-29s | %s\n" "\$TAG" "\$DATE"
        fi
    done
ENDSSH
```

---

## Option 2: Rollback to Last Backup

If argument is `last`:

```bash
echo "🔍 Finding most recent backup..."

BACKUP_TAG=$(ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" \
    "ls -t $CLAWD_MINI_WORKSPACE/.backups/ 2>/dev/null | head -1")

if [ -z "$BACKUP_TAG" ]; then
    echo "❌ No backups found"
    exit 1
fi

echo "📦 Most recent backup: $BACKUP_TAG"
```

Then proceed to rollback (Step 1 below).

---

## Option 3: Rollback to Specific Backup

If argument is a specific tag:

```bash
BACKUP_TAG="$ARGUMENTS"

echo "🔍 Verifying backup exists..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" \
    "test -d $CLAWD_MINI_WORKSPACE/.backups/$BACKUP_TAG" || {
    echo "❌ Backup not found: $BACKUP_TAG"
    echo ""
    echo "Run '/clawd-rollback list' to see available backups"
    exit 1
}

echo "✅ Backup found: $BACKUP_TAG"
```

---

## Step 1: Create Pre-Rollback Safety Backup

```bash
echo "📦 Creating safety backup before rollback..."

SAFETY_TAG="pre-rollback-$(date +%Y%m%d_%H%M%S)"

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << ENDSSH
    cd $CLAWD_MINI_WORKSPACE
    mkdir -p .backups/$SAFETY_TAG

    cp SOUL.md .backups/$SAFETY_TAG/ 2>/dev/null || true
    cp TOOLS.md .backups/$SAFETY_TAG/ 2>/dev/null || true
    cp IDENTITY.md .backups/$SAFETY_TAG/ 2>/dev/null || true
    cp AGENTS.md .backups/$SAFETY_TAG/ 2>/dev/null || true

    if [ -d skills ]; then
        cp -r skills .backups/$SAFETY_TAG/
    fi

    echo "Safety backup: $SAFETY_TAG"
ENDSSH

echo "✅ Safety backup created: $SAFETY_TAG"
```

---

## Step 2: Stop Daemon

```bash
echo "⏸️  Stopping daemon..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" \
    "launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null || true"

echo "✅ Daemon stopped"
```

---

## Step 3: Restore from Backup

```bash
echo "🔄 Restoring from backup: $BACKUP_TAG..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << ENDSSH
    cd $CLAWD_MINI_WORKSPACE
    BACKUP_DIR=".backups/$BACKUP_TAG"

    # Restore core files
    cp "\$BACKUP_DIR/SOUL.md" . 2>/dev/null && echo "  ✅ SOUL.md restored"
    cp "\$BACKUP_DIR/TOOLS.md" . 2>/dev/null && echo "  ✅ TOOLS.md restored"
    cp "\$BACKUP_DIR/IDENTITY.md" . 2>/dev/null && echo "  ✅ IDENTITY.md restored"
    cp "\$BACKUP_DIR/AGENTS.md" . 2>/dev/null && echo "  ✅ AGENTS.md restored"

    # Restore skills
    if [ -d "\$BACKUP_DIR/skills" ]; then
        rm -rf skills/*
        cp -r "\$BACKUP_DIR/skills/"* skills/ 2>/dev/null || true
        echo "  ✅ skills/ restored"
    fi
ENDSSH

echo "✅ Backup restored"
```

---

## Step 4: Start Daemon

```bash
echo "▶️  Starting daemon..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << 'ENDSSH'
    launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
    sleep 3

    if launchctl list | grep -q "com.clawdbot.gateway"; then
        echo "✅ Daemon started"
    else
        echo "❌ Daemon failed to start"
        exit 1
    fi
ENDSSH

echo "✅ Daemon started"
```

---

## Step 5: Verify Rollback

```bash
echo "🏥 Verifying rollback..."

ssh -i "$CLAWD_MINI_SSH_KEY" "$CLAWD_MINI_USER@$CLAWD_MINI_HOST" << 'ENDSSH'
    clawdbot health
ENDSSH

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ ROLLBACK COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Restored from: $BACKUP_TAG"
echo "Safety backup: $SAFETY_TAG"
echo ""
echo "If you need to undo this rollback:"
echo "  /clawd-rollback $SAFETY_TAG"
echo ""
```

---

## Quick Reference

```bash
# List backups
/clawd-rollback list

# Rollback to most recent
/clawd-rollback last

# Rollback to specific backup
/clawd-rollback pre-deploy-20240127_120000

# What it does:
# 1. Creates safety backup of current state
# 2. Stops daemon
# 3. Restores files from specified backup
# 4. Starts daemon
# 5. Verifies health
```
