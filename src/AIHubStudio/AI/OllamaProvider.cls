/// Factory for Ollama through the OpenAI-compatible AI Hub provider.
/// Ollama is not a native %AI.Provider name. The AI Hub SDK guide requires
/// using provider "openai" with Ollama's /v1 compatibility endpoint.
Class AIHubStudio.AI.OllamaProvider Extends %RegisteredObject
{

Parameter DEFAULTENDPOINT = "http://host.docker.internal:11434/v1/";

/// Create an Ollama-backed %AI.Provider.
/// apiKey is required by the OpenAI adapter but is not validated by Ollama
/// unless authentication has explicitly been enabled in front of Ollama.
ClassMethod Create(Output runtimeProvider As %AI.Provider, endpoint As %String = "", apiKey As %String = "ollama") As %Status
{
    Set sc = $$$OK
    Set runtimeProvider = $$$NULLOREF

    Try {
        Set endpoint = ..NormalizeEndpoint(endpoint)
        If apiKey = "" Set apiKey = "ollama"

        Set settings = {}
        Do settings.%Set("base_url", endpoint)
        Do settings.%Set("api_key", apiKey)

        Set runtimeProvider = ##class(%AI.Provider).Create("openai", settings)
    } Catch ex {
        Set sc = ex.AsStatus()
    }

    Quit sc
}

/// Create a ready-to-use runtime agent backed by Ollama.
ClassMethod CreateAgent(Output runtimeAgent As %AI.Agent, model As %String, systemPrompt As %String = "", endpoint As %String = "", apiKey As %String = "ollama") As %Status
{
    Set sc = $$$OK
    Set runtimeAgent = $$$NULLOREF

    If model = "" {
        Quit $$$ERROR($$$GeneralError, "Ollama model is required")
    }

    Set sc = ..Create(.runtimeProvider, endpoint, apiKey)
    If $$$ISERR(sc) {
        Quit sc
    }

    Try {
        Set runtimeAgent = ##class(%AI.Agent).%New(runtimeProvider)
        Set runtimeAgent.Model = model
        Set runtimeAgent.SystemPrompt = systemPrompt
    } Catch ex {
        Set sc = ex.AsStatus()
    }

    Quit sc
}

/// Normalize an Ollama server URL to its OpenAI-compatible /v1/ base URL.
ClassMethod NormalizeEndpoint(endpoint As %String = "") As %String
{
    If endpoint = "" Set endpoint = ..#DEFAULTENDPOINT

    While ($LENGTH(endpoint) > 0) && ($EXTRACT(endpoint, $LENGTH(endpoint)) = "/") {
        Set endpoint = $EXTRACT(endpoint, 1, $LENGTH(endpoint) - 1)
    }

    If $EXTRACT(endpoint, $LENGTH(endpoint) - 2, $LENGTH(endpoint)) '= "/v1" {
        Set endpoint = endpoint _ "/v1"
    }

    Quit endpoint _ "/"
}

}
