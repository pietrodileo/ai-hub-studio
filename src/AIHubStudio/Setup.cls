Class AIHubStudio.Setup Extends %RegisteredObject
{

ClassMethod Run() As %Status
{
    Set sc = $$$OK
    Set model = ..ResolveOllamaModel(.sc)
    If $$$ISERR(sc) Quit sc

    Set provider = ##class(AIHubStudio.AI.Provider).Open("LocalOllama")
    If '$ISOBJECT(provider) Set provider = ##class(AIHubStudio.AI.OllamaProvider).Create("LocalOllama")
    Do provider.DefaultModel(model)
    Set sc = provider.Save()
    If $$$ISERR(sc) Quit sc

    Set toolSet = ##class(AIHubStudio.AI.ToolSet).Open("AIHubStudio.ToolSet.Starter")
    If '$ISOBJECT(toolSet) {
        Set toolSet = ##class(AIHubStudio.AI.ToolSet).Create("AIHubStudio.ToolSet.Starter")
        Do toolSet.Description("Runtime AI Hub starter toolset")
        Set sc = toolSet.Save()
        If $$$ISERR(sc) Quit sc
    }

    Set agent = ##class(AIHubStudio.AI.Agent).Open("OllamaAssistant")
    If '$ISOBJECT(agent) Set agent = ##class(AIHubStudio.AI.Agent).Create("OllamaAssistant")
    Do agent.Description("Metadata-defined local assistant with secure IRIS data tools")
    Do agent.Provider("LocalOllama")
    Do agent.Model(model)
    Do agent.Instructions("Be concise. Use tools for calculations and sample-data questions. Never claim access outside allowlisted resources.")
    Set sc = agent.Save()
    If $$$ISERR(sc) Quit sc
    Set sc = agent.AddToolSet("AIHubStudio.ToolSet.Starter")
    If $$$ISERR(sc) Quit sc

    Set sc = ##class(AIHubStudio.Data.SampleCustomer).Seed()
    Quit sc
}

ClassMethod ResolveOllamaModel(Output sc As %Status) As %String
{
    Set sc = $$$OK, model = ""
    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "host.docker.internal"
        Set request.Port = 11434
        Set request.Https = 0
        Set request.Timeout = 10
        Set sc = request.Get("/v1/models")
        If $$$ISOK(sc), request.HttpResponse.StatusCode = 200 {
            Set payload = {}.%FromJSON(request.HttpResponse.Data)
            For index=0:1:(payload.data.%Size()-1) {
                Set candidate = payload.data.%Get(index).id
                If (candidate '[ "mmproj") && (model = "") Set model = candidate
            }
        } ElseIf $$$ISOK(sc) {
            Set sc = $$$ERROR($$$GeneralError,"Ollama returned HTTP "_request.HttpResponse.StatusCode)
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    If $$$ISOK(sc), model = "" Set sc = $$$ERROR($$$GeneralError,"Ollama returned no installed models")
    Quit model
}

}
