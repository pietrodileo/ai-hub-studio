Class AIHubStudio.Test Extends %RegisteredObject
{
ClassMethod RunAll() As %Status
{
    Set sc = ##class(AIHubStudio.Setup).Run()
    If $$$ISERR(sc) Quit sc
    Set catalog = ##class(AIHubStudio.Runtime.AgentCatalog).List()
    If catalog.%Size() < 2 Quit $$$ERROR($$$GeneralError,"Expected native and metadata agents")
    Set tool = ##class(AIHubStudio.Tool.DataAccess).%New()
    Set result = tool.FindCustomers("",2)
    If result.%Get("row_count",0) '= 2 Quit $$$ERROR($$$GeneralError,"SQL row limit failed")
    Set result = tool.ReadSampleGlobal("^AIHubStudio.Sample",2,10)
    If result.%Get("count",0) < 1 Quit $$$ERROR($$$GeneralError,"Allowlisted global read failed")
    Set sc = ..TestCustomProvider()
    If $$$ISERR(sc) Quit sc
    Set sc = ..TestCustomAgent()
    If $$$ISERR(sc) Quit sc
    Quit $$$OK
}

/// Verify creation, persistence, reopening and deletion of a custom provider.
/// No network request is performed and no credential value is persisted.
ClassMethod TestCustomProvider() As %Status
{
    Set name = "TestOpenAICompatible"
    If ##class(AIHubStudio.AI.Provider).Exists(name) Set cleanup = ##class(AIHubStudio.AI.Provider).Delete(name)

    Set provider = ##class(AIHubStudio.AI.Provider).Create(name,"openai-compatible")
    Do provider.Endpoint("http://example.invalid/v1/")
    Do provider.APIKeyFromEnvironment("TEST_PROVIDER_API_KEY")
    Do provider.DefaultModel("test-model")
    Set sc = provider.Save()
    If $$$ISOK(sc) {
        Set saved = ##class(AIHubStudio.AI.Provider).Open(name)
        If '$ISOBJECT(saved) Set sc = $$$ERROR($$$GeneralError,"Custom provider could not be reopened")
    }
    If $$$ISOK(sc), saved.Type '= "openai-compatible" Set sc = $$$ERROR($$$GeneralError,"Custom provider type was not persisted")
    If $$$ISOK(sc), saved.CredentialName '= "TEST_PROVIDER_API_KEY" Set sc = $$$ERROR($$$GeneralError,"Credential environment name was not persisted")
    If $$$ISOK(sc), saved.GetProviderInfo().%IsDefined("apiKey") Set sc = $$$ERROR($$$GeneralError,"Provider JSON exposed an API key")

    Set cleanup = ##class(AIHubStudio.AI.Provider).Delete(name)
    If $$$ISOK(sc), $$$ISERR(cleanup) Set sc = cleanup
    If $$$ISOK(sc), ##class(AIHubStudio.AI.Provider).Exists(name) Set sc = $$$ERROR($$$GeneralError,"Custom provider cleanup failed")
    Quit sc
}

/// Verify creation, catalog discovery, runtime construction and deletion of a
/// metadata-defined agent using the existing generic provider framework.
ClassMethod TestCustomAgent() As %Status
{
    Set name = "TestCustomAssistant"
    Set existing = ##class(AIHubStudio.AI.Agent).Open(name)
    If $ISOBJECT(existing) {
        Set cleanup = existing.RemoveToolSet("AIHubStudio.ToolSet.Starter")
        Set cleanup = ##class(AIHubStudio.AI.Agent).Delete(name)
    }

    Set provider = ##class(AIHubStudio.AI.Provider).Open("LocalOllama")
    If '$ISOBJECT(provider) Quit $$$ERROR($$$GeneralError,"LocalOllama provider is not configured")

    Set agent = ##class(AIHubStudio.AI.Agent).Create(name)
    Do agent.Description("Temporary custom-agent validation")
    Do agent.Provider("LocalOllama")
    Do agent.Model(provider.DefaultModel)
    Do agent.Instructions("Reply concisely and use tools when needed.")
    Do agent.Temperature(0.2)
    Do agent.MaxTokens(256)
    Set sc = agent.Save()
    If $$$ISOK(sc) Set sc = agent.AddToolSet("AIHubStudio.ToolSet.Starter")
    If $$$ISOK(sc) {
        Set item = ##class(AIHubStudio.Runtime.AgentCatalog).Get("metadata:"_name)
        If item.%Get("name","") '= name Set sc = $$$ERROR($$$GeneralError,"Custom agent was not discovered in catalog")
    }
    If $$$ISOK(sc) Set sc = ##class(AIHubStudio.Runtime.AgentCatalog).CreateRuntime("metadata:"_name,.runtimeAgent)
    If $$$ISOK(sc), '$ISOBJECT(runtimeAgent) Set sc = $$$ERROR($$$GeneralError,"Custom agent runtime was not created")

    Set saved = ##class(AIHubStudio.AI.Agent).Open(name)
    If $ISOBJECT(saved) Set cleanup = saved.RemoveToolSet("AIHubStudio.ToolSet.Starter")
    Set cleanup = ##class(AIHubStudio.AI.Agent).Delete(name)
    If $$$ISOK(sc), $$$ISERR(cleanup) Set sc = cleanup
    If $$$ISOK(sc), ##class(AIHubStudio.AI.Agent).Exists(name) Set sc = $$$ERROR($$$GeneralError,"Custom agent cleanup failed")
    Quit sc
}
}
