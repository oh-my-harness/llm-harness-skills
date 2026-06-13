# Architecture

Use this reference when deciding where a change belongs in the LLM Harness framework family.

## Layers

`llm-api-adapter` is the provider adapter layer. It normalizes OpenAI Chat Completions, Anthropic Messages, DeepSeek, and OpenAI-compatible endpoints into canonical request, response, stream, tool-call, reasoning, usage, and error types.

`llm-harness-core` is the agent framework layer. It defines messages, tools, execution environments, hooks, events, the streaming loop, `Agent`, `AgentHarness`, sessions, compaction, and skills/templates.

`llm-harness-runtime` is the platform/runtime infrastructure layer above core. In v0.2 it is a workspace of platform traits plus optional implementation crates for sandboxing, auth, MCP, tracing, and audit. It provides orchestration mechanisms such as `Sandbox`, `ToolRegistry`, `ToolSource`, `TaskRunner`, `ResourceProvider`, `PromptSource`, `SubAgentSpawner`, `TraceExporter`, `AuditSink`, `BudgetControlAdapter`, and `HumanApprovalWrapper`.

## Crate Map

Adapter:

- `llm_adapter::provider::Provider`: canonical provider trait.
- `llm_adapter::types`: canonical chat request/response/message/content/stream/tool-call types.
- `llm_adapter::openai`: OpenAI Chat Completions and OpenAI-compatible endpoints.
- `llm_adapter::anthropic`: Anthropic Messages.
- `llm_adapter::deepseek`: factory returning a DeepSeek-configured `OpenAIProvider`.

Core:

- `llm-harness-types`: stable contracts for messages, tools, envs, hooks, events, errors, compaction, stream options, thinking level, token usage.
- `llm-harness-loop`: low-level streaming agent loop, adapter bridge, retry config, conversion, and tool dispatch.
- `llm-harness`: public framework facade with `Agent`, `AgentHarness`, session repos, compaction, and skill/template loading.

Runtime v0.2:

- `crates/llm-harness-runtime`: platform traits and core orchestration helpers.
- `llm-harness-runtime-sandbox-os`: development/local `OsEnvSandbox`.
- `llm-harness-runtime-sandbox-bwrap`: Linux bubblewrap sandbox backend.
- `llm-harness-runtime-sandbox-seatbelt`: macOS seatbelt sandbox backend.
- `llm-harness-runtime-auth`: `EnvAuthHook` and `FileAuthHook`.
- `llm-harness-runtime-mcp`: MCP tool/prompt adapter layer through runtime traits.
- `llm-harness-runtime-audit-jsonl`: JSONL `AuditSink`.
- `llm-harness-runtime-trace-otel`: tracing exporters including in-memory and OTLP-style tracing.

## Choosing The Entry Point

Use `Agent` when the task is a lightweight stateful prototype, test, or script. It keeps an in-memory transcript and emits `AgentEvent`.

Use `AgentHarness` when the task needs session persistence, compaction, skills/templates, branch/session operations, harness lifecycle events, hooks, or product-facing observability.

Use runtime v0.2 when the product needs platform services around core: sandbox lifecycle, tool discovery/registry, MCP integration, resource injection, prompt source compilation, task lifecycle/checkpoints, sub-agent spawning, tracing, audit, budget control, auth, or human approval. Runtime does not replace `AgentHarness`; it composes around it through core hooks and platform traits.

Use `llm-harness-loop` directly only when building a framework/runtime layer or testing loop behavior.

## Boundary Rules

Provider code belongs in `llm-api-adapter`. Do not hand-write provider HTTP clients in product agents unless the task is explicitly to add a new adapter provider.

Tool contracts and hook contracts belong to `llm-harness-types`. Product/domain crates implement those traits.

Agent loop orchestration belongs to core. Product agents should configure `Agent` or `AgentHarness`, not duplicate loop dispatch.

Runtime platform concerns belong to `llm-harness-runtime`. Product agents still own product prompts, provider selection policy, domain tools, task verification policy, and UI/CLI integration.
