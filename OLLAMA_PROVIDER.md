# Ollama provider

AI Hub does not expose `ollama` as a native `%AI.Provider` name. Ollama uses
the SDK's `openai` provider through its OpenAI-compatible `/v1` API.

## 1. Start Ollama on the host

```bash
ollama serve
ollama pull llama3.2
ollama list
```

From macOS, verify the server:

```bash
curl http://localhost:11434/api/tags
curl http://localhost:11434/v1/models
```

IRIS runs in Docker, so it reaches the host using `host.docker.internal`.
Verify this before testing AI Hub:

```bash
docker exec iris-ai-hub-studio python3 -c 'import urllib.request; print(urllib.request.urlopen("http://host.docker.internal:11434/v1/models").read().decode())'
```

If this request is refused, make Ollama listen beyond loopback. For a local
development machine, start it with `OLLAMA_HOST=0.0.0.0:11434`. Binding to
`0.0.0.0` exposes Ollama to the local network; use it only on a trusted network.

## 2. Create and chat with a runtime agent

Open an IRIS terminal in namespace `AI_HUB_STUDIO`:

```objectscript
Set sc=##class(AIHubStudio.AI.OllamaProvider).CreateAgent(.agent,"llama3.2","You are a concise assistant.")
Write $SYSTEM.Status.GetErrorText(sc),!

Set session=agent.CreateSession()
Set response=agent.Chat(session,"Hello! Introduce yourself.")
Write response.Content,!
```

The default endpoint is `http://host.docker.internal:11434/v1/`. To override it:

```objectscript
Set sc=##class(AIHubStudio.AI.OllamaProvider).CreateAgent(.agent,"qwen3:8b","You are helpful.","http://host.docker.internal:11434")
```

The implementation normalizes the URL to end in `/v1/`. The model string must
exactly match a model returned by `ollama list` or `/v1/models`.

## 3. Save provider and agent metadata

Metadata registration is separate from runtime object creation:

```objectscript
Set provider=##class(AIHubStudio.AI.Provider).Create("LocalOllama","ollama")
Do provider.Endpoint("http://host.docker.internal:11434/v1/")
Do provider.DefaultModel("llama3.2")
Set sc=provider.Save()
Write $SYSTEM.Status.GetErrorText(sc),!

Set savedAgent=##class(AIHubStudio.AI.Agent).Create("OllamaAssistant")
Do savedAgent.Provider("LocalOllama")
Do savedAgent.Model("llama3.2")
Do savedAgent.Instructions("You are a concise assistant.")
Set sc=savedAgent.Save()
Write $SYSTEM.Status.GetErrorText(sc),!
```

To construct the runtime from that metadata:

```objectscript
Set savedAgent=##class(AIHubStudio.AI.Agent).Open("OllamaAssistant")
Set savedProvider=##class(AIHubStudio.AI.Provider).Open(savedAgent.Provider)
Set sc=##class(AIHubStudio.AI.OllamaProvider).CreateAgent(.agent,savedAgent.Model,savedAgent.Instructions,savedProvider.Endpoint)
Write $SYSTEM.Status.GetErrorText(sc),!
```

No real API key is necessary. Internally the factory supplies the placeholder
`ollama` because the AI Hub OpenAI adapter expects an `api_key` setting.

## 4. Expected negative tests

Missing model:

```objectscript
Set sc=##class(AIHubStudio.AI.OllamaProvider).CreateAgent(.agent,"","")
Write $SYSTEM.Status.GetErrorText(sc),!
```

Expected: status error `Ollama model is required`.

Unknown model:

```objectscript
Set sc=##class(AIHubStudio.AI.OllamaProvider).CreateAgent(.agent,"model-that-does-not-exist","")
Set session=agent.CreateSession()
Set response=agent.Chat(session,"hello")
```

Expected: provider/model-not-found error from Ollama during `Chat()`.
