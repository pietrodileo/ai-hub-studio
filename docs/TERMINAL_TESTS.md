# Terminal Validation

Run terminal gates before REST or UI tests.

## Start and compile

```bash
docker compose up -d --build iris
docker compose exec -it iris iris session iris -U AI_HUB_STUDIO
```

```objectscript
Set sc=$SYSTEM.OBJ.LoadDir("/home/irisowner/dev/src","ck",,1)
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
Set sc=##class(AIHubStudio.Setup).Run()
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
```

Repeat `Setup.Run()`; both calls must return `PASS`.

Host compliance checks:

```bash
rg '\$LISTCREATE' src
rg -n 'Try|Catch|Quit|Return' src/AIHubStudio
```

First command must return nothing. Review each `Try/Catch`: store status inside block and return only after block.

## Catalog and providers

```objectscript
Set catalog=##class(AIHubStudio.Runtime.AgentCatalog).List()
Write catalog.%ToJSON(),!
Set p=##class(AIHubStudio.AI.Provider).Open("LocalOllama")
Set sc=p.CreateRuntime(.runtimeProvider)
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
```

Expected catalog entries:

- `metadata:OllamaAssistant`
- `native:AIHubStudio.Agent.StudioAssistant`

## Custom providers and agents

Run the automated metadata lifecycle tests first:

```objectscript
Set sc=##class(AIHubStudio.Test).TestCustomProvider()
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
Set sc=##class(AIHubStudio.Test).TestCustomAgent()
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
```

Both calls must print `PASS`. They create temporary records, verify persistence,
catalog discovery and runtime construction, then delete the records.

Create a persistent OpenAI-compatible provider manually. Store only the
environment-variable name in metadata, never the API key:

```objectscript
Set p=##class(AIHubStudio.AI.Provider).Create("MyProvider","openai-compatible")
Do p.Endpoint("https://example.com/v1/")
Do p.APIKeyFromEnvironment("MY_PROVIDER_API_KEY")
Do p.DefaultModel("my-model")
Set sc=p.Save()
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
Set p=##class(AIHubStudio.AI.Provider).Open("MyProvider")
Write p.GetProviderInfo().%ToJSON(),!
```

Before starting the container, provide the credential through `.env` and map
it into the `iris.environment` section of `docker-compose.yml`:

```text
MY_PROVIDER_API_KEY=replace-with-real-key
```

Create and run an agent using that provider:

```objectscript
Set a=##class(AIHubStudio.AI.Agent).Create("MyAssistant")
Do a.Description("My configurable assistant")
Do a.Provider("MyProvider")
Do a.Model("my-model")
Do a.Instructions("Be concise and use tools when appropriate.")
Do a.Temperature(0.2)
Do a.MaxTokens(1000)
Set sc=a.Save()
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
Set sc=a.AddToolSet("AIHubStudio.ToolSet.Starter")
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
Set item=##class(AIHubStudio.Runtime.AgentCatalog).Get("metadata:MyAssistant")
Write item.%ToJSON(),!
Set sc=##class(AIHubStudio.Runtime.Chat).Start("metadata:MyAssistant",.id)
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!,id,!
Set sc=##class(AIHubStudio.Runtime.Chat).Send(id,"Hello",.reply)
Write $SELECT($$$ISOK(sc):reply.%ToJSON(),1:$SYSTEM.Status.GetErrorText(sc)),!
Set sc=##class(AIHubStudio.Runtime.Chat).Delete(id)
```

Cleanup the manual example in dependency order:

```objectscript
Set a=##class(AIHubStudio.AI.Agent).Open("MyAssistant")
Set sc=a.RemoveToolSet("AIHubStudio.ToolSet.Starter")
Set sc=##class(AIHubStudio.AI.Agent).Delete("MyAssistant")
Set sc=##class(AIHubStudio.AI.Provider).Delete("MyProvider")
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
```

For Ollama, create the provider through the provider-specific translator while
keeping the same generic metadata and agent APIs:

```objectscript
Set p=##class(AIHubStudio.AI.OllamaProvider).Create("RemoteOllama")
Do p.Endpoint("http://ollama-host:11434/v1/")
Do p.DefaultModel("exact-installed-model-id")
Set sc=p.Save()
Write $SELECT($$$ISOK(sc):"PASS",1:$SYSTEM.Status.GetErrorText(sc)),!
```

An API that is neither natively supported by `%AI.Provider` nor
OpenAI-compatible requires a provider adapter overriding `CreateRuntime()`.

## Persistent chat

```objectscript
Set sc=##class(AIHubStudio.Runtime.Chat).Start("metadata:OllamaAssistant",.id)
Write sc," ",id,!
Set sc=##class(AIHubStudio.Runtime.Chat).Send(id,"Remember codeword PINEAPPLE. Reply only STORED",.r1)
Write r1.content,!
Set sc=##class(AIHubStudio.Runtime.Chat).Send(id,"What codeword did I ask you to remember? Reply only with it.",.r2)
Write r2.content,!
Set sc=##class(AIHubStudio.Runtime.Chat).Get(id,.conversation)
Write conversation.%ToJSON(),!
Set sc=##class(AIHubStudio.Runtime.Chat).Delete(id)
```

Expected second response: `PINEAPPLE`. Repeat with `native:AIHubStudio.Agent.StudioAssistant`.

## Data tools and policies

```objectscript
Set sc=##class(AIHubStudio.Runtime.AgentCatalog).CreateRuntime("native:AIHubStudio.Agent.StudioAssistant",.agent)
Set allowed=agent.ToolManager.ExecuteTool("FindCustomers",{"name":"","limit":999})
Write allowed.%ToJSON(),!
Try {
  Set denied=agent.ToolManager.ExecuteTool("ReadSampleGlobal",{"path":"^Secret","depth":9,"limit":999})
} Catch ex {
  Write "PASS denied: ",ex.DisplayString(),!
}
```

Allowed result contains at most 50 rows. Forbidden global must throw `ToolAccessDenied`.

```objectscript
&sql(SELECT ToolName,StatusCode,ResultCount,CreatedAt FROM AIHubStudio_Metadata.ToolAudit ORDER BY CreatedAt DESC)
```

Audit must contain successful and denied calls without secrets or result payloads.

## REST after terminal gates

```bash
curl -sS http://localhost:9092/ai-hub/api/studio/agents
curl -sS -X POST http://localhost:9092/ai-hub/api/studio/conversations \
  -H 'Content-Type: application/json' \
  -d '{"agentKey":"metadata:OllamaAssistant"}'
curl -sS -X POST http://localhost:9092/ai-hub/api/studio/conversations/CONVERSATION_ID/messages \
  -H 'Content-Type: application/json' \
  -d '{"message":"Reply only REST_OK"}'
```

Replace `CONVERSATION_ID`. See [API.md](API.md).

## Troubleshooting

- `no Route matched`: endpoint must end `/v1/`.
- `does not support chat`: selected entry is usually an `mmproj` model; rerun setup after installing a chat model.
- Ollama unreachable: container uses `host.docker.internal:11434`.
- Missing context: confirm conversation `SessionData` exists; do not call `%InitWithSession()` after importing the serialized session.
