Class AIHubStudio.Test Extends %RegisteredObject
{
    
ClassMethod InitAgent(Output runtimeAgent As %AI.Agent) As %Status
{
    // Test method implementation
    Set saved=##class(AIHubStudio.AI.Agent).Open("MistralAssistant")
    Set providerMetadata=##class(AIHubStudio.AI.Provider).Open(saved.Provider)
    Set apiKey=$SYSTEM.Util.GetEnviron(providerMetadata.CredentialName)
    Set settings = {"base_url": (providerMetadata.Endpoint)}
    Set customProviderName = "nim"
    Set runtimeProvider=##class(%AI.Provider).Create(customProviderName, settings)
    Set runtimeAgent=##class(%AI.Agent).%New(runtimeProvider)
    Set runtimeAgent.Model=saved.Model
    Set runtimeAgent.SystemPrompt=saved.Instructions
    Return $$$OK
}

ClassMethod InitOllamaAgent() As %Status
{
    Set sc = $$$OK
    Set sc=##class(AIHubStudio.AI.OllamaProvider).CreateAgent(.agent,"lms-lmstudio-community-qwen3-8-27b-gguf-qwen3-8-27b-q4-k-m:latest","You are concise.")
    Write $SYSTEM.Status.GetErrorText(sc),!

    Set session=agent.CreateSession()
    Set response=agent.Chat(session,"Hello!")
    Write response.Content,!    
    Quit sc
}

ClassMethod InitLocalAgent(Output runtimeAgent As %AI.Agent) As %Status
{
    Set sc = $$$OK

    Try {
        Set settings = {}
        Do settings.%Set("base_url", "http://host.docker.internal:1234")

        // Harmless dummy value if the provider requires a non-empty key.
        // LM Studio ignores it unless authentication is enabled.
        Do settings.%Set("api_key", "lm-studio")

        Set runtimeProvider = ##class(%AI.Provider).Create(
            "openai",
            settings
        )

        Set runtimeAgent = ##class(%AI.Agent).%New(runtimeProvider)
        Set runtimeAgent.Model = "qwen/qwen3.8-27b"
        Set runtimeAgent.SystemPrompt = "You are a helpful local assistant."
    } Catch ex {
        Set sc = ex.AsStatus()
    }

    Quit sc
}

ClassMethod TestAgent() As %Status
{
    Set sc = $$$OK
    Set sc=##class(AIHubStudio.Test).InitLocalAgent(.runtimeAgent)
    Write $SYSTEM.Status.GetErrorText(sc),!

    Set session=runtimeAgent.CreateSession()
    Set response=runtimeAgent.Chat(session,"Hello! Introduce yourself.")
    Write response.Content,!    
    Quit sc

}

}
