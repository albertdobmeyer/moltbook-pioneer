#!/usr/bin/env bash
# Tests for agent-census.sh

CENSUS="$REPO_ROOT/tools/agent-census.sh"

test_help_exits_0() {
  assert_exit_code 0 bash "$CENSUS" --help
}

test_help_shows_usage() {
  assert_output_contains "Usage" bash "$CENSUS" --help
}

test_bogus_flag_exits_1() {
  assert_exit_code 1 bash "$CENSUS" --bogus
}
