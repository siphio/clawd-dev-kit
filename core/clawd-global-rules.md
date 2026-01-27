# ClawdDev Kit - Global Rules & Conventions

> **Purpose**: This document establishes the conventions, patterns, and rules for developing Clawdbot capabilities using the ClawdDev Kit. All other commands in this kit reference these rules.

---

## 1. Core Philosophy

### 1.1 Prompt-Orchestration First, Code Second

Clawdbot capabilities are primarily built through **prompt orchestration** in SOUL.md and TOOLS.md files, NOT through code. Only create TypeScript skills when built-in tools (browser, shell, cron, memory) are insufficient.

**Decision Tree:**
```
Can this be done with SOUL.md behavioral rules?
  └─ YES → Write orchestration in SOUL.md
  └─ NO → Can this be done with built-in tools (browser/shell)?
           └─ YES → Document tool usage in TOOLS.md
           └─ NO → Is there an MCP server available?
                    └─ YES → Use MCP server, document in TOOLS.md
                    └─ NO → Create TypeScript skill (last resort)
```

### 1.2 Proactivity is Mandatory

Every Clawdbot capability MUST define its proactivity model:
- **Reactive Only**: Responds only when messaged (rare for capabilities)
- **Scheduled Proactive**: Runs on cron schedule (e.g., daily at 9am)
- **Heartbeat Proactive**: Wakes periodically to check conditions
- **Event-Driven**: Triggers on specific events (file change, webhook, etc.)
- **Hybrid**: Combination of above

### 1.3 Persistence Across Restarts

All capability state MUST survive daemon restarts. Use:
- `MEMORY.md` for long-term facts, preferences, decisions
- `memory/YYYY-MM-DD.md` for daily logs and activity
- Never rely on in-memory state for anything important

### 1.4 Human-in-the-Loop Rigor

- **Marley validates every phase** before proceeding
- No capability self-improvement without human approval
- Escalation points defined for when to ask vs. act autonomously

---

## 2. File Structure Conventions

### 2.1 Workspace Structure

```
~/clawd-dev/                    # Local test workspace
├── SOUL.md                     # Agent persona and behavior rules
├── TOOLS.md                    # Tool usage conventions
├── AGENTS.md                   # Operating instructions
├── MEMORY.md                   # Long-term persistent memory
├── IDENTITY.md                 # Agent name, personality, emoji
├── USER.md                     # User profile information
├── memory/                     # Daily logs
│   └── YYYY-MM-DD.md          # One file per day
└── skills/                     # Custom TypeScript skills (if needed)
    └── <skill-name>/
        ├── SKILL.md           # Skill definition with YAML frontmatter
        └── index.ts           # Skill implementation
```

### 2.2 Capability Development Structure

When developing a new capability, create a project folder with this structure:

```
your-capability-project/
│
├── docs/                       # PLANNING (human reference, NOT deployed)
│   ├── PRD.md                  # Product Requirements Document
│   ├── SOUL-additions.md       # Reference copy of SOUL rules
│   ├── TOOLS-additions.md      # Reference copy of tool definitions
│   ├── memory-schema.md        # Memory file specifications
│   ├── test-cases.md           # Validation test cases
│   └── plans/                  # Implementation plans
│       └── plan-phase-X.md     # Per-phase implementation plan
│
├── workspace/                  # LIVE AGENT (deployed to Clawdbot)
│   ├── IDENTITY.md             # Agent identity
│   ├── SOUL.md                 # Complete behavioral rules
│   ├── TOOLS.md                # Complete tool definitions
│   ├── AGENTS.md               # Operating instructions
│   ├── MEMORY.md               # Long-term memory
│   ├── USER.md                 # User preferences
│   ├── memory/                 # Daily memory files (JSON)
│   ├── skills/                 # Custom TypeScript skills
│   │   └── <skill-name>/
│   │       ├── SKILL.md        # Skill manifest
│   │       └── index.ts        # TypeScript implementation
│   └── media/                  # Media assets
│
├── .env                        # Credentials (gitignored)
└── README.md                   # Project documentation
```

**Key distinction:**
- `docs/` = Blueprint (planning, NOT deployed)
- `workspace/` = The house (live config, DEPLOYED)

---

## 3. SOUL.md Conventions

### 3.1 Structure

```markdown
---
name: <Agent Name>
emoji: <emoji>
version: <version>
---

# Persona

<Who the agent is, personality, tone>

# Core Directives

<Primary behavioral rules - what the agent ALWAYS does>

# Capabilities

## <Capability Name>
<Behavioral rules specific to this capability>

### Triggers
<What activates this capability>

### Behavior
<What the agent does when triggered>

### Escalation
<When to ask the human instead of acting>

# Boundaries

<What the agent NEVER does>

# Memory Patterns

<How the agent uses memory for this capability>
```

### 3.2 Writing Effective SOUL.md Rules

**DO:**
- Write in second person ("You are...", "You will...")
- Be specific about triggers and conditions
- Define clear escalation points
- Include examples of expected behavior

**DON'T:**
- Write vague instructions ("be helpful")
- Assume context from previous sessions
- Create rules that conflict with each other
- Forget to define failure modes

### 3.3 Example Capability Section

```markdown
## Daily Briefing Capability

### Triggers
- Heartbeat at 8:00 AM local time
- User message containing "briefing" or "morning update"

### Behavior
When triggered, you will:
1. Check calendar for today's events
2. Review unread priority messages
3. Summarize pending tasks from memory
4. Compose a concise briefing (max 200 words)
5. Send via primary channel (Telegram)

### Escalation
Ask before acting if:
- Calendar shows conflicts requiring resolution
- Priority messages need immediate response decisions
- Tasks are overdue by more than 2 days

### Memory Usage
- Read: MEMORY.md for user preferences, priorities
- Read: memory/YYYY-MM-DD.md for yesterday's activity
- Write: memory/YYYY-MM-DD.md to log briefing sent
```

---

## 4. TOOLS.md Conventions

### 4.1 Structure

```markdown
# Tool Conventions

## Browser Tool
<When and how to use browser automation>

## Shell Tool
<When and how to use shell commands>

## Memory Tool
<Patterns for reading/writing memory>

## <MCP Server Name>
<How to use specific MCP tools>
```

### 4.2 Example Tool Convention

```markdown
## Instantly MCP

### Available Tools
- `mcp__instantly__create_lead` - Add lead to campaign
- `mcp__instantly__get_campaigns` - List active campaigns
- `mcp__instantly__send_email` - Send individual email

### Usage Patterns
- Always check campaign exists before adding leads
- Rate limit: Max 100 leads per minute
- Log all lead additions to daily memory

### Error Handling
- If API returns 429, wait 60 seconds and retry
- If campaign not found, escalate to human
- Log all errors to memory with timestamp
```

---

## 5. Memory Conventions

### 5.1 MEMORY.md (Long-term)

Use for:
- User preferences that rarely change
- Important decisions and their rationale
- Capability configurations
- Contact information and relationships

Format:
```markdown
## User Preferences
- Preferred communication channel: Telegram
- Timezone: Europe/London
- Working hours: 9am-6pm

## Capability: X Growth
- Target audience: AI automation professionals
- Posting schedule: Tue/Thu/Sat at 10am
- Content pillars: tutorials, insights, announcements

## Key Decisions
- 2026-01-15: Decided to focus on B2B clients only
- 2026-01-20: Approved automated DM responses for inquiries
```

### 5.2 Daily Logs (memory/YYYY-MM-DD.md)

Use for:
- Activity tracking
- Temporary state
- Debug information
- Audit trail

Format:
```markdown
# 2026-01-26

## Activity Log
- 08:00 - Heartbeat triggered, sent morning briefing
- 10:00 - Posted to X: "Thread about AI automation..."
- 10:15 - Received 3 new DMs, queued for review
- 14:30 - User requested capability update, escalated

## Errors
- 10:02 - X API rate limit hit, retried after 60s

## Notes
- User mentioned wanting to add LinkedIn posting next week
```

---

## 6. Skill Development Conventions

### 6.1 When to Create a Skill

Create a TypeScript skill ONLY when:
- Built-in tools cannot accomplish the task
- No MCP server exists for the integration
- Complex data transformation is required
- Performance requires compiled code

### 6.2 Skill Structure

```
skills/<skill-name>/
├── SKILL.md           # Required: Skill definition
├── index.ts           # Required: Main implementation
├── types.ts           # Optional: TypeScript types
├── utils.ts           # Optional: Helper functions
└── README.md          # Optional: Development notes
```

### 6.3 SKILL.md Format

```markdown
---
name: <skill-name>
description: <one-line description>
version: 1.0.0
author: <your-name>
requires:
  - node: ">=22"
  - binary: "ffmpeg"  # if needed
  - env: "INSTANTLY_API_KEY"  # if needed
---

# <Skill Name>

## Purpose
<What this skill does and why it exists>

## Tools Provided
- `tool_name_1` - <description>
- `tool_name_2` - <description>

## Usage Examples
<Examples of how the agent should use this skill>

## Configuration
<Any required environment variables or setup>
```

### 6.4 TypeScript Conventions

- Use strict TypeScript (no `any` types)
- Use ESM modules
- Format with Oxfmt, lint with Oxlint
- Include JSDoc comments for all exported functions
- Handle errors gracefully, never throw unhandled

---

## 7. Validation Conventions

### 7.1 Test Case Format

Every capability must have test cases defined:

```markdown
## Test Cases

### TC-001: Basic Trigger
- **Input**: "Send me my morning briefing"
- **Expected Output Contains**: ["calendar", "tasks", "messages"]
- **Expected Action**: Memory write to daily log
- **Expected Tool Calls**: browser (calendar), memory (read/write)

### TC-002: Proactive Trigger
- **Trigger**: Heartbeat at configured time
- **Expected Output**: Briefing sent to primary channel
- **Expected Memory**: Daily log entry created

### TC-003: Escalation
- **Input**: "Cancel all my meetings today"
- **Expected Behavior**: Ask for confirmation before acting
- **Should NOT**: Automatically cancel without approval
```

### 7.2 Validation Levels

All capabilities must pass these validation levels:

1. **Static**: YAML parses, TypeScript compiles
2. **Injection**: SOUL.md loads into agent context
3. **Logic**: Test cases pass with expected outputs
4. **Proactivity**: Cron/heartbeat triggers work
5. **Persistence**: State survives daemon restart
6. **Error Handling**: Graceful failure, proper escalation
7. **Integration**: Full end-to-end workflow

---

## 8. Deployment Conventions

### 8.1 Environment Separation

| Environment | Location | Purpose |
|-------------|----------|---------|
| Development | `~/clawd-dev/` on Mac/Windows | Testing, iteration |
| Production | `~/clawd/` on Mac Mini | 24/7 autonomous operation |

### 8.2 Deployment Flow

```
Development → Validation → Git Commit → Git Push → SSH Pull on Mini → Daemon Restart
```

### 8.3 Rollback Policy

- Always tag releases before deployment
- Keep last 5 deployment backups
- Rollback via Git checkout + daemon restart
- Never manually edit production files

---

## 9. Archon Integration Conventions

### 9.1 RAG Queries

Always query Archon for technology documentation before implementation:

```
# Check available sources
mcp__archon__rag_get_available_sources()

# Query knowledge base (concepts, patterns)
mcp__archon__rag_search_knowledge_base(
    query="<technology> <specific-topic>",
    source_id="<source-id>",
    match_count=10
)

# Query code examples
mcp__archon__rag_search_code_examples(
    query="<technology> <implementation-pattern>",
    source_id="<source-id>",
    match_count=5
)
```

### 9.2 Task Management

Use Archon for tracking capability development:

```
# Create project for capability
mcp__archon__manage_project("create", title="Capability: <name>")

# Create tasks from plan
mcp__archon__manage_task("create", project_id=..., title="...", status="todo")

# Update task status as you progress
mcp__archon__manage_task("update", task_id=..., status="doing|review|done")
```

---

## 10. Security Conventions

### 10.1 Secrets Management

- Never commit secrets to Git
- Store in `.env` file (gitignored)
- Reference via environment variables
- Rotate keys if accidentally exposed

### 10.2 SSH Keys

- Use dedicated keys for Clawdbot deployment
- Store key path in `.env` as `CLAWD_MINI_SSH_KEY`
- Never share keys with framework distribution

### 10.3 API Keys

- Store in Clawdbot's credential system or `.env`
- Never hardcode in SOUL.md or skills
- Validate presence before capability execution

---

## 11. Naming Conventions

### 11.1 Capabilities

- Use kebab-case: `x-growth-scout`, `daily-briefing`
- Prefix with domain: `social-x-poster`, `email-instantly-sender`

### 11.2 Skills

- Use kebab-case matching capability: `instantly-api`, `x-api-extended`

### 11.3 Memory Keys

- Use descriptive prefixes: `capability:x-growth:last-post-time`
- Date format: ISO 8601 (`2026-01-26T10:00:00Z`)

### 11.4 Cron Jobs

- Name format: `capability-name:trigger-type`
- Example: `x-growth:daily-post`, `briefing:morning`

---

## 12. Documentation Conventions

### 12.1 PRD Requirements

Every capability PRD must include:
- Executive Summary
- Proactivity Map (when does it run?)
- Orchestration Layer (how does it decide?)
- Autonomy Profile (what can it do without asking?)
- Memory Schema (what does it remember?)
- Test Cases (how do we validate?)
- Rollback Plan (how do we undo?)

### 12.2 Plan Requirements

Every implementation plan must include:
- Research synthesis from Archon/sub-agents
- SOUL.md additions (exact text)
- TOOLS.md additions (exact text)
- Cron configuration
- Memory schema
- Validation commands (executable)
- Estimated tasks with time

---

## Summary Checklist

Before considering any capability complete:

- [ ] SOUL.md additions written and validated
- [ ] TOOLS.md conventions documented
- [ ] Proactivity configured (cron/heartbeat)
- [ ] Memory schema defined and tested
- [ ] All validation levels passed
- [ ] Tested on local Clawdbot instance
- [ ] Restart persistence verified
- [ ] Error handling and escalation tested
- [ ] Documentation complete
- [ ] Git committed with proper message
- [ ] Deployed to production via /clawd-deploy
- [ ] Post-deployment health check passed
