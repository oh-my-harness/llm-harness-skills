# Architecture

Use this reference when deciding where a change belongs in the LLM Harness framework family.

## Layers

`llm-api-adapter` is the provider adapter layer. It normalizes OpenAI Chat Completions, Anthropic Messages, DeepSeek, and OpenAI-compatible endpoints into canonical request, response, stream, tool-call, reasoning, usage, and error types.

`llm-harness-core` is the agent framework layer. It defines messages, tools, execution environments, hooks, events, the streaming loop, `Agent`, `AgentHarness`, sessions, compaction, and skills/templates.

`llm-harness-runtime` is a higher-level runtime wrapper for coding-agent style products. It provides built-in tools, prompt assembly, settings, context-file loading, JSONL session wiring, retry, and auto-compaction.

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

Runtime:

- `CodingAgent` / `CodingAgentBuilder`: coding-agent runtime wrapper.
- `tools`: read/bash/edit/write/grep/find/ls.
- `prompt`: system prompt assembly.
- `settings`: global/project settings merge.

## Choosing The Entry Point

Use `Agent` when the task is a lightweight stateful prototype, test, or script. It keeps an in-memory transcript and emits `AgentEvent`.

Use `AgentHarness` when the task needs session persistence, compaction, skills/templates, branch/session operations, harness lifecycle events, hooks, or product-facing observability.

Use runtime `CodingAgentBuilder` when the product intentionally resembles a coding agent and wants built-in tools, prompt assembly, context file loading, JSONL sessions, retry, and auto-compaction.

Use `llm-harness-loop` directly only when building a framework/runtime layer or testing loop behavior.

## Boundary Rules

Provider code belongs in `llm-api-adapter`. Do not hand-write provider HTTP clients in product agents unless the task is explicitly to add a new adapter provider.

Tool contracts and hook contracts belong to `llm-harness-types`. Product/domain crates implement those traits.

Agent loop orchestration belongs to core. Product agents should configure `Agent` or `AgentHarness`, not duplicate loop dispatch.

Runtime conveniences belong to `llm-harness-runtime`. Domain products may skip runtime if they need a different product shape.
