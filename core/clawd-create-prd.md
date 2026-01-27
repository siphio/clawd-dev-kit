---
description: Generate comprehensive PRD, design docs, and workspace structure for a Clawdbot capability
argument-hint: [capability-description]
---

# Create Clawdbot Capability PRD

You are creating a comprehensive Product Requirements Document and initializing the full project structure including the deployable `workspace/` folder.

## Project Structure Overview

```
./                              ← Your project root
├── docs/                       ← PLANNING (human reference, NOT deployed)
│   ├── PRD.md
│   ├── SOUL-additions.md
│   ├── TOOLS-additions.md
│   ├── memory-schema.md
│   ├── test-cases.md
│   └── plans/                  ← Phase implementation plans
│       └── plan-phase-1.md
│
├── workspace/                  ← LIVE AGENT (deployed to Clawdbot)
│   ├── IDENTITY.md
│   ├── SOUL.md
│   ├── TOOLS.md
│   ├── AGENTS.md
│   ├── MEMORY.md
│   ├── USER.md
│   ├── memory/
│   ├── skills/
│   └── media/
│
├── skills/                     ← Shared/dev skills (optional)
├── tests/                      ← Test scripts
└── README.md
```

### docs/ vs workspace/ - The Key Difference

| Aspect | docs/ | workspace/ |
|--------|-------|------------|
| **What** | Documentation | Configuration |
| **Who reads** | You + Claude | Clawdbot agent |
| **When** | During development | At runtime |
| **Deploy?** | ❌ No | ✅ Yes |
| **Changes** | By you manually | By agent (memory) + you |

**Think of `docs/` as the blueprint and `workspace/` as the actual house.**

---

## Step 1: Create Project Structure

```bash
# Create documentation directory with plans subfolder
mkdir -p ./docs/plans

# Create STATE.md for progress tracking
cat > ./docs/STATE.md << 'EOF'
---
capability: [CAPABILITY_NAME]
created: [DATE]
last_updated: [DATE]
current_phase: 0
total_phases: [X]
status: initialized
---

# Development State

## Phase Progress

| Phase | Status | Planned | Executed | Validated |
|-------|--------|---------|----------|-----------|
| 1 | pending | - | - | - |
| 2 | pending | - | - | - |
| 3 | pending | - | - | - |

## Activity Log

### [DATE] - Project Initialized
- Created PRD and project structure
- Total phases defined: [X]
- Next: Run `/clawd-plan-phase 1`

---

## Status Key

- `pending` - Not started
- `planned` - Plan created in docs/plans/
- `executed` - Implementation complete in workspace/
- `validated` - Tests passed
- `deployed` - Live in production

## Next Action

**Run**: `/clawd-plan-phase 1`
EOF

# Create workspace (deployable Clawdbot instance)
mkdir -p ./workspace/memory
mkdir -p ./workspace/skills
mkdir -p ./workspace/media/clips
mkdir -p ./workspace/media/downloads
mkdir -p ./workspace/media/transcripts

# Create shared directories
mkdir -p ./skills
mkdir -p ./tests

# Create .gitignore
cat > ./.gitignore << 'EOF'
.env
.DS_Store
*.log
node_modules/

# Don't commit large media files
workspace/media/clips/*.mp4
workspace/media/downloads/*
!workspace/media/downloads/.gitkeep

# Memory files are agent-generated (optional to commit)
# workspace/memory/*.json
EOF

# Create .env.example
cat > ./.env.example << 'EOF'
# Deployment Configuration
CLAWD_MINI_HOST=your-macmini.local
CLAWD_MINI_USER=your-username
CLAWD_MINI_SSH_KEY=~/.ssh/id_ed25519
CLAWD_MINI_WORKSPACE=~/clawd

# Capability-specific secrets (add as needed)
# GROK_API_KEY=your-grok-key
# TELEGRAM_BOT_TOKEN=your-telegram-token
# X_API_KEY=your-x-api-key
EOF

# Create .gitkeep files for empty directories
touch ./workspace/media/clips/.gitkeep
touch ./workspace/media/downloads/.gitkeep
touch ./workspace/media/transcripts/.gitkeep
touch ./workspace/memory/.gitkeep
touch ./skills/.gitkeep
touch ./tests/.gitkeep
```

---

## Step 2: Initialize workspace/ Files

### workspace/IDENTITY.md

```markdown
---
name: [Capability Name]
emoji: [Relevant emoji]
version: 1.0.0
created: [Date]
author: [Author]
---

# Identity

You are **[Agent Name]**, [brief persona description].

## Core Purpose

[One sentence describing what this agent does]

## Personality Traits

- [Trait 1]
- [Trait 2]
- [Trait 3]
```

### workspace/SOUL.md

```markdown
---
name: [Capability Name]
version: 1.0.0
---

# Persona

[Detailed persona description - who is this agent?]

# Core Directives

[The fundamental rules this agent follows]

- [Directive 1]
- [Directive 2]
- [Directive 3]

# Capabilities

## [Capability Name]

[Detailed behavioral rules for this capability]

### Proactivity Rules

[When and how the agent acts autonomously]

### Decision Framework

[How the agent makes decisions]

### Autonomy Boundaries

**You MAY autonomously**:
- [Safe auto actions]

**You MUST get approval before**:
- [Actions requiring human confirmation]

**You MUST NEVER**:
- [Hard constraints]
```

### workspace/TOOLS.md

```markdown
---
name: [Capability Name] Tools
version: 1.0.0
---

# Available Tools

## [Tool 1 Name]

**Purpose**: [What this tool does]
**When to use**: [Conditions]

**Usage**:
\`\`\`
[How to invoke]
\`\`\`

## [Tool 2 Name]

[Continue for each tool...]
```

### workspace/AGENTS.md

```markdown
---
name: [Capability Name] Agents
version: 1.0.0
---

# Operating Instructions

## Startup Behavior

[What the agent does when it starts]

## Scheduled Tasks

| Schedule | Task | Description |
|----------|------|-------------|
| [Cron] | [Task name] | [What it does] |

## Error Handling

[How to handle common errors]
```

### workspace/MEMORY.md

```markdown
---
name: [Capability Name] Memory
version: 1.0.0
last_updated: [Timestamp]
---

# Persistent Memory

## Tracked Data

[What the agent remembers between sessions]

## Recent Activity

[Agent updates this section]
```

### workspace/USER.md

```markdown
---
name: User Profile
version: 1.0.0
---

# User Preferences

## Communication Style

- [Preference 1]
- [Preference 2]

## Notification Settings

- [Setting 1]
- [Setting 2]

## Known Context

[Things the agent should remember about the user]
```

---

## Step 3: Generate docs/ Files

### docs/PRD.md

Create a comprehensive PRD with these sections:

```markdown
# [Capability Name] - Product Requirements Document

> **Capability Name**: `[kebab-case-name]`
> **Version**: 1.0.0
> **Author**: [Author]
> **Created**: [Date]
> **Status**: Draft - Pending Approval

---

## 1. Overview

### 1.1 Problem Statement
[What problem does this capability solve?]

### 1.2 Solution Summary
[How does this capability solve it?]

### 1.3 Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

---

## 2. Capability Design

### 2.1 Proactivity Model

| Trigger Type | Schedule/Event | Action |
|--------------|----------------|--------|
| [Cron/Event/Manual] | [When] | [What happens] |

### 2.2 Autonomy Boundaries

| Action | Autonomy Level | Requires Approval |
|--------|----------------|-------------------|
| [Action 1] | Full Auto / Draft / Manual | Yes/No |

### 2.3 External Integrations

| Service | Purpose | Auth Method |
|---------|---------|-------------|
| [Service 1] | [Why needed] | [API Key/OAuth/etc] |

---

## 3. Implementation Phases

### Phase 1: [Phase Name]
**Focus**: [What this phase delivers]
**Deliverables**:
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]

### Phase 2: [Phase Name]
[Continue for all phases...]

---

## 4. Test Cases

| Test ID | Description | Type |
|---------|-------------|------|
| TC-001 | [Test description] | [Unit/Integration/E2E] |

---

## 5. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk 1] | [High/Med/Low] | [How to address] |

---

## 6. Open Questions

- [ ] [Question 1]
- [ ] [Question 2]
```

### docs/SOUL-additions.md

```markdown
# SOUL.md Reference - [Capability Name]

> **Note**: This is a REFERENCE copy. The live version is in `workspace/SOUL.md`.
> Use this to track changes and review additions.

---

[Copy of the capability-specific SOUL.md content]
```

### docs/TOOLS-additions.md

```markdown
# TOOLS.md Reference - [Capability Name]

> **Note**: This is a REFERENCE copy. The live version is in `workspace/TOOLS.md`.

---

[Copy of tool definitions]
```

### docs/memory-schema.md

```markdown
# Memory Schema - [Capability Name]

> Defines the persistence structure used in `workspace/memory/`

---

## Files

| File | Purpose | Schema |
|------|---------|--------|
| `[name].json` | [Purpose] | [Structure] |

## Schema Definitions

[Detailed schemas for each memory file]
```

### docs/test-cases.md

```markdown
# Test Cases - [Capability Name]

> Validation tests for `/clawd-validate-phase`

---

## Test Summary

| ID | Category | Description | Priority |
|----|----------|-------------|----------|
| TC-001 | Recognition | Agent knows capability | High |
| TC-002 | Behavioral | Follows SOUL.md rules | High |

## Detailed Test Cases

### TC-001: Capability Awareness
**Description**: Verify Clawdbot knows about this capability
**Command**:
\`\`\`bash
clawdbot agent --message "What do you know about [capability name]?" --thinking low
\`\`\`
**Expected**: Response mentions the capability and its purpose
**Pass Criteria**: Contains keywords: [keyword1], [keyword2]

[Continue for each test...]
```

### docs/plans/plan-phase-1.md

```markdown
# Phase 1 Implementation Plan

> Implementation guide for Phase 1

---

## Deliverables

1. [ ] [Deliverable 1]
2. [ ] [Deliverable 2]

## Implementation Steps

[Detailed steps]

## Files to Create/Modify

- `workspace/SOUL.md` - Add [content]
- `workspace/skills/[skill].md` - Create [skill]
```

---

## Step 4: Generate README.md

```markdown
# [Capability Name]

> [One-line description]

## Status

🚧 **In Development** - Phase 1

## Quick Start

\`\`\`bash
# 1. Review the PRD
cat docs/PRD.md

# 2. Validate the workspace
/clawd-validate-phase

# 3. Execute Phase 1
/clawd-execute-phase 1

# 4. Deploy when ready
/clawd-deploy
\`\`\`

## Project Structure

\`\`\`
.
├── docs/                    # Planning documentation (NOT deployed)
│   ├── PRD.md
│   ├── test-cases.md
│   └── plans/
│       └── plan-phase-1.md
│
├── workspace/               # Live agent files (DEPLOYED to Clawdbot)
│   ├── SOUL.md
│   ├── TOOLS.md
│   ├── memory/
│   └── skills/
│
└── README.md
\`\`\`

## Deployment

The `workspace/` folder is deployed directly to your Clawdbot installation:

\`\`\`bash
# Validation (copies to ~/clawd-dev/)
/clawd-validate-phase

# Production (copies to ~/clawd/ on Mac Mini)
/clawd-deploy
\`\`\`
```

---

## Step 5: Update STATE.md

After creating the PRD, update `docs/STATE.md` with:
- The capability name
- Total number of phases from the PRD
- Generate the phase progress table with all phases

```bash
# Update STATE.md with actual values from PRD
# Replace placeholders with real data
```

---

## Final Output Summary

After generating all files:

```
✅ Project initialized!

Structure created:
├── docs/                        # Planning (NOT deployed)
│   ├── PRD.md                   (XX KB)
│   ├── STATE.md                 (XX KB) - Progress tracking
│   ├── SOUL-additions.md        (XX KB) - Reference copy
│   ├── TOOLS-additions.md       (XX KB) - Reference copy
│   ├── memory-schema.md         (XX KB)
│   ├── test-cases.md            (XX KB)
│   └── plans/                   (empty - plans created later)
│
├── workspace/                   # Live agent (DEPLOYED)
│   ├── IDENTITY.md              (XX KB)
│   ├── SOUL.md                  (XX KB) - THE live version
│   ├── TOOLS.md                 (XX KB) - THE live version
│   ├── AGENTS.md                (XX KB)
│   ├── MEMORY.md                (XX KB)
│   ├── USER.md                  (XX KB)
│   ├── memory/                  (empty)
│   ├── skills/                  (empty)
│   └── media/                   (empty)
│
└── README.md

Current State (from docs/STATE.md):
- Phase: 0 of X
- Status: initialized
- Next: Plan Phase 1

Next steps:
1. Review docs/PRD.md
2. Run: /clawd-plan-phase 1
```
