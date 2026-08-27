# AI Hub Studio — How to Use

## 1. Prerequisites

- Docker Desktop with Docker Compose.
- InterSystems IRIS AI Hub image referenced by `Dockerfile` available locally.
- An `.env` file in the project root.

For local development without an external LLM call, `.env` may be empty. To use OpenAI:

```dotenv
OPENAI_API_KEY=your-key
```

Do not commit `.env` or API keys.

## 2. Start the application

From the repository root:

```sh
docker compose up -d --build
docker compose ps
```

Expected services:

| Service | URL/port |
|---|---|
| Web UI | http://localhost:5173 |
| Backend API | http://localhost:3000 |
| IRIS REST API | http://localhost:9092/ai-hub/api/studio |
| IRIS Management Portal | http://localhost:9092/csp/sys/UtilHome.csp |
| IRIS SuperServer | `localhost:9091` |

Development Management Portal credentials are configured by the project image. Current defaults are `_SYSTEM` / `SYS` for the backend and `SuperUser` / `SYS` for interactive portal access. Replace insecure defaults before production use.

Stop services:

```sh
docker compose down
```

View logs:

```sh
docker compose logs -f iris
docker compose logs -f backend
docker compose logs -f frontend
```

## 3. Validate from IRIS Terminal first

Always validate ObjectScript before testing HTTP:

```sh
docker compose exec iris iris session IRIS
```

Inside IRIS Terminal:

```objectscript
ZN "AI_HUB_STUDIO"
Set sc=$SYSTEM.OBJ.LoadDir("/home/irisowner/dev/src","ck",,1)
Write "COMPILE=",$SYSTEM.Status.GetErrorText(sc),!
Set sc=##class(AIHubStudio.Tests.StarterTest).RunAllTests()
Write "STARTER=",$SYSTEM.Status.GetErrorText(sc),!
Set health=##class(AIHubStudio.Status).HealthCheck()
Write health.%ToJSON(),!
Write "DATABASE=",##class(AIHubStudio.Status).CheckDatabase(),!
```

Expected:

- compilation finishes successfully;
- `COMPILE=` and `STARTER=` contain no error text;
- starter suite prints `All tests PASSED!`;
- health JSON has `"status":"healthy"`;
- `DATABASE=1`.

Detailed manual verification is available in `MANUAL_VALIDATION_TESTS.md`.

## 4. QuickStart from ObjectScript

Create the default provider, calculator tool, toolset, and assistant:

```objectscript
ZN "AI_HUB_STUDIO"
Set sc=##class(AIHubStudio.AI.Manager).Initialize()
Write $SYSTEM.Status.GetErrorText(sc),!
Set sc=##class(AIHubStudio.AI.Manager).QuickStart()
Write $SYSTEM.Status.GetErrorText(sc),!
Set stats=##class(AIHubStudio.AI.Manager).GetStats()
Write stats.%ToJSON(),!
```

Open the generated agent:

```objectscript
Set agent=##class(AIHubStudio.AI.Agent).Open("Assistant")
Write "FOUND=",$IsObject(agent),!
Do agent.Show()
```

`QuickStart()` creates persistent metadata. Do not run it repeatedly with the same names unless the store is empty.

## 5. Create objects with the facade API

### Provider

```objectscript
Set provider=##class(AIHubStudio.AI.Provider).Create("openai","openai")
Do provider.Credential("OPENAI_API_KEY")
Do provider.DefaultModel("gpt-4o-mini")
Set sc=provider.Save()
Write $SYSTEM.Status.GetErrorText(sc),!
```

Only the environment-variable name is persisted. A raw key supplied through `provider.APIKey(...)` remains in memory and is not saved to metadata.

### Tool

```objectscript
Set tool=##class(AIHubStudio.AI.Tool).Create("Calculator")
Do tool.Description("Evaluate arithmetic expressions")
Do tool.Implementation("AIHubStudio.Tool.Calculator","Evaluate")
Set sc=tool.Save()
Write $SYSTEM.Status.GetErrorText(sc),!
```

Try it directly:

```objectscript
Write ##class(AIHubStudio.Tool.Calculator).Evaluate("(2+3)*4"),!
```

Expected: `Result: 20`.

### Toolset

```objectscript
Set toolset=##class(AIHubStudio.AI.ToolSet).Create("BasicTools")
Set sc=toolset.Save()
Write $SYSTEM.Status.GetErrorText(sc),!
Set sc=toolset.AddTool("Calculator")
Write $SYSTEM.Status.GetErrorText(sc),!
```

The toolset must be saved before adding tools.

### Agent

```objectscript
Set agent=##class(AIHubStudio.AI.Agent).Create("Assistant")
Do agent.Description("General assistant")
Do agent.Provider("openai")
Do agent.Model("gpt-4o-mini")
Do agent.Instructions("Answer clearly and concisely.")
Set sc=agent.Save()
Write $SYSTEM.Status.GetErrorText(sc),!
Set sc=agent.AddTool("Calculator")
Write $SYSTEM.Status.GetErrorText(sc),!
Set sc=agent.AddToolSet("BasicTools")
Write $SYSTEM.Status.GetErrorText(sc),!
```

The agent must be saved before relationships are added.

### MCP metadata

```objectscript
Set mcp=##class(AIHubStudio.AI.MCP).Create("StudioMCP")
Do mcp.Description("Expose BasicTools through MCP")
Do mcp.ToolSet("BasicTools")
Do mcp.Endpoint("/mcp/studio")
Do mcp.Port(8080)
Set sc=mcp.Save()
Write $SYSTEM.Status.GetErrorText(sc),!
```

This saves MCP service metadata. Starting an external MCP transport remains a separate deployment operation.

## 6. List, open, and delete metadata

```objectscript
Write ##class(AIHubStudio.AI.Provider).List(),!
Write ##class(AIHubStudio.AI.Tool).List(),!
Write ##class(AIHubStudio.AI.ToolSet).List(),!
Write ##class(AIHubStudio.AI.Agent).List(),!
Write ##class(AIHubStudio.AI.MCP).List(),!

Set agent=##class(AIHubStudio.AI.Agent).Open("Assistant")
Write $IsObject(agent),!

Set sc=##class(AIHubStudio.AI.Agent).Delete("Assistant")
Write $SYSTEM.Status.GetErrorText(sc),!
```

## 7. Use the IRIS REST API

Base URL:

```text
http://localhost:9092/ai-hub/api/studio
```

Smoke tests:

```sh
curl http://localhost:9092/ai-hub/api/studio/status
curl http://localhost:9092/ai-hub/api/studio/status/detailed
curl http://localhost:9092/ai-hub/api/studio/starter/templates
curl http://localhost:9092/ai-hub/api/studio/agents
curl http://localhost:9092/ai-hub/api/studio/tools
curl http://localhost:9092/ai-hub/api/studio/skills
```

Create a starter agent:

```sh
curl -X POST http://localhost:9092/ai-hub/api/studio/starter/create \
  -H 'Content-Type: application/json' \
  -d '{"templateName":"hello_world","agentName":"My Hello Agent","description":"First test agent"}'
```

Core routes are declared in `src/AIHubStudio/REST/WebGateway.cls`.

## 8. Use the backend API

The Node backend proxies IRIS registry endpoints:

```sh
curl http://localhost:3000/api/health
curl http://localhost:3000/api/agents
curl http://localhost:3000/api/tools
curl http://localhost:3000/api/skills
```

The same API is available through the frontend nginx proxy:

```sh
curl http://localhost:5173/api/health
curl http://localhost:5173/api/agents
```

## 9. Use the web UI

Open http://localhost:5173.

Available views:

- Dashboard
- Agents
- Tools
- Skills
- Configuration shell

The current verified UI supports loading agent/tool/skill lists through the backend proxy. Some actions remain placeholders or are not yet connected end-to-end:

- `/agents/new`, `/tools/new`, and `/skills/new` do not have dedicated React routes;
- agent/tool execution and history backend routes do not have matching IRIS gateway routes;
- the Configuration page is rendered, but configuration endpoints are not proxied by the Node backend;
- actual LLM chat requires provider credentials and runtime integration beyond metadata creation.

Use the ObjectScript facade or direct IRIS REST endpoints for supported creation and configuration workflows.

## 10. Troubleshooting

### REST returns 404

Use the complete application path:

```text
/ai-hub/api/studio/...
```

Not the obsolete `/ai-hub/api/...` path.

### REST returns 500 after upgrading an existing container

Re-register the web application by rebuilding the IRIS service:

```sh
docker compose up -d --build iris
```

Its dispatch class must be `AIHubStudio.REST.WebGateway`.

### Frontend loads but data calls fail

Check all three services:

```sh
docker compose ps
curl http://localhost:3000/api/health
curl http://localhost:9092/ai-hub/api/studio/status
```

### ObjectScript status handling

For `%Status` values:

```objectscript
If $$$ISERR(sc) Write $SYSTEM.Status.GetErrorText(sc),!
```

Use `$$$OK`, `$$$ISOK`, `$$$ISERR`, and the standard status macros. Avoid returning a value from inside `Try`/`Catch`; assign the result/status and return after the block.

