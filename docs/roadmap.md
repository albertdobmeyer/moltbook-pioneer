# Moltbook-Pioneer Roadmap

**Updated:** 2026-04-04
**Current state:** Three tools operational (feed scanner, agent census, identity checklist), 25 injection patterns, 16 behavioral tests passing, Makefile, safe_patterns wired. Phases 1-2 complete.
**Cross-reference:** See `docs/trifecta.md` in the lobster-trapp root for how this module fits with openclaw-vault and clawhub-forge.

---

## Phase 1: Fix Known Bugs — COMPLETE (2026-04-04)

11-commit sequence fixing all known bugs:

| Fix | Commit |
|-----|--------|
| CRLF → LF + .gitattributes | `b3d6007` |
| Executable bits on tools/*.sh | `d5e50bd` |
| eval → array-based curl | `86f4733` |
| fetch_posts stderr | `4d17d0f` |
| Dead in_pattern variable | `e00b31a` |
| Wire safe_patterns | `512fd2e` |
| Pattern count 30 → 25 | `e75a7c0` |
| component.yml states | `c77d192` |
| Makefile | `52b2414` |

Also fixed two latent bugs discovered during testing: `(?i)` PCRE flag broke grep ERE matching, and `|` delimiter collided with regex alternation in the pattern storage format.

---

## Phase 2: Automated Tests — COMPLETE (2026-04-04)

| Deliverable | Status |
|-------------|--------|
| Test framework (tool-runner.sh + tool-assertions.sh) | Ported from forge |
| Feed scanner tests (10) | Passing |
| Agent census tests (3) | Passing |
| Identity checklist tests (3) | Passing |
| Fixtures (clean, malicious, safe-research, empty) | Created |
| `make test` target | Working |

**Total:** 16 tests, 0 failures.

---

## Phase 3: Offline / Dry-Run Mode

**Why:** Moltbook API liveness is unknown. The census tool should work without network access for development, CI, and demo purposes. The feed scanner already supports `--file` mode (used by all fixture tests).

| Task | Details |
|---|---|
| Add `--file` to agent-census.sh | Read a saved JSON snapshot instead of hitting the API. Model on feed-scanner's existing `--file` mode. |
| Add census fixture | `tests/fixtures/census-snapshot.json` — sample API response for testing |
| Add census `--file` tests | 2-3 tests: `--file` exits 0, output contains expected sections |
| Add `make check-api` target | curl Moltbook API, report status (up/down/timeout) |
| Document API status | Confirm whether `moltbook.com/api/v1` is currently accessible. Add findings to this roadmap. |

**What's NOT needed:** The feed scanner already has `--file` mode — that IS its offline mode. No `--dry-run` wrapper needed.

**Exit criteria:** All three tools work offline via `--file` or fixtures. API liveness documented. `make test` still passes.

---

## Phase 4: Vault Integration — Pattern Export for Proxy-Level Feed Scanning

**Why:** When Moltbook domains enter the vault's proxy allowlist, social content must be scanned for injection attacks before the agent sees it. The scanning happens at the proxy level (host-side, trusted) — the agent never sees flagged critical content.

**Full spec:** `docs/specs/2026-04-04-vault-integration-design.md`

| Task | Details |
|---|---|
| Create `make export-patterns` target | Generates `data/patterns-export.yml` — stripped YAML with id, regex, severity only |
| Validate export format with vault-proxy.py | Ensure Python `re.compile()` handles all 25 patterns correctly |
| Add proxy integration code to vault-proxy.py | Moltbook-domain response inspection, pattern matching, critical blocking, logging |
| Add integration tests | Test with fixture data: malicious response blocked, clean response passed through |
| Document activation | When/how Moltbook domains enter the allowlist, what the user sees |

**Blocking policy:** Critical findings block the response (replaced with sanitized version). High/Medium findings are logged but the agent still sees the content.

**Not blocking anything now** — Moltbook domains are not in the vault's allowlist. But the pattern export mechanism should be built so the format is stable when integration happens.

**Exit criteria:** Pattern export works. Spec approved. Integration code exists but dormant until Moltbook domains are allowlisted.

---

## Phase 5: Pattern Harmonization with Forge

**Why:** Forge has 87 patterns for skill content. Pioneer has 25 patterns for social content. Different domains, different patterns — but the format and tooling could be shared.

| Task | Details |
|---|---|
| Compare pattern formats | Forge uses `tools/lib/patterns.sh` (bash functions). Pioneer uses `config/injection-patterns.yml` (YAML + regex). Assess whether a shared format is beneficial. |
| Identify overlapping patterns | Are any of pioneer's 25 patterns already covered by forge's 87? Document overlap. |
| Evaluate shared pattern library | If overlap is significant, consider a shared `patterns/` directory in lobster-trapp root. If not, keep separate. |

**Decision: Don't force convergence.** Skill content and social content have different threat profiles. Shared tooling is only valuable if it reduces maintenance burden without losing domain specificity.

**Exit criteria:** Pattern comparison documented. Decision made (share or keep separate) with rationale.

---

## Dependency Graph

```
Phase 1 (Bug fixes) ✅
    ↓
Phase 2 (Automated tests) ✅
    ↓
Phase 3 (Offline mode)
    ↓
Phase 4 (Vault integration) ← depends on vault allowlist decision
    ↓
Phase 5 (Pattern harmonization) ← depends on forge pattern access
```

---

*This roadmap covers the moltbook-pioneer module only. See `openclaw-vault/docs/roadmap.md` and `clawhub-forge/docs/roadmap.md` for the other modules.*
