# Moltbook-Pioneer — TODO

Tracked gaps from the 2026-03-03 audit. See `docs/vision-and-status.md` in lobster-trapp for the high-level roadmap.

---

## No Automated Tests

- [ ] Zero test files exist. Vault has 12 test scripts, forge has 168 test functions. At minimum, add tests for:
  - `feed-scanner.sh` pattern matching (known-malicious and known-clean feeds)
  - `agent-census.sh` JSON parsing (mock API responses)
  - `identity-checklist.sh` section validation

---

## safe_patterns Not Wired

- [ ] `config/feed-allowlist.yml` declares a `safe_patterns` key, but `tools/feed-scanner.sh` silently ignores it. The scanner loads `known_safe_accounts` but never reads `safe_patterns`. Either wire it in or remove the key from the config to avoid confusion.

---

## No Executable Bits on Fresh Clone

- [ ] After `git clone`, `tools/*.sh` files lack executable permission. Running any command fails with "permission denied" until `chmod +x tools/*.sh` is run. This is not documented in the quick-start. Fix options:
  - Add `chmod +x` to a setup step
  - Document in README quick-start section
  - Add a git hook or `.gitattributes` entry

---

## eval in curl (Minor Security Surface)

- [ ] `tools/feed-scanner.sh` (~line 197) uses `eval` for auth header construction in curl commands. This is a minor shell injection surface if `.env` values contain malicious content. Replace with direct variable expansion.

---

## API Availability Unknown

- [ ] All three tools call `moltbook.com/api/v1` endpoints. It's unclear if this is a live API. No offline or mock mode exists for testing without network access. Consider adding `--dry-run` with fixture data.
