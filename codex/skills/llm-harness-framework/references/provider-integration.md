# Provider Integration

Use this reference for LLM provider changes, DeepSeek support, OpenAI-compatible endpoints, runtime switching, or provider factories.

## Core Interface

The canonical provider trait is:

```rust
llm_adapter::provider::Provider
```

`llm-harness-loop` re-exports it as:

```rust
pub use llm_adapter::provider::Provider as LlmClient;
```

Core and product-agent code should pass providers as:

```rust
Arc<dyn LlmClient>
```

## DeepSeek

DeepSeek is already supported by `llm-api-adapter`:

```rust
use std::sync::Arc;
use llm_adapter::deepseek;
use llm_harness_loop::LlmClient;

let client = Arc::new(deepseek::client(api_key)) as Arc<dyn LlmClient>;
```

`deepseek::client(api_key)` returns an `OpenAIProvider` configured with:

- `base_url("https://api.deepseek.com")`
- `parse_reasoning_content(true)`
- `tolerant_keepalive(true)`
- capabilities: `images = false`, `reasoning = true`, `json_schema = true`

Use `DEEPSEEK_API_KEY` for the key. Use `DEEPSEEK_MODEL` or a product-level `LLM_MODEL` convention for the model. Common model names in examples include `deepseek-v4-flash` and `deepseek-reasoner`.

## OpenAI-Compatible Endpoints

Use `OpenAIProvider::builder(key)` with `base_url` and optional `chat_path` overrides:

```rust
use llm_adapter::openai::OpenAIProvider;

let provider = OpenAIProvider::builder(key)
    .base_url("https://example.com")
    .chat_path("/v1/chat/completions")
    .build();
```

Use `OpenAIExt::extra_body` for gateway-specific fields that do not belong in canonical `ChatRequest`.

## Universal vs Native Paths

Use universal calls for provider-agnostic agent code:

```rust
provider.chat(&req).await?;
provider.chat_stream(&req).await?;
```

Use native provider paths only when the product needs provider-specific knobs:

- OpenAI: seed, penalties, `reasoning_effort`, `extra_body`, native response format behavior.
- DeepSeek: disabling thinking with `extra_body`, gateway-specific fields.
- Anthropic: `thinking`, `top_k`, metadata, cache hints, structured output via tool use.

Native paths require concrete provider types and are not object-safe through `Arc<dyn LlmClient>`.

## Extended Thinking

The current adapter exposes a provider-agnostic `ChatRequest::extended_thinking_budget(...)` builder field:

```rust
let req = ChatRequest::builder(model, max_tokens)
    .message(Message::User(vec![RequestContent::Text(prompt.into())]))
    .extended_thinking_budget(2_000)
    .build();
```

This canonical field is supported by Anthropic conversion and ignored by providers that do not support it. Anthropic native `AnthropicExt::thinking(...)` still exists and overrides the canonical request budget when both are present.

Use the canonical field when generic harness/runtime code wants to request thinking without depending on Anthropic native types. Use native `AnthropicExt` only when other Anthropic-specific fields are also needed.

DeepSeek reasoning is exposed through parsed `reasoning_content`; do not use `extended_thinking_budget` as a DeepSeek thinking control. Use OpenAI-compatible native `extra_body` only for DeepSeek-specific controls such as disabling thinking for tool-choice edge cases.

## Provider Factory Pattern

When a product supports multiple providers, centralize provider construction.

Recommended shape:

```rust
pub struct LlmConfig {
    pub provider: String,
    pub model: String,
    pub api_key: String,
    pub base_url: Option<String>,
    pub chat_path: Option<String>,
}

pub struct LlmRuntimeConfig {
    pub model: String,
    pub client: Arc<dyn LlmClient>,
    pub auth_provider_name: String,
}
```

Keep environment-variable parsing near this factory. Avoid reading provider env vars at every harness call site.

## Harness Integration

Pass the provider into `Agent` or `AgentHarness`:

```rust
let opts = AgentHarnessOptions::new(config.model.clone());
let harness = AgentHarness::new_in_memory(config.client, env, opts).await;
```

If using an auth hook, ensure the provider name matches the selected provider convention. Do not leave `EnvAuthHook::for_provider("anthropic")` when using DeepSeek.

## Common Mistakes

Do not bypass `llm_adapter` with raw `reqwest` calls in product code.

Do not hardcode `AnthropicProvider` in chat, planning, solving, and synthesis paths separately.

Do not mix provider-specific model defaults into business logic. Keep them in config.

Do not use native paths in generic runtime-switching code unless the selected provider is known and concrete.

Do not assume `extended_thinking_budget` affects every provider. Guard product expectations with provider capability checks and provider-specific documentation.
