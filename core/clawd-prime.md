---
description: Load context for Clawdbot capability development - familiarize with PRD, current state, and next steps
argument-hint: [capability-name]
---

# Prime Context for Clawdbot Capability Development

You are preparing to develop a Clawdbot capability. This command loads project context so you understand what you're building and where you are in development.

**Purpose**: Familiarize yourself with the capability, current state, and next steps.
**NOT for**: Deep research (that happens in `/clawd-plan-phase`).

---

## Step 1: Load State File (CRITICAL)

### 1.1 Read STATE.md First

**This is the source of truth for project progress.**

```
Read: ./docs/STATE.md
```

If STATE.md doesn't exist:
- Check if PRD exists (`./docs/PRD.md`)
- If no PRD: instruct user to run `/clawd-create-prd [capability-name]` first
- If PRD exists but no STATE.md: this is a legacy project, create STATE.md manually

### 1.2 Parse State Information

From STATE.md YAML frontmatter, extract:
- `capability`: Project name
- `current_phase`: Which phase we're on
- `total_phases`: Total phases in PRD
- `status`: Current status (initialized/planned/executed/validated/deployed)
- `last_updated`: When last action occurred

From the Phase Progress table, extract:
- Status of each phase (pending/planned/executed/validated)
- Dates for each milestone

### 1.3 Read PRD for Context

```
Read: ./docs/PRD.md
```

Get a summary of:
- Capability description
- Phase breakdown (verify matches STATE.md total_phases)
- Key integrations

### 1.4 Read Global Rules

```
Read: clawd-global-rules.md
```

---

## Step 2: Understand Current State

### 2.1 Check workspace/ Folder

See what's been implemented:

```bash
ls -la ./workspace/
```

For each existing file, note its current state:
- `SOUL.md` - What capabilities are already defined?
- `TOOLS.md` - What tool conventions exist?
- `AGENTS.md` - What operating instructions exist?
- `MEMORY.md` - What memory schema is set up?
- `skills/` - What skills have been created?
- `memory/` - Any activity logs?

### 2.2 Read Key workspace/ Files

If they exist, read them to understand current implementation:

```bash
# Check what's been built
cat ./workspace/SOUL.md 2>/dev/null || echo "Not yet created"
cat ./workspace/TOOLS.md 2>/dev/null || echo "Not yet created"
ls -la ./workspace/skills/ 2>/dev/null || echo "No skills yet"
```

---

## Step 3: Determine Development Phase (from STATE.md)

### 3.1 Read Current State

The `docs/STATE.md` file tells you EXACTLY where you are:

| STATE.md Status | Current Phase | Next Step |
|-----------------|---------------|-----------|
| `status: initialized` | Phase 0 | Run `/clawd-plan-phase 1` |
| `status: planned` | Phase X planned | Run `/clawd-execute-phase X` |
| `status: executed` | Phase X built | Run `/clawd-validate-phase` |
| `status: validated` + more phases | Phase X done | Run `/clawd-plan-phase [X+1]` |
| `status: validated` + all phases done | Complete | Run `/clawd-deploy` |
| `status: deployed` | In production | Development complete |

### 3.2 Use STATE.md Data (Not Guessing)

**DO NOT guess based on file existence.** Use the explicit state:

```markdown
From STATE.md:
- current_phase: X
- total_phases: Y
- status: [current status]

Therefore:
- Phase X of Y
- Status: [status]
- Next action: [determined by status and remaining phases]
```

### 3.3 Verify State Matches Reality (Sanity Check)

Quick verification that STATE.md is accurate:

```bash
# If status says "planned", plan file should exist
ls ./docs/plans/plan-phase-$CURRENT_PHASE.md

# If status says "executed", workspace should have content
ls ./workspace/SOUL.md
ls ./workspace/skills/

# If status says "validated", we should NOT be fixing workspace issues
```

If STATE.md doesn't match reality, flag this to the user and help reconcile.

---

## Step 4: Generate Context Summary (from STATE.md)

Compile a brief context summary **using STATE.md as the source of truth**:

```markdown
# Context: [Capability Name]

## State Summary (from docs/STATE.md)

| Field | Value |
|-------|-------|
| **Current Phase** | [X] of [total_phases] |
| **Status** | [status from STATE.md] |
| **Last Updated** | [last_updated from STATE.md] |

## Phase Progress

| Phase | Status | Planned | Executed | Validated |
|-------|--------|---------|----------|-----------|
| 1 | [status] | [date] | [date] | [date] |
| 2 | [status] | [date] | [date] | [date] |
| ... | ... | ... | ... | ... |

## PRD Summary
- **Name**: [from PRD]
- **Description**: [one-line from PRD]
- **Total Phases**: [X]
- **Key Integrations**: [list from PRD]

## Current Phase Details

**Phase [X]: [Phase Name from PRD]**
- Status: [planned/executed/validated]
- Focus: [what this phase delivers]

## Next Action

Based on STATE.md:
- **Status**: [current status]
- **Phases remaining**: [total - current]
- **Recommended**: `/clawd-[next-command]`

### Decision Logic:
- If `status: initialized` → `/clawd-plan-phase 1`
- If `status: planned` → `/clawd-execute-phase [X]`
- If `status: executed` → `/clawd-validate-phase`
- If `status: validated` AND `current_phase < total_phases` → `/clawd-plan-phase [X+1]`
- If `status: validated` AND `current_phase == total_phases` → `/clawd-deploy`

## Quick Notes
- [Any observations from Activity Log]
- [Any blockers noted]
```

---

## Step 5: Present to User

Present the context summary and confirm:

1. **Is the PRD still accurate?** (requirements may have changed)
2. **Is my assessment of current state correct?**
3. **Ready to proceed with [recommended next step]?**

---

## Output Checklist

Before proceeding:

- [ ] PRD read and summarized
- [ ] docs/ folder scanned for planning documents
- [ ] workspace/ folder scanned for implementation
- [ ] Current phase determined
- [ ] Next step identified
- [ ] User confirms context is accurate

---

## Next Steps (Determined by STATE.md)

**Use the status from STATE.md to determine next action:**

| STATE.md Status | Condition | Next Command |
|-----------------|-----------|--------------|
| `initialized` | - | `/clawd-plan-phase 1` |
| `planned` | - | `/clawd-execute-phase [current_phase]` |
| `executed` | - | `/clawd-validate-phase` |
| `validated` | `current_phase < total_phases` | `/clawd-plan-phase [current_phase + 1]` |
| `validated` | `current_phase == total_phases` | `/clawd-deploy` |
| `deployed` | - | Development complete! |

**NEVER suggest deploy unless ALL phases are validated.**

---

## What This Command Does NOT Do

❌ **No Archon research** - That's for `/clawd-plan-phase`
❌ **No sub-agent spawning** - That's for `/clawd-plan-phase`
❌ **No deep API research** - That's for `/clawd-plan-phase`
❌ **No implementation** - That's for `/clawd-execute-phase`

This command is purely about **understanding where you are** so you can make the right next move.

---

## Architecture Validation (MANDATORY)

After loading all project files (PRD.md, STATE.md, workspace files, etc.):

1. Provide a concise recap of the Clawdbot/Moltbot Skill Architecture from clawd-global-rules.md (focus on: skills are teaching documents, no custom tool calling, invocation via /skill_name or explicit exec/curl).

2. Scan the PRD.md and any existing SOUL-additions.md / SKILL.md drafts:
   - If they mention "tool calls", "function schemas", "expose as tool", "index.ts", or similar, output a prominent warning:
     "⚠️ WARNING: PRD or drafts assume invalid skill architecture (tool-calling style). Revise to use prompt-orchestration teaching in SKILL.md with explicit exec/curl/browser steps and /skill_name invocations before proceeding."

3. Always recommend: If in early phases, run /clawd-plan-phase which now includes automatic exemplar skill analysis.
