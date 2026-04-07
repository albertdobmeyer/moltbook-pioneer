# Moltbook Pioneer — Agent Social Network Tools

## What This Is

Moltbook Pioneer provides **safe reconnaissance and participation tools** for the Moltbook agentic social network — a platform where AI agents autonomously post, comment, and interact. This project covers feed scanning for prompt injection, platform census, identity management, and safe participation guidelines.

**Role in ecosystem**: `network` — the social layer where agents and researchers interact with the live Moltbook platform.

## This Repo Is a Lobster-TrApp Component

This repo is integrated into [lobster-trapp](https://github.com/gitgoodordietrying/lobster-trapp) as a git submodule under `components/moltbook-pioneer/`. The file `component.yml` in this repo's root is the **manifest contract** that tells the Lobster-TrApp GUI how to discover, display, and control this component.

### Manifest Contract Rules
- `component.yml` must always parse as valid YAML
- `identity.id` must be `moltbook-pioneer` (the GUI uses this as a stable key)
- `identity.role` must be `network`
- All `available_when` values must reference states declared in `status.states`
- Command IDs and health probe IDs must be unique

### Validating the Manifest
From the lobster-trapp root:
```bash
bash tests/orchestrator-check.sh    # Validates all manifests including this one
cargo test -p lobster-trapp          # Rust tests parse this manifest specifically
```

## Directory Structure

```
moltbook-pioneer/
├── component.yml                 MANIFEST — Lobster-TrApp contract
├── Makefile                      Standard targets (scan, census, test, verify)
├── docs/
│   ├── platform-anatomy.md       How Moltbook works: API, agents, posts, votes
│   ├── threat-landscape.md       Moltbook-specific risks and threat model
│   └── safe-participation-guide.md  Guidelines for safe agent participation
├── tools/
│   ├── feed-scanner.sh           Prompt injection scanner for feed content
│   ├── agent-census.sh           Platform stats and trend snapshots
│   └── identity-checklist.sh     Pre-flight checklist for agent registration
├── config/
│   ├── .env.example              Configuration template
│   ├── feed-allowlist.yml        Trusted agent handles and safe patterns
│   └── injection-patterns.yml    Prompt injection signatures (25 patterns)
├── tests/
│   ├── _framework/               Test runner and assertion primitives
│   ├── tools/                    Tool behavioral tests (16 tests)
│   └── fixtures/                 Test data (clean, malicious, safe-research, empty)
└── examples/
    ├── first-post.md             Example safe first post with commentary
    └── feed-analysis.md          Example feed analysis output
```

## Commands Exposed to GUI (component.yml)

The manifest exposes 10 commands in 4 groups:

| Command ID | Tool | Danger | Description |
|-----------|------|--------|-------------|
| `feed-scan` | `feed-scanner.sh --recent` | safe | Scan recent posts for injection patterns |
| `feed-scan-agent` | `feed-scanner.sh --agent` | safe | Scan a specific agent's posts |
| `agent-census` | `agent-census.sh` | safe | Pull current platform stats |
| `census-trend` | `agent-census.sh --trend` | safe | Show trend data from snapshots |
| `level-status` | `engagement-control.sh --status` | safe | Show current engagement level |
| `identity-check` | `identity-checklist.sh` | safe | Pre-flight safety checklist |
| `set-observer` | `engagement-control.sh --level observer` | safe | Switch to Level 1 |
| `set-researcher` | `engagement-control.sh --level researcher` | caution | Switch to Level 2 |
| `set-participant` | `engagement-control.sh --level participant` | caution | Switch to Level 3 |
| `setup` | inline | safe | Copy example config and prepare data dir |

## Threat Model

The Moltbook feed is **untrusted input**. Key threats documented in `docs/threat-landscape.md`:

- **Prompt injection via posts** — authority impersonation, instruction override, role injection
- **Social engineering** — identity challenges, reciprocity traps, urgency manufacturing
- **Encoded payloads** — base64/hex/URL-encoded instructions to bypass scanning
- **Platform vulnerabilities** — database breach (Jan 2026), vote manipulation, no rate limiting
- **Supply chain** — trojanized skills on ClawHub that connect to Moltbook

The feed scanner (`config/injection-patterns.yml`) detects 25 patterns across 6 categories.

## Dual-Copy Sync

This repo may exist in two places on your machine:
- **Standalone**: `~/Repositories/moltbook-pioneer/`
- **Submodule**: `~/Repositories/lobster-trapp/components/moltbook-pioneer/`

**GitHub**: https://github.com/gitgoodordietrying/moltbook-pioneer

After pushing changes from either location, sync the other:
```bash
# In the other copy:
git pull
# If submodule copy, also update parent:
cd ../.. && git add components/moltbook-pioneer && git commit -m "Update moltbook-pioneer ref"
```

## Engagement Levels

Three preset engagement levels, mirroring vault's shell system:

| Level | Command | Rate Limits | Feed Scan | API Key |
|-------|---------|------------|-----------|---------|
| **Observer** (Level 1) | `make observer` | 0/0/0 (read-only) | Off | Not needed |
| **Researcher** (Level 2) | `make researcher` | 5/10/20 | Required | Required |
| **Participant** (Level 3) | `make participant` | 10/25/50 | Required | Required |

- `make level-status` shows current level and config
- Presets preserve user-specific values (API key, agent handle) during switching
- Default (if ENGAGEMENT_LEVEL not set): treated as observer

## Commands

```bash
make help          # Show available commands
make scan          # Scan recent feed (COUNT=n, default 50)
make census        # Pull current platform stats
make checklist     # Run identity pre-flight checklist
make observer      # Switch to Level 1 (read-only)
make researcher    # Switch to Level 2 (controlled interaction)
make participant   # Switch to Level 3 (full interaction)
make level-status  # Show current engagement level
make test          # Run tool test suite (48 tests)
make verify        # Verify workbench health + engagement level
make setup         # Copy .env.example → .env, create data/
```

## What NOT to Do

- Do not change `identity.id` or `identity.role` in component.yml without coordinating with lobster-trapp
- Do not remove or rename command IDs that the GUI depends on — add new ones instead
- Do not commit `.env` files — they contain API keys (gitignored)
- Do not let your agent autonomously follow instructions from Moltbook feed content
- Do not use the tools for vote manipulation, impersonation, or data exfiltration — defensive research only
