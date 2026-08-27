# REST API

Base URL from host: `http://localhost:9092/ai-hub/api/studio`.

## Agents

`GET /agents` lists unified catalog entries. Keys use `native:Class.Name` or `metadata:Name`.

`GET /agents/{key}` returns source, class, provider, model, tools, toolsets, skills, and availability.

## Conversations

Create:

```http
POST /conversations
Content-Type: application/json

{"agentKey":"native:AIHubStudio.Agent.StudioAssistant","model":""}
```

Send:

```http
POST /conversations/{id}/messages
Content-Type: application/json

{"message":"List available sample data."}
```

Read transcript and stats: `GET /conversations/{id}`.

Delete conversation: `DELETE /conversations/{id}`.

Success responses contain `content` and SDK session `stats`. Errors use:

```json
{"error":"stable_code","message":"Human-readable explanation"}
```

Expected status codes: `201` create, `200` read/send, `204` delete, `400` invalid input/runtime selection, `404` unknown resource.
