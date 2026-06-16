# Testing Patterns

Use this reference when adding tests around providers, harness loops, tools, hooks, or runtime integrations.

## Provider Adapter Tests

`llm-api-adapter` is designed for offline tests with recorded fixtures and `wiremock`. Default tests should not require network or API keys.

Integration tests against real providers should be opt-in and gated by feature flags and environment variables.

For DeepSeek, look for existing `deepseek_*` tests and `integration_deepseek.rs` patterns before adding new coverage.

## Core Loop Tests

Use `llm-harness-loop` test utilities when available. With the `test-utils` feature, use mock clients to drive deterministic responses.

Core compaction and harness integration tests that depend on mock clients are gated behind the `test-utils` feature. When adding tests that use `MockLlmClient`, `MockResponse`, or `NoOpEnv`, ensure the crate feature is enabled in the test target or guard the test module appropriately.

Test loop behavior with:

- text responses
- tool calls
- tool errors
- streaming deltas
- aborted runs
- retryable provider errors
- max-token/should-stop behavior

## Harness Tests

Use `AgentHarness::new_in_memory` for focused tests.

Subscribe to events before `prompt` when asserting event emission.

Assert phase returns to idle after success and after expected errors.

For session behavior, inspect the session context after prompt completion.

## Tool Tests

Test tools independently by creating a `ToolContext` with a mock or local execution env.

Assert bad arguments fail cleanly and do not panic.

Assert `ToolResult.content` and `ToolResult.details` separately.

Use temp directories for filesystem tools.

## Hook Tests

Test hooks with minimal context structs where possible.

For harness-level behavior, attach the hook to `AgentHarnessOptions` and drive a mock model response that triggers the hook path.

Assert both the hook decision and the final event/session effects.

## Runtime Tests

For runtime v0.2, test platform traits and implementation crates separately:

- `llm-harness-runtime`: traits, registries, adapters, task state, budget, approval, audit, tracing adapters.
- `llm-harness-runtime-sandbox-os`: local sandbox and `ExecutionEnv` behavior.
- `llm-harness-runtime-sandbox-bwrap`: Linux-specific sandbox behavior.
- `llm-harness-runtime-sandbox-seatbelt`: macOS-specific sandbox behavior.
- `llm-harness-runtime-auth`: env/file auth hooks.
- `llm-harness-runtime-audit-jsonl`: JSONL audit sink.
- `llm-harness-runtime-trace-otel`: in-memory and exporter behavior.

Use temp directories for sandbox work dirs, audit logs, auth files, checkpoints, session storage, and resource/prompt fixtures.

Use in-memory exporters and fake providers for deterministic runtime tests. Do not make runtime unit tests depend on a real MCP server, OTel collector, or provider API unless the test is explicitly an opt-in integration test.

For `TaskRunnerImpl`, cover both modes: the no-client stub path for state transitions and the `with_harness(client, model)` path with `MockLlmClient` for end-to-end task execution. When testing hook wiring, pass cloned `HarnessHooks` through `with_hooks(...)` and assert observable effects such as exported tracing spans.

## Real API Tests

Gate real API tests behind environment variables:

- `DEEPSEEK_API_KEY`
- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`

Skip, do not fail, when the relevant key is absent.

Keep real API prompts stable, cheap, and short. Avoid depending on exact prose unless testing wire-format behavior.

## Verification Commands

Use focused commands first:

```powershell
cargo test -p <crate-name> <test-name>
```

Then broaden as needed:

```powershell
cargo test --workspace
```

For adapter integration tests, follow the repository's feature and script conventions instead of inventing new environment handling.
