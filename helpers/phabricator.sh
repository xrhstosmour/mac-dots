#!/bin/bash

# Derive the org's Phabricator MCP URL from `~/.arcrc`, standard `arc`/Phabricator
# tooling config, not company-specific, works for anyone with `arc` set up for
# their own instance. `/ai/mcp` is a path convention, not guaranteed universal,
# but it's a reasonable first guess before falling back to asking the user
# (handled per-skill, see the read-phabricator-task/manage-phabricator-task
# skills). Never hardcode an org's actual URL in this repo. Prints nothing, and
# returns success, when `~/.arcrc` or `jq` aren't available yet, callers decide
# what "nothing derived" means for them.
# Usage:
#   PHABRICATOR_MCP_URL="${PHABRICATOR_MCP_URL:-$(derive_phabricator_mcp_url)}"
derive_phabricator_mcp_url() {
  local host

  [ -f "$HOME/.arcrc" ] || return 0
  command -v jq &>/dev/null || return 0

  host=$(jq -r '.hosts | to_entries[] | select(.key | test("phabricator")) | .key' "$HOME/.arcrc" 2>/dev/null | head -1)
  [ -n "$host" ] && echo "${host%/api/}/ai/mcp"
}
