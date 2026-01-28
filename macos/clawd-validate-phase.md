---
description: Validate capability by copying workspace/ to test instance
argument-hint: [capability-name]
---

# Validate Clawdbot Capability (macOS)

You are validating a Clawdbot capability by **copying the `workspace/` folder to `~/clawd-dev/`** and running tests.

## The Flow: workspace/ → ~/clawd-dev/ → Test → Revert

```
YOUR PROJECT                         TEST INSTANCE
─────────────────────────           ─────────────────────────
./workspace/                   ──►  ~/clawd-dev/
├── IDENTITY.md                     ├── IDENTITY.md
├── SOUL.md                         ├── SOUL.md
├── TOOLS.md                        ├── TOOLS.md
├── AGENTS.md                       ├── AGENTS.md
├── MEMORY.md                       ├── MEMORY.md
├── USER.md                         ├── USER.md
├── memory/                         ├── memory/
├── skills/                         └── skills/
└── media/

     SOURCE                              COPY FOR TESTING
     (stays intact)                      (reverted after tests)
```

---

## Pre-Validation: Connectivity & Dependency Checks

Before any testing:

### 1. Connectivity Pre-Check (Tailscale Recommended)

```bash
echo "🔌 Testing connectivity to Mac Mini..."

# Load .env for host info
if [ -f ./.env ]; then
    source ./.env
fi

# Use Tailscale hostname if configured, otherwise fall back to local
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
    echo "🔑 Testing SSH connection..."

    # Handle host key issues automatically
    if ! ssh -i "$CLAWD_MINI_SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes \
        -o StrictHostKeyChecking=accept-new \
        "$CLAWD_MINI_USER@$TARGET_HOST" "echo 'SSH OK'" 2>/dev/null; then

        echo "⚠️  SSH connection failed. Attempting host key cleanup..."
        ssh-keygen -R "$TARGET_HOST" 2>/dev/null || true

        if ! ssh -i "$CLAWD_MINI_SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes \
            -o StrictHostKeyChecking=accept-new \
            "$CLAWD_MINI_USER@$TARGET_HOST" "echo 'SSH OK'" 2>/dev/null; then
            echo "❌ SSH to Mac Mini failed."
            echo ""
            echo "Check Tailscale status on both machines:"
            echo "  tailscale status"
            echo ""
            echo "Ensure both machines are online and can reach each other."
            exit 1
        fi
    fi
    echo "✅ SSH connection verified"
fi
```

### 2. Dependency Validation

```bash
echo "📦 Validating skill dependencies..."

# Parse all SKILL.md files for metadata.requires
for skill_dir in ./workspace/skills/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        echo "Checking: $skill_name"

        # Extract requires from SKILL.md metadata (YAML frontmatter)
        # Check env vars
        ENV_VARS=$(grep -A20 'requires:' "$skill_dir/SKILL.md" | grep -A5 'env:' | grep -o '"[^"]*"' | tr -d '"' || true)
        for var in $ENV_VARS; do
            if [ -z "${!var:-}" ]; then
                echo "  ⚠️  Missing env var: $var"
                MISSING_DEPS=1
            else
                echo "  ✅ env: $var"
            fi
        done

        # Check python packages
        PYTHON_PKGS=$(grep -A20 'requires:' "$skill_dir/SKILL.md" | grep -A5 'python:' | grep -o '"[^"]*"' | tr -d '"' || true)
        for pkg in $PYTHON_PKGS; do
            pkg_name=$(echo "$pkg" | cut -d'>' -f1 | cut -d'=' -f1)
            if python3 -c "import $pkg_name" 2>/dev/null; then
                echo "  ✅ python: $pkg_name"
            else
                echo "  ⚠️  Missing python package: $pkg"
                MISSING_DEPS=1
            fi
        done

        # Check system binaries
        SYSTEM_BINS=$(grep -A20 'requires:' "$skill_dir/SKILL.md" | grep -A5 'system:' | grep -o '"[^"]*"' | tr -d '"' || true)
        for bin in $SYSTEM_BINS; do
            if command -v "$bin" >/dev/null 2>&1; then
                echo "  ✅ system: $bin"
            else
                echo "  ⚠️  Missing binary: $bin"
                MISSING_DEPS=1
            fi
        done
    fi
done

if [ "${MISSING_DEPS:-0}" -eq 1 ]; then
    echo ""
    echo "❌ Missing dependencies detected. Install them before proceeding."
    echo "   For python: pip install <package>"
    echo "   For system: brew install <binary>"
    exit 1
fi

echo "✅ All dependencies satisfied"
```

---

## Pre-Validation Checklist

### Verify workspace/ exists and has required files:

```bash
echo "🔍 Checking workspace/ structure..."

# Required files
REQUIRED_FILES=(
    "./workspace/SOUL.md"
    "./workspace/TOOLS.md"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing: $file"
        MISSING=1
    else
        echo "✅ Found: $file"
    fi
done

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "⚠️  Run /clawd-execute-phase first to create workspace files"
    exit 1
fi

echo "✅ workspace/ structure verified"
```

---

## Step 1: Backup Test Instance

```bash
echo "📦 Backing up current ~/clawd-dev/ state..."

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/clawd-dev/.backup/$TIMESTAMP

mkdir -p "$BACKUP_DIR"

# Backup existing files
if [ -f ~/clawd-dev/SOUL.md ]; then
    cp ~/clawd-dev/SOUL.md "$BACKUP_DIR/"
fi
if [ -f ~/clawd-dev/TOOLS.md ]; then
    cp ~/clawd-dev/TOOLS.md "$BACKUP_DIR/"
fi
if [ -d ~/clawd-dev/skills ]; then
    cp -r ~/clawd-dev/skills "$BACKUP_DIR/"
fi

echo "✅ Backup created at $BACKUP_DIR"
```

---

## Step 2: Copy workspace/ to Test Instance

```bash
echo "📋 Copying workspace/ to ~/clawd-dev/..."

# Ensure test instance directory exists
mkdir -p ~/clawd-dev/memory
mkdir -p ~/clawd-dev/skills
mkdir -p ~/clawd-dev/media

# Copy all workspace files
cp ./workspace/IDENTITY.md ~/clawd-dev/ 2>/dev/null || true
cp ./workspace/SOUL.md ~/clawd-dev/
cp ./workspace/TOOLS.md ~/clawd-dev/
cp ./workspace/AGENTS.md ~/clawd-dev/ 2>/dev/null || true
cp ./workspace/MEMORY.md ~/clawd-dev/ 2>/dev/null || true
cp ./workspace/USER.md ~/clawd-dev/ 2>/dev/null || true

# Copy skills
if [ -d ./workspace/skills ] && [ "$(ls -A ./workspace/skills 2>/dev/null)" ]; then
    cp -r ./workspace/skills/* ~/clawd-dev/skills/
    echo "✅ Skills copied"
fi

# Copy memory templates (don't overwrite existing data)
if [ -d ./workspace/memory ] && [ "$(ls -A ./workspace/memory 2>/dev/null)" ]; then
    cp -n ./workspace/memory/* ~/clawd-dev/memory/ 2>/dev/null || true
    echo "✅ Memory templates copied"
fi

echo "✅ workspace/ copied to ~/clawd-dev/"
```

---

## Step 3: Restart Clawdbot Daemon

```bash
echo "🔄 Restarting Clawdbot daemon..."

# Unload and reload the launch agent
launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null || true
sleep 2
launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist

# Wait for daemon to be ready
sleep 3

# Verify daemon is running
if launchctl list | grep -q "com.clawdbot.gateway"; then
    echo "✅ Clawdbot daemon restarted successfully"
else
    echo "❌ Failed to restart daemon - check logs"
    echo "   Run: cat ~/Library/Logs/clawdbot/gateway.log"
fi
```

---

## Step 4: Run Validation Tests

### 4.1 Health Check

```bash
echo "🏥 Running health check..."
clawdbot health
```

### 4.2 Identity Check

```bash
echo "🧪 Testing identity recognition..."
clawdbot agent --message "Who are you? What is your name and purpose?" --thinking low
```

### 4.3 Capability Recognition

```bash
echo "🧪 Testing capability recognition..."
clawdbot agent --message "What capabilities do you have? What can you do?" --thinking low
```

### 4.4 Run Test Cases from docs/test-cases.md

Read `./docs/test-cases.md` and execute each test:

```bash
echo "🧪 Running test cases from docs/test-cases.md..."
```

**For each test case:**

1. **State the test** being run (ID and description)
2. **Execute** using `clawdbot agent --message "..." --thinking low`
3. **Compare** output to expected result
4. **Record** PASS or FAIL

### 4.5 Validation Report

```markdown
## Validation Report

**Date**: [Current date]
**Project**: [Current directory name]
**Test Instance**: ~/clawd-dev/

### Test Results

| Test ID | Description | Status |
|---------|-------------|--------|
| TC-001 | Identity recognition | ✅ PASS / ❌ FAIL |
| TC-002 | Capability awareness | ✅ PASS / ❌ FAIL |
| TC-003 | [From test-cases.md] | ✅ PASS / ❌ FAIL |
| ... | ... | ... |

### Summary

- **Total Tests**: X
- **Passed**: X
- **Failed**: X

### Issues Found

[List any failures or unexpected behaviors]

### Recommendations

[Next steps based on results]
```

---

## Step 5: Revert Test Instance (Optional)

After validation, you can choose to:

**A) Keep the test instance** (for continued testing):
```bash
echo "ℹ️  Test instance kept at ~/clawd-dev/"
echo "   Run validation again to refresh, or manually revert"
```

**B) Revert to clean state**:
```bash
echo "🔄 Reverting ~/clawd-dev/ to backup..."

# Restore from backup
cp "$BACKUP_DIR/SOUL.md" ~/clawd-dev/ 2>/dev/null || true
cp "$BACKUP_DIR/TOOLS.md" ~/clawd-dev/ 2>/dev/null || true
if [ -d "$BACKUP_DIR/skills" ]; then
    rm -rf ~/clawd-dev/skills/*
    cp -r "$BACKUP_DIR/skills/"* ~/clawd-dev/skills/ 2>/dev/null || true
fi

# Restart daemon with reverted state
launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist 2>/dev/null || true
sleep 2
launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist

echo "✅ Test instance reverted to pre-validation state"
```

---

## Step 6: Update STATE.md

**CRITICAL**: After validation, update `docs/STATE.md`:

### Read Current State First

```bash
# Check current phase and total phases
cat ./docs/STATE.md | head -10
```

### If ALL Tests Pass ✅

1. Update the YAML frontmatter:
   - `status: validated`
   - `last_updated: [current date]`

2. Update the Phase Progress table:
   - Set current Phase Status to `validated`
   - Set Validated date to current date

3. Add to Activity Log:
```markdown
### [DATE] - Phase [X] Validated
- All tests passed
- Test results: [X/X passed]
- Next: [See Next Action below]
```

4. **IMPORTANT - Determine Next Action**:

   **Check `docs/STATE.md`** for `current_phase` vs `total_phases`:

   - If `current_phase < total_phases`:
     ```markdown
     ## Next Action
     **Run**: `/clawd-plan-phase [current_phase + 1]`

     Phase [X] of [total] validated. [Y] phases remaining.
     ```

   - If `current_phase == total_phases` (ALL phases complete):
     ```markdown
     ## Next Action
     **Run**: `/clawd-deploy`

     All [total] phases validated! Ready for production deployment.
     ```

### If Some Tests Fail ❌

1. Keep status as `executed` (not validated)

2. Add to Activity Log:
```markdown
### [DATE] - Phase [X] Validation FAILED
- Tests failed: [X/Y]
- Issues: [list failures]
- Next: Fix workspace/ and re-validate
```

3. Update Next Action:
```markdown
## Next Action
**Fix issues in workspace/, then run**: `/clawd-validate-phase`
```

---

## Step 7: Present Next Steps

### If ALL Tests Pass ✅

**Check STATE.md to determine correct recommendation:**

```bash
# Get phase info
CURRENT=$(grep "current_phase:" ./docs/STATE.md | cut -d' ' -f2)
TOTAL=$(grep "total_phases:" ./docs/STATE.md | cut -d' ' -f2)
```

**If more phases remain** (current < total):
```
🎉 Phase [X] validation successful!

All tests passed for Phase [X].

Current progress: Phase [X] of [TOTAL] complete
Remaining phases: [TOTAL - X]

Next steps:
1. Run: /clawd-plan-phase [X+1]
2. Continue developing remaining phases

⚠️ Do NOT deploy yet - [Y] phases still remaining in PRD.
```

**If ALL phases complete** (current == total):
```
🎉 ALL phases validated!

All [TOTAL] phases complete and tested.

Your workspace/ folder is fully validated and ready for production.

Next steps:
1. Final review of workspace/ files
2. Run: /clawd-deploy

The deployment will copy workspace/ to your production Mac Mini.
```

### If Some Tests Fail ❌

```
⚠️ Validation found issues.

X tests failed. Review the failures above and:

1. Edit workspace/SOUL.md to fix behavioral issues
2. Edit workspace/skills/ to fix skill problems
3. Run: /clawd-validate-phase (to re-test)

Do NOT proceed until all tests pass.
```

---

## Quick Reference

```bash
# Full validation flow
/clawd-validate-phase

# What it does:
# 1. Backs up ~/clawd-dev/ current state
# 2. Copies entire workspace/ folder to ~/clawd-dev/
# 3. Restarts Clawdbot daemon
# 4. Runs all tests from docs/test-cases.md
# 5. Reports results
# 6. Optionally reverts ~/clawd-dev/

# The key insight:
# workspace/ is your deployable unit
# Just copy the whole folder to test or deploy
```
