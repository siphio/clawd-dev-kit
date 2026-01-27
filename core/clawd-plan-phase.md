---
description: Deep planning for Clawdbot capability with sub-agent research
argument-hint: [capability-name]
---

# Clawdbot Capability Planning Phase

You are creating a comprehensive implementation plan for a Clawdbot capability. This is the most critical phase - the plan must contain ALL information needed for one-pass implementation.

## Critical Context

**MANDATORY READS**:
1. `clawd-global-rules.md` - Development conventions
2. `./docs/PRD.md` - Requirements (in current project folder)
3. `./workspace/` - Current implementation state

**Planning Principles**:
- "Context is King" - Plans must be self-contained
- No code during planning - Research and design only
- Sub-agents handle deep research in parallel
- Human validates before execution begins
- Target: 500-700 lines of dense, actionable content

---

## Phase 1: Capability Understanding (Main Agent)

### 1.1 Load Context

Read all context documents:
- `./docs/PRD.md` - Product requirements
- `./workspace/SOUL.md` - Current agent rules (if exists)
- `./workspace/TOOLS.md` - Current tools (if exists)

### 1.2 Extract Planning Requirements

From the PRD, identify:

**Orchestration Requirements:**
- What SOUL.md rules need to be written?
- What decision logic must the agent follow?
- What triggers activate this capability?

**Proactivity Requirements:**
- Cron expressions needed
- Heartbeat logic needed
- Event triggers needed

**Integration Requirements:**
- APIs to integrate
- MCP servers to use
- Built-in tools to leverage

**Memory Requirements:**
- What to store in MEMORY.md
- What to log in daily files
- What to read on each trigger

**Validation Requirements:**
- Test cases from PRD
- Expected behaviors to verify

---

## Phase 2: Workspace Intelligence (Main Agent)

### 2.1 Analyze Existing Patterns

Deep analysis of `~/clawd-dev/`:

```bash
# Full SOUL.md analysis
cat ~/clawd-dev/SOUL.md

# Full TOOLS.md analysis
cat ~/clawd-dev/TOOLS.md

# Check for similar capability patterns
grep -r "[relevant-keywords]" ~/clawd-dev/

# Analyze memory patterns
cat ~/clawd-dev/MEMORY.md
ls -la ~/clawd-dev/memory/
cat ~/clawd-dev/memory/$(date +%Y-%m-%d).md 2>/dev/null || echo "No log for today"

# Check existing skills
ls -la ~/clawd-dev/skills/
```

### 2.2 Identify Integration Points

Document:
- Where in SOUL.md should new capability section go?
- What existing patterns to follow/match?
- Any conflicts with existing capabilities?
- Shared memory sections to be aware of?

---

## Phase 3: External Intelligence Gathering (Sub-Agents)

### CRITICAL: Spawn Research Sub-Agents in Parallel

Based on technologies identified in the PRD, spawn specialized research agents.

---

### Sub-Agent 1: Clawdbot Deep Research

```
Task(
    subagent_type="Explore",
    description="Research Clawdbot patterns",
    prompt="""
    Deep research on Clawdbot patterns for capability: [capability-name]

    ## Your Mission
    Research Clawdbot documentation to find the best patterns for this capability.

    ## MANDATORY Archon Queries

    ### 1. SOUL.md Patterns
    mcp__archon__rag_search_knowledge_base(
        query="SOUL.md capability section triggers behavior escalation",
        source_id="clawdbot-docs",
        match_count=10
    )

    ### 2. Proactivity Patterns
    mcp__archon__rag_search_knowledge_base(
        query="[cron|heartbeat] proactive scheduling autonomous behavior",
        source_id="clawdbot-docs",
        match_count=10
    )

    ### 3. Memory Patterns
    mcp__archon__rag_search_knowledge_base(
        query="MEMORY.md daily log persistence read write patterns",
        source_id="clawdbot-docs",
        match_count=10
    )

    ### 4. Tool Usage Patterns
    mcp__archon__rag_search_knowledge_base(
        query="[browser|shell|specific-tool] automation patterns",
        source_id="clawdbot-docs",
        match_count=10
    )

    ### 5. Skill Structure (if custom skill needed)
    mcp__archon__rag_search_code_examples(
        query="TypeScript skill SKILL.md structure implementation",
        source_id="clawdbot-docs",
        match_count=5
    )

    ## If Documentation Missing
    Use WebFetch to research:
    - https://docs.clawd.bot/concepts/agent-workspace
    - https://docs.clawd.bot/concepts/memory
    - https://docs.clawd.bot/tools/browser
    - https://docs.clawd.bot/tools/skills

    ## Return Format

    ### SOUL.md Patterns Found
    - [Pattern 1 with example]
    - [Pattern 2 with example]

    ### Proactivity Patterns Found
    - [Cron patterns]
    - [Heartbeat patterns]

    ### Memory Patterns Found
    - [MEMORY.md structure]
    - [Daily log format]

    ### Tool Usage Examples
    - [Relevant tool examples]

    ### Skill Structure (if needed)
    - [SKILL.md format]
    - [TypeScript patterns]

    ### Recommendations
    - [Specific recommendations for this capability]
    """
)
```

---

### Sub-Agent 2: Technology API Research

**Spawn one sub-agent per external technology** identified in the PRD.

```
Task(
    subagent_type="Explore",
    description="Research [Technology] API",
    prompt="""
    Deep research on [Technology Name] API for Clawdbot capability.

    ## Your Mission
    Gather all information needed to integrate [Technology] into a Clawdbot capability.

    ## MANDATORY Archon Queries

    ### 1. Authentication
    mcp__archon__rag_search_knowledge_base(
        query="[technology] API authentication OAuth API key bearer token",
        source_id="[technology]-docs",
        match_count=10
    )

    ### 2. Required Endpoints
    Based on PRD requirements, research these operations:
    - [Operation 1 from PRD]
    - [Operation 2 from PRD]

    mcp__archon__rag_search_knowledge_base(
        query="[technology] API [operation] endpoint",
        source_id="[technology]-docs",
        match_count=10
    )

    ### 3. Code Examples
    mcp__archon__rag_search_code_examples(
        query="[technology] [specific-implementation]",
        source_id="[technology]-docs",
        match_count=5
    )

    ### 4. Rate Limits & Constraints
    mcp__archon__rag_search_knowledge_base(
        query="[technology] rate limit quota throttling",
        source_id="[technology]-docs",
        match_count=5
    )

    ### 5. Error Handling
    mcp__archon__rag_search_knowledge_base(
        query="[technology] API error codes handling retry",
        source_id="[technology]-docs",
        match_count=5
    )

    ## If Documentation Not in Archon
    Use WebFetch to research official documentation:
    - [Official API docs URL]
    - [Developer portal URL]

    ## Return Format

    ### Authentication
    - Method: [OAuth 2.0 / API Key / Bearer Token]
    - Required credentials: [list]
    - Token refresh: [if applicable]
    - Storage recommendation: [.env key name]

    ### Endpoints Required
    | Endpoint | Method | Purpose | Parameters |
    |----------|--------|---------|------------|
    | [endpoint] | [GET/POST] | [purpose] | [params] |

    ### Code Examples
    ```typescript
    // Example for [operation]
    [code example]
    ```

    ### Rate Limits
    - Limit: [X requests per Y time]
    - Handling: [queue/retry/backoff strategy]

    ### Error Handling
    | Error Code | Meaning | Response |
    |------------|---------|----------|
    | [code] | [meaning] | [how to handle] |

    ### Gotchas & Edge Cases
    - [Gotcha 1]
    - [Gotcha 2]
    """
)
```

---

### Sub-Agent 3: MCP Server Research

```
Task(
    subagent_type="Explore",
    description="Research MCP servers",
    prompt="""
    Research MCP servers relevant to capability: [capability-name]

    ## Your Mission
    Find available MCP servers that could simplify implementation.

    ## Archon Queries

    ### 1. Search for relevant MCP servers
    mcp__archon__rag_search_knowledge_base(
        query="[technology] MCP server tools",
        source_id="mcp-servers-docs",
        match_count=10
    )

    ### 2. Get tool definitions
    mcp__archon__rag_search_code_examples(
        query="[mcp-server] tool parameters schema",
        source_id="[mcp-server]-docs",
        match_count=5
    )

    ## Also Search
    - GitHub for "[technology] MCP server"
    - MCP server registries

    ## Return Format

    ### Available MCP Servers
    | Server Name | Tools Provided | Status |
    |-------------|---------------|--------|
    | [name] | [tools] | [available/needs-setup] |

    ### Tool Definitions
    For each relevant MCP server:

    #### [MCP Server Name]

    **Tool: [tool_name]**
    - Purpose: [what it does]
    - Parameters: [param definitions]
    - Returns: [return type]
    - Example usage:
    ```
    mcp__[server]__[tool](param1="value", param2="value")
    ```

    ### Recommendation
    - Use MCP: [Yes/No]
    - Reason: [why MCP is better or why direct API is needed]
    - Setup required: [any configuration needed]
    """
)
```

---

### Sub-Agent 4: Similar Capabilities Research

```
Task(
    subagent_type="Explore",
    description="Research similar capabilities",
    prompt="""
    Search for existing Clawdbot capabilities similar to: [capability-name]

    ## Search Locations
    1. ClawdHub skill registry
    2. Clawdbot GitHub discussions/issues
    3. Community examples
    4. Archon knowledge base

    ## Archon Query
    mcp__archon__rag_search_knowledge_base(
        query="[capability-type] capability skill example",
        source_id="clawdbot-docs",
        match_count=10
    )

    ## Web Search
    Search for:
    - "Clawdbot [capability-type] skill"
    - "Clawdbot [technology] integration"

    ## Return Format

    ### Similar Capabilities Found
    | Name | Source | Relevance |
    |------|--------|-----------|
    | [name] | [ClawdHub/GitHub/etc] | [high/medium/low] |

    ### Reusable Patterns
    - [Pattern 1 from similar capability]
    - [Pattern 2 from similar capability]

    ### Anti-Patterns to Avoid
    - [What didn't work in similar implementations]

    ### Lessons Learned
    - [Insight 1]
    - [Insight 2]
    """
)
```

---

## Phase 4: Research Synthesis (Main Agent)

### 4.1 Wait for All Sub-Agents

Collect results from all spawned sub-agents.

### 4.2 Synthesize Findings

Compile into unified research summary:

```markdown
## Research Synthesis

### Clawdbot Patterns (Sub-Agent 1)
[Key findings]

### [Technology] Integration (Sub-Agent 2)
[Key findings for each technology]

### MCP Availability (Sub-Agent 3)
[Key findings]

### Similar Capabilities (Sub-Agent 4)
[Key findings]

### Implementation Decision Matrix

| Component | Approach | Rationale |
|-----------|----------|-----------|
| Orchestration | SOUL.md rules | [why] |
| [Technology] | MCP / Direct API | [why] |
| Proactivity | Cron / Heartbeat | [why] |
| Custom Code | Skill / None | [why] |
```

---

## Phase 5: Strategic Thinking (Main Agent)

### 5.1 Orchestration Design

Draft the SOUL.md additions with complete behavioral rules:

```markdown
## SOUL.md Additions

### [Capability Name]

#### Triggers
- [Trigger 1]: [condition]
- [Trigger 2]: [condition]

#### Behavior
When triggered, you will:
1. [Step 1 with specific details]
2. [Step 2 with specific details]
3. [Step 3 with specific details]

#### Decision Logic
```
[Decision tree or flowchart in text]
```

#### Constraints
- [Constraint 1]
- [Constraint 2]

#### Escalation Points
Ask before acting if:
- [Condition 1]
- [Condition 2]

#### Memory Access
- Read: [what and when]
- Write: [what and when]
```

### 5.2 TOOLS.md Additions

Draft tool conventions:

```markdown
## TOOLS.md Additions

### [Tool/MCP Name]

#### Available Tools
- `[tool_name]` - [purpose]

#### Usage Conventions
- [Convention 1]
- [Convention 2]

#### Error Handling
- [Error type]: [response]

#### Rate Limiting
- [Limit and handling strategy]
```

### 5.3 Proactivity Configuration

Design cron/heartbeat setup:

```markdown
## Proactivity Configuration

### Cron Jobs
| Job Name | Expression | Action |
|----------|------------|--------|
| [name] | [cron expr] | [what it triggers] |

### Heartbeat Rules (if applicable)
- Check interval: [duration]
- Condition: [what to check]
- Action: [what to do if condition met]

### Quiet Hours
- Hours: [range]
- Behavior: [queue/skip/etc]
```

### 5.4 Memory Schema

Design memory structure:

```markdown
## Memory Schema

### MEMORY.md Section
```markdown
## Capability: [Name]

### Configuration
- [config-key]: [default-value]

### State
- [state-key]: [initial-value]
```

### Daily Log Format
```markdown
## [Capability Name] Activity

### [HH:MM]
- Action: [template]
- Result: [template]
```
```

### 5.5 Skill Specification (If Needed)

If custom skill is required, provide COMPLETE specifications including TypeScript code:

```markdown
## Skill Specification

### Skill Structure
```
workspace/skills/[skill-name]/
├── SKILL.md           # Skill manifest
├── index.ts           # TypeScript implementation
├── types.ts           # Optional: Type definitions
└── utils.ts           # Optional: Helper functions
```

### SKILL.md Content
```markdown
---
name: [skill-name]
description: [description]
version: 1.0.0
author: [author]
requires:
  - node: ">=22"
  - env: "[ENV_VAR_1]"
  - env: "[ENV_VAR_2]"
---

# [Skill Name]

## Purpose
[Why this skill exists - what problem it solves]

## Tools Provided
- `[tool_name_1]` - [description]
- `[tool_name_2]` - [description]

## Usage Examples
```typescript
// Example usage of each tool
const result = await tool_name_1({ param: "value" });
```

## Configuration
- `[ENV_VAR_1]` - [what it's for]
- `[ENV_VAR_2]` - [what it's for]
```

### index.ts Implementation (REQUIRED)

Provide the ACTUAL TypeScript code that will be executed:

```typescript
// workspace/skills/[skill-name]/index.ts

import { z } from "zod";

// ============================================================
// TYPES
// ============================================================

interface [TypeName] {
  [property]: [type];
}

// ============================================================
// TOOL: [tool_name_1]
// ============================================================

export const [tool_name_1] = {
  name: "[tool_name_1]",
  description: "[What this tool does]",
  parameters: z.object({
    [param_name]: z.[type]().describe("[description]"),
  }),

  async execute(params: { [param_name]: [type] }): Promise<[ReturnType]> {
    // Check for required env vars
    const apiKey = process.env.[ENV_VAR];
    if (!apiKey) {
      return { success: false, error: "[ENV_VAR] not configured" };
    }

    try {
      // Implementation
      [actual implementation code]

      return { success: true, data: [result] };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
};

// ============================================================
// TOOL: [tool_name_2]
// ============================================================

export const [tool_name_2] = {
  // ... similar structure
};

// ============================================================
// EXPORTS
// ============================================================

export default {
  [tool_name_1],
  [tool_name_2],
};
```

### TypeScript Requirements
- Use strict TypeScript (no `any` types where possible)
- Use Zod for parameter validation
- Handle all errors gracefully (never throw unhandled)
- Use ESM modules
- Include proper return types
```

---

## Phase 6: Plan Generation (Main Agent)

### 6.1 Task Breakdown

Create atomic, actionable tasks:

```markdown
## Implementation Tasks

### Stage 1: Orchestration Setup
| Task ID | Description | Files | Validation |
|---------|-------------|-------|------------|
| T1.1 | Add capability section to SOUL.md | SOUL.md | Section exists, YAML valid |
| T1.2 | Add tool conventions to TOOLS.md | TOOLS.md | Conventions documented |
| T1.3 | Initialize memory schema | MEMORY.md | Schema section exists |

### Stage 2: Proactivity Configuration
| Task ID | Description | Files | Validation |
|---------|-------------|-------|------------|
| T2.1 | Configure cron job | cron config | `clawdbot cron list` shows job |
| T2.2 | Set up heartbeat rules | SOUL.md | Rules in behavior section |

### Stage 3: Integration Setup
| Task ID | Description | Files | Validation |
|---------|-------------|-------|------------|
| T3.1 | Configure [technology] credentials | .env | Credentials accessible |
| T3.2 | Set up MCP server connection | config | MCP tools available |

### Stage 4: Skill Development (if needed)
| Task ID | Description | Files | Validation |
|---------|-------------|-------|------------|
| T4.1 | Create skill folder | workspace/skills/[name]/ | Folder exists |
| T4.2 | Create SKILL.md manifest | workspace/skills/[name]/SKILL.md | Valid YAML frontmatter |
| T4.3 | Implement index.ts | workspace/skills/[name]/index.ts | `npx tsc --noEmit` passes |
| T4.4 | Test skill tools | - | Tools callable via clawdbot |

### Stage 5: Testing & Validation
| Task ID | Description | Files | Validation |
|---------|-------------|-------|------------|
| T5.1 | Run test case TC-001 | - | Expected output |
| T5.2 | Run test case TC-002 | - | Expected output |
| T5.3 | Run persistence test | - | State survives restart |
| T5.4 | Run escalation test | - | Asks when should |
```

### 6.2 Exact File Contents

For each file that needs to be created or modified, provide EXACT content:

```markdown
## File Contents

### SOUL.md Additions
```markdown
[EXACT TEXT TO ADD TO workspace/SOUL.md]
```

### TOOLS.md Additions
```markdown
[EXACT TEXT TO ADD TO workspace/TOOLS.md]
```

### MEMORY.md Additions
```markdown
[EXACT TEXT TO ADD TO workspace/MEMORY.md]
```

### Skill Files (if needed)

**IMPORTANT**: Skills require BOTH SKILL.md AND index.ts

#### workspace/skills/[skill-name]/SKILL.md
```markdown
---
name: [skill-name]
description: [description]
version: 1.0.0
requires:
  - env: "[ENV_VAR]"
---

[Full SKILL.md content...]
```

#### workspace/skills/[skill-name]/index.ts
```typescript
import { z } from "zod";

// [Full TypeScript implementation...]
// This must be ACTUAL WORKING CODE, not pseudocode

export const [tool_name] = {
  name: "[tool_name]",
  description: "[description]",
  parameters: z.object({ ... }),
  async execute(params) {
    // Actual implementation
  },
};

export default { [tool_name] };
```

### Memory Files (if needed)

#### workspace/memory/[filename].json
```json
{
  "schema_version": "1.0",
  "last_updated": "[timestamp]",
  [Initial data structure...]
}
```
```

### 6.3 Validation Commands

Executable commands to validate each stage:

```markdown
## Validation Commands

### Stage 1 Validation
```bash
# Check SOUL.md is valid
python3 -c "import yaml; yaml.safe_load(open('$HOME/clawd-dev/SOUL.md').read().split('---')[1])"

# Verify capability section exists
grep -q "[Capability Name]" ~/clawd-dev/SOUL.md && echo "PASS" || echo "FAIL"
```

### Stage 2 Validation
```bash
# Check cron is configured
clawdbot cron list | grep "[job-name]" && echo "PASS" || echo "FAIL"
```

### Stage 3 Validation
```bash
# Test MCP connection
clawdbot agent --message "List available [mcp-server] tools" --thinking low
```

### Stage 5 Validation
```bash
# Run test case TC-001
result=$(clawdbot agent --message "[test-input]" --thinking low)
echo "$result" | grep -q "[expected-content]" && echo "TC-001 PASS" || echo "TC-001 FAIL"
```
```

---

## Phase 7: Plan Output

### 7.1 Save Plan Document

Save the complete plan to:
```
./docs/plans/plan-phase-[X].md
```

Where [X] is the phase number (e.g., `plan-phase-1.md`, `plan-phase-2.md`).

### 7.2 Plan Summary

Generate executive summary:

```markdown
## Plan Summary

**Capability**: [Name]
**Total Tasks**: [count]
**Estimated Stages**: [count]
**Custom Skill Required**: [Yes/No]
**MCP Servers Used**: [list]

### Key Decisions
- [Decision 1]
- [Decision 2]

### Risks Identified
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

### Dependencies
- [Dependency 1]
- [Dependency 2]
```

---

## Phase 8: Human Validation Checkpoint

Present the plan to the user:

1. **Review SOUL.md additions** - Do the behavioral rules look correct?
2. **Review proactivity configuration** - Is the schedule/triggers correct?
3. **Review task breakdown** - Are tasks atomic and clear?
4. **Review validation commands** - Will these adequately test the capability?
5. **Confirm dependencies** - Are all credentials and MCP servers available?

**DO NOT proceed to execution until the user explicitly approves the plan.**

---

## Output Checklist

Before proceeding to `/clawd-execute-phase`:

- [ ] All sub-agent research completed
- [ ] Research synthesized
- [ ] SOUL.md additions drafted
- [ ] TOOLS.md additions drafted
- [ ] Proactivity configured
- [ ] Memory schema defined
- [ ] Skill specified (if needed)
- [ ] Tasks broken down with validation commands
- [ ] Exact file contents provided
- [ ] Plan saved to capabilities folder
- [ ] User has approved the plan

---

## Next Steps

Once plan is approved:
```
/clawd-execute-phase [capability-name]
```
