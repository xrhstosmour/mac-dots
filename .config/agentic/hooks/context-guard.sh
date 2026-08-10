#!/bin/bash

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  mtime=$(stat -f%m "$transcript_path" 2>/dev/null || stat -c%Y "$transcript_path" 2>/dev/null)
  now=$(date +%s)
  idle_seconds=$((now - mtime))
  idle_minutes=$((idle_seconds / 60))

  # Matches Claude Code's automatic 1-hour prompt-cache TTL on a subscription
  # (code.claude.com/docs/en/prompt-caching#cache-lifetime). Past this point the
  # cache is already cold, so warn right at the boundary, not an hour after it.
  idle_warn_seconds=3600

  if [ "$idle_seconds" -gt "$idle_warn_seconds" ]; then
    echo ""
    echo "# Context Health Warning"
    echo ""
    echo "This session has been idle for ~${idle_minutes} minutes."
    echo "Long idle gaps force an expensive full cache rebuild on the next turn."
    echo "Finish responding to the user's current request first. Then inform them the session has been idle a while, and advise compacting, handoff, or a new session."
    echo "Do not interrupt the current answer to do this, and do not invoke anything yourself, only inform and advise."
  fi
fi
