/// Ollama provider facade and runtime adapter.
/// Ollama is not a native %AI.Provider name. The AI Hub SDK guide requires
/// using provider "openai" with Ollama's /v1 compatibility endpoint.
Class AIHubStudio.AI.OllamaProvider Extends AIHubStudio.AI.Provider
{

Parameter DEFAULTENDPOINT = "http://host.docker.internal:11434/v1/";

/// Create Ollama provider metadata facade. Call Save() to persist it.
ClassMethod Create(name As %String, type As %String = "ollama") As AIHubStudio.AI.Provider
{
    Set provider = ..%New()
    Set provider.Name = name
    Set provider.Type = "ollama"
    Set provider.Endpoint = ..#DEFAULTENDPOINT
    Set provider.Enabled = 1
    Set provider.IsNew = 1
    Quit provider
}

/// Create Ollama-backed %AI.Provider from this facade's configuration.
/// apiKey is required by the OpenAI adapter but is not validated by Ollama
/// unless authentication has explicitly been enabled in front of Ollama.
Method CreateRuntime(Output runtimeProvider As %AI.Provider) As %Status
{
    Set sc = $$$OK
    Set runtimeProvider = $$$NULLOREF

    If '..Enabled {
        Quit $$$ERROR($$$GeneralError, "Provider '" _ ..Name _ "' is disabled")
    }

    Try {
        Set endpoint = ..NormalizeEndpoint(..Endpoint)
        Set apiKey = ..APIKey
        If (apiKey = "") && (..CredentialName '= "") {
            Set apiKey = $SYSTEM.Util.GetEnviron(..CredentialName)
        }
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
