---
description: Deploy validated Clawdbot capability to production Mac Mini (from WSL2/Linux)
argument-hint: [capability-name]
---

# Deploy Clawdbot Capability to Production (from WSL2/Linux)

You are deploying a validated Clawdbot capability from your WSL2/Linux development machine to your production Mac Mini via Git and SSH.

## Critical Context

**MANDATORY READS**:
1. `~/clawd-dev-kit/capabilities/$ARGUMENTS/validation-report.md` - Must show ALL PASS

**Requirements**:
- Validation report shows all levels passed
- SSH keys configured to Mac Mini (accessible from WSL2)
- Git repository set up for capabilities
- `.env` file configured with deployment settings

**Platform**: Deploying FROM WSL2/Linux TO macOS Mac Mini

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

Same as macOS version.

### Step 3: Connectivity Pre-Check (Tailscale Recommended)

```bash
echo "📋 Pre-deployment connectivity check from WSL2..."

# Expand SSH key path
ssh_key="${CLAWD_MINI_SSH_KEY/#\~/$HOME}"

# WSL2-specific: Ensure SSH key permissions are correct
chmod 600 "$ssh_key" 2>/dev/null

# Test ping first
if ping -c 1 -W 3 "$CLAWD_MINI_HOST" >/dev/null 2>&1; then
    echo "✅ Host $CLAWD_MINI_HOST is reachable"
else
    echo "❌ Cannot reach $CLAWD_MINI_HOST"
    echo ""
    echo "Tailscale Troubleshooting (Recommended for WSL2):"
    echo "  1. Install Tailscale on WSL2: curl -fsSL https://tailscale.com/install.sh | sh"
    echo "  2. Check status: tailscale status"
    echo "  3. Ensure Mac Mini is also on Tailscale"
    echo "  4. Set CLAWD_MINI_HOST to Mac Mini's Tailscale name"
    exit 1
fi

# Test SSH with auto host-key cleanup
echo "🔑 Testing SSH connection..."

if ! ssh -i "$ssh_key" -o ConnectTimeout=10 -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" "echo 'SSH connection OK'" 2>/dev/null; then

    echo "⚠️  SSH failed. Attempting host key cleanup..."
    ssh-keygen -R "$CLAWD_MINI_HOST" 2>/dev/null || true

    if ! ssh -i "$ssh_key" -o ConnectTimeout=10 -o BatchMode=yes \
        -o StrictHostKeyChecking=accept-new \
        "${CLAWD_MINI_USER}@${CLAWD_MINI_HOST}" "echo 'SSH connection OK'" 2>/dev/null; then
        echo "❌ ERROR: Cannot connect to Mac Mini"
        echo ""
        echo "Tailscale Troubleshooting:"
        echo "  1. On WSL2: tailscale status"
        echo "  2. On Mac Mini: tailscale status"
        echo "  3. Ensure both show 'online'"
        echo ""
        echo "WSL2-Specific:"
        echo "  - SSH key must be in WSL2 filesystem (not /mnt/c/)"
        echo "  - Key permissions: chmod 600 $ssh_key"
        exit 1
    fi
fi

echo "✅ SSH connection verified"
```

### Steps 4-11: Same as macOS version

The deployment steps (backup, commit, push, pull, restart) are identical to the macOS version since they all execute on the Mac Mini via SSH.

---

## WSL2-Specific Notes

### SSH Key Location

SSH keys should be stored in the WSL2 filesystem, not the Windows filesystem:
- ✅ Good: `~/.ssh/id_ed25519_clawd_mini`
- ❌ Bad: `/mnt/c/Users/username/.ssh/id_ed25519_clawd_mini`

Windows-mounted paths have permission issues that cause SSH to fail.

### Generating SSH Keys in WSL2

```bash
# Generate key in WSL2
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_clawd_mini -N ""

# Copy to Mac Mini
ssh-copy-id -i ~/.ssh/id_ed25519_clawd_mini.pub user@macmini.local
```

### Network Connectivity

If you can't reach the Mac Mini:
1. Check Windows Firewall isn't blocking WSL2 network
2. Try using IP address instead of hostname
3. Check both machines are on same network segment

---

## Deployment Report

Same format as macOS version.

---

## Next Steps

After successful deployment:
- Monitor production for 24 hours
- Check cron jobs fire correctly
- Verify proactive behaviors work
- Document any production-specific observations
