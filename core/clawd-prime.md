---
description: Load context for Clawdbot capability development - familiarize with PRD, current state, and next steps
argument-hint: [capability-name]
---

# Prime Context for Clawdbot Capability Development

You are preparing to develop a Clawdbot capability. This command loads project context so you understand what you're building and where you are in development.

**Purpose**: Familiarize yourself with the capability, current state, and next steps.
**NOT for**: Deep research (that happens in `/clawd-plan-phase`).

---

## Step 1: Load Project Files

### 1.1 Read Global Rules

First, understand the development conventions:

```
Read: clawd-global-rules.md
```

### 1.2 Read PRD

Load the Product Requirements Document:

```
Read: ./docs/PRD.md
```

If PRD doesn't exist:
- Stop and instruct user to run `/clawd-create-prd [capability-name]` first
- Do not proceed without an approved PRD

### 1.3 Check for Existing Planning Documents

Check what planning work has been done:

```bash
ls -la ./docs/
ls -la ./docs/plans/
```

Look for:
- `SOUL-additions.md` - Behavioral rules planned?
- `TOOLS-additions.md` - Tool conventions planned?
- `memory-schema.md` - Memory structure planned?
- `test-cases.md` - Test cases defined?
- `plans/plan-phase-X.md` - Any phase plans exist?

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

## Step 3: Determine Development Phase

### 3.1 Assess Progress

Based on what exists, determine current phase:

| State | Current Phase | Next Step |
|-------|---------------|-----------|
| Only PRD exists | Phase 0 | Run `/clawd-plan-phase` to plan Phase 1 |
| PRD + plans/plan-phase-1.md | Phase 1 Planning Done | Run `/clawd-execute-phase 1` |
| workspace/ has SOUL.md started | Phase 1 In Progress | Continue execution or validate |
| Phase 1 complete, no phase-2-plan | Between Phases | Run `/clawd-plan-phase` for Phase 2 |
| All phases complete | Done | Run `/clawd-validate-phase` then `/clawd-deploy` |

### 3.2 Check for Incomplete Work

Look for signs of incomplete work:
- Partially written SOUL.md sections
- TODO comments in workspace/ files
- Phase plan with unchecked tasks

---

## Step 4: Generate Context Summary

Compile a brief context summary:

```markdown
# Context: [Capability Name]

## PRD Summary
- **Name**: [from PRD]
- **Description**: [one-line from PRD]
- **Proactivity Model**: [Scheduled/Event/Heartbeat/Reactive]
- **Key Integrations**: [list from PRD]

## Current Development State

### Planning Documents (docs/)
- PRD.md: ✅ Exists
- SOUL-additions.md: [✅/❌]
- TOOLS-additions.md: [✅/❌]
- test-cases.md: [✅/❌]
- plans/plan-phase-X.md: [list what exists]

### Implementation (workspace/)
- SOUL.md: [Not started / In progress / Complete]
- TOOLS.md: [Not started / In progress / Complete]
- Skills: [None / list created skills]
- Memory: [Not configured / Configured]

## Current Phase
**Phase**: [X]
**Status**: [Not started / In progress / Complete]

## Next Step
**Recommended Command**: `/clawd-[next-command]`
**Reason**: [why this is the next step]

## Quick Notes
- [Any important observations]
- [Blockers or concerns]
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

## Next Steps

Based on current phase:

| If Current State | Run Next |
|------------------|----------|
| Need to plan | `/clawd-plan-phase [phase-number]` |
| Plan exists, need to build | `/clawd-execute-phase [phase-number]` |
| Built, need to test | `/clawd-validate-phase` |
| Tested, need to deploy | `/clawd-deploy` |

---

## What This Command Does NOT Do

❌ **No Archon research** - That's for `/clawd-plan-phase`
❌ **No sub-agent spawning** - That's for `/clawd-plan-phase`
❌ **No deep API research** - That's for `/clawd-plan-phase`
❌ **No implementation** - That's for `/clawd-execute-phase`

This command is purely about **understanding where you are** so you can make the right next move.
