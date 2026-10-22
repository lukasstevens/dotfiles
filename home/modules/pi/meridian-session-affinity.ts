import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Keep Meridian's backing Claude session stable across Pi tool rounds. */
export default function (pi: ExtensionAPI) {
  pi.on("before_provider_headers", (event, ctx) => {
    // The Meridian provider configuration supplies this routing header.
    // Leave direct Anthropic requests and other providers untouched.
    if (ctx.model?.provider !== "anthropic" || event.headers["x-meridian-agent"] !== "pi") return;

    // Resolve on every request so new sessions and forks get their own key.
    const sessionId = ctx.sessionManager.getSessionId();
    if (sessionId) event.headers["x-session-affinity"] = sessionId;
  });
}
