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
│   ├── 🔍 clawd-prime.md              # Context loading + Archon research
│   ├── 🧠 clawd-plan-phase.md         # Deep planning with sub-agents
│   └── ⚡ clawd-execute-phase.md      # Orchestration-first implementation
│
├── 🍎 macos/                          # macOS-specific (launchctl)
│   ├── ✅ clawd-validate-phase.md     # Auto-setup + 7-level testing
│   ├── 🚀 clawd-deploy.md             # Git + SSH deployment
│   └── ⏪ clawd-rollback.md           # Emergency rollback
│
└── 🐧 wsl2/                           # WSL2/Linux-specific (systemctl)
    ├── ✅ clawd-validate-phase.md     # Auto-setup + 7-level testing
    ├── 🚀 clawd-deploy.md             # Git + SSH deployment
    └── ⏪ clawd-rollback.md           # Emergency rollback
```

---

## 🔄 Development Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CLAWDDEV KIT WORKFLOW                            │
└─────────────────────────────────────────────────────────────────────────┘

  📝 /clawd-create-prd                    Create PRD with Proactivity Map
         │
         ▼
  ┌──────────────┐
  │   👤 Human   │◄─────────────────── Validate requirements
  │   Validates  │
  └──────┬───────┘
         │
         ▼
  🔍 /clawd-prime                         Load context + Archon research
         │
         ▼
  🧠 /clawd-plan-phase                    Sub-agents research in parallel
         │                                ├── 🔎 Clawdbot docs research
         │                                ├── 🔎 Technology API research
         │                                ├── 🔎 MCP server research
         │                                └── 🔎 Similar capabilities
         ▼
  ┌──────────────┐
  │   👤 Human   │◄─────────────────── Validate plan
  │   Validates  │
  └──────┬───────┘
         │
         ▼
  ⚡ /clawd-execute-phase                 Implement with Archon tracking
         │
         ▼
  ✅ /clawd-validate-phase                7-Level automated testing
         │                                ├── Level 1: Static validation
         │                                ├── Level 2: Injection test
         │                                ├── Level 3: Logic validation
         │                                ├── Level 4: Proactivity test
         │                                ├── Level 5: Persistence test
         │                                ├── Level 6: Error handling
         │                                └── Level 7: Integration test
         ▼
  ┌──────────────┐
  │  All Pass?   │
  └──────┬───────┘
         │
    YES  │   NO
    ┌────┴────┐
    ▼         ▼
  🚀 /clawd-deploy    🔧 Fix & re-validate
    │
    ▼
  ┌──────────────┐
  │  Issues?     │───YES───▶ ⏪ /clawd-rollback
  └──────┬───────┘
         │ NO
         ▼
    ✨ Done!
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

---

## ⚙️ Configuration

Edit `~/clawd-dev-kit/.env` with your settings:

```bash
# Mac Mini SSH Connection
CLAWD_MINI_HOST=your-macmini.local
CLAWD_MINI_USER=your-username
CLAWD_MINI_SSH_KEY=~/.ssh/id_ed25519_clawd_mini

# Workspace Paths
CLAWD_MINI_WORKSPACE=~/clawd
CLAWD_DEV_WORKSPACE=~/clawd-dev

# Git Repository
CLAWD_CAPABILITIES_REPO=git@github.com:you/clawd-capabilities.git
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

| Command | Purpose | Phase |
|---------|---------|-------|
| `/clawd-create-prd <name>` | Create Product Requirements Document | 📝 Requirements |
| `/clawd-prime <name>` | Load context and research technologies | 🔍 Research |
| `/clawd-plan-phase <name>` | Generate detailed implementation plan | 🧠 Planning |
| `/clawd-execute-phase <name>` | Implement the capability | ⚡ Implementation |
| `/clawd-validate-phase <name>` | Run comprehensive tests | ✅ Validation |
| `/clawd-deploy <name>` | Deploy to Mac Mini | 🚀 Deployment |
| `/clawd-rollback [target]` | Rollback to previous state | ⏪ Recovery |

---

## 🏗️ Architecture

### Development Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     YOUR DEV MACHINE (Mac/Windows)                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ~/clawd-dev-kit/          ~/clawd-dev/                                │
│   ├── Commands              ├── SOUL.md (test)                          │
│   ├── .env                  ├── TOOLS.md (test)                         │
│   └── capabilities/         ├── MEMORY.md (test)                        │
│       └── <name>/           └── skills/ (test)                          │
│           ├── PRD.md                                                     │
│           ├── plan.md       Local Clawdbot Instance                     │
│           └── ...           (for testing only)                          │
│                                                                          │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 │ Git Push + SSH
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         MAC MINI (Production)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ~/clawd/                                                               │
│   ├── SOUL.md (production)                                              │
│   ├── TOOLS.md (production)                                             │
│   ├── MEMORY.md (live data)                                             │
│   └── skills/ (production)                                              │
│                                                                          │
│   Production Clawdbot Instance                                          │
│   └── 24/7 autonomous operation                                         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Validation Levels

| Level | Name | What It Tests |
|-------|------|---------------|
| 1 | Static | YAML syntax, TypeScript compilation |
| 2 | Injection | SOUL.md loads into agent context |
| 3 | Logic | Test cases from PRD pass |
| 4 | Proactivity | Cron/heartbeat triggers work |
| 5 | Persistence | State survives daemon restart |
| 6 | Error Handling | Graceful failures, proper escalation |
| 7 | Integration | Full end-to-end workflow |

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
