---
description: Generate comprehensive PRD, design docs, and workspace structure for a Clawdbot capability
argument-hint: [capability-description]
---

# Create Clawdbot Capability PRD

You are creating a comprehensive Product Requirements Document and initializing the full project structure including the deployable `workspace/` folder.

---

## ⚠️ CRITICAL: Line Limits (Context Bloat Prevention)

**PRD.md MUST NOT exceed 1000 lines.**

This is a HARD LIMIT. Exceeding this causes context bloat and degrades performance.

### Enforcement Rules:
- **Maximum**: 1000 lines for PRD.md
- **Target**: 600-800 lines (ideal)
- **If exceeding**: Ruthlessly cut verbose sections, use tables instead of prose
- **Validation**: Count lines before finalizing - `wc -l ./docs/PRD.md`

### How to Stay Under Limit:
- Use bullet points, not paragraphs
- Use tables for structured data
- Keep phase descriptions to 5-10 lines each
- Omit obvious details - focus on what's unique
- Reference external docs instead of duplicating content

**If you cannot fit requirements in 1000 lines, the scope is too large - split into multiple capabilities.**

---

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

## Step 1b: Generate docs/CLAUDE.md (Global Rules for Claude Code)

**CRITICAL**: This file is auto-loaded by Claude Code every session. It provides persistent guidance for Clawdbot/Moltbot capability development.

```bash
cat > ./docs/CLAUDE.md << 'CLAUDEEOF'
# CLAWDDEV KIT GLOBAL RULES & BEST PRACTICES FOR CLAWDBOT/MOLTBOT CAPABILITIES

You are Claude developing Moltbot/Clawdbot capabilities with ClawdDev Kit. Follow these rules exactly for prompt-orchestration-first, human-in-the-loop development.

---

## CORE PHILOSOPHY

- **Human validates every phase** — no unsupervised changes.
- **Prompt-orchestration first**: SOUL.md rules over code.
- **Proactivity as first-class** (cron, heartbeats, autonomous behavior).
- **Persistence via file-based memory** (survives daemon restarts).
- **Context efficiency**: Strict character limits on workspace files.

---

## CLAWDBOT / MOLTBOT SKILL ARCHITECTURE – MUST FOLLOW

**Clawdbot/Moltbot capabilities are prompt-orchestration first, not code/tool-calling centric.** Skills teach the agent behaviors via natural language instructions in SKILL.md, not by registering function schemas or tool calls.

### Key Principles

- **Skills = Teaching Documents**: The core is `SKILL.md` — a Markdown file with frontmatter (metadata), procedural steps, and concrete command examples. The agent loads it on-demand and follows the taught patterns using built-in tools (exec, shell, curl, browser, python, etc.).
- **No Native Tool Calling for Custom Skills**: NEVER plan JSON tool schemas, function definitions, or direct calls like `scan_ai_news(params)`. Moltbot has no OpenAI-style tool registry for custom skills.
- **Invocation Patterns**:
  - Slash commands: SOUL.md says "Invoke /skill_name" → agent runs the skill's instructions.
  - Explicit exec/shell/curl: "Use exec to run python /skills/script.py --args" or "curl -X POST ...".
  - Step-by-step natural language: Numbered procedures that explicitly use built-ins.
- **Code is Optional Helper Only**: Any scripts in skills/ folders are run ONLY when SKILL.md explicitly tells the agent via exec. No auto-discovery or index.ts tool exposure.

### Common Anti-Patterns to Avoid

⚠️ **WARNING**: These cause deployment failures:
- Referencing imaginary tools in SOUL.md (e.g., "use scan_ai_news tool").
- Building TypeScript/Node tools expecting automatic registration.
- Writing code-heavy logic without clear prompt wrappers.
- Assuming OpenAI-style function calling or JSON schemas.

### Best Practices

- Always declare dependencies in frontmatter metadata (env vars, python packages, system bins).
- Include concrete command examples and guardrails.
- Tie proactivity (cron, heartbeats) via SOUL.md triggers.
- Reference exemplar skills from Moltbot repo: weather, slack, github, summarize.

---

## EXTERNAL API USAGE – ALWAYS VERIFY FRESHNESS

When any external API (Grok/xAI, Twitter/X, YouTube, etc.) appears in the PRD or plans:

- **ALWAYS start research with the current official documentation and changelog.**
- **Never rely on cached or outdated knowledge** of endpoints, parameters, models, or auth methods.
- The /clawd-plan-phase command includes an automatic API Freshness Sub-Agent.
- Flag any references to deprecated endpoints (e.g., old /v1/chat/completions for xAI).

---

## DEPENDENCY DECLARATION

All skills MUST declare dependencies in SKILL.md frontmatter:

```yaml
metadata:
  clawdbot:
    requires:
      env: ["XAI_API_KEY", "TWITTER_TOKEN"]  # required env vars
      python: ["tweepy>=4.14", "yt-dlp"]     # pip packages
      system: ["ffmpeg", "curl"]             # brew/apt binaries
```

This enables automatic validation during /clawd-validate-phase and auto-install during /clawd-deploy.

---

## CONTEXT EFFICIENCY (CRITICAL)

**Every character in workspace files costs tokens on EVERY conversation.**

### Workspace Files (character limits):
| File | Purpose | Max Chars |
|------|---------|-----------|
| `IDENTITY.md` | Name, emoji, one-liner | **500** |
| `SOUL.md` | Terse behavioral rules only | **3,000** |
| `TOOLS.md` | Environment notes only | **1,500** |
| `AGENTS.md` | Operating instructions | **2,000** |
| `USER.md` | User preferences | **500** |
| `SKILL.md` | Skill docs (on-demand) | **5,000** |

### Planning Documents (line limits):
| Document | Target | Maximum |
|----------|--------|---------|
| `PRD.md` | 600-800 | **1,000 lines** |
| `plan-phase-X.md` | 550-650 | **700 lines** |

**Philosophy: Minimum viable context — everything needed, nothing extra.**

---

## FILE STRUCTURE

```
./
├── docs/                    # PLANNING (NOT deployed)
│   ├── PRD.md               # Requirements
│   ├── STATE.md             # Progress tracking (SOURCE OF TRUTH)
│   ├── CLAUDE.md            # This file (Claude Code rules)
│   └── plans/               # Phase plans
│
└── workspace/               # LIVE AGENT (deployed to Clawdbot)
    ├── SOUL.md              # Behavioral rules
    ├── TOOLS.md             # Environment notes
    ├── skills/              # Custom skills (SKILL.md files)
    └── memory/              # Agent memory
```

**Key distinction:**
- `docs/` = Blueprint (planning, NOT deployed)
- `workspace/` = The house (live config, DEPLOYED)

---

## WORKFLOW COMMANDS

| Command | Purpose |
|---------|---------|
| `/clawd-prime` | Load context, determine current state and next step |
| `/clawd-plan-phase N` | Deep research + planning (spawns sub-agents) |
| `/clawd-execute-phase N` | Implement the plan in workspace/ |
| `/clawd-validate-phase` | Test by copying workspace/ to ~/clawd-dev/ |
| `/clawd-deploy` | Deploy workspace/ to production Mac Mini |

---

## BEST PRACTICES FOR ALL PHASES

1. **Flag tool-calling assumptions early** — if PRD mentions "tool calls", "function schemas", "expose as tool", output a warning.
2. **Use /skill_name or explicit exec/curl/browser/python** — never imaginary tools.
3. **Declare all requires in SKILL.md metadata** — env, python, system.
4. **Escalate approvals/actions to human** — no autonomous destructive actions.
5. **Leverage sub-agents in plan-phase** for exemplar analysis and API freshness.
6. **Check STATE.md** before recommending next steps.
7. **Validate line/char limits** before saving documents.

---

## PROJECT-SPECIFIC CONTEXT

- **Capability**: [CAPABILITY_NAME]
- **PRD Location**: ./docs/PRD.md
- **Current State**: See ./docs/STATE.md

**Key Reminder**: Always reference exemplar skill patterns (weather, slack, github) and use API freshness reports for external integrations.

---

**⚠️ Deviations from these rules must be flagged and corrected immediately.**
CLAUDEEOF

echo "✅ Generated docs/CLAUDE.md with comprehensive global rules and best practices."
```

After generating, replace `[CAPABILITY_NAME]` with the actual capability name:

```bash
# Update CLAUDE.md with capability name
CAPABILITY_NAME="[Extract from user input or PRD]"
sed -i '' "s/\[CAPABILITY_NAME\]/$CAPABILITY_NAME/g" ./docs/CLAUDE.md 2>/dev/null || \
sed -i "s/\[CAPABILITY_NAME\]/$CAPABILITY_NAME/g" ./docs/CLAUDE.md
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

## Step 6: Validate Line Counts (MANDATORY)

**Before finalizing, verify all documents are within limits:**

```bash
echo "=== Line Count Validation ==="

PRD_LINES=$(wc -l < ./docs/PRD.md)
echo "PRD.md: $PRD_LINES lines"

if [ $PRD_LINES -gt 1000 ]; then
    echo "❌ FAILED: PRD exceeds 1000 lines. MUST reduce before proceeding."
    echo "   Target: 600-800 lines. Current: $PRD_LINES"
    exit 1
elif [ $PRD_LINES -gt 800 ]; then
    echo "⚠️ WARNING: PRD is $PRD_LINES lines. Consider trimming."
else
    echo "✅ PASSED: PRD within limit."
fi
```

**If PRD exceeds 1000 lines**: DO NOT PROCEED. Go back and:
1. Convert prose to bullet points
2. Use tables instead of paragraphs
3. Remove redundant explanations
4. Keep phase descriptions to 5-10 lines each
5. If still over: scope is too large, split into multiple capabilities

---

## Final Output Summary

After generating all files:

```
✅ Project initialized!

Structure created:
├── docs/                        # Planning (NOT deployed)
│   ├── PRD.md                   (XX KB)
│   ├── STATE.md                 (XX KB) - Progress tracking
│   ├── CLAUDE.md                (XX KB) - Global rules for Claude Code ⭐
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

Generated docs/CLAUDE.md with comprehensive global rules and best practices.
Claude Code will auto-load this file every session for persistent guidance.

Current State (from docs/STATE.md):
- Phase: 0 of X
- Status: initialized
- Next: Plan Phase 1

Next steps:
1. Review docs/PRD.md
2. Run: /clawd-plan-phase 1
```
