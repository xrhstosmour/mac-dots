#!/bin/bash

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  size_bytes=$(stat -f%z "$transcript_path")
  mtime=$(stat -f%m "$transcript_path")
  now=$(date +%s)
  idle_seconds=$((now - mtime))
  idle_minutes=$((idle_seconds / 60))
  estimated_tokens=$((size_bytes / 17))

  size_warn_bytes=850000
  idle_warn_seconds=7200
  growth_cooldown_bytes=255000

  if [ "$size_bytes" -gt "$size_warn_bytes" ] || [ "$idle_seconds" -gt "$idle_warn_seconds" ]; then
    # Cooldown marker so this doesn't re-fire the handoff instruction every single turn
    # once the threshold is crossed, only on meaningful growth or after enough time passes.
    marker="${TMPDIR:-/tmp}/agentic-context-guard-${session_id:-unknown}"
    last_warned_size=0
    last_warned_time=0
    if [ -f "$marker" ]; then
      last_warned_size=$(cut -d' ' -f1 "$marker" 2>/dev/null)
      last_warned_time=$(cut -d' ' -f2 "$marker" 2>/dev/null)
      last_warned_size=${last_warned_size:-0}
      last_warned_time=${last_warned_time:-0}
    fi
    growth=$((size_bytes - last_warned_size))
    since_last_warn=$((now - last_warned_time))

    if [ ! -f "$marker" ] || [ "$growth" -ge "$growth_cooldown_bytes" ] || [ "$since_last_warn" -ge "$idle_warn_seconds" ]; then
      echo "${size_bytes} ${now}" > "$marker"
      size_megabytes=$((size_bytes / 1024 / 1024))
      echo ""
      echo "# Context Health Warning"
      echo ""
      echo "This session's transcript is ~${size_megabytes}MB (~${estimated_tokens} estimated tokens), last active ${idle_minutes} minutes ago."
      echo "Long idle gaps on large contexts force an expensive full cache rebuild on the next turn."
      echo "Finish responding to the user's current request first. Then inform them their context is large or stale, and advise compacting, handoff, or a new session."
      echo "Do not interrupt the current answer to do this, and do not invoke anything yourself, only inform and advise."
    fi
  fi
fi
