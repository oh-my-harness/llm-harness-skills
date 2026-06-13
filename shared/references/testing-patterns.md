# Testing Patterns

Use this reference when adding tests around providers, harness loops, tools, hooks, or runtime integrations.

## Provider Adapter Tests

`llm-api-adapter` is designed for offline tests with recorded fixtures and `wiremock`. Default tests should not require network or API keys.

Integration tests against real providers should be opt-in and gated by feature flags and environment variables.

For DeepSeek, look for existing `deepseek_*` tests and `integration_deepseek.rs` patterns before adding new coverage.

## Core Loop Tests

Use `llm-harness-loop` test utilities when available. With the `test-utils` feature, use mock clients to drive deterministic responses.

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

For `CodingAgentBuilder`, test builder behavior without network by passing a mock `Arc<dyn LlmClient>`.

Use temp directories for session storage, context files, settings files, and skill/template dirs.

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
