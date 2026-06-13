# Anti-Patterns

Use this reference as a checklist before finalizing framework changes.

## Provider Anti-Patterns

Do not bypass `llm_adapter` with raw HTTP in product-agent code.

Do not hardcode `AnthropicProvider` or `OpenAIProvider` in every business function. Use a provider factory when multiple providers may be supported.

Do not leave `EnvAuthHook::for_provider("anthropic")` in a DeepSeek or provider-agnostic path.

Do not read provider environment variables at every call site. Centralize config resolution.

Do not force native provider paths into generic provider-switching code.

Do not assume `ChatRequest::extended_thinking_budget` controls every provider's reasoning mode. It is currently consumed by Anthropic conversion and ignored elsewhere unless support is added.

## Core/Runtime Boundary Anti-Patterns

Do not put product prompts, CLI/TUI concerns, auth storage policy, or model registry policy into `llm-harness-core`.

Do not put low-level agent loop logic into runtime or product crates when `Agent` or `AgentHarness` can do it.

Do not treat runtime v0.2 as a replacement for core. Runtime composes around core using `AgentHarness`, platform traits, and hooks.

Do not reintroduce a monolithic `CodingAgentBuilder` abstraction as the only runtime path. Runtime v0.2 is a platform layer; product agents should assemble only the services they need.

Do not duplicate runtime platform traits in product crates when runtime already exposes `Sandbox`, `ToolRegistry`, `ToolSource`, `ResourceProvider`, `PromptSource`, `TaskRunner`, `SubAgentSpawner`, `TraceExporter`, `AuditSink`, `AuthHook`, `BudgetControlAdapter`, or `HumanApprovalWrapper`.

## Tool Anti-Patterns

Do not call local filesystem or shell APIs directly from tools when `ExecutionEnv` can express the operation.

Do not put UI/audit-only payloads in `ToolResult.content`.

Do not panic on invalid tool arguments.

Do not encode provider/model assumptions inside tools.

Do not make mutating tools parallel when they must serialize.

## Hook Anti-Patterns

Do not implement global approval, budget, audit, or replan policy separately in each tool.

Do not overwrite existing hooks without checking whether composition is needed.

Do not register tracing, budget, audit, and approval hooks by assigning the same `HarnessHooks` slot repeatedly. Use runtime composite hook helpers when multiple adapters need the same lifecycle point.

Do not use `ShouldStopHook` as active cancellation.

Do not mutate session logs manually to simulate context transforms.

## Event/Streaming Anti-Patterns

Do not subscribe after calling `prompt` if the caller needs all events.

Do not stop consuming on the first text delta.

Do not confuse LLM tool-call events with Rust tool-execution events.

Do not ignore `Aborted`, `Settled`, `AgentEnd`, or idle-state completion.

## Testing Anti-Patterns

Do not make ordinary tests require real API keys.

Do not assert exact natural-language responses from real models unless the test is explicitly brittle by design.

Do not skip phase/idle assertions after error paths.

Do not test provider switching only through a live provider; use mock/factory tests too.
