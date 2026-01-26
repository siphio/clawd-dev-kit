---
description: Deploy validated Clawdbot capability to production Mac Mini
argument-hint: [capability-name]
---

# Deploy Clawdbot Capability to Production (macOS)

You are deploying a validated Clawdbot capability from your development machine to your production Mac Mini via Git and SSH.

## Critical Context

**MANDATORY READS**:
1. `~/clawd-dev-kit/capabilities/$ARGUMENTS/validation-report.md` - Must show ALL PASS

**Requirements**:
- Validation report shows all levels passed
- SSH keys configured to Mac Mini
- Git repository set up for capabilities
- `.env` file configured with deployment settings

**Platform**: Deploying FROM macOS development machine TO macOS Mac Mini

---

## Pre-Deployment Checklist

### Step 1: Load Configuration

```bash
echo "📋 Loading deployment configuration..."

# Load environment variables
if [ -f ~/clawd-dev-kit/.env ]; then
    source ~/clawd-dev-kit/.env
    echo "✅ Configuration loaded"
else
    echo "❌ ERROR: .env file not found"
    echo "   Copy .env.example to .env and configure your settings"
    exit 1
fi

# Validate required variables
missing_vars=""

if [ -z "$CLAWD_MINI_HOST" ]; then
    missing_vars="$missing_vars CLAWD_MINI_HOST"
fi

if [ -z "$CLAWD_MINI_USER" ]; then
    missing_vars="$missing_vars CLAWD_MINI_USER"
fi

if [ -z "$CLAWD_MINI_SSH_KEY" ]; then
    missing_vars="$missing_vars CLAWD_MINI_SSH_KEY"
fi

if [ -z "$CLAWD_MINI_WORKSPACE" ]; then
    missing_vars="$missing_vars CLAWD_MINI_WORKSPACE"
fi

if [ -n "$missing_vars" ]; then
    echo "❌ ERROR: Missing required configuration:"
    echo "   $missing_vars"
    echo "   Please update ~/clawd-dev-kit/.env"
    exit 1
fi

echo "   Host: $CLAWD_MINI_HOST"
echo "   User: $CLAWD_MINI_USER"
echo "   SSH Key: $CLAWD_MINI_SSH_KEY"
echo "   Workspace: $CLAWD_MINI_WORKSPACE"
```

### Step 2: Verify Validation Passed

```bash
echo "📋 Verifying validation status..."

validation_report=~/clawd-dev-kit/capabilities/$ARGUMENTS/validation-report.md

if [ ! -f "$validation_report" ]; then
    echo "❌ ERROR: Validation report not found"
    echo "   Run /clawd-validate-phase $ARGUMENTS first"
    exit 1
fi

# Check for FAIL in validation report
if grep -q "❌ FAIL" "$validation_report" || grep -q "NEEDS FIXES" "$validation_report"; then
    echo "❌ ERROR: Validation has failures"
    echo "   Fix issues and re-run /clawd-validate-phase before deploying"
    cat "$validation_report" | grep -A1 "FAIL\|NEEDS FIXES"
    exit 1
fi

echo "✅ Validation passed - ready for deployment"
```

### Step 3: Test SSH Connection

```bash
echo "📋 Testing SSH connection to Mac Mini..."

# Expand SSH key path
ssh_key="${CLAWD_MINI_SSH_KEY/#\~/$HOME}"

# Test connection
if ssh -i "$ssh_key" -o ConnectTimeout=10 -o BatchMode=yes \
    "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" "echo 'SSH connection OK'" 2>/dev/null; then
    echo "✅ SSH connection successful"
else
    echo "❌ ERROR: Cannot connect to Mac Mini"
    echo "   Host: $CLAWD_MINI_HOST"
    echo "   User: $CLAWD_MINI_USER"
    echo "   Key: $ssh_key"
    echo ""
    echo "   Troubleshooting:"
    echo "   1. Is the Mac Mini powered on and on the network?"
    echo "   2. Is SSH enabled? (System Preferences > Sharing > Remote Login)"
    echo "   3. Is the SSH key correct? Test: ssh -i $ssh_key ${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}"
    echo "   4. Is the key added to Mini's authorized_keys?"
    exit 1
fi
```

---

## Deployment Process

### Step 4: Create Backup on Mac Mini

```bash
echo "📋 Creating backup on Mac Mini..."

backup_name="clawd-backup-$(date +%Y%m%d-%H%M%S)"

ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
    echo "Creating backup: $backup_name"

    if [ -d "$CLAWD_MINI_WORKSPACE" ]; then
        cp -r "$CLAWD_MINI_WORKSPACE" "${CLAWD_MINI_WORKSPACE}-${backup_name}"
        echo "✅ Backup created: ${CLAWD_MINI_WORKSPACE}-${backup_name}"
    else
        echo "⚠️  Production workspace doesn't exist yet - no backup needed"
    fi
EOF

echo "✅ Backup step complete"
```

### Step 5: Prepare Capability Files for Git

```bash
echo "📋 Preparing capability files..."

# Navigate to dev workspace
cd ~/clawd-dev

# Check git status
echo "Current git status:"
git status

# Stage capability-related changes
echo "Staging changes..."

# Stage SOUL.md, TOOLS.md, MEMORY.md changes
git add SOUL.md TOOLS.md MEMORY.md AGENTS.md 2>/dev/null

# Stage any skill directories
if [ -d "skills" ]; then
    git add skills/
fi

# Stage memory schema (but not daily logs with test data)
# Don't stage memory/*.md as those contain test data

echo "✅ Files staged for commit"
```

### Step 6: Commit Changes

```bash
echo "📋 Committing changes..."

capability_name="$ARGUMENTS"
commit_message="feat(capability): $capability_name - validated and ready for production

- Added SOUL.md orchestration rules
- Added TOOLS.md conventions
- Configured memory schema
- All validation levels passed

Validated: $(date +%Y-%m-%d)
Validation Report: capabilities/$capability_name/validation-report.md"

git commit -m "$commit_message"

if [ $? -eq 0 ]; then
    echo "✅ Changes committed"
else
    echo "⚠️  No changes to commit or commit failed"
fi
```

### Step 7: Push to Remote Repository

```bash
echo "📋 Pushing to remote repository..."

git push origin main

if [ $? -eq 0 ]; then
    echo "✅ Pushed to remote repository"
else
    echo "❌ ERROR: Git push failed"
    echo "   Check your Git configuration and remote access"
    exit 1
fi
```

### Step 8: Pull on Mac Mini

```bash
echo "📋 Pulling changes on Mac Mini..."

ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
    echo "Navigating to workspace..."
    cd "$CLAWD_MINI_WORKSPACE"

    echo "Current commit:"
    git log --oneline -1

    echo "Pulling latest changes..."
    git pull origin main

    if [ \$? -eq 0 ]; then
        echo "✅ Changes pulled successfully"
        echo "New commit:"
        git log --oneline -1
    else
        echo "❌ Git pull failed"
        exit 1
    fi
EOF

if [ $? -eq 0 ]; then
    echo "✅ Mac Mini updated"
else
    echo "❌ ERROR: Failed to update Mac Mini"
    exit 1
fi
```

### Step 9: Restart Clawdbot Daemon on Mac Mini

```bash
echo "📋 Restarting Clawdbot daemon on Mac Mini..."

ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
    echo "Stopping Clawdbot daemon..."
    launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null
    sleep 2

    echo "Starting Clawdbot daemon..."
    launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
    sleep 5

    echo "Checking daemon status..."
    if launchctl list 2>/dev/null | grep -q "clawdbot"; then
        echo "✅ Clawdbot daemon is running"
    else
        echo "❌ Daemon may not have started - check logs"
    fi
EOF

echo "✅ Daemon restart complete"
```

### Step 10: Verify Deployment

```bash
echo "📋 Verifying deployment..."

ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" << EOF
    echo "=== Clawdbot Health Check ==="
    clawdbot health --verbose

    echo ""
    echo "=== Current SOUL.md capabilities ==="
    grep -A2 "^## " "$CLAWD_MINI_WORKSPACE/SOUL.md" | head -30

    echo ""
    echo "=== Recent logs ==="
    clawdbot logs --limit 10
EOF

echo ""
echo "✅ Deployment verification complete"
```

### Step 11: Tag Release

```bash
echo "📋 Tagging release..."

cd ~/clawd-dev

# Create release tag
tag_name="capability-$ARGUMENTS-v1.0-$(date +%Y%m%d)"
git tag -a "$tag_name" -m "Deployed capability: $ARGUMENTS to production"
git push origin "$tag_name"

echo "✅ Tagged release: $tag_name"
```

---

## Deployment Report

Generate deployment summary:

```markdown
# DEPLOYMENT REPORT
# Capability: [Capability Name]
# Date: [date]

═══════════════════════════════════════════════════════════════
                     DEPLOYMENT SUMMARY
═══════════════════════════════════════════════════════════════

✅ Configuration loaded
✅ Validation verified (all passed)
✅ SSH connection successful
✅ Backup created on Mac Mini
✅ Changes committed to Git
✅ Pushed to remote repository
✅ Pulled on Mac Mini
✅ Daemon restarted
✅ Deployment verified
✅ Release tagged

═══════════════════════════════════════════════════════════════

## Deployment Details

- **Source**: ~/clawd-dev (development machine)
- **Target**: [CLAWD_MINI_HOST]:$CLAWD_MINI_WORKSPACE
- **Git Commit**: [commit hash]
- **Release Tag**: [tag name]
- **Backup**: ${CLAWD_MINI_WORKSPACE}-[backup-name]

## Rollback Command

If issues occur, run:
```
/clawd-rollback last
```

Or to rollback to specific backup:
```
/clawd-rollback [backup-name or commit-hash]
```

═══════════════════════════════════════════════════════════════
```

---

## Human Checkpoint

Present deployment report to user:

1. **Confirm deployment successful** - All steps completed?
2. **Test in production** - Send a test message to production Clawdbot?
3. **Monitor logs** - Watch for any issues?

---

## Post-Deployment Monitoring

Recommend monitoring for the next 24 hours:

```bash
# Check logs remotely
ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" "clawdbot logs --limit 50"

# Check for errors
ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" "clawdbot logs --limit 100 | grep -i error"

# Check health
ssh -i "$ssh_key" "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" "clawdbot health"
```

---

## Troubleshooting

### If Deployment Fails

1. **Check SSH connection**: `ssh -i $CLAWD_MINI_SSH_KEY ${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}`
2. **Check Git status on Mini**: SSH in and run `git status`
3. **Check daemon logs**: `clawdbot logs --limit 100`
4. **Rollback if needed**: `/clawd-rollback last`

### If Capability Doesn't Work in Production

1. **Check SOUL.md loaded**: Ask Clawdbot about its capabilities
2. **Check logs for errors**: `clawdbot logs --limit 100 | grep error`
3. **Compare with dev**: Diff SOUL.md between dev and production
4. **Rollback and investigate**: `/clawd-rollback last`

---

## Next Steps

After successful deployment:
- Monitor production for 24 hours
- Check cron jobs fire correctly
- Verify proactive behaviors work
- Document any production-specific observations
