# Secure MCP Data Toolkit

`AIHubStudio.MCP.DataService` exposes `AIHubStudio.ToolSet.Starter` at `/mcp/data`.

Tools:

- `ListDataResources`
- `FindCustomers`
- `ReadSampleGlobal`
- `Calculate`

SQL is fixed and parameterized. Arbitrary SQL is not accepted. Global access only permits `^AIHubStudio.Sample`; depth is capped at 3 and results at 50.

## Security setup

Installer creates `AIHubStudioMCP` role with access only to `%DB_AI_HUB_STUDIO`. Create two non-SuperUser accounts:

- Bridge account for IRIS superserver connection.
- Endpoint account granted `AIHubStudioMCP` for MCP calls.

Set `WG_USER`, `WG_PASS`, `APP_USER`, and `APP_PASS` in `.env`. `config_http.toml` references them independently. Never commit values.

Start transport:

```bash
docker compose exec iris iris-mcp-server --config /home/irisowner/dev/config_http.toml run
```

Then run:

```bash
python test_mcp.py
```

Discovery endpoint inside IRIS: `http://localhost:9092/mcp/data/v1/services` with endpoint-account Basic authentication. Client-facing MCP URL: `http://localhost:8080/mcp/data`.

Tests must verify correct credentials, wrong bridge credentials, wrong endpoint credentials, allowlisted reads, denied global, caps, and audit rows.
