# AI Hub Studio — Manual Validation Tests

Validated against InterSystems IRIS namespace `AI_HUB_STUDIO` on 2026-08-26.

## Preconditions

- Container `iris-ai-hub-studio` is running.
- Repository `src/` is mounted at `/home/irisowner/dev/src` in the container.
- Run terminal tests with:

```sh
docker exec -it iris-ai-hub-studio iris session IRIS
```

Then select the namespace:

```objectscript
ZN "AI_HUB_STUDIO"
```

For each `%Status`, an empty string from `$SYSTEM.Status.GetErrorText(sc)` means success.

## 1. Full compilation

```objectscript
Set sc=$SYSTEM.OBJ.LoadDir("/home/irisowner/dev/src","ck",,1)
Write "STATUS=",$SYSTEM.Status.GetErrorText(sc),!
```

Expected:

- `Load finished successfully.`
- `Compiling 40 classes` (class count may increase later).
- `STATUS=` with no error text.

## 2. Static ObjectScript compatibility checks

Run from the repository root:

```sh
rg '\$LISTCREATE|\$LISTNEW' src
```

Expected: no matches. Native lists must use `$LISTBUILD`, `$LIST`, or another supported IRIS API.

Also inspect every `Try`/`Catch`: return-value `Quit`/`Return` must occur after the block. Inside the block, set a result or `%Status`; use `$$$OK`, `$$$ISOK`, `$$$ISERR`, `$$$ERROR`, `$$$ThrowOnError`, or `$$$ThrowStatus` as appropriate.

## 3. Starter end-to-end suite

```objectscript
Set sc=##class(AIHubStudio.Tests.StarterTest).RunAllTests()
Write "STATUS=",$SYSTEM.Status.GetErrorText(sc),!
```

Expected:

- initialization: `PASSED`
- 3 templates found
- agent creation and registration: `PASSED`
- 6 example conversation turns
- guide contains 5 steps
- `All tests PASSED!`
- empty `STATUS=`

## 4. Calculator parser

```objectscript
Write ##class(AIHubStudio.Tool.Calculator).Evaluate("2+3*4"),!
Write ##class(AIHubStudio.Tool.Calculator).Evaluate("(2+3)*4"),!
Write ##class(AIHubStudio.Tool.Calculator).Evaluate("2^3^2"),!
Write ##class(AIHubStudio.Tool.Calculator).Evaluate("-2+5"),!
Write ##class(AIHubStudio.Tool.Calculator).Evaluate("1/0"),!
Write ##class(AIHubStudio.Tool.Calculator).Evaluate("2+abc"),!
```

Expected, in order:

```text
Result: 14
Result: 20
Result: 512
Result: 3
Error: Invalid expression
Error: Invalid expression
```

## 5. Metadata QuickStart with rollback

This test leaves no metadata rows behind. `Initialize()` may create persistent SQL tables if they do not exist.

```objectscript
Set sc=##class(AIHubStudio.AI.Manager).Initialize()
Write "INIT=",$SYSTEM.Status.GetErrorText(sc),!
Set before=##class(AIHubStudio.AI.Manager).GetStats()
Write "BEFORE=",before.%ToJSON(),!
TSTART
Set sc=##class(AIHubStudio.AI.Manager).QuickStart()
Write "QUICKSTART=",$SYSTEM.Status.GetErrorText(sc),!
Set after=##class(AIHubStudio.AI.Manager).GetStats()
Write "AFTER=",after.%ToJSON(),!
TROLLBACK
Set final=##class(AIHubStudio.AI.Manager).GetStats()
Write "ROLLBACK=",final.%ToJSON(),!
```

Expected from an empty metadata store:

- `INIT=` and `QUICKSTART=` are empty.
- `BEFORE` counts are all zero.
- `AFTER`: provider 1, agent 1, tool 1, toolset 1, MCP 0.
- `ROLLBACK` equals `BEFORE`.

If data already exists, compare deltas instead: provider/agent/tool/toolset each increase by one inside the transaction and return to their original counts after rollback.

## 6. Facade CRUD and relationships

Use unique names if these names already exist.

```objectscript
TSTART
Set p=##class(AIHubStudio.AI.Provider).Create("ManualProvider","openai")
Do p.Credential("OPENAI_API_KEY")
Do p.DefaultModel("gpt-4o-mini")
Set sc=p.Save() Write "PROVIDER=",$SYSTEM.Status.GetErrorText(sc),!

Set t=##class(AIHubStudio.AI.Tool).Create("ManualCalculator")
Do t.Implementation("AIHubStudio.Tool.Calculator","Evaluate")
Set sc=t.Save() Write "TOOL=",$SYSTEM.Status.GetErrorText(sc),!

Set ts=##class(AIHubStudio.AI.ToolSet).Create("ManualTools")
Set sc=ts.Save() Write "TOOLSET=",$SYSTEM.Status.GetErrorText(sc),!
Set sc=ts.AddTool("ManualCalculator") Write "TOOLSET_ADD=",$SYSTEM.Status.GetErrorText(sc),!

Set a=##class(AIHubStudio.AI.Agent).Create("ManualAgent")
Do a.Provider("ManualProvider")
Do a.Model("gpt-4o-mini")
Set sc=a.Save() Write "AGENT=",$SYSTEM.Status.GetErrorText(sc),!
Set sc=a.AddTool("ManualCalculator") Write "AGENT_TOOL=",$SYSTEM.Status.GetErrorText(sc),!
Set sc=a.AddToolSet("ManualTools") Write "AGENT_TOOLSET=",$SYSTEM.Status.GetErrorText(sc),!

Set m=##class(AIHubStudio.AI.MCP).Create("ManualMCP")
Do m.ToolSet("ManualTools")
Do m.Endpoint("/manual-mcp")
Do m.Port(8080)
Set sc=m.Save() Write "MCP=",$SYSTEM.Status.GetErrorText(sc),!

Set reopened=##class(AIHubStudio.AI.Agent).Open("ManualAgent")
Write "REOPENED=",$IsObject(reopened),!
Write "AGENTS=",##class(AIHubStudio.AI.Agent).List(),!
TROLLBACK
```

Expected:

- Every status line has no error text.
- `REOPENED=1`.
- `AGENTS` is valid JSON and contains `ManualAgent`.
- Rollback removes all rows created by this test.

## 7. Negative validation

```objectscript
Set a=##class(AIHubStudio.AI.Agent).Create("")
Set sc=a.Save()
Write $SYSTEM.Status.GetErrorText(sc),!

Set a=##class(AIHubStudio.AI.Agent).Create("UnsavedAgent")
Set sc=a.AddTool("MissingTool")
Write $SYSTEM.Status.GetErrorText(sc),!

Set t=##class(AIHubStudio.AI.Tool).Create("InvalidTool")
Do t.Implementation("Missing.Class","MissingMethod")
Set sc=t.Save()
Write $SYSTEM.Status.GetErrorText(sc),!
```

Expected errors:

- agent name required
- save agent before adding tools
- implementation class not found or inaccessible

No `<INVALID OREF>`, `<METHOD DOES NOT EXIST>`, or unhandled ObjectScript exception should appear.

## 8. Credential persistence safety

```objectscript
TSTART
Set p=##class(AIHubStudio.AI.Provider).Create("SecretCheck","openai")
Do p.APIKey("must-not-be-persisted")
Do p.Credential("OPENAI_API_KEY")
Set sc=p.Save() Write $SYSTEM.Status.GetErrorText(sc),!
Set reopened=##class(AIHubStudio.AI.Provider).Open("SecretCheck")
Write "APIKEY=",reopened.APIKey,!
Write "CREDENTIAL=",reopened.CredentialName,!
TROLLBACK
```

Expected:

- save succeeds
- `APIKEY=` is empty after reopening
- `CREDENTIAL=OPENAI_API_KEY`
- raw secrets are not stored in metadata

## 9. REST smoke tests

Use the configured web application base URL. Replace `${BASE_URL}` with the actual host/port/path.

```sh
curl -i "${BASE_URL}/starter/guide"
curl -i "${BASE_URL}/starter/templates"
curl -i "${BASE_URL}/starter/templates/hello_world"
curl -i "${BASE_URL}/status"
```

Expected:

- HTTP 200 for configured routes
- `Content-Type: application/json`
- syntactically valid JSON body
- guide has 5 steps; templates has 3 entries

REST validation remains environment-dependent until the CSP web application route and port are known.

## Recorded automated execution

| Test | Result |
|---|---|
| Full IRIS compile, 40 classes | PASS |
| Starter end-to-end suite | PASS |
| Calculator precedence/parentheses/exponent/invalid input | PASS |
| Manager initialization | PASS |
| QuickStart metadata counts | PASS |
| Transaction rollback restores counts | PASS |
| Facade provider/tool/toolset/agent/MCP CRUD | PASS |
| Agent-tool and agent-toolset relationships | PASS |
| Static absence of `$LISTCREATE` and `$LISTNEW` | PASS |
| REST over HTTP | NOT RUN — base URL not established |
