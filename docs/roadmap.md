# Moltbook-Pioneer Roadmap

**Updated:** 2026-03-27
**Current state:** Three functional tools (feed scanner, agent census, identity checklist), comprehensive threat model, zero automated tests. The least mature of the three modules but feature-complete for its stated purpose.
**Cross-reference:** See `docs/trifecta.md` in the lobster-trapp root for how this module fits with openclaw-vault and clawhub-forge.

---

## Phase 1: Fix Known Bugs

**Why:** Operational issues that affect first-time users.

| Task | Details |
|---|---|
| Add `chmod +x` to setup or README | `tools/*.sh` lack executable bits on fresh clone. Either fix in `make setup` or document in quick-start. |
| Wire `safe_patterns` in feed scanner | `config/feed-allowlist.yml` declares `safe_patterns` but the scanner ignores them. Either implement or remove the key to eliminate silent config confusion. |
| Fix `eval` in `feed-scanner.sh` | Line ~197 uses `eval` for auth header construction. Replace with direct variable expansion to close minor shell injection surface. |
| Complete Gear → Shell terminology | Update any references to "Gear" to use "Shell" per `GLOSSARY.md`. |

**Exit criteria:** Tools work correctly on fresh clone. No silent config failures. No eval usage.

---

## Phase 2: Automated Tests

**Why:** Pioneer has zero automated tests. Forge has 168 assertions, vault has 12 test scripts + 15-point verify. Pioneer is the gap.

| Task | Details |
|---|---|
| Pattern matching tests | Verify feed scanner detects each of the 25 injection patterns against test fixtures |
| False positive tests | Verify scanner doesn't flag known-safe content (meta-discussion about injection, etc.) |
| Census JSON parsing tests | Verify agent census correctly parses Moltbook API responses (use fixture data) |
| Checklist validation tests | Verify identity checklist correctly detects missing/invalid configuration |
| Add `make test` target | Run all tests with pass/fail reporting |

**Test approach:** Use fixture data (saved API responses and known-malicious posts) so tests don't require live Moltbook API access.

**Exit criteria:** `make test` runs and passes. All 25 injection patterns verified. False positive rate measured.

---

## Phase 3: Offline / Dry-Run Mode

**Why:** Moltbook API liveness is unknown. Tools should work without network access for development and testing.

| Task | Details |
|---|---|
| Add `--dry-run` to feed scanner | Use fixture data instead of live API calls |
| Add `--dry-run` to agent census | Return cached snapshot data |
| Document API status | Confirm whether `moltbook.com/api/v1` is currently accessible. Document findings. |
| Add `data/fixtures/` | Sample API responses for testing and dry-run mode |

**Exit criteria:** All tools work offline with `--dry-run`. API liveness documented.

---

## Phase 4: Vault Integration

**Why:** When Moltbook domains are added to the vault's allowlist (Soft Shell or later), pioneer's feed scanning should protect the agent.

| Task | Details |
|---|---|
| Define integration point | Where does feed scanning happen? Options: proxy-level (vault-proxy.py inspects Moltbook responses), workspace-level (patterns loaded as agent resource), or host-level (periodic scan of agent's feed interactions) |
| Export injection patterns | Create a machine-readable export of the 25 patterns that vault-proxy.py or the agent can consume |
| Coordinate with vault Phase 5c | Align on the integration approach |
| Test end-to-end | Agent interacts with Moltbook, feed content is scanned, injection flagged |

**This is not blocking anything now** — Moltbook domains are not in the vault's allowlist until Soft Shell or later.

**Exit criteria:** Feed scanning integration designed and documented. Pattern export format defined.

---

## Phase 5: Pattern Harmonization with Forge

**Why:** Forge has 87 patterns for skill content. Pioneer has 25 patterns for social content. Different domains, different patterns — but the format and tooling could be shared.

| Task | Details |
|---|---|
| Compare pattern formats | Forge uses `tools/lib/patterns.sh`. Pioneer uses `config/injection-patterns.yml`. Assess whether a shared format is beneficial. |
| Identify overlapping patterns | Are any of pioneer's 25 patterns already covered by forge's 87? Document overlap. |
| Evaluate shared pattern library | If overlap is significant, consider a shared `patterns/` directory in lobster-trapp root. If not, keep separate (different domains warrant different patterns). |

**Decision: Don't force convergence.** Skill content and social content have different threat profiles. Shared tooling is only valuable if it reduces maintenance burden without losing domain specificity.

**Exit criteria:** Pattern comparison documented. Decision made (share or keep separate) with rationale.

---

## Dependency Graph

```
Phase 1 (Bug fixes)
    ↓
Phase 2 (Automated tests)
    ↓
Phase 3 (Offline mode)
    ↓
Phase 4 (Vault integration) ← depends on vault Phase 4/5
    ↓
Phase 5 (Pattern harmonization) ← depends on forge Phase 4
```

---

*This roadmap covers the moltbook-pioneer module only. See `openclaw-vault/docs/roadmap.md` and `clawhub-forge/docs/roadmap.md` for the other modules.*
