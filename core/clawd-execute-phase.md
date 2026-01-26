---
description: Execute the implementation plan for a Clawdbot capability
argument-hint: [capability-name]
---

# Execute Clawdbot Capability Implementation

You are executing the approved implementation plan for a Clawdbot capability. Follow the plan exactly and track progress using Archon task management.

## Critical Context

**MANDATORY READS**:
1. `clawd-global-rules.md` - Development conventions
2. `~/clawd-dev-kit/capabilities/$ARGUMENTS/PRD.md` - Requirements
3. `~/clawd-dev-kit/capabilities/$ARGUMENTS/plan.md` - Implementation plan (MUST BE APPROVED)

**Execution Principles**:
- Follow the plan exactly - it contains all needed context
- Orchestration first, code second
- One task at a time, validate before moving on
- Track all tasks in Archon
- Stop and escalate if something doesn't match the plan

---

## Pre-Execution Checklist

Before starting execution, verify:

- [ ] Plan file exists at `~/clawd-dev-kit/capabilities/$ARGUMENTS/plan.md`
- [ ] Plan has been approved by user (check for approval note or ask)
- [ ] Development workspace exists at `~/clawd-dev/`
- [ ] Required credentials are configured (check `.env`)
- [ ] Required MCP servers are accessible

If any item fails, STOP and resolve before proceeding.

---

## Step 1: Load the Plan

### 1.1 Read Plan Document

```bash
cat ~/clawd-dev-kit/capabilities/$ARGUMENTS/plan.md
```

### 1.2 Extract Task List

Identify all tasks from the plan's "Implementation Tasks" section.

### 1.3 Verify Plan Completeness

Confirm the plan includes:
- [ ] Exact SOUL.md content to add
- [ ] Exact TOOLS.md content to add
- [ ] Memory schema definitions
- [ ] Proactivity configuration
- [ ] Validation commands for each stage
- [ ] Skill specifications (if needed)

If anything is missing, STOP and return to `/clawd-plan-phase`.

---

## Step 2: Initialize Archon Project

### 2.1 Create Project

```
mcp__archon__manage_project(
    "create",
    title="Capability: [capability-name]",
    description="Implementation of [capability-name] capability for Clawdbot"
)
```

Store the returned `project_id` for use throughout execution.

### 2.2 Create All Tasks

For EACH task in the plan, create an Archon task:

```
mcp__archon__manage_task(
    "create",
    project_id="[project_id]",
    title="[Task ID]: [Task Description]",
    description="[Detailed description from plan]",
    status="todo"
)
```

**IMPORTANT**: Create ALL tasks upfront before starting implementation.

---

## Step 3: Stage 1 - Orchestration Setup

### 3.1 SOUL.md Additions

**Task**: Add capability section to SOUL.md

1. **Mark task as in-progress**:
   ```
   mcp__archon__manage_task("update", task_id="[id]", status="doing")
   ```

2. **Read current SOUL.md**:
   ```bash
   cat ~/clawd-dev/SOUL.md
   ```

3. **Identify insertion point**:
   - Find the `# Capabilities` section
   - Or appropriate location per existing structure

4. **Add capability section**:
   Use the EXACT content from the plan's "SOUL.md Additions" section.

   ```bash
   # Append to SOUL.md (or edit to insert at correct location)
   ```

5. **Validate**:
   Run the validation command from the plan:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('$HOME/clawd-dev/SOUL.md').read().split('---')[1])"
   grep -q "[Capability Name]" ~/clawd-dev/SOUL.md && echo "PASS" || echo "FAIL"
   ```

6. **Mark task for review**:
   ```
   mcp__archon__manage_task("update", task_id="[id]", status="review")
   ```

### 3.2 TOOLS.md Additions

**Task**: Add tool conventions to TOOLS.md

1. **Mark task as in-progress**
2. **Read current TOOLS.md**
3. **Add conventions** from plan's "TOOLS.md Additions" section
4. **Validate** per plan
5. **Mark task for review**

### 3.3 Memory Schema Initialization

**Task**: Initialize memory schema in MEMORY.md

1. **Mark task as in-progress**
2. **Read current MEMORY.md**
3. **Add memory schema** from plan
4. **Validate** - check section exists
5. **Mark task for review**

### Stage 1 Checkpoint

Run all Stage 1 validation commands from the plan.

If ALL pass:
- Mark all Stage 1 tasks as "done"
- Proceed to Stage 2

If ANY fail:
- Investigate and fix
- Re-run validation
- Do NOT proceed until all pass

---

## Step 4: Stage 2 - Proactivity Configuration

### 4.1 Cron Job Configuration

**Task**: Configure cron job(s)

1. **Mark task as in-progress**

2. **Configure cron job** per plan specifications:

   The exact method depends on Clawdbot's cron configuration approach.
   Check the plan for specific commands or configuration files.

3. **Validate**:
   ```bash
   clawdbot cron list
   # Verify job appears with correct schedule
   ```

4. **Mark task for review**

### 4.2 Heartbeat Rules (if applicable)

**Task**: Set up heartbeat rules

1. **Mark task as in-progress**
2. **Add heartbeat logic** to SOUL.md behavior section (if not already included)
3. **Validate** per plan
4. **Mark task for review**

### Stage 2 Checkpoint

Run all Stage 2 validation commands.

If ALL pass → Mark tasks as "done", proceed to Stage 3
If ANY fail → Fix before proceeding

---

## Step 5: Stage 3 - Integration Setup

### 5.1 Credential Configuration

**Task**: Configure credentials

1. **Mark task as in-progress**

2. **Verify credentials in .env**:
   ```bash
   grep "[CREDENTIAL_NAME]" ~/clawd-dev-kit/.env
   ```

3. **Configure in Clawdbot** (if needed):
   Credentials may need to be added to Clawdbot's credential store
   or referenced in configuration.

4. **Validate** - test credential access:
   ```bash
   # Method depends on integration
   # E.g., test API call or MCP connection
   ```

5. **Mark task for review**

### 5.2 MCP Server Connection (if applicable)

**Task**: Set up MCP server connection

1. **Mark task as in-progress**

2. **Verify MCP server is installed/configured**

3. **Test MCP tools are accessible**:
   ```bash
   clawdbot agent --message "List available tools from [mcp-server]" --thinking low
   ```

4. **Mark task for review**

### Stage 3 Checkpoint

Run all Stage 3 validation commands.

If ALL pass → Mark tasks as "done", proceed to Stage 4 (if exists) or Stage 5
If ANY fail → Fix before proceeding

---

## Step 6: Stage 4 - Skill Development (If Required)

**Only execute this stage if the plan specifies a custom skill is needed.**

### 6.1 Create Skill Directory

**Task**: Create skill structure

1. **Mark task as in-progress**

2. **Create directory**:
   ```bash
   mkdir -p ~/clawd-dev/skills/[skill-name]
   ```

3. **Mark task for review**

### 6.2 Create SKILL.md

**Task**: Create SKILL.md definition

1. **Mark task as in-progress**

2. **Write SKILL.md** with EXACT content from plan:
   ```bash
   cat > ~/clawd-dev/skills/[skill-name]/SKILL.md << 'EOF'
   [EXACT CONTENT FROM PLAN]
   EOF
   ```

3. **Validate YAML frontmatter**:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('$HOME/clawd-dev/skills/[skill-name]/SKILL.md').read().split('---')[1])"
   ```

4. **Mark task for review**

### 6.3 Implement Skill Logic

**Task**: Create index.ts

1. **Mark task as in-progress**

2. **Write TypeScript implementation** per plan specifications

3. **Validate TypeScript compiles**:
   ```bash
   cd ~/clawd-dev/skills/[skill-name]
   tsc --noEmit
   ```

4. **Mark task for review**

### 6.4 Test Skill Tools

**Task**: Verify skill tools are callable

1. **Mark task as in-progress**

2. **Test tool invocation**:
   ```bash
   clawdbot agent --message "Use the [tool_name] tool with test parameters" --thinking low
   ```

3. **Verify expected behavior**

4. **Mark task for review**

### Stage 4 Checkpoint

Run all Stage 4 validation commands.

If ALL pass → Mark tasks as "done", proceed to Stage 5
If ANY fail → Fix before proceeding

---

## Step 7: Stage 5 - Testing & Validation

### 7.1 Run Test Cases

For EACH test case defined in the PRD/plan:

**Task**: Run test case [TC-XXX]

1. **Mark task as in-progress**

2. **Execute test**:
   Use the exact validation command from the plan:
   ```bash
   result=$(clawdbot agent --message "[test-input]" --thinking low)
   echo "$result"
   ```

3. **Verify expected output**:
   ```bash
   echo "$result" | grep -q "[expected-content]" && echo "TC-XXX PASS" || echo "TC-XXX FAIL"
   ```

4. **Document result**

5. **Mark task for review** (or fix and retry if failed)

### 7.2 Persistence Test

**Task**: Verify state survives restart

1. **Mark task as in-progress**

2. **Create test state**:
   ```bash
   clawdbot agent --message "Remember test value: PERSISTENCE_TEST_$(date +%s)" --thinking low
   ```

3. **Verify memory written**:
   ```bash
   cat ~/clawd-dev/MEMORY.md | grep "PERSISTENCE_TEST"
   ```

4. **Restart daemon**:
   ```bash
   # Platform-specific - see validate-phase for full commands
   # macOS: launchctl unload/load
   ```

5. **Verify memory persisted**:
   ```bash
   clawdbot agent --message "What test value did I ask you to remember?" --thinking low
   ```

6. **Mark task for review**

### 7.3 Escalation Test

**Task**: Verify escalation works correctly

1. **Mark task as in-progress**

2. **Trigger escalation condition**:
   ```bash
   clawdbot agent --message "[trigger that should cause escalation]" --thinking low
   ```

3. **Verify agent asks for approval** instead of acting autonomously

4. **Mark task for review**

### Stage 5 Checkpoint

Run full validation suite.

If ALL pass → Mark all tasks as "done"
If ANY fail → Fix and retest

---

## Step 8: Finalization

### 8.1 Mark All Tasks Complete

For each task that passed validation:
```
mcp__archon__manage_task("update", task_id="[id]", status="done")
```

### 8.2 Generate Execution Report

Create a summary of the execution:

```markdown
# Execution Report: [Capability Name]

**Date**: [date]
**Duration**: [time taken]
**Status**: [Complete/Partial]

## Tasks Summary
| Task ID | Description | Status |
|---------|-------------|--------|
| T1.1 | [desc] | ✅ Done |
| T1.2 | [desc] | ✅ Done |
| ... | ... | ... |

## Test Results
| Test Case | Result | Notes |
|-----------|--------|-------|
| TC-001 | ✅ Pass | |
| TC-002 | ✅ Pass | |
| ... | ... | ... |

## Files Modified
- ~/clawd-dev/SOUL.md - Added capability section
- ~/clawd-dev/TOOLS.md - Added tool conventions
- ~/clawd-dev/MEMORY.md - Added memory schema
- ~/clawd-dev/skills/[name]/ - Created skill (if applicable)

## Issues Encountered
- [Issue 1 and resolution]
- [Issue 2 and resolution]

## Ready for Validation Phase
- [ ] All tasks complete
- [ ] All tests passing
- [ ] No unresolved issues
```

### 8.3 Save Report

```bash
cat > ~/clawd-dev-kit/capabilities/[capability-name]/execution-report.md << 'EOF'
[REPORT CONTENT]
EOF
```

---

## Step 9: Human Checkpoint

Present execution report to user:

1. **Review task completion** - All tasks marked done?
2. **Review test results** - All tests passing?
3. **Review issues** - Any concerns?
4. **Confirm ready for validation** - Proceed to full validation?

---

## Error Handling

### If a Task Fails

1. **Document the failure** in Archon task notes
2. **Analyze the error** - Is it a plan issue or execution issue?
3. **If plan issue** - Return to `/clawd-plan-phase` for plan update
4. **If execution issue** - Fix and retry
5. **Do NOT skip** failed tasks

### If Archon Is Unavailable

1. Use TodoWrite for local task tracking
2. Continue execution
3. Sync to Archon when available

---

## Output Checklist

Before proceeding to `/clawd-validate-phase`:

- [ ] All tasks executed
- [ ] All tasks marked "done" in Archon
- [ ] All test cases passed
- [ ] Persistence test passed
- [ ] Escalation test passed
- [ ] Execution report generated
- [ ] User has reviewed execution report

---

## Next Steps

Once execution is validated:
```
/clawd-validate-phase [capability-name]
```

The validation phase will:
1. Auto-setup local Clawdbot if needed
2. Run comprehensive automated testing
3. Verify all validation levels pass
4. Generate validation report for deployment decision
