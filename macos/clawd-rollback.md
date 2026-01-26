---
description: Rollback production Clawdbot to previous state
argument-hint: [commit-hash or "last" or "list"]
---

# Rollback Clawdbot Production (macOS)

You are rolling back your Mac Mini Clawdbot instance to a previous state. This command allows you to safely undo a deployment without physically accessing the Mac Mini.

## Usage

- `/clawd-rollback list` - Show recent deployments and backups
- `/clawd-rollback last` - Rollback to the previous deployment
- `/clawd-rollback <commit-hash>` - Rollback to a specific Git commit
- `/clawd-rollback <backup-name>` - Restore from a specific backup

---

## Step 1: Load Configuration

```bash
echo "📋 Loading configuration..."

# Load environment variables
if [ -f ~/clawd-dev-kit/.env ]; then
    source ~/clawd-dev-kit/.env
else
    echo "❌ ERROR: .env file not found"
    exit 1
fi

# Validate required variables
if [ -z "$CLAWD_MINI_HOST" ] || [ -z "$CLAWD_MINI_USER" ] || [ -z "$CLAWD_MINI_SSH_KEY" ] || [ -z "$CLAWD_MINI_WORKSPACE" ]; then
    echo "❌ ERROR: Missing required configuration in .env"
    exit 1
fi

# Expand SSH key path
ssh_key="${CLAWD_MINI_SSH_KEY/#\~/$HOME}"

echo "✅ Configuration loaded"
echo "   Target: ${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}"
```

---

## Step 2: Test SSH Connection

```bash
echo "📋 Testing SSH connection..."

if ssh -i "$ssh_key" -o ConnectTimeout=10 -o BatchMode=yes \
    "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" "echo 'Connection OK'" 2>/dev/null; then
    echo "✅ SSH connection successful"
else
    echo "❌ ERROR: Cannot connect to Mac Mini"
    echo "   Ensure Mac Mini is on and SSH is accessible"
    exit 1
fi
```

---

## Step 3: Parse Arguments

```bash
argument="$ARGUMENTS"

if [ -z "$argument" ]; then
    echo "Usage: /clawd-rollback [list|last|<commit-hash>|<backup-name>]"
    echo ""
    echo "Options:"
    echo "  list          Show recent deployments and available backups"
    echo "  last          Rollback to the previous deployment (HEAD~1)"
    echo "  <commit-hash> Rollback to a specific Git commit"
    echo "  <backup-name> Restore from a filesystem backup"
    exit 0
fi
```

---

## Option A: List Deployments and Backups

If argument is "list":

```bash
if [ "$argument" == "list" ]; then
    echo "📋 Fetching deployment history..."

    ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
        echo "═══════════════════════════════════════════════════════════════"
        echo "                    DEPLOYMENT HISTORY"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "📍 Current state:"
        cd "$CLAWD_MINI_WORKSPACE"
        git log --oneline -1
        echo ""

        echo "📜 Recent Git commits (last 10):"
        git log --oneline -10
        echo ""

        echo "🏷️  Release tags:"
        git tag -l "capability-*" | tail -10
        echo ""

        echo "💾 Filesystem backups:"
        ls -la "${CLAWD_MINI_WORKSPACE}-"* 2>/dev/null | tail -10 || echo "No filesystem backups found"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
EOF

    exit 0
fi
```

---

## Option B: Rollback to Last Deployment

If argument is "last":

```bash
if [ "$argument" == "last" ]; then
    echo "📋 Rolling back to previous deployment (HEAD~1)..."

    # Get current and target commits
    ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
        cd "$CLAWD_MINI_WORKSPACE"

        current_commit=\$(git rev-parse HEAD)
        target_commit=\$(git rev-parse HEAD~1)

        echo "📍 Current commit: \$current_commit"
        echo "🎯 Target commit:  \$target_commit"
        echo ""
        echo "Changes to be rolled back:"
        git log --oneline HEAD~1..HEAD
EOF

    # Confirmation checkpoint
    echo ""
    echo "⚠️  CONFIRMATION REQUIRED"
    echo "This will:"
    echo "  1. Checkout the previous commit on Mac Mini"
    echo "  2. Restart the Clawdbot daemon"
    echo "  3. Any current changes will be reverted"
    echo ""
    echo "Proceed with rollback? (Awaiting user confirmation)"

    # In actual execution, the user confirms in chat
    # Then continue:

    ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << 'EOF'
        cd "$CLAWD_MINI_WORKSPACE"

        # Create safety tag
        safety_tag="pre-rollback-$(date +%Y%m%d-%H%M%S)"
        git tag -a "$safety_tag" -m "Auto-backup before rollback"
        echo "✅ Created safety tag: $safety_tag"

        # Stop daemon
        echo "⏸️  Stopping Clawdbot daemon..."
        launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null
        sleep 2

        # Perform rollback
        echo "⏪ Rolling back to HEAD~1..."
        git checkout HEAD~1

        # Restart daemon
        echo "▶️  Starting Clawdbot daemon..."
        launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
        sleep 5

        # Verify
        if launchctl list 2>/dev/null | grep -q "clawdbot"; then
            echo "✅ Daemon restarted"
        else
            echo "❌ Daemon may not have started"
        fi

        echo ""
        echo "📍 Now running:"
        git log --oneline -1
EOF

    echo "✅ Rollback to last deployment complete"
    exit 0
fi
```

---

## Option C: Rollback to Specific Commit

If argument looks like a commit hash (7+ hex characters):

```bash
if [[ "$argument" =~ ^[a-f0-9]{7,}$ ]]; then
    target_commit="$argument"
    echo "📋 Rolling back to commit: $target_commit"

    ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
        cd "$CLAWD_MINI_WORKSPACE"

        # Verify commit exists
        if git cat-file -t "$target_commit" >/dev/null 2>&1; then
            echo "✅ Commit found"
        else
            echo "❌ ERROR: Commit $target_commit not found"
            exit 1
        fi

        echo "📍 Current commit:"
        git log --oneline -1

        echo "🎯 Target commit:"
        git log --oneline -1 "$target_commit"

        echo ""
        echo "Changes to be rolled back:"
        git log --oneline "$target_commit"..HEAD
EOF

    # Confirmation checkpoint
    echo ""
    echo "⚠️  CONFIRMATION REQUIRED"
    echo "Proceed with rollback to $target_commit? (Awaiting user confirmation)"

    # After confirmation:

    ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
        cd "$CLAWD_MINI_WORKSPACE"

        # Create safety tag
        safety_tag="pre-rollback-\$(date +%Y%m%d-%H%M%S)"
        git tag -a "\$safety_tag" -m "Auto-backup before rollback to $target_commit"
        echo "✅ Created safety tag: \$safety_tag"

        # Stop daemon
        echo "⏸️  Stopping Clawdbot daemon..."
        launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null
        sleep 2

        # Perform rollback
        echo "⏪ Rolling back to $target_commit..."
        git checkout "$target_commit"

        # Restart daemon
        echo "▶️  Starting Clawdbot daemon..."
        launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
        sleep 5

        # Verify
        echo "📍 Now running:"
        git log --oneline -1

        # Health check
        echo ""
        clawdbot health
EOF

    echo "✅ Rollback to $target_commit complete"
    exit 0
fi
```

---

## Option D: Restore from Filesystem Backup

If argument matches backup naming pattern:

```bash
if [[ "$argument" == *"backup"* ]] || [[ "$argument" == *"clawd-"* ]]; then
    backup_name="$argument"
    echo "📋 Restoring from backup: $backup_name"

    ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
        # Check if backup exists
        backup_path="${CLAWD_MINI_WORKSPACE}-${backup_name}"

        if [ ! -d "\$backup_path" ]; then
            # Try without prefix
            backup_path="$backup_name"
        fi

        if [ ! -d "\$backup_path" ]; then
            echo "❌ ERROR: Backup not found: $backup_name"
            echo "Available backups:"
            ls -la "${CLAWD_MINI_WORKSPACE}-"* 2>/dev/null || echo "No backups found"
            exit 1
        fi

        echo "✅ Backup found: \$backup_path"
EOF

    # Confirmation checkpoint
    echo ""
    echo "⚠️  CONFIRMATION REQUIRED"
    echo "This will REPLACE the current workspace with the backup."
    echo "Current workspace will be backed up first."
    echo "Proceed? (Awaiting user confirmation)"

    # After confirmation:

    ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
        backup_path="${CLAWD_MINI_WORKSPACE}-${backup_name}"
        if [ ! -d "\$backup_path" ]; then
            backup_path="$backup_name"
        fi

        # Stop daemon
        echo "⏸️  Stopping Clawdbot daemon..."
        launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null
        sleep 2

        # Backup current state
        current_backup="${CLAWD_MINI_WORKSPACE}-pre-restore-\$(date +%Y%m%d-%H%M%S)"
        echo "💾 Backing up current state to: \$current_backup"
        mv "$CLAWD_MINI_WORKSPACE" "\$current_backup"

        # Restore from backup
        echo "📦 Restoring from backup..."
        cp -r "\$backup_path" "$CLAWD_MINI_WORKSPACE"

        # Restart daemon
        echo "▶️  Starting Clawdbot daemon..."
        launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
        sleep 5

        # Verify
        echo "✅ Restore complete"
        echo ""
        clawdbot health
EOF

    echo "✅ Restore from backup complete"
    exit 0
fi
```

---

## Post-Rollback Verification

After any rollback:

```bash
echo "📋 Post-rollback verification..."

ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    ROLLBACK VERIFICATION"
    echo "═══════════════════════════════════════════════════════════════"

    echo ""
    echo "📍 Current state:"
    cd "$CLAWD_MINI_WORKSPACE"
    git log --oneline -1

    echo ""
    echo "🔍 Daemon status:"
    if launchctl list 2>/dev/null | grep -q "clawdbot"; then
        echo "✅ Clawdbot daemon is running"
    else
        echo "❌ Clawdbot daemon is NOT running"
    fi

    echo ""
    echo "💚 Health check:"
    clawdbot health

    echo ""
    echo "📜 Recent logs:"
    clawdbot logs --limit 10

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
EOF
```

---

## Rollback Report

```markdown
# ROLLBACK REPORT
# Date: [date]

═══════════════════════════════════════════════════════════════
                      ROLLBACK SUMMARY
═══════════════════════════════════════════════════════════════

✅ SSH connection verified
✅ Safety backup created
✅ Daemon stopped
✅ Rollback performed
✅ Daemon restarted
✅ Health check passed

═══════════════════════════════════════════════════════════════

## Rollback Details

- **Type**: [last / commit / backup]
- **Previous State**: [old commit/state]
- **Current State**: [new commit/state]
- **Safety Tag**: [tag name] (to undo this rollback)

## To Undo This Rollback

If you need to restore the state before this rollback:
```
/clawd-rollback [safety-tag-name]
```

═══════════════════════════════════════════════════════════════
```

---

## Emergency Recovery

If rollback fails and daemon won't start:

```bash
echo "🚨 Emergency recovery..."

ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
    echo "Force killing any Clawdbot processes..."
    pkill -9 -f clawdbot 2>/dev/null
    sleep 2

    echo "Checking for recent logs..."
    clawdbot logs --limit 50 2>/dev/null || echo "Cannot get logs"

    echo ""
    echo "Checking workspace integrity..."
    cd "$CLAWD_MINI_WORKSPACE"
    ls -la

    echo ""
    echo "Attempting daemon start..."
    launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
    sleep 5

    if launchctl list 2>/dev/null | grep -q "clawdbot"; then
        echo "✅ Daemon recovered"
    else
        echo "❌ Daemon still not running"
        echo ""
        echo "Manual intervention may be required."
        echo "Try: SSH to Mini and run 'clawdbot status --all'"
    fi
EOF
```

---

## Troubleshooting

### Rollback Commands Quick Reference

```bash
# List all options
/clawd-rollback list

# Rollback to previous deployment
/clawd-rollback last

# Rollback to specific commit
/clawd-rollback abc1234

# Restore from backup
/clawd-rollback backup-20260126-143022

# Undo a rollback (use safety tag)
/clawd-rollback pre-rollback-20260126-150000
```

### Common Issues

1. **SSH connection fails**
   - Check Mini is powered on
   - Check network connectivity
   - Verify SSH key is correct

2. **Commit not found**
   - Run `/clawd-rollback list` to see available commits
   - Make sure to use full commit hash if short one is ambiguous

3. **Daemon won't start after rollback**
   - Check logs: `clawdbot logs --limit 50`
   - Check SOUL.md is valid YAML
   - Try emergency recovery commands above

4. **Backup not found**
   - Run `/clawd-rollback list` to see available backups
   - Backups are named with timestamps: `clawd-backup-YYYYMMDD-HHMMSS`
