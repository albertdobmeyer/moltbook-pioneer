.PHONY: help scan scan-agent census census-trend checklist check-api setup test verify

TOOLS_DIR := tools
TESTS_DIR := tests

# Default target
help: ## Show available commands
	@grep -E '^[a-z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk -F ':.*## ' '{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# ── Operations ──────────────────────────────────────────
scan: ## Scan recent feed (COUNT=n, default 50)
	@bash $(TOOLS_DIR)/feed-scanner.sh --recent $(or $(COUNT),50)

scan-agent: ## Scan specific agent (AGENT=handle)
	@bash $(TOOLS_DIR)/feed-scanner.sh --agent $(AGENT)

census: ## Pull current platform stats
	@bash $(TOOLS_DIR)/agent-census.sh

census-trend: ## Show trend data from saved snapshots
	@bash $(TOOLS_DIR)/agent-census.sh --trend

checklist: ## Run identity pre-flight checklist
	@bash $(TOOLS_DIR)/identity-checklist.sh

check-api: ## Check Moltbook API liveness
	@echo "Checking Moltbook API..."
	@curl -sf --max-time 10 https://api.moltbook.com/posts?limit=1 >/dev/null 2>&1 \
		&& echo "  API: UP (api.moltbook.com responds)" \
		|| echo "  API: DOWN or unreachable (api.moltbook.com)"

# ── Lifecycle ───────────────────────────────────────────
setup: ## Copy .env.example → .env, create data/
	@cp -n config/.env.example config/.env 2>/dev/null && \
		echo "Created config/.env from template" || \
		echo "config/.env already exists"
	@mkdir -p data
	@echo "Setup complete — edit config/.env to configure"

# ── Testing ─────────────────────────────────────────────
test: ## Run tool test suite
	@bash $(TESTS_DIR)/_framework/tool-runner.sh

# ── Verification ────────────────────────────────────────
verify: ## Verify workbench health (config, tools, patterns)
	@echo "Moltbook Pioneer — Health Check"
	@echo ""
	@printf "  config/.env              ... " && \
		(test -f config/.env && echo "OK" || echo "MISSING (run make setup)")
	@printf "  feed-scanner.sh +x       ... " && \
		(test -x $(TOOLS_DIR)/feed-scanner.sh && echo "OK" || echo "FAIL")
	@printf "  agent-census.sh +x       ... " && \
		(test -x $(TOOLS_DIR)/agent-census.sh && echo "OK" || echo "FAIL")
	@printf "  identity-checklist.sh +x ... " && \
		(test -x $(TOOLS_DIR)/identity-checklist.sh && echo "OK" || echo "FAIL")
	@printf "  injection-patterns.yml   ... " && \
		(python3 -c "import yaml; d=yaml.safe_load(open('config/injection-patterns.yml')); print(f'OK ({sum(len(v) for v in d.values())} patterns)')" 2>/dev/null || \
		python3 -c "import json,re; t=open('config/injection-patterns.yml').read(); print('OK (YAML present)')" 2>/dev/null || \
		echo "FAIL")
	@printf "  feed-allowlist.yml       ... " && \
		(test -f config/feed-allowlist.yml && echo "OK" || echo "MISSING")
	@echo ""
