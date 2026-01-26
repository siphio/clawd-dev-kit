---
description: Prime context for Clawdbot capability development with Archon RAG research
argument-hint: [capability-name]
---

# Prime Context for Clawdbot Capability Development

You are preparing to develop a Clawdbot capability. This command loads all necessary context and performs initial research using Archon RAG.

## Critical Context

**Read First**: Review the global conventions:
- `clawd-global-rules.md` - Development conventions and patterns

---

## Step 1: Load Capability PRD

### 1.1 Locate PRD

Read the PRD for the specified capability:

```
~/clawd-dev-kit/capabilities/$ARGUMENTS/PRD.md
```

If PRD doesn't exist:
- Stop and instruct user to run `/clawd-create-prd [capability-name]` first
- Do not proceed without an approved PRD

### 1.2 Extract Key Information

From the PRD, extract and summarize:

**Capability Overview:**
- Name: [from PRD]
- One-line description: [from PRD]
- Proactivity model: [Scheduled/Event-Driven/Heartbeat/Reactive/Hybrid]

**Technology Stack:**
- External services needed: [list from PRD Section 6]
- MCP servers available: [list]
- Built-in tools needed: [Browser/Shell/Memory/Cron]

**Integration Points:**
- APIs: [list with auth methods]
- Credentials required: [list]

---

## Step 2: Analyze Existing Clawdbot Workspace

### 2.1 Check Development Workspace

Analyze `~/clawd-dev/` to understand current state:

```bash
# Check if workspace exists
ls -la ~/clawd-dev/

# Read current SOUL.md patterns
cat ~/clawd-dev/SOUL.md

# Read current TOOLS.md conventions
cat ~/clawd-dev/TOOLS.md

# Check existing capabilities
cat ~/clawd-dev/AGENTS.md

# Review memory structure
ls -la ~/clawd-dev/memory/

# Check existing skills
ls -la ~/clawd-dev/skills/
```

### 2.2 Document Current Patterns

Summarize:
- Existing SOUL.md structure and patterns
- Current TOOLS.md conventions
- Memory patterns in use
- Existing skills that might be relevant
- Any conflicts or considerations for new capability

---

## Step 3: Archon RAG Research

### 3.1 Check Available Documentation Sources

Query Archon for available documentation:

```
mcp__archon__rag_get_available_sources()
```

Document which sources are available:
- [ ] `clawdbot-docs` - Clawdbot official documentation
- [ ] `x-api-docs` - X/Twitter API (if needed)
- [ ] `instantly-api-docs` - Instantly.ai API (if needed)
- [ ] `[other-relevant-sources]`

### 3.2 Research Clawdbot Patterns

**MANDATORY**: Query Clawdbot documentation for relevant patterns:

```
# SOUL.md orchestration patterns
mcp__archon__rag_search_knowledge_base(
    query="SOUL.md behavioral rules orchestration persona",
    source_id="clawdbot-docs",
    match_count=10
)

# Proactivity patterns (based on PRD proactivity model)
mcp__archon__rag_search_knowledge_base(
    query="[cron|heartbeat|proactive] scheduling triggers",
    source_id="clawdbot-docs",
    match_count=10
)

# Memory persistence patterns
mcp__archon__rag_search_knowledge_base(
    query="MEMORY.md daily log persistence patterns",
    source_id="clawdbot-docs",
    match_count=10
)

# Built-in tool patterns (based on PRD requirements)
mcp__archon__rag_search_knowledge_base(
    query="[browser|shell|cron] tool usage",
    source_id="clawdbot-docs",
    match_count=10
)
```

### 3.3 Research Required Technologies

For EACH external service identified in the PRD, query Archon:

**Template for each technology:**

```
# Check if documentation is available
# If source exists, run these queries:

# Authentication patterns
mcp__archon__rag_search_knowledge_base(
    query="[technology] API authentication OAuth API key",
    source_id="[technology]-docs",
    match_count=10
)

# Relevant endpoints/operations
mcp__archon__rag_search_knowledge_base(
    query="[technology] [specific-operations-from-PRD]",
    source_id="[technology]-docs",
    match_count=10
)

# Code examples
mcp__archon__rag_search_code_examples(
    query="[technology] [implementation-pattern]",
    source_id="[technology]-docs",
    match_count=5
)

# Rate limits and constraints
mcp__archon__rag_search_knowledge_base(
    query="[technology] rate limit throttling constraints",
    source_id="[technology]-docs",
    match_count=5
)
```

### 3.4 Research MCP Servers

If the PRD mentions MCP servers:

```
# Search for MCP server documentation
mcp__archon__rag_search_knowledge_base(
    query="[service-name] MCP server tools",
    source_id="mcp-servers-docs",
    match_count=10
)

# Get tool definitions
mcp__archon__rag_search_code_examples(
    query="[mcp-server] tool parameters usage",
    source_id="[mcp-server]-docs",
    match_count=5
)
```

### 3.5 Handle Missing Documentation

If required documentation is NOT in Archon:

1. **Note the gap**: Document which sources are missing
2. **Flag for browser research**: Mark for sub-agent research in planning phase
3. **Suggest indexing**: Recommend adding source to Archon for future use

```markdown
## Missing Documentation

The following sources are not available in Archon and will require browser research:
- [ ] [Service Name] - [URL to official docs]
- [ ] [Service Name] - [URL to official docs]

**Recommendation**: After capability is complete, index these sources:
mcp__archon__rag_add_source(
    name="[service]-docs",
    url="[documentation-url]",
    type="documentation"
)
```

---

## Step 4: Generate Context Summary

Compile all research into a structured context document:

```markdown
# Capability Context: [Capability Name]

## PRD Summary
- **Description**: [one-line]
- **Proactivity**: [model]
- **Key Integrations**: [list]

## Existing Workspace Patterns

### Current SOUL.md Structure
[Summary of existing patterns to match]

### Current TOOLS.md Conventions
[Summary of conventions to follow]

### Existing Relevant Skills
[Any skills that might be reusable or relevant]

## Technology Research (Archon RAG)

### Clawdbot Patterns
- **SOUL.md**: [key patterns found]
- **Proactivity**: [relevant patterns]
- **Memory**: [persistence patterns]
- **Tools**: [usage patterns]

### [Technology 1] Research
- **Authentication**: [method and requirements]
- **Key Endpoints**: [list with purposes]
- **Rate Limits**: [constraints]
- **Code Patterns**: [examples found]

### [Technology 2] Research
[Same structure]

### MCP Server Availability
- **Available**: [list of available MCP servers]
- **Tools Provided**: [list of relevant tools]
- **Recommendation**: [use MCP vs direct API]

## Missing Documentation
[List of sources not in Archon that need browser research]

## Integration Considerations
- [Consideration 1: e.g., "Rate limit of 100 requests/min will require queuing"]
- [Consideration 2: e.g., "OAuth refresh tokens need secure storage"]
- [Consideration 3: e.g., "Existing X capability might conflict with posting schedule"]

## Ready for Planning
- [ ] PRD approved
- [ ] Workspace analyzed
- [ ] Clawdbot patterns researched
- [ ] Technology documentation gathered
- [ ] MCP availability confirmed
- [ ] Missing docs flagged for browser research
```

---

## Step 5: Save Context Document

Save the context summary to:

```
~/clawd-dev-kit/capabilities/[capability-name]/context.md
```

---

## Step 6: Human Checkpoint

Present the context summary to the user:

1. **Confirm research is complete** for all required technologies
2. **Highlight any missing documentation** that needs browser research
3. **Note any potential conflicts** with existing capabilities
4. **Identify any blockers** before planning can begin

**Questions for user:**
- Is any critical documentation missing from Archon that we should index first?
- Are there any existing capabilities that might conflict with this one?
- Any additional context I should gather before planning?

---

## Output Checklist

Before proceeding to `/clawd-plan-phase`:

- [ ] PRD loaded and summarized
- [ ] Existing workspace patterns documented
- [ ] Clawdbot documentation researched via Archon
- [ ] All technology APIs researched via Archon
- [ ] MCP server availability confirmed
- [ ] Missing documentation flagged
- [ ] Context document saved
- [ ] User has validated context is complete

---

## Next Steps

Once context is validated:
```
/clawd-plan-phase [capability-name]
```

The planning phase will:
1. Load this context document
2. Spawn sub-agents for deep research (including browser for missing docs)
3. Generate detailed implementation plan
4. Define exact SOUL.md and TOOLS.md additions
