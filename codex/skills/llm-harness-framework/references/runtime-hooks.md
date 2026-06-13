# Runtime Hooks

Use this reference when adding cross-cutting behavior to an `AgentHarness` run.

## Hook Container

`AgentHarnessOptions` contains:

```rust
pub hooks: HarnessHooks
```

Start from:

```rust
let mut opts = AgentHarnessOptions::new(model);
opts.hooks = HarnessHooks {
    before_tool_call: Some(hook),
    ..HarnessHooks::none()
};
```

## Available Hooks

`before_run`: modify initial messages or system prompt before a prompt run starts.

`before_turn`: observe the start of each turn.

`after_turn`: observe the end of each turn.

`before_tool_call`: allow, modify, or deny a tool call before execution.

`after_tool_call`: pass through or patch a tool result after execution.

`transform_context`: transform the full context before each LLM request.

`prepare_next_turn`: alter context, model, thinking level, tools, or active tools after a turn.

`should_stop`: decide whether natural LLM stop should end the loop or continue.

`before_provider_request`: mutate stream/provider request options before an LLM request.

`after_provider_response`: observe provider response info, usage, status, headers, and latency.

`before_compact`: proceed, skip, or override compaction.

## Approval And Policy

Use `BeforeToolCallHook` for human approval, policy gates, argument rewriting, or denying tools with a synthetic `ToolResult`.

Do not implement approval inside each tool if the policy applies across tools.

## Replanning And Phase Control

Use `BeforeToolCallHook`, `PrepareNextTurnHook`, and `ShouldStopHook` for replan loops or phase control.

A replan tool can set shared state. A hook can detect it and cause the orchestrator to branch or stop. Keep this state explicit and tested.

## Budget And Audit

Use `AfterProviderResponseHook` for token/cost tracking and provider response audit.

Use `before_tool_call`, `after_tool_call`, and turn hooks for tool audit.

Do not sprinkle audit writes across provider calls and tools when a hook can centralize it.

## Context Transforms

Use `TransformContextHook` for systematic context changes before LLM calls. This is the right place for compaction-style transforms, redaction, injected memory, or filtering.

Avoid mutating session storage directly as a substitute for context transforms.

## Auth

`AuthHook` resolves current credentials before LLM calls. Use it when keys can rotate or provider auth should be resolved dynamically.

If using provider switching, make sure auth provider names and env var conventions match the selected provider.

## Hook Composition

When multiple before-tool policies apply, compose hooks instead of overwriting one another. Runtime/core may provide helpers such as composite hook implementations.

Order matters. Put hard-deny safety policies before softer rewriting policies when denial should win.

## Common Mistakes

Do not hide business workflow state in global variables. Keep shared hook/orchestrator state explicit, usually behind `Arc<Mutex<_>>` or a domain state object.

Do not use `ShouldStopHook` to interrupt an active turn. Use abort/cancellation for active interruption.

Do not use provider response hooks to mutate message content; they are observation/accounting hooks.
