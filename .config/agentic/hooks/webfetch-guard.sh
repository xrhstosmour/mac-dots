#!/bin/bash
# Blocks WebFetch on hosts that have a dedicated CLI/skill instead. github.com/sentry.io
# also sit in claude/settings.json's permissions.deny as a defense-in-depth fallback;
# self-hosted Phabricator/Grafana hostnames can't be expressed as a static domain: rule,
# so those rely on this hook alone.
input=$(cat)
[ "$(echo "$input" | jq -r '.tool_name // empty')" = "WebFetch" ] || exit 0
url=$(echo "$input" | jq -r '.tool_input.url // empty')
# Match against the host only, not the full URL, so a path/query segment that
# happens to contain one of these words (e.g. blog.example.com/learn-grafana)
# isn't mistaken for the real host.
host=$(echo "$url" | sed -E 's#^[a-zA-Z]+://##; s#[/?#].*##; s#:[0-9]+$##')
if echo "$host" | grep -qiE '(^|\.)github\.com$'; then
  reason="Use the gh CLI per the read-github-pr/read-github-issue/read-github-files/manage-github-pr/manage-github-issue skills, not WebFetch."
elif echo "$host" | grep -qiE '(^|\.)phabricator\.'; then
  reason="Use the Conduit API per the read-phabricator-task skill, not WebFetch."
elif echo "$host" | grep -qiE '(^|\.)sentry\.io$'; then
  reason="Use sentry-cli/curl per the read-sentry-issue skill, not WebFetch."
elif echo "$host" | grep -qiE '(^|\.)grafana\.'; then
  reason="Use logcli per the search-grafana-logs skill, not WebFetch."
else
  exit 0
fi
jq -n --arg reason "$reason" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
