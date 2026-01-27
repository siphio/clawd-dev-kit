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

## Step 6: Next Steps

### If ALL Tests Pass ✅

```
🎉 Validation successful!

All tests passed. The capability is ready for deployment.

Your workspace/ folder is validated and ready to deploy.

Next steps:
1. Review the test results above
2. Make any final adjustments to workspace/ files
3. Run: /clawd-deploy

The deployment will copy workspace/ to your production Mac Mini.
```

### If Some Tests Fail ❌

```
⚠️ Validation found issues.

X tests failed. Review the failures above and:

1. Edit workspace/SOUL.md to fix behavioral issues
2. Edit workspace/skills/ to fix skill problems
3. Run: /clawd-validate-phase (to re-test)

Do NOT deploy until all tests pass.
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
