// OpenCode adapter for the agentic hooks. Mirrors what Claude Code does via
// settings.json:
//   - Blocks WebFetch on service URLs that have a dedicated CLI, since OpenCode
//     cannot deny WebFetch by host in config (Claude uses permissions.deny).
//   - Warns once a session's token usage or idle time gets large, mirroring
//     Claude Code's context-guard.sh (same thresholds, exact token counts here
//     instead of a byte-size estimate, since the session API reports them).
//     Thresholds are intentionally aggressive (50K tokens, 30 min idle) to
//     force compaction before context bloat becomes irreversible.
//
// Static instructions (communication/standards/versioning) load via opencode.json's
// `instructions` array instead, no hook needed for those.
//
// experimental.chat.system.transform is not on opencode.ai/docs. Source of truth:
//   signature:  https://github.com/anomalyco/opencode/blob/dev/packages/plugin/src/index.ts
//   invocation: https://github.com/anomalyco/opencode/blob/dev/packages/opencode/src/session/llm/request.ts
//   session shape (tokens, time.updated in epoch ms): https://github.com/anomalyco/opencode/blob/dev/packages/core/src/session.ts

// Service URLs that must go through a dedicated CLI, never WebFetch.
const blockedHosts = [
  { pattern: /github\.com/i, use: "the `gh` CLI, see the `read-github-pr`/`read-github-issue`/`read-github-files` skills" },
  { pattern: /phabricator\./i, use: "the Conduit API per the `read-phabricator-task` skill" },
  { pattern: /sentry\.io/i, use: "`sentry-cli` per the `read-sentry-issue` skill" },
  { pattern: /grafana\./i, use: "`logcli` per the `search-grafana-logs` skill" },
];

// Warn early. 50K tokens is roughly 2-3 API calls with a full context window.
// At 180K the context is already bloated and compaction cannot recover lost cache.
const SIZE_WARN_TOKENS = 50000;
const IDLE_WARN_SECONDS = 1800;
const GROWTH_COOLDOWN_TOKENS = 15000;

// In-memory, per running OpenCode process. Mirrors context-guard.sh's file-based
// cooldown marker, so this doesn't re-fire the handoff instruction every single
// turn once the threshold is crossed, only on meaningful growth or after enough
// idle time passes.
const lastWarned = new Map();

export const AgenticReminderPlugin = async ({ client }) => {
  return {
    "experimental.chat.system.transform": async (input, output) => {
      const sessionID = input.sessionID;
      if (!sessionID) return;

      try {
        const { data: session } = await client.session.get({ path: { id: sessionID } });
        if (!session) return;

        const tokens = session.tokens ?? {};
        const totalTokens = (tokens.input ?? 0) + (tokens.output ?? 0) + (tokens.cache?.read ?? 0) + (tokens.cache?.write ?? 0);
        const idleSeconds = (Date.now() - (session.time?.updated ?? Date.now())) / 1000;

        if (totalTokens > SIZE_WARN_TOKENS || idleSeconds > IDLE_WARN_SECONDS) {
          const nowSeconds = Date.now() / 1000;
          const last = lastWarned.get(sessionID);
          const growth = totalTokens - (last?.tokens ?? 0);
          const sinceLastWarn = nowSeconds - (last?.time ?? 0);

          if (!last || growth >= GROWTH_COOLDOWN_TOKENS || sinceLastWarn >= IDLE_WARN_SECONDS) {
            lastWarned.set(sessionID, { tokens: totalTokens, time: nowSeconds });
            const idleMinutes = Math.round(idleSeconds / 60);
            output.system.push(
              `# Context Health Warning\n\nThis session has used ~${totalTokens} tokens, last active ${idleMinutes} minutes ago. Long sessions burn tokens because every API call re-sends the full conversation history.\nFinish responding to the user's current request first. Once that's done, invoke the handoff skill on your own, without asking the user for permission first, then mention the saved path in one line before compacting or starting a fresh session.\nDo not interrupt the current answer to do this, and do not just surface this as a warning and wait for a permission decision.`,
            );
          }
        }
      } catch {
        // Best-effort. Never break a session if session info can't be fetched.
      }
    },
    "tool.execute.before": async (input, output) => {
      if ((input.tool ?? "").toLowerCase() !== "webfetch") return;
      const url = String(output.args?.url ?? "");
      const blocked = blockedHosts.find((host) => host.pattern.test(url));
      if (blocked) {
        throw new Error(`Blocked: use ${blocked.use}, not WebFetch.`);
      }
    },
  };
};
