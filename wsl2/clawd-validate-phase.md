---
description: Comprehensive validation of Clawdbot capability on local WSL2/Linux instance
argument-hint: [capability-name]
---

# Validate Clawdbot Capability (WSL2/Linux)

You are performing comprehensive validation of a Clawdbot capability on your local WSL2 or Linux development instance. This phase auto-sets up the local environment if needed and runs all validation levels.

## Critical Context

**MANDATORY READS**:
1. `clawd-global-rules.md` - Development conventions
2. `~/clawd-dev-kit/capabilities/$ARGUMENTS/PRD.md` - Requirements (for test cases)
3. `~/clawd-dev-kit/capabilities/$ARGUMENTS/plan.md` - Plan (for validation commands)
4. `~/clawd-dev-kit/capabilities/$ARGUMENTS/execution-report.md` - Execution status

**Platform**: WSL2/Linux (uses systemctl for daemon management)

---

## Pre-Validation: Connectivity & Dependency Checks

Before any testing:

### 1. Connectivity Pre-Check (Tailscale Recommended)

```bash
echo "🔌 Testing connectivity to Mac Mini..."

# Load .env for host info
if [ -f ./.env ]; then
    source ./.env
elif [ -f ~/clawd-dev-kit/.env ]; then
    source ~/clawd-dev-kit/.env
fi

# Use Tailscale hostname if configured
TARGET_HOST="${CLAWD_MINI_HOST:-macmini.local}"

# Test ping
if ping -c 1 -W 3 "$TARGET_HOST" >/dev/null 2>&1; then
    echo "✅ Host $TARGET_HOST is reachable"
else
    echo "❌ Cannot reach $TARGET_HOST"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check Tailscale status: tailscale status"
    echo "  2. Ensure both machines are online in Tailscale"
    echo "  3. Try: ping $TARGET_HOST"
    echo ""
    echo "If using Tailscale, ensure CLAWD_MINI_HOST is set to your Tailscale node name"
    exit 1
fi

# Test SSH (if key configured)
if [ -n "$CLAWD_MINI_SSH_KEY" ] && [ -n "$CLAWD_MINI_USER" ]; then
    ssh_key="${CLAWD_MINI_SSH_KEY/#\~/$HOME}"
    echo "🔑 Testing SSH connection..."

    # Handle host key issues automatically
    if ! ssh -i "$ssh_key" -o ConnectTimeout=10 -o BatchMode=yes \
        -o StrictHostKeyChecking=accept-new \
        "$CLAWD_MINI_USER@$TARGET_HOST" "echo 'SSH OK'" 2>/dev/null; then

        echo "⚠️  SSH connection failed. Attempting host key cleanup..."
        ssh-keygen -R "$TARGET_HOST" 2>/dev/null || true

        if ! ssh -i "$ssh_key" -o ConnectTimeout=10 -o BatchMode=yes \
            -o StrictHostKeyChecking=accept-new \
            "$CLAWD_MINI_USER@$TARGET_HOST" "echo 'SSH OK'" 2>/dev/null; then
            echo "❌ SSH to Mac Mini failed."
            echo ""
            echo "Check Tailscale status on both machines:"
            echo "  tailscale status"
            exit 1
        fi
    fi
    echo "✅ SSH connection verified"
fi
```

### 2. Dependency Validation

```bash
echo "📦 Validating skill dependencies..."

WORKSPACE_DIR="${1:-./workspace}"
if [ ! -d "$WORKSPACE_DIR" ]; then
    WORKSPACE_DIR="~/clawd-dev-kit/capabilities/$ARGUMENTS/workspace"
fi

# Parse all SKILL.md files for metadata.requires
for skill_dir in $WORKSPACE_DIR/skills/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        echo "Checking: $skill_name"

        # Check env vars, python packages, system binaries
        # (Same logic as macOS version)
        ENV_VARS=$(grep -A20 'requires:' "$skill_dir/SKILL.md" | grep -A5 'env:' | grep -o '"[^"]*"' | tr -d '"' || true)
        for var in $ENV_VARS; do
            if [ -z "${!var:-}" ]; then
                echo "  ⚠️  Missing env var: $var"
                MISSING_DEPS=1
            fi
        done

        SYSTEM_BINS=$(grep -A20 'requires:' "$skill_dir/SKILL.md" | grep -A5 'system:' | grep -o '"[^"]*"' | tr -d '"' || true)
        for bin in $SYSTEM_BINS; do
            if ! command -v "$bin" >/dev/null 2>&1; then
                echo "  ⚠️  Missing binary: $bin"
                MISSING_DEPS=1
            fi
        done
    fi
done

if [ "${MISSING_DEPS:-0}" -eq 1 ]; then
    echo "❌ Missing dependencies. Install before proceeding."
    exit 1
fi

echo "✅ All dependencies satisfied"
```

---

## Pre-Validation: Auto-Setup Local Environment

### Step 1: Check/Create Development Workspace

```bash
# Check if workspace exists
if [ ! -d ~/clawd-dev ]; then
    echo "📁 Creating development workspace..."
    mkdir -p ~/clawd-dev
    mkdir -p ~/clawd-dev/memory
    mkdir -p ~/clawd-dev/skills

    # Initialize minimal SOUL.md
    cat > ~/clawd-dev/SOUL.md << 'EOF'
---
name: ClawdDev Test Instance
emoji: 🧪
version: 1.0.0
---

# Persona

You are a test instance of Clawdbot used for capability development and validation.
You run on the developer's local machine, not in production.

# Core Directives

- Execute test scenarios as instructed
- Report results clearly
- Do not perform any actions that affect external systems unless explicitly testing integrations

# Capabilities

[Capabilities under development will be added here]

# Boundaries

- This is a TEST instance only
- Do not perform production actions
- Do not send messages to real contacts during testing
EOF

    # Initialize empty files
    touch ~/clawd-dev/TOOLS.md
    touch ~/clawd-dev/MEMORY.md
    touch ~/clawd-dev/AGENTS.md
    touch ~/clawd-dev/IDENTITY.md
    touch ~/clawd-dev/USER.md

    echo "✅ Development workspace created at ~/clawd-dev/"
else
    echo "✅ Development workspace exists at ~/clawd-dev/"
fi
```

### Step 2: Check/Configure Clawdbot for Dev Workspace

```bash
# Check if Clawdbot is configured for dev workspace
if [ -f ~/.clawdbot/clawdbot.json ]; then
    current_workspace=$(cat ~/.clawdbot/clawdbot.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('agents',{}).get('defaults',{}).get('workspace',''))" 2>/dev/null)

    if [ "$current_workspace" != "$HOME/clawd-dev" ]; then
        echo "⚠️  Clawdbot workspace is set to: $current_workspace"
        echo "   For testing, you may want to configure it to use ~/clawd-dev/"
        echo "   Run: clawdbot configure --workspace ~/clawd-dev/"
    else
        echo "✅ Clawdbot configured for dev workspace"
    fi
else
    echo "⚠️  Clawdbot config not found. Run 'clawdbot onboard' first."
fi
```

### Step 3: Check/Start Clawdbot Daemon (systemd)

```bash
# Check if systemd is available (required for WSL2)
if ! command -v systemctl &> /dev/null; then
    echo "⚠️  systemctl not found"
    echo "   If on WSL2, ensure systemd is enabled:"
    echo "   Add to /etc/wsl.conf:"
    echo "   [boot]"
    echo "   systemd=true"
    echo "   Then restart WSL: wsl --shutdown"
    exit 1
fi

# Check if daemon is running
if systemctl --user is-active --quiet clawdbot 2>/dev/null; then
    echo "✅ Clawdbot daemon is running"
else
    echo "🚀 Starting Clawdbot daemon..."

    # Check if service exists
    if [ -f ~/.config/systemd/user/clawdbot.service ]; then
        systemctl --user start clawdbot
        sleep 5

        # Verify started
        if systemctl --user is-active --quiet clawdbot 2>/dev/null; then
            echo "✅ Clawdbot daemon started"
        else
            echo "❌ Failed to start Clawdbot daemon"
            echo "   Check: systemctl --user status clawdbot"
            echo "   Logs: journalctl --user -u clawdbot -n 50"
            exit 1
        fi
    else
        echo "❌ Clawdbot service not found"
        echo "   Run: clawdbot onboard --install-daemon"
        exit 1
    fi
fi
```

### Step 4: Verify Clawdbot Health

```bash
echo "🔍 Checking Clawdbot health..."
clawdbot health --verbose

if [ $? -eq 0 ]; then
    echo "✅ Clawdbot is healthy"
else
    echo "❌ Clawdbot health check failed"
    echo "   Debug: clawdbot status --all"
    exit 1
fi
```

---

## Level 1: Static Validation

**Purpose**: Verify file syntax and structure without running Clawdbot

### 1.1 SOUL.md Validation

```bash
echo "📋 Level 1.1: Validating SOUL.md..."

# Check file exists
if [ ! -f ~/clawd-dev/SOUL.md ]; then
    echo "❌ FAIL: SOUL.md not found"
    exit 1
fi

# Validate YAML frontmatter
python3 -c "
import yaml
import sys

try:
    with open('$HOME/clawd-dev/SOUL.md', 'r') as f:
        content = f.read()

    parts = content.split('---')
    if len(parts) >= 3:
        frontmatter = yaml.safe_load(parts[1])
        print('✅ YAML frontmatter is valid')
        print(f'   Name: {frontmatter.get(\"name\", \"N/A\")}')
    else:
        print('⚠️  No YAML frontmatter found')
except Exception as e:
    print(f'❌ FAIL: YAML parse error: {e}')
    sys.exit(1)
"

# Check capability section exists
if grep -q "\[Capability-Name-From-PRD\]" ~/clawd-dev/SOUL.md; then
    echo "✅ Capability section found in SOUL.md"
else
    echo "⚠️  Capability section may be missing - verify manually"
fi
```

### 1.2-1.4: Same as macOS version

[TOOLS.md, Memory Schema, and Skill validations are identical to macOS - see macOS version]

### Level 1 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 1 (Static Validation): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Level 2-4: Same as macOS version

[Injection, Logic, and Proactivity validations are identical - see macOS version]

---

## Level 5: Persistence Validation (Critical)

**Purpose**: Verify all state survives daemon restart

### 5.1-5.2: Same as macOS

### 5.3 Restart Daemon (systemd)

```bash
echo "📋 Level 5.3: Restarting Clawdbot daemon..."

# Stop daemon
systemctl --user stop clawdbot
echo "⏸️  Daemon stopped"

sleep 3

# Start daemon
systemctl --user start clawdbot
echo "▶️  Daemon starting..."

sleep 5

# Verify running
if systemctl --user is-active --quiet clawdbot 2>/dev/null; then
    echo "✅ Daemon restarted successfully"
else
    echo "❌ FAIL: Daemon did not restart"
    echo "   Check: systemctl --user status clawdbot"
    exit 1
fi

# Health check
clawdbot health --verbose
```

### 5.4-5.5: Same as macOS

### Level 5 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 5 (Persistence Validation): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Level 6-7: Same as macOS version

[Error/Escalation and Integration tests are identical - see macOS version]

---

## Validation Report

Same format as macOS version, with platform noted as "WSL2/Linux".

---

## Next Steps

If ALL validations pass:
```
/clawd-deploy [capability-name]
```

If validations fail:
1. Fix identified issues
2. Re-run `/clawd-execute-phase` for affected components
3. Re-run `/clawd-validate-phase`
