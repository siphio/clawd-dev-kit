---
description: Comprehensive validation of Clawdbot capability on local macOS instance
argument-hint: [capability-name]
---

# Validate Clawdbot Capability (macOS)

You are performing comprehensive validation of a Clawdbot capability on your local macOS development instance. This phase auto-sets up the local environment if needed and runs all validation levels.

## Critical Context

**MANDATORY READS**:
1. `clawd-global-rules.md` - Development conventions
2. `~/clawd-dev-kit/capabilities/$ARGUMENTS/PRD.md` - Requirements (for test cases)
3. `~/clawd-dev-kit/capabilities/$ARGUMENTS/plan.md` - Plan (for validation commands)
4. `~/clawd-dev-kit/capabilities/$ARGUMENTS/execution-report.md` - Execution status

**Platform**: macOS (uses launchctl for daemon management)

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
    # Check current workspace setting
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

### Step 3: Check/Start Clawdbot Daemon

```bash
# Check if daemon is running
if launchctl list 2>/dev/null | grep -q "clawdbot"; then
    echo "✅ Clawdbot daemon is running"
else
    echo "🚀 Starting Clawdbot daemon..."

    # Check if launch agent exists
    if [ -f ~/Library/LaunchAgents/com.clawdbot.gateway.plist ]; then
        launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
        sleep 5

        # Verify started
        if launchctl list 2>/dev/null | grep -q "clawdbot"; then
            echo "✅ Clawdbot daemon started"
        else
            echo "❌ Failed to start Clawdbot daemon"
            echo "   Check: clawdbot logs --limit 50"
            exit 1
        fi
    else
        echo "❌ Clawdbot launch agent not found"
        echo "   Run: clawdbot onboard --install-daemon"
        exit 1
    fi
fi
```

### Step 4: Verify Clawdbot Health

```bash
# Health check
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

    # Extract frontmatter
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

### 1.2 TOOLS.md Validation

```bash
echo "📋 Level 1.2: Validating TOOLS.md..."

if [ -f ~/clawd-dev/TOOLS.md ]; then
    echo "✅ TOOLS.md exists"

    # Check for tool conventions
    if [ -s ~/clawd-dev/TOOLS.md ]; then
        echo "✅ TOOLS.md has content"
    else
        echo "⚠️  TOOLS.md is empty"
    fi
else
    echo "⚠️  TOOLS.md not found (may be optional)"
fi
```

### 1.3 Memory Schema Validation

```bash
echo "📋 Level 1.3: Validating memory schema..."

if [ -f ~/clawd-dev/MEMORY.md ]; then
    echo "✅ MEMORY.md exists"
else
    echo "⚠️  MEMORY.md not found"
fi

if [ -d ~/clawd-dev/memory ]; then
    echo "✅ memory/ directory exists"
else
    mkdir -p ~/clawd-dev/memory
    echo "✅ memory/ directory created"
fi
```

### 1.4 Skill Validation (if applicable)

```bash
echo "📋 Level 1.4: Validating skills..."

# Check if capability requires a skill
SKILL_DIR=~/clawd-dev/skills/[skill-name]

if [ -d "$SKILL_DIR" ]; then
    echo "📦 Skill directory found: $SKILL_DIR"

    # Validate SKILL.md
    if [ -f "$SKILL_DIR/SKILL.md" ]; then
        python3 -c "
import yaml
with open('$SKILL_DIR/SKILL.md', 'r') as f:
    content = f.read()
parts = content.split('---')
if len(parts) >= 3:
    yaml.safe_load(parts[1])
    print('✅ SKILL.md YAML is valid')
"
    else
        echo "❌ FAIL: SKILL.md not found in skill directory"
    fi

    # Validate TypeScript compiles
    if [ -f "$SKILL_DIR/index.ts" ]; then
        cd "$SKILL_DIR"
        if command -v tsc &> /dev/null; then
            tsc --noEmit && echo "✅ TypeScript compiles" || echo "❌ FAIL: TypeScript compilation error"
        else
            echo "⚠️  TypeScript compiler not found - skipping compilation check"
        fi
        cd -
    fi
else
    echo "ℹ️  No custom skill required for this capability"
fi
```

### Level 1 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 1 (Static Validation): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Level 2: Injection Validation

**Purpose**: Verify SOUL.md and other bootstrap files are correctly loaded into agent context

### 2.1 Bootstrap Injection Test

```bash
echo "📋 Level 2.1: Testing bootstrap injection..."

# Start a new session and ask about persona
result=$(clawdbot agent --message "What is your name and what are your core directives? Be specific." --thinking low 2>&1)

echo "Response: $result"

# Check if response contains expected SOUL.md content
if echo "$result" | grep -qi "test\|development\|clawddev"; then
    echo "✅ SOUL.md appears to be injected"
else
    echo "⚠️  SOUL.md injection unclear - verify response manually"
fi
```

### 2.2 Capability Section Injection

```bash
echo "📋 Level 2.2: Testing capability section injection..."

# Ask about the specific capability
result=$(clawdbot agent --message "Do you have a capability called [Capability-Name]? Describe what it does." --thinking low 2>&1)

echo "Response: $result"

if echo "$result" | grep -qi "[expected-keyword-from-capability]"; then
    echo "✅ Capability section appears to be loaded"
else
    echo "⚠️  Capability may not be properly injected - verify manually"
fi
```

### 2.3 TOOLS.md Injection

```bash
echo "📋 Level 2.3: Testing TOOLS.md injection..."

result=$(clawdbot agent --message "What tool conventions are you following? List any specific tools or MCP servers you know about." --thinking low 2>&1)

echo "Response: $result"
echo "✅ TOOLS.md injection test complete - verify response manually"
```

### Level 2 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 2 (Injection Validation): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Level 3: Capability Logic Validation

**Purpose**: Test capability behavior against expected outputs from PRD test cases

### 3.1 Load Test Cases

Read test cases from PRD:
```
~/clawd-dev-kit/capabilities/$ARGUMENTS/PRD.md
```

### 3.2 Execute Test Cases

For EACH test case in the PRD:

```bash
echo "📋 Level 3: Running test case TC-XXX..."

# Test Case TC-001: [Description from PRD]
echo "Running TC-001: [Description]"

input="[Test input from PRD]"
expected_contains="[Expected content from PRD]"

result=$(clawdbot agent --message "$input" --thinking low 2>&1)

echo "Input: $input"
echo "Response: $result"

if echo "$result" | grep -qi "$expected_contains"; then
    echo "✅ TC-001: PASS"
else
    echo "❌ TC-001: FAIL - Expected output containing '$expected_contains'"
fi
```

Repeat for all test cases defined in the PRD.

### Level 3 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 3 (Logic Validation): [X/Y Tests Passed]"
echo "═══════════════════════════════════════"
```

---

## Level 4: Proactivity Validation

**Purpose**: Verify cron jobs and heartbeat triggers work correctly

### 4.1 Cron Configuration Check

```bash
echo "📋 Level 4.1: Checking cron configuration..."

# List configured cron jobs
clawdbot cron list

# Check for capability's cron job
if clawdbot cron list | grep -qi "[capability-cron-job-name]"; then
    echo "✅ Cron job is configured"
else
    echo "❌ FAIL: Cron job not found"
fi
```

### 4.2 Manual Trigger Test

```bash
echo "📋 Level 4.2: Testing manual proactive trigger..."

# Trigger the proactive behavior manually via message
result=$(clawdbot agent --message "[Trigger phrase that should activate proactive behavior]" --thinking low 2>&1)

echo "Response: $result"

# Verify expected proactive behavior occurred
if echo "$result" | grep -qi "[expected-proactive-output]"; then
    echo "✅ Proactive behavior triggered successfully"
else
    echo "⚠️  Proactive behavior unclear - verify manually"
fi
```

### 4.3 Check Logs for Proactive Activity

```bash
echo "📋 Level 4.3: Checking logs for proactive activity..."

clawdbot logs --limit 50 | grep -i "[capability-name]\|heartbeat\|cron"

echo "✅ Log check complete - verify entries manually"
```

### Level 4 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 4 (Proactivity Validation): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Level 5: Persistence Validation (Critical)

**Purpose**: Verify all state survives daemon restart

### 5.1 Create Test State

```bash
echo "📋 Level 5.1: Creating test state..."

timestamp=$(date +%s)
test_value="PERSISTENCE_TEST_$timestamp"

result=$(clawdbot agent --message "Remember this important test value: $test_value" --thinking low 2>&1)

echo "Stored test value: $test_value"
echo "Response: $result"
```

### 5.2 Verify Memory Written

```bash
echo "📋 Level 5.2: Verifying memory was written..."

# Check MEMORY.md
if grep -q "$test_value" ~/clawd-dev/MEMORY.md 2>/dev/null; then
    echo "✅ Value found in MEMORY.md"
else
    echo "⚠️  Value not in MEMORY.md (may be in daily log)"
fi

# Check daily log
today=$(date +%Y-%m-%d)
if grep -q "$test_value" ~/clawd-dev/memory/$today.md 2>/dev/null; then
    echo "✅ Value found in daily log"
else
    echo "⚠️  Value not in daily log"
fi
```

### 5.3 Restart Daemon

```bash
echo "📋 Level 5.3: Restarting Clawdbot daemon..."

# Unload
launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist
echo "⏸️  Daemon stopped"

sleep 3

# Reload
launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
echo "▶️  Daemon starting..."

sleep 5

# Verify running
if launchctl list 2>/dev/null | grep -q "clawdbot"; then
    echo "✅ Daemon restarted successfully"
else
    echo "❌ FAIL: Daemon did not restart"
    exit 1
fi

# Health check
clawdbot health --verbose
```

### 5.4 Verify Memory Persisted

```bash
echo "📋 Level 5.4: Verifying memory persisted..."

result=$(clawdbot agent --message "What test value did I ask you to remember? It should contain 'PERSISTENCE_TEST'." --thinking low 2>&1)

echo "Response: $result"

if echo "$result" | grep -qi "PERSISTENCE_TEST"; then
    echo "✅ PASS: Memory persisted across restart"
else
    echo "❌ FAIL: Memory did not persist"
fi
```

### 5.5 Verify Daily Log Persisted

```bash
echo "📋 Level 5.5: Verifying daily log persisted..."

today=$(date +%Y-%m-%d)
if [ -f ~/clawd-dev/memory/$today.md ]; then
    echo "✅ Daily log file exists"
    cat ~/clawd-dev/memory/$today.md
else
    echo "⚠️  Daily log file not found"
fi
```

### Level 5 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 5 (Persistence Validation): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Level 6: Error Handling & Escalation

**Purpose**: Verify graceful error handling and proper escalation

### 6.1 Error Handling Test

```bash
echo "📋 Level 6.1: Testing error handling..."

# Trigger an error condition (capability-specific)
result=$(clawdbot agent --message "[Input that should cause graceful error handling]" --thinking low 2>&1)

echo "Response: $result"

# Should NOT crash, should handle gracefully
if echo "$result" | grep -qi "error\|sorry\|unable\|cannot"; then
    echo "✅ Error handled gracefully (check response for quality)"
else
    echo "⚠️  Error handling unclear - verify manually"
fi
```

### 6.2 Escalation Test

```bash
echo "📋 Level 6.2: Testing escalation..."

# Trigger an escalation condition (from PRD escalation triggers)
result=$(clawdbot agent --message "[Input that should trigger escalation per PRD]" --thinking low 2>&1)

echo "Response: $result"

# Should ask for confirmation, not act autonomously
if echo "$result" | grep -qi "should I\|would you like\|confirm\|approve\|permission"; then
    echo "✅ PASS: Agent asked for approval (escalation working)"
else
    echo "❌ FAIL: Agent may have acted without escalation"
fi
```

### Level 6 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 6 (Error/Escalation): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Level 7: Full Integration Test

**Purpose**: Run complete capability workflow end-to-end

### 7.1 Full Workflow Test

```bash
echo "📋 Level 7: Running full integration test..."

# Execute the complete capability workflow as defined in PRD
# This is capability-specific - use the workflow from PRD Section 3

echo "Executing full workflow..."

# [Capability-specific commands here]

# Example:
# result=$(clawdbot agent --message "Execute the full [capability-name] workflow with test mode enabled" --thinking low 2>&1)
# echo "$result"
```

### 7.2 Verify All Expected Outputs

Check:
- [ ] API calls made correctly (check logs)
- [ ] Memory updated correctly
- [ ] Response matches expected format
- [ ] No errors in logs

```bash
echo "📋 Checking logs for errors..."
clawdbot logs --limit 100 | grep -i "error\|warn\|fail"
```

### Level 7 Summary

```bash
echo ""
echo "═══════════════════════════════════════"
echo "LEVEL 7 (Integration): [PASS/FAIL]"
echo "═══════════════════════════════════════"
```

---

## Validation Report

Generate comprehensive validation report:

```markdown
# VALIDATION REPORT
# Capability: [Capability Name]
# Platform: macOS
# Date: [date]
# Clawdbot Version: [version]

═══════════════════════════════════════════════════════════════
                     VALIDATION SUMMARY
═══════════════════════════════════════════════════════════════

Level 1 (Static Validation):      ✅ PASS / ❌ FAIL
Level 2 (Injection Validation):   ✅ PASS / ❌ FAIL
Level 3 (Logic Validation):       ✅ PASS / ❌ FAIL  ([X/Y] tests)
Level 4 (Proactivity):            ✅ PASS / ❌ FAIL
Level 5 (Persistence):            ✅ PASS / ❌ FAIL
Level 6 (Error/Escalation):       ✅ PASS / ❌ FAIL
Level 7 (Integration):            ✅ PASS / ❌ FAIL

═══════════════════════════════════════════════════════════════

OVERALL STATUS: ✅ READY FOR DEPLOYMENT / ❌ NEEDS FIXES

═══════════════════════════════════════════════════════════════

## Failed Tests (if any)
- [Test ID]: [Failure description]
- [Test ID]: [Failure description]

## Warnings
- [Warning 1]
- [Warning 2]

## Notes
- [Any observations or recommendations]

═══════════════════════════════════════════════════════════════
```

Save report:
```bash
cat > ~/clawd-dev-kit/capabilities/[capability-name]/validation-report.md << 'EOF'
[REPORT CONTENT]
EOF
```

---

## Human Checkpoint

Present validation report to user:

1. **Review all levels** - Any failures that need addressing?
2. **Review warnings** - Any concerns?
3. **Deployment decision** - Ready to deploy to Mac Mini?

**DO NOT deploy if ANY critical level (1, 3, 5) has failures.**

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
