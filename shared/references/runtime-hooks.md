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

In runtime v0.2, `BudgetControlAdapter` is the standard bridge from cost policy to core hooks. It implements provider-response accounting and stop decisions through core hook traits. It should be registered alongside `after_provider_response` and `should_stop` rather than handled in business call sites.

`AuditSink` and implementations such as JSONL audit belong to runtime. Use audit sinks for decision and state-transition records; keep large replay/debug payloads in tracing or tool details when appropriate.

## Context Transforms

Use `TransformContextHook` for systematic context changes before LLM calls. This is the right place for compaction-style transforms, redaction, injected memory, or filtering.

Avoid mutating session storage directly as a substitute for context transforms.

## Auth

`AuthHook` resolves current credentials before LLM calls. Use it when keys can rotate or provider auth should be resolved dynamically.

If using provider switching, make sure auth provider names and env var conventions match the selected provider.

Runtime v0.2 reuses core `AuthHook` instead of defining a parallel auth trait. The `llm-harness-runtime-auth` crate provides `EnvAuthHook` and `FileAuthHook`.

## Hook Composition

When multiple before-tool policies apply, compose hooks instead of overwriting one another. Runtime v0.2 provides composite hook helpers such as `CompositeBeforeToolCallHook`, `CompositeAfterToolCallHook`, `CompositeAfterTurnHook`, `CompositeBeforeProviderRequestHook`, and `CompositeAfterProviderResponseHook`.

Order matters. Put hard-deny safety policies before softer rewriting policies when denial should win.

When tracing and budget both observe provider responses, register tracing first and budget second so spans are captured even when budget control stops later turns.

`HarnessHooks` is cloneable. Runtime task orchestration can build hook sets once and pass them into `TaskRunnerImpl::with_hooks(...)`, which wires them into the `AgentHarness` created by `TaskRunnerImpl::start()` when `with_harness(client, model)` has also been configured.

## Runtime Platform Hooks

Runtime v0.2 uses core hooks to attach platform services:

- `HumanApprovalWrapper`: implements `BeforeToolCallHook`.
- `BudgetControlAdapter`: uses provider response accounting and stop decisions.
- `TracingHookAdapter`: maps provider, tool, and turn events to `TraceExporter` spans.
- `ResourceInjector`: injects `ResourceProvider` content through context transformation patterns.
- `PromptTemplateCompiler`: compiles runtime `PromptSourceTemplate` into core `PromptTemplate` instead of introducing a second prompt engine.

Do not create parallel hook systems in runtime or product crates when a core hook expresses the same lifecycle point.

## Common Mistakes

Do not hide business workflow state in global variables. Keep shared hook/orchestrator state explicit, usually behind `Arc<Mutex<_>>` or a domain state object.

Do not use `ShouldStopHook` to interrupt an active turn. Use abort/cancellation for active interruption.

Do not use provider response hooks to mutate message content; they are observation/accounting hooks.
