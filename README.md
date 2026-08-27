# IRIS AI Hub Studio

IRIS-native platform covering three InterSystems AI Hub bounty objectives:

- Generic chat playground for native `%AI.Agent` subclasses and metadata-defined agents.
- Read-only MCP toolkit for allowlisted SQL data and globals, with authorization and audit records.
- End-to-end starter agent using local Ollama, tools, a reusable skill, persistent conversations, REST, React, and Docker Compose.

## Architecture

IRIS owns metadata, providers, runtime agents, conversations, policies, tools, MCP, and REST. React is served by nginx, which proxies `/api` directly to IRIS. No Node middleware exists.

Key classes:

- `AIHubStudio.Runtime.AgentCatalog`: unified native/metadata discovery and runtime creation.
- `AIHubStudio.Runtime.Chat`: persistent multi-turn conversation API.
- `AIHubStudio.Agent.StudioAssistant`: canonical native starter.
- `AIHubStudio.ToolSet.Starter`: calculator and secure data tools.
- `AIHubStudio.MCP.DataService`: MCP exposure.

## Quick start

1. Start Ollama or an Ollama-compatible local server on port `11434` with at least one chat model.
2. Create `.env`. MCP credentials are intentionally not defaulted:

```dotenv
WG_USER=iris_mcp_bridge
WG_PASS=replace-me
APP_USER=iris_mcp_user
APP_PASS=replace-me
```

3. Build:

```bash
docker compose up -d --build iris frontend
```

4. Run terminal gates in [docs/TERMINAL_TESTS.md](docs/TERMINAL_TESTS.md).
5. Open <http://localhost:5173>.

IRIS Management Portal: <http://localhost:9092/csp/sys/UtilHome.csp>.

## Security defaults

- Provider metadata stores environment-variable names, never API-key values.
- SQL tools execute fixed parameterized SQL only.
- Global access is limited to `^AIHubStudio.Sample`, depth 3, 50 results.
- MCP application requires password authentication and `AIHubStudioMCP` role.
- Bridge and endpoint credentials are separate.
- Audit rows exclude secrets and full result payloads.

## Documentation

- [Terminal validation](docs/TERMINAL_TESTS.md)
- [REST API](docs/API.md)
- [MCP toolkit](docs/MCP_TOOLKIT.md)
- [Demo walkthrough](docs/DEMO.md)

## EAP compatibility note

This AI Hub EAP build restricts persisted `%AI.Agent.Session.Model` to 50 characters, while local model IDs can be longer. Conversations therefore persist the SDK-supported `Session.Export()` representation and restore it with `Session.Import()`. No model name is truncated or aliased.

License: MIT.
