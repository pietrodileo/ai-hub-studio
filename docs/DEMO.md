# Demo Walkthrough

1. Show `docker compose ps`: only IRIS and frontend services.
2. Run `AIHubStudio.Setup.Run()` twice to prove idempotency and dynamic Ollama model selection.
3. Print unified catalog; point out native and metadata sources.
4. Start terminal conversation, store codeword, reconnect in next command, retrieve codeword.
5. Ask starter agent to calculate an expression and inspect sample customers.
6. Execute forbidden global read and show `ToolAccessDenied` plus audit record.
7. Start MCP bridge, list tools, call SQL/global tools.
8. Open <http://localhost:5173>, select each agent source, chat, reset, and show token/tool statistics.

Bounty mapping:

- Generic Agent Test UI: unified catalog, persistent chat, model override, runtime capabilities, React playground.
- MCP Data Exposure Toolkit: SQL/global discovery and reads, authorization, caps, audit, MCP service.
- My First Agent: `StudioAssistant`, local provider, exact discovered model, toolset, reusable skill, policies, Docker, terminal, REST, UI.
