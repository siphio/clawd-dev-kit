---
description: Create a Product Requirements Document for a new Clawdbot capability
argument-hint: [capability-name or description]
---

# Create Clawdbot Capability PRD

You are creating a comprehensive Product Requirements Document (PRD) for a new Clawdbot capability. This PRD will guide all subsequent phases of development.

## Critical Context

**Read First**: Before proceeding, ensure you understand Clawdbot's unique paradigm by reviewing:
- `clawd-global-rules.md` - Development conventions and patterns

**Key Paradigm Shifts** (Clawdbot vs. Traditional Development):
- **Prompt-orchestration first**: Capabilities are primarily SOUL.md rules, not code
- **Proactivity is mandatory**: Define when the capability runs autonomously
- **Persistence required**: All state must survive daemon restarts
- **Human-in-the-loop**: Define escalation points clearly

---

## Step 1: Capability Discovery

### 1.1 Initial Input

The user has requested a capability: **$ARGUMENTS**

### 1.2 Clarifying Questions

Before writing the PRD, gather essential information. Ask the user:

**Core Purpose:**
- What problem does this capability solve?
- What is the primary outcome when it runs successfully?
- Who/what does this capability interact with? (APIs, platforms, users)

**Proactivity Model:**
- Should this run on a schedule? (e.g., daily at 9am)
- Should this run in response to events? (e.g., new email arrives)
- Should this only run when explicitly triggered by user?
- Combination of above?

**Autonomy Level:**
- What should it do completely autonomously?
- What should it ask permission for before acting?
- What should it NEVER do without explicit approval?

**Integration Requirements:**
- What external services/APIs are needed?
- Are there existing MCP servers for these services?
- What credentials/authentication is required?

**Success Criteria:**
- How do we know the capability is working correctly?
- What does a successful run look like?
- What metrics matter?

---

## Step 2: PRD Generation

Based on the discovery conversation, generate a comprehensive PRD with ALL of the following sections:

---

### PRD TEMPLATE

```markdown
# Capability PRD: [Capability Name]

**Version**: 1.0.0
**Created**: [Date]
**Author**: [Name]
**Status**: Draft

---

## 1. Executive Summary

### 1.1 One-Line Description
[Single sentence describing what this capability does]

### 1.2 Problem Statement
[What problem does this solve? Why is it needed?]

### 1.3 Solution Overview
[High-level description of how the capability works]

### 1.4 Success Metrics
- [Metric 1: e.g., "Posts 3x per week without manual intervention"]
- [Metric 2: e.g., "Identifies 5+ qualified leads per week"]
- [Metric 3: e.g., "Zero missed scheduled posts"]

---

## 2. Proactivity Map

### 2.1 Trigger Types

| Trigger | Schedule/Condition | Action |
|---------|-------------------|--------|
| [Trigger 1] | [e.g., "Cron: 0 10 * * 2,4,6"] | [What happens] |
| [Trigger 2] | [e.g., "Heartbeat check every 4h"] | [What happens] |
| [Trigger 3] | [e.g., "User message containing 'post now'"] | [What happens] |

### 2.2 Proactivity Model
- [ ] Scheduled Only (runs at fixed times)
- [ ] Event-Driven (responds to external events)
- [ ] Heartbeat-Based (periodic checks)
- [ ] Reactive Only (only when user triggers)
- [ ] Hybrid (combination - explain below)

**Proactivity Details:**
[Explain the proactivity model in detail. When does it wake up? What does it check? How often?]

### 2.3 Quiet Hours
- Should the capability respect quiet hours? [Yes/No]
- Quiet hours: [e.g., "10pm - 8am local time"]
- Behavior during quiet hours: [e.g., "Queue actions for morning"]

---

## 3. Orchestration Layer

### 3.1 Decision Logic

```
[Describe the decision tree the agent follows]

Example:
When triggered for posting:
1. Check if content queue has pending items
   └─ NO → Generate new content based on content pillars
   └─ YES → Select next item from queue
2. Check if within posting window
   └─ NO → Queue for next window
   └─ YES → Proceed to post
3. Post to platform
4. Log result to daily memory
5. If engagement threshold met, notify user
```

### 3.2 SOUL.md Behavior Rules

[Draft the behavioral rules that will go into SOUL.md]

```markdown
## [Capability Name]

### Triggers
- [Trigger 1]
- [Trigger 2]

### Behavior
When triggered, you will:
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Constraints
- [Constraint 1: e.g., "Never post more than 3x per day"]
- [Constraint 2: e.g., "Always use approved content pillars"]

### Escalation
Ask before acting if:
- [Condition 1]
- [Condition 2]
```

### 3.3 Tool Requirements

| Tool | Purpose | Built-in or MCP? |
|------|---------|------------------|
| [Tool 1] | [Purpose] | [Built-in: Browser/Shell/Memory OR MCP: name] |
| [Tool 2] | [Purpose] | [Built-in/MCP] |

---

## 4. Autonomy Profile

### 4.1 Autonomous Actions (No approval needed)
- [Action 1: e.g., "Post pre-approved content"]
- [Action 2: e.g., "Log activity to memory"]
- [Action 3: e.g., "Read and analyze data"]

### 4.2 Approval Required Actions
- [Action 1: e.g., "Respond to DMs from new contacts"]
- [Action 2: e.g., "Modify posting schedule"]
- [Action 3: e.g., "Send emails to leads"]

### 4.3 Prohibited Actions (Never do, even if asked)
- [Action 1: e.g., "Delete content without backup"]
- [Action 2: e.g., "Share credentials"]
- [Action 3: e.g., "Make purchases"]

### 4.4 Escalation Triggers
The capability MUST ask the user when:
- [Trigger 1: e.g., "Uncertainty about content appropriateness"]
- [Trigger 2: e.g., "API errors after 3 retries"]
- [Trigger 3: e.g., "Unusual patterns detected"]

---

## 5. Memory Schema

### 5.1 Long-Term Memory (MEMORY.md)

```markdown
## Capability: [Name]

### Configuration
- [Config 1: e.g., "posting_schedule: Tue/Thu/Sat 10am"]
- [Config 2: e.g., "content_pillars: tutorials, insights, news"]

### Persistent State
- [State 1: e.g., "approved_contacts: [list]"]
- [State 2: e.g., "content_queue: [list]"]

### Learned Preferences
- [Preference 1: e.g., "best_posting_times: {platform: times}"]
```

### 5.2 Daily Log Entries (memory/YYYY-MM-DD.md)

```markdown
## [Capability Name] Activity

### [Timestamp]
- Action: [what happened]
- Result: [outcome]
- Notes: [any observations]
```

### 5.3 Memory Access Patterns

| Operation | Frequency | Data |
|-----------|-----------|------|
| Read MEMORY.md | [e.g., "On each trigger"] | [What data] |
| Write MEMORY.md | [e.g., "On config change"] | [What data] |
| Read daily log | [e.g., "Morning briefing"] | [What data] |
| Write daily log | [e.g., "After each action"] | [What data] |

---

## 6. Integration Requirements

### 6.1 External Services

| Service | Purpose | Auth Method | MCP Available? |
|---------|---------|-------------|----------------|
| [Service 1] | [Purpose] | [OAuth/API Key/etc.] | [Yes: name / No] |
| [Service 2] | [Purpose] | [Auth method] | [Yes/No] |

### 6.2 API Requirements

**[Service 1 Name]:**
- Endpoints needed: [list]
- Rate limits: [limits]
- Required scopes/permissions: [list]

### 6.3 Credential Storage
- [Credential 1]: Store in [.env / Clawdbot credentials / etc.]
- [Credential 2]: Store in [location]

---

## 7. Error Handling

### 7.1 Error Categories

| Error Type | Detection | Response | Escalation |
|------------|-----------|----------|------------|
| API Rate Limit | HTTP 429 | Wait and retry (3x) | After 3 failures |
| Auth Failure | HTTP 401/403 | Log and escalate | Immediate |
| Network Error | Timeout/connection | Retry with backoff | After 5 failures |
| Data Validation | Invalid response | Log and skip | If critical data |

### 7.2 Graceful Degradation
When errors occur, the capability should:
- [Behavior 1: e.g., "Continue with other tasks if one fails"]
- [Behavior 2: e.g., "Queue failed actions for retry"]
- [Behavior 3: e.g., "Notify user of degraded state"]

---

## 8. Test Cases

### TC-001: [Basic Functionality Test]
- **Description**: [What this tests]
- **Trigger**: [How to trigger]
- **Input**: [Test input]
- **Expected Output Contains**: [Key phrases/data in response]
- **Expected Actions**: [Tools called, memory written, etc.]
- **Pass Criteria**: [How to verify success]

### TC-002: [Proactive Trigger Test]
- **Description**: [What this tests]
- **Trigger**: [Cron/heartbeat/event]
- **Preconditions**: [Setup required]
- **Expected Behavior**: [What should happen]
- **Expected Memory**: [What should be logged]
- **Pass Criteria**: [How to verify]

### TC-003: [Error Handling Test]
- **Description**: [What this tests]
- **Trigger**: [How to trigger error condition]
- **Error Condition**: [What error to simulate]
- **Expected Behavior**: [Graceful handling]
- **Should NOT**: [What must not happen]
- **Pass Criteria**: [How to verify]

### TC-004: [Escalation Test]
- **Description**: [Test escalation triggers]
- **Trigger**: [Condition that should escalate]
- **Expected Behavior**: [Ask user, not act autonomously]
- **Pass Criteria**: [Verification method]

### TC-005: [Persistence Test]
- **Description**: [Test state survives restart]
- **Setup**: [Create state that should persist]
- **Action**: [Restart daemon]
- **Expected**: [State is preserved]
- **Pass Criteria**: [Verification method]

---

## 9. Phased Implementation

### Phase 1: Core Orchestration
- [ ] SOUL.md behavioral rules
- [ ] Basic trigger handling
- [ ] Memory schema setup
- [ ] Manual testing

### Phase 2: Proactivity
- [ ] Cron job configuration
- [ ] Heartbeat logic (if applicable)
- [ ] Quiet hours handling
- [ ] Automated trigger testing

### Phase 3: Integration
- [ ] External API integration
- [ ] MCP server setup (if needed)
- [ ] Error handling
- [ ] Rate limit handling

### Phase 4: Polish
- [ ] Edge case handling
- [ ] Escalation refinement
- [ ] Performance optimization
- [ ] Documentation

---

## 10. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | [High/Med/Low] | [High/Med/Low] | [How to mitigate] |
| [Risk 2] | [Likelihood] | [Impact] | [Mitigation] |

---

## 11. Rollback Plan

If the capability causes issues in production:

1. **Immediate**: Disable cron triggers via [method]
2. **Short-term**: Rollback via `/clawd-rollback last`
3. **Investigation**: Check logs at `~/clawd/memory/YYYY-MM-DD.md`
4. **Fix Forward**: Address issue and redeploy

---

## 12. Open Questions

- [ ] [Question 1 that needs resolution]
- [ ] [Question 2 that needs resolution]

---

## Appendix A: Reference Documentation

- [Link to relevant API docs]
- [Link to MCP server docs]
- [Link to similar capability examples]

---

## Approval

- [ ] PRD reviewed by Marley
- [ ] Questions resolved
- [ ] Ready for /clawd-prime and /clawd-plan-phase
```

---

## Step 3: PRD Output

Save the completed PRD to:
```
~/clawd-dev-kit/capabilities/[capability-name]/PRD.md
```

Create the capability directory structure:
```bash
mkdir -p ~/clawd-dev-kit/capabilities/[capability-name]
```

---

## Step 4: Human Validation Checkpoint

Present the PRD to the user and ask:

1. Does the Proactivity Map accurately reflect when this should run?
2. Is the Autonomy Profile correct (what it can/cannot do alone)?
3. Are the test cases comprehensive enough?
4. Are there any missing integration requirements?
5. Any open questions that need resolution before planning?

**Do NOT proceed to planning until the user approves the PRD.**

---

## Next Steps

Once PRD is approved:
1. Run `/clawd-prime [capability-name]` to load context
2. Run `/clawd-plan-phase [capability-name]` to create implementation plan
