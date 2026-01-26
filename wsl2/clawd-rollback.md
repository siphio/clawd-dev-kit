---
description: Rollback production Clawdbot to previous state (from WSL2/Linux)
argument-hint: [commit-hash or "last" or "list"]
---

# Rollback Clawdbot Production (from WSL2/Linux)

You are rolling back your Mac Mini Clawdbot instance to a previous state from your WSL2/Linux machine. This command allows you to safely undo a deployment without physically accessing the Mac Mini.

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

# WSL2-specific: Ensure SSH key permissions
chmod 600 "$ssh_key" 2>/dev/null

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
    echo ""
    echo "   WSL2 Troubleshooting:"
    echo "   1. Check network: ping $CLAWD_MINI_HOST"
    echo "   2. Check SSH key permissions: chmod 600 $ssh_key"
    echo "   3. Ensure key is in WSL filesystem, not /mnt/c/"
    exit 1
fi
```

---

## Steps 3+: Same as macOS version

The rollback logic (list, last, specific commit, backup restore) is identical to the macOS version since all commands execute on the Mac Mini via SSH.

Note: The Mac Mini daemon commands use `launchctl` (macOS), not `systemctl` (Linux). The SSH commands sent to the Mini are macOS-specific regardless of where you're running the rollback from.

---

## WSL2-Specific Notes

### SSH Key Management

Store SSH keys in WSL2 filesystem with proper permissions:
```bash
# Keys should be here, not in /mnt/c/
~/.ssh/id_ed25519_clawd_mini

# Set permissions
chmod 600 ~/.ssh/id_ed25519_clawd_mini
```

### Network Issues

If SSH connection fails:
1. Try IP address instead of hostname
2. Check Windows Firewall settings
3. Verify WSL2 network mode (NAT vs bridged)
4. Test with: `ssh -vvv -i $ssh_key user@host` for debug output

---

## Troubleshooting

Same as macOS version, with additional WSL2 network considerations.
