---
description: Execute implementation phase - builds actual code and configuration in workspace/
argument-hint: [phase-number]
---

# Execute Clawdbot Capability Phase

You are implementing a specific phase of a Clawdbot capability. **All changes go to `workspace/`** - the live, deployable agent configuration.

## Critical Rule: Edit workspace/, Reference docs/

```
docs/                           workspace/
(Reference - don't deploy)      (Live - gets deployed)
─────────────────────────       ─────────────────────────
docs/PRD.md                  ◄──READ
docs/plans/plan-phase-X.md   ◄──READ
docs/test-cases.md           ◄──READ
                                workspace/SOUL.md      ◄──EDIT
                                workspace/TOOLS.md     ◄──EDIT
                                workspace/AGENTS.md    ◄──EDIT
                                workspace/MEMORY.md    ◄──EDIT
                                workspace/skills/      ◄──CREATE (TypeScript!)
                                workspace/memory/      ◄──CREATE (JSON)
```

**Think of it as:**
- `docs/` = The blueprint (read-only during execution)
- `workspace/` = The house you're building (edit this)

---

## Pre-Execution: Load Context

**MANDATORY READS** (from docs/):

1. `./docs/PRD.md` - Full requirements
2. `./docs/plans/plan-phase-$ARGUMENTS.md` - This phase's implementation plan
3. `./docs/test-cases.md` - Tests to satisfy

**VERIFY** (in workspace/):

1. `./workspace/SOUL.md` - Current state
2. `./workspace/TOOLS.md` - Current tools
3. `./workspace/skills/` - Existing skills

---

## Execution Rules

### 1. All Edits Go to workspace/

```bash
# ✅ CORRECT - Edit workspace files
./workspace/SOUL.md
./workspace/TOOLS.md
./workspace/AGENTS.md
./workspace/MEMORY.md
./workspace/skills/ai-news-scanner/SKILL.md      # Skill manifest
./workspace/skills/ai-news-scanner/index.ts      # TypeScript implementation
./workspace/memory/posted-stories.json           # Data files

# ❌ WRONG - Never edit these during execution
./docs/SOUL-additions.md      # This is just a reference
./docs/PRD.md                 # This is the spec, not the product
~/clawd-dev/                  # Only touched by validate phase
~/clawd/                      # Only touched by deploy phase
```

### 2. workspace/SOUL.md is THE Source

When adding capability rules, edit `workspace/SOUL.md` directly:

```markdown
# In workspace/SOUL.md, add to the Capabilities section:

## AI News Curator

You are an elite AI news analyst and content creator...

### News Priority Hierarchy

**TIER 1 - IMMEDIATE** (Alert within minutes):
- Major model releases (GPT-5, Claude 4, Gemini 2, etc.)
- Company acquisitions/mergers in AI space
...

### Proactivity Rules

**Scheduled Behaviors**:
- Every 2 hours: Scan configured news sources
- 8:00 AM daily: Generate daily digest
...
```

---

## Skill Development: CRITICAL

### When to Create Skills

Per `clawd-global-rules.md`, only create TypeScript skills when:
- Built-in tools cannot accomplish the task
- No MCP server exists for the integration
- Complex data transformation is required
- Performance requires compiled code

### Skill Structure (MANDATORY)

Every skill MUST follow this structure:

```
workspace/skills/<skill-name>/
├── SKILL.md           # Required: Skill definition with YAML frontmatter
├── index.ts           # Required: Main TypeScript implementation
├── types.ts           # Optional: TypeScript types
├── utils.ts           # Optional: Helper functions
└── README.md          # Optional: Development notes
```

### SKILL.md Format

```markdown
---
name: ai-news-scanner
description: Scans X/Twitter and news sources for AI-related stories using Grok API
version: 1.0.0
author: Clawdbot
requires:
  - node: ">=22"
  - env: "GROK_API_KEY"
  - env: "TELEGRAM_BOT_TOKEN"
  - env: "TELEGRAM_CHAT_ID"
---

# AI News Scanner

## Purpose

Provides tools for scanning news sources and sending alerts via Telegram.

## Tools Provided

- `scan_ai_news` - Scan configured sources for AI news stories
- `send_telegram_alert` - Send formatted alert to Telegram
- `check_story_posted` - Check if a story has already been posted

## Usage Examples

```
// Scan for news
const stories = await scan_ai_news({ max_results: 10, hours_back: 2 });

// Send alert for a story
await send_telegram_alert({ story: stories[0], tier: 1 });

// Check if already posted
const posted = await check_story_posted({ story_id: "abc123" });
```

## Configuration

Environment variables required:
- `GROK_API_KEY` - xAI API key for Grok Live Search
- `TELEGRAM_BOT_TOKEN` - Telegram bot token
- `TELEGRAM_CHAT_ID` - Target chat ID for alerts
```

### index.ts Implementation

```typescript
// workspace/skills/ai-news-scanner/index.ts

import { z } from "zod";

// ============================================================
// TYPES
// ============================================================

interface NewsStory {
  id: string;
  headline: string;
  source: string;
  url: string;
  publishedAt: string;
  tier: 1 | 2 | 3;
  summary?: string;
}

interface ScanResult {
  success: boolean;
  stories: NewsStory[];
  scannedAt: string;
  error?: string;
}

// ============================================================
// TOOL: scan_ai_news
// ============================================================

export const scan_ai_news = {
  name: "scan_ai_news",
  description: "Scan news sources for AI-related stories using Grok Live Search",
  parameters: z.object({
    max_results: z.number().default(10).describe("Maximum stories to return"),
    hours_back: z.number().default(2).describe("Hours to look back"),
    tier_filter: z.array(z.number()).optional().describe("Filter by tier (1, 2, 3)"),
  }),

  async execute(params: {
    max_results?: number;
    hours_back?: number;
    tier_filter?: number[];
  }): Promise<ScanResult> {
    const { max_results = 10, hours_back = 2 } = params;

    const apiKey = process.env.GROK_API_KEY;
    if (!apiKey) {
      return {
        success: false,
        stories: [],
        scannedAt: new Date().toISOString(),
        error: "GROK_API_KEY not configured",
      };
    }

    try {
      const response = await fetch("https://api.x.ai/v1/chat/completions", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "grok-3-fast",
          messages: [
            {
              role: "system",
              content: `You are an AI news analyst. Search for significant AI news from the past ${hours_back} hours.
                       Return JSON array of stories with: headline, source, url, tier (1=breaking, 2=important, 3=notable).
                       Focus on: model releases, acquisitions, policy changes, research breakthroughs.`,
            },
            {
              role: "user",
              content: `Find the top ${max_results} AI news stories from the past ${hours_back} hours.`,
            },
          ],
          search_parameters: {
            mode: "on",
            max_search_results: max_results * 2,
            return_citations: true,
          },
        }),
      });

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content || "[]";

      // Parse stories from response
      const stories = parseStoriesFromResponse(content);

      return {
        success: true,
        stories: stories.slice(0, max_results),
        scannedAt: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        stories: [],
        scannedAt: new Date().toISOString(),
        error: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
};

// ============================================================
// TOOL: send_telegram_alert
// ============================================================

export const send_telegram_alert = {
  name: "send_telegram_alert",
  description: "Send a formatted news alert to Telegram",
  parameters: z.object({
    headline: z.string().describe("Story headline"),
    source: z.string().describe("News source"),
    url: z.string().describe("Story URL"),
    tier: z.number().min(1).max(3).describe("Priority tier"),
    summary: z.string().optional().describe("Brief summary"),
  }),

  async execute(params: {
    headline: string;
    source: string;
    url: string;
    tier: number;
    summary?: string;
  }): Promise<{ success: boolean; messageId?: number; error?: string }> {
    const botToken = process.env.TELEGRAM_BOT_TOKEN;
    const chatId = process.env.TELEGRAM_CHAT_ID;

    if (!botToken || !chatId) {
      return {
        success: false,
        error: "Telegram credentials not configured",
      };
    }

    const tierEmoji = params.tier === 1 ? "🔴" : params.tier === 2 ? "🟡" : "🟢";
    const tierLabel = params.tier === 1 ? "BREAKING" : params.tier === 2 ? "IMPORTANT" : "NOTABLE";

    const message = `
<b>📰 AI NEWS ${tierLabel}</b> ${tierEmoji}

<b>${params.headline}</b>

${params.summary || ""}

<b>Source:</b> ${params.source}
<a href="${params.url}">Read full story →</a>
    `.trim();

    try {
      const response = await fetch(
        `https://api.telegram.org/bot${botToken}/sendMessage`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            chat_id: chatId,
            text: message,
            parse_mode: "HTML",
            link_preview_options: { is_disabled: true },
          }),
        }
      );

      const data = await response.json();

      if (data.ok) {
        return { success: true, messageId: data.result.message_id };
      } else {
        return { success: false, error: data.description };
      }
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
};

// ============================================================
// TOOL: check_story_posted
// ============================================================

export const check_story_posted = {
  name: "check_story_posted",
  description: "Check if a story has already been posted (by URL or headline hash)",
  parameters: z.object({
    url: z.string().optional().describe("Story URL to check"),
    headline: z.string().optional().describe("Headline to check"),
  }),

  async execute(params: {
    url?: string;
    headline?: string;
  }): Promise<{ posted: boolean; postedAt?: string }> {
    // In a real implementation, this would check workspace/memory/posted-stories.json
    // For now, return false to indicate not posted
    return { posted: false };
  },
};

// ============================================================
// HELPER FUNCTIONS
// ============================================================

function parseStoriesFromResponse(content: string): NewsStory[] {
  try {
    // Try to extract JSON from the response
    const jsonMatch = content.match(/\[[\s\S]*\]/);
    if (jsonMatch) {
      const parsed = JSON.parse(jsonMatch[0]);
      return parsed.map((story: any, index: number) => ({
        id: `story-${Date.now()}-${index}`,
        headline: story.headline || story.title || "Unknown",
        source: story.source || "Unknown",
        url: story.url || story.link || "",
        publishedAt: story.publishedAt || new Date().toISOString(),
        tier: story.tier || 3,
        summary: story.summary,
      }));
    }
  } catch (e) {
    console.error("Failed to parse stories:", e);
  }
  return [];
}

// ============================================================
// EXPORTS
// ============================================================

export default {
  scan_ai_news,
  send_telegram_alert,
  check_story_posted,
};
```

### TypeScript Conventions

Per `clawd-global-rules.md`:

- Use strict TypeScript (no `any` types)
- Use ESM modules
- Format with Oxfmt, lint with Oxlint
- Include JSDoc comments for all exported functions
- Handle errors gracefully, never throw unhandled
- Use Zod for parameter validation

---

## Memory Files in workspace/memory/

Create JSON data files for persistence:

```json
// workspace/memory/posted-stories.json
{
  "schema_version": "1.0",
  "last_updated": "2024-01-27T12:00:00Z",
  "stories": [
    {
      "id": "story-123",
      "url": "https://example.com/story",
      "headline_hash": "abc123",
      "posted_at": "2024-01-27T12:00:00Z",
      "tier": 1
    }
  ]
}
```

```json
// workspace/memory/scan-history.json
{
  "schema_version": "1.0",
  "scans": [
    {
      "timestamp": "2024-01-27T12:00:00Z",
      "stories_found": 5,
      "alerts_sent": 2,
      "errors": []
    }
  ]
}
```

---

## Phase Execution Checklist

### Step 1: Understand the Phase
- [ ] Read `docs/PRD.md` for overall requirements
- [ ] Read `docs/plans/plan-phase-$ARGUMENTS.md` for this phase's deliverables
- [ ] Identify what needs to be added to workspace/

### Step 2: Update workspace/SOUL.md
- [ ] Add/update behavioral rules for this phase's features
- [ ] Add proactivity rules if this phase includes scheduled behaviors
- [ ] Update autonomy boundaries if needed

### Step 3: Update workspace/TOOLS.md
- [ ] Add any new tool definitions (MCP or skill tools)
- [ ] Document parameters and usage patterns
- [ ] Add error handling conventions

### Step 4: Create Skills (if needed)
- [ ] Create skill folder: `workspace/skills/<skill-name>/`
- [ ] Write `SKILL.md` with YAML frontmatter
- [ ] Implement `index.ts` with actual TypeScript code
- [ ] Use Zod for parameter validation
- [ ] Handle all errors gracefully
- [ ] Export tools properly

### Step 5: Initialize Memory
- [ ] Create JSON template files in `workspace/memory/`
- [ ] Ensure schema matches `docs/memory-schema.md`
- [ ] Include `schema_version` for future migrations

### Step 6: Update workspace/AGENTS.md
- [ ] Add any new scheduled tasks
- [ ] Update operating instructions
- [ ] Document startup behavior

---

## After Execution

### Summary Output

```
✅ Phase $ARGUMENTS implementation complete!

Files modified in workspace/:
├── SOUL.md              (+XX lines) - Added [capability rules]
├── TOOLS.md             (+XX lines) - Added [tool definitions]
├── AGENTS.md            (+XX lines) - Added [scheduled tasks]
├── MEMORY.md            (+XX lines) - Added [memory schema]
├── skills/
│   └── ai-news-scanner/
│       ├── SKILL.md     (new) - Skill manifest
│       └── index.ts     (new) - TypeScript implementation (XXX lines)
└── memory/
    ├── posted-stories.json  (new) - Story tracking
    └── scan-history.json    (new) - Scan logs

TypeScript skill created with tools:
- scan_ai_news
- send_telegram_alert
- check_story_posted

Ready to validate. Run:
/clawd-validate-phase
```

### Validation Before Moving On

Before running `/clawd-validate-phase`, verify:

```bash
# Check TypeScript compiles (if skills created)
cd ./workspace/skills/ai-news-scanner
npx tsc --noEmit

# Check SKILL.md has valid YAML
head -20 ./workspace/skills/ai-news-scanner/SKILL.md

# Verify memory files are valid JSON
cat ./workspace/memory/posted-stories.json | jq .
```

### Do NOT:
- ❌ Create `.md` files in skills/ (except SKILL.md)
- ❌ Skip the TypeScript implementation
- ❌ Edit files in `docs/` (those are references)
- ❌ Edit files in `~/clawd-dev/` (that's for validation)
- ❌ Edit files in `~/clawd/` (that's production)
- ❌ Create skills outside of workspace/skills/

---

## Example Flow

```
User: /clawd-execute-phase 1

Claude:
1. Reads docs/PRD.md - understands Phase 1 requirements
2. Reads docs/plans/plan-phase-1.md - understands deliverables
3. Edits workspace/SOUL.md - adds news curator persona & rules
4. Edits workspace/TOOLS.md - adds skill tool definitions
5. Creates workspace/skills/ai-news-scanner/SKILL.md - skill manifest
6. Creates workspace/skills/ai-news-scanner/index.ts - ACTUAL TypeScript
7. Creates workspace/memory/posted-stories.json - tracking data
8. Updates workspace/AGENTS.md - adds 2-hour scan schedule
9. Verifies TypeScript compiles
10. Summarizes changes and recommends validation
```

---

## Common Patterns

### API Integration Skill

```typescript
// Pattern for API-calling tools
export const call_external_api = {
  name: "call_external_api",
  description: "...",
  parameters: z.object({
    endpoint: z.string(),
    method: z.enum(["GET", "POST"]),
    body: z.any().optional(),
  }),

  async execute(params) {
    const apiKey = process.env.API_KEY;
    if (!apiKey) {
      return { success: false, error: "API_KEY not configured" };
    }

    try {
      const response = await fetch(params.endpoint, {
        method: params.method,
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: params.body ? JSON.stringify(params.body) : undefined,
      });

      const data = await response.json();
      return { success: true, data };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
};
```

### Memory Read/Write Skill

```typescript
// Pattern for memory operations
import { readFile, writeFile } from "fs/promises";
import { join } from "path";

const MEMORY_DIR = "./memory";

export const read_memory = {
  name: "read_memory",
  description: "Read from a memory file",
  parameters: z.object({
    file: z.string().describe("Memory file name (e.g., 'posted-stories.json')"),
  }),

  async execute(params: { file: string }) {
    try {
      const path = join(MEMORY_DIR, params.file);
      const content = await readFile(path, "utf-8");
      return { success: true, data: JSON.parse(content) };
    } catch (error) {
      return { success: false, error: "File not found or invalid JSON" };
    }
  },
};

export const write_memory = {
  name: "write_memory",
  description: "Write to a memory file",
  parameters: z.object({
    file: z.string(),
    data: z.any(),
  }),

  async execute(params: { file: string; data: any }) {
    try {
      const path = join(MEMORY_DIR, params.file);
      await writeFile(path, JSON.stringify(params.data, null, 2));
      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Write failed",
      };
    }
  },
};
```
