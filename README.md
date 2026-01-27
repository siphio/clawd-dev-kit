# 🤖 ClawdDev Kit

> A systematic, human-in-the-loop development framework for building Clawdbot capabilities.

[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20WSL2%20%7C%20Linux-blue)](/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Clawdbot](https://img.shields.io/badge/clawdbot-compatible-purple)](https://github.com/clawdbot/clawdbot)

---

## 🎯 What is ClawdDev Kit?

ClawdDev Kit is a **rigorous, phased development framework** for building Clawdbot capabilities. It mirrors battle-tested agentic coding workflows (like PIVloop) but is specifically tailored for Clawdbot's unique paradigm:

- **Prompt-orchestration first** (SOUL.md rules over code)
- **Proactivity as a first-class citizen** (cron, heartbeats, autonomous behavior)
- **Persistence across restarts** (file-based memory)
- **Human validates every phase** (no unsupervised self-improvement)

Perfect for building "AI employees" that run 24/7 on your Mac Mini.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔄 **Human-in-the-Loop** | Validation checkpoints at every phase - you stay in control |
| 🤖 **Sub-Agent Research** | Parallel Archon RAG queries for deep technology research |
| 🚀 **Auto Environment Setup** | Automatically spins up `~/clawd-dev/` when needed |
| 📚 **Archon MCP Integration** | Query documentation for any API or MCP server |
| ⏪ **One-Command Rollback** | Safely undo deployments without touching your Mini |
| 🔐 **Secure Config** | SSH keys and credentials in `.env` (never committed) |
| 💻 **Dual Platform** | Full support for macOS and WSL2/Linux development |

---

## 📁 Project Structure

When you create a new capability project, ClawdDev Kit generates this structure:

```
your-capability-project/
│
├── 📂 docs/                        ← PLANNING (human reference, NOT deployed)
│   ├── PRD.md                      # Product Requirements Document
│   ├── STATE.md                    # Progress tracking (source of truth)
│   ├── SOUL-additions.md           # Behavioral rules to add
│   ├── TOOLS-additions.md          # Tool definitions to add
│   ├── memory-schema.md            # Memory file specifications
│   ├── test-cases.md               # Validation test cases
│   └── plans/                      # Implementation plans
│       ├── plan-phase-1.md
│       └── plan-phase-2.md
│
├── 📂 workspace/                   ← LIVE AGENT (deployed to Clawdbot)
│   ├── IDENTITY.md                 # Agent identity
│   ├── SOUL.md                     # Complete behavioral rules
│   ├── TOOLS.md                    # Complete tool definitions
│   ├── AGENTS.md                   # Operating instructions
│   ├── MEMORY.md                   # Long-term memory
│   ├── USER.md                     # User preferences
│   ├── memory/                     # Daily memory files
│   ├── skills/                     # Executable skill scripts
│   └── media/                      # Media assets
│
└── .env                            # SSH config for deployment
```

### The Key Distinction: docs/ vs workspace/

```
┌───────────┬────────────────────────┬─────────────────────────────┐
│           │       docs/            │       workspace/            │
├───────────┼────────────────────────┼─────────────────────────────┤
│ What      │ Planning documentation │ Live agent configuration    │
│ Who reads │ You + Claude           │ Clawdbot agent at runtime   │
│ When      │ During development     │ At runtime                  │
│ Deploy?   │ ❌ No                  │ ✅ Yes                      │
│ Changes   │ By you manually        │ By agent (memory) + you     │
└───────────┴────────────────────────┴─────────────────────────────┘
```

**Why this separation?**
- Keep all development within your project folder
- Continue developing capabilities later without confusion
- Deploy by simply copying the `workspace/` folder
- Clear separation between "what we planned" and "what runs"

---

## 📁 Framework Structure

```
clawd-dev-kit/
│
├── 📋 .env.example                    # Configuration template
├── 🚀 setup.sh                        # One-liner installer
│
├── 📂 core/                           # Platform-agnostic commands
│   ├── 📋 clawd-global-rules.md       # Foundation conventions & patterns
│   ├── 📝 clawd-create-prd.md         # PRD with Proactivity Map
│   ├── 🔍 clawd-prime.md              # Load context, determine next step
│   ├── 🧠 clawd-plan-phase.md         # Deep planning with Archon + sub-agents
│   └── ⚡ clawd-execute-phase.md      # Orchestration-first implementation
│
├── 🍎 macos/                          # macOS-specific (launchctl)
│   ├── ✅ clawd-validate-phase.md     # Copy to test instance + testing
│   ├── 🚀 clawd-deploy.md             # SSH + SCP deployment
│   └── ⏪ clawd-rollback.md           # Emergency rollback
│
└── 🐧 wsl2/                           # WSL2/Linux-specific (systemctl)
    ├── ✅ clawd-validate-phase.md     # Copy to test instance + testing
    ├── 🚀 clawd-deploy.md             # SSH + SCP deployment
    └── ⏪ clawd-rollback.md           # Emergency rollback
```

---

## 🔄 Development Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CLAWDDEV KIT WORKFLOW                            │
└─────────────────────────────────────────────────────────────────────────┘

  📝 /clawd-create-prd                    Create PRD + project structure
         │                                ├── Creates docs/ folder
         │                                └── Creates workspace/ folder
         ▼
  ┌──────────────┐
  │   👤 Human   │◄─────────────────── Validate requirements
  │   Validates  │
  └──────┬───────┘
         │
         ▼
  🔍 /clawd-prime                         Familiarize with project
         │                                ├── Read PRD and docs/
         │                                ├── Check workspace/ state
         │                                └── Determine next step
         ▼
  🧠 /clawd-plan-phase                    Deep research + planning
         │                                ├── 🔎 Archon RAG queries
         │                                ├── 🔎 Sub-agents for APIs
         │                                ├── 🔎 MCP server research
         │                                └── 📄 Generate phase plan
         ▼
  ┌──────────────┐
  │   👤 Human   │◄─────────────────── Validate plan
  │   Validates  │
  └──────┬───────┘
         │
         ▼
  ⚡ /clawd-execute-phase                 Implement capability
         │                                ├── Reads from docs/
         │                                └── Writes to workspace/
         ▼
  ✅ /clawd-validate-phase                Copy workspace/ → ~/clawd-dev/
         │                                ├── Restart local daemon
         │                                └── Run tests from docs/test-cases.md
         ▼
  ┌──────────────┐
  │  All Pass?   │
  └──────┬───────┘
         │
    YES  │   NO
    ┌────┴────┐
    ▼         ▼
  🚀 /clawd-deploy    🔧 Fix workspace/ & re-validate
    │
    │  Copy workspace/ → Mac Mini via SSH
    ▼
  ┌──────────────┐
  │  Issues?     │───YES───▶ ⏪ /clawd-rollback
  └──────┬───────┘
         │ NO
         ▼
    ✨ Done!
```

---

## 🏗️ Architecture

### Three Environments

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     YOUR PROJECT FOLDER (Source of Truth)               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ./docs/                      ./workspace/                              │
│   ├── PRD.md                   ├── IDENTITY.md                          │
│   ├── STATE.md ◄─── PROGRESS   ├── SOUL.md ◄─── THE DEPLOYABLE UNIT    │
│   ├── SOUL-additions.md        ├── TOOLS.md                             │
│   ├── test-cases.md            ├── AGENTS.md                            │
│   └── plans/                   ├── memory/                              │
│       └── plan-phase-X.md      └── skills/                               │
│       PLANNING                      LIVE CONFIGURATION                   │
│       (Reference only)              (Gets deployed)                      │
│                                                                          │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  │                  ▼
┌─────────────────────────┐      │      ┌─────────────────────────┐
│    ~/clawd-dev/         │      │      │    ~/clawd/             │
│    (Local Test)         │      │      │    (Production)         │
├─────────────────────────┤      │      ├─────────────────────────┤
│  Copy workspace/ here   │◄─────┘      │  Copy workspace/ here   │
│  for validation         │  Validate   │  via SSH + SCP          │
│                         │             │                          │
│  launchctl daemon       │             │  24/7 operation          │
│  (your dev machine)     │             │  (Mac Mini)              │
└─────────────────────────┘             └─────────────────────────┘
```

### Deployment Flow

```
workspace/ ──► Validate ──► ~/clawd-dev/ ──► Tests Pass? ──► Deploy ──► ~/clawd/
                                                 │                    (Mac Mini)
                                                 │
                                                 └── No ──► Fix workspace/ ──► Re-validate
```

---

## 🚀 Quick Start

### One-Line Installation

```bash
curl -sL https://raw.githubusercontent.com/siphio/clawd-dev-kit/main/setup.sh | bash
```

The installer automatically detects your platform (macOS or WSL2) and downloads the appropriate files.

### Manual Installation

```bash
# Clone the repo
git clone https://github.com/siphio/clawd-dev-kit.git ~/clawd-dev-kit

# Copy configuration template
cp ~/clawd-dev-kit/.env.example ~/clawd-dev-kit/.env

# Edit with your settings
nano ~/clawd-dev-kit/.env
```

### Create Your First Capability

```bash
# Create a new project folder
mkdir ~/projects/my-capability && cd ~/projects/my-capability

# Initialize with ClawdDev Kit
/clawd-create-prd my-capability

# This creates:
# ./docs/PRD.md, test-cases.md, etc.
# ./workspace/SOUL.md, TOOLS.md, etc.
```

---

## ⚙️ Configuration

Edit your project's `.env` with your settings:

```bash
# Mac Mini SSH Connection
CLAWD_MINI_HOST=your-macmini.local
CLAWD_MINI_USER=your-username
CLAWD_MINI_SSH_KEY=~/.ssh/id_ed25519_clawd_mini

# Workspace Paths
CLAWD_MINI_WORKSPACE=~/clawd
CLAWD_DEV_WORKSPACE=~/clawd-dev
```

### SSH Key Setup

```bash
# Generate a dedicated key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_clawd_mini -N ""

# Copy to your Mac Mini
ssh-copy-id -i ~/.ssh/id_ed25519_clawd_mini.pub user@macmini.local
```

---

## 📖 Command Reference

| Command | Purpose | What It Does |
|---------|---------|--------------|
| `/clawd-create-prd <name>` | Initialize project | Creates docs/ + workspace/ structure |
| `/clawd-prime` | Familiarize | Reads project files, determines current state and next step |
| `/clawd-plan-phase <phase>` | Plan + Research | Uses Archon + sub-agents for deep research, generates phase plan |
| `/clawd-execute-phase <phase>` | Implement | Edits workspace/ files based on plan |
| `/clawd-validate-phase` | Test | Copies workspace/ → ~/clawd-dev/, runs tests |
| `/clawd-deploy` | Deploy | Copies workspace/ → Mac Mini via SSH |
| `/clawd-rollback [tag]` | Rollback | Restores from backup on Mac Mini |

### Command Responsibilities

**`/clawd-prime`** - Lightweight context loading (NO Archon)
- Reads PRD and existing docs/
- Checks workspace/ implementation state
- Tells you what phase you're in and what to do next

**`/clawd-plan-phase`** - Heavy research (Archon + sub-agents)
- Spawns sub-agents for parallel research
- Queries Archon RAG for API docs, MCP servers, patterns
- Generates detailed implementation plan in docs/plans/

---

## 🔑 Key Concepts

### Prompt-Orchestration First

Unlike traditional development where you write code to control logic, Clawdbot capabilities are primarily defined through **SOUL.md behavioral rules**:

```markdown
## My Capability

### Triggers
- Cron: "0 10 * * *" (daily at 10am)
- Message containing "run my task"

### Behavior
When triggered, you will:
1. Check memory for pending items
2. Process each item using browser tool
3. Log results to daily memory

### Escalation
Ask before acting if:
- More than 10 items to process
- Any item fails 3 times
```

### Proactivity Map

Every capability must define its proactivity model in the PRD:

| Trigger Type | Example | Use Case |
|--------------|---------|----------|
| Scheduled | `0 9 * * 1-5` | Morning briefing on weekdays |
| Heartbeat | Every 4 hours | Check for new opportunities |
| Event-Driven | New email arrives | Process incoming requests |
| Reactive | User says "post now" | On-demand actions |

### Memory Persistence

All state is file-based and survives restarts:

- **MEMORY.md** → Long-term facts, preferences, configurations
- **memory/YYYY-MM-DD.md** → Daily activity logs

---

## 🤝 Contributing

Contributions are welcome! Please read the [contribution guidelines](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by [Cole Medin's PIVloop](https://github.com/coleam00/context-engineering-intro) and Context Engineering
- Built for [Clawdbot](https://github.com/clawdbot/clawdbot) - the open-source personal AI assistant
- Developed with guidance from the [Dynamous AI](https://dynamous.ai/) community patterns

---

<p align="center">
  <b>Built with 🤖 by the Clawdbot community</b>
</p>
