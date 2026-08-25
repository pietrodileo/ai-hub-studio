/// Class: AIHubStudio.REST.ConfigService
/// Description: REST API for Configuration Management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.ConfigService Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

/// Method: GetAllConfig
/// Description: Get all configuration values
ClassMethod GetAllConfig() As %Status
{
    Set sc = $$$OK
    try {
        set config = ##class(AIHubStudio.Config).GetAllConfig()
        write config
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetConfig
/// Description: Get a specific configuration value by key
ClassMethod GetConfig(key As %String) As %Status
{
    Set sc = $$$OK
    try {
        set value = ##class(AIHubStudio.Config).GetConfig(key)
        write {"key": (key), "value": (value)}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: SetConfig
/// Description: Set a configuration value
ClassMethod SetConfig(key As %String, value As %String) As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Config).SetConfig(key, value)
        write {"key": (key), "value": (value), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: DeleteConfig
/// Description: Delete a configuration value
ClassMethod DeleteConfig(key As %String) As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Config).DeleteConfig(key)
        write {"key": (key), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetAllAPIKeys
/// Description: Get all API key configurations
ClassMethod GetAllAPIKeys() As %Status
{
    Set sc = $$$OK
    try {
        set apiKeys = ##class(AIHubStudio.Config).GetAllAPIKeys()
        write apiKeys
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetAPIKey
/// Description: Get API key for a specific provider
ClassMethod GetAPIKey(provider As %String) As %Status
{
    Set sc = $$$OK
    try {
        set apiKey = ##class(AIHubStudio.Config).GetAPIKey(provider)
        write {"provider": (provider), "apiKey": (apiKey), "hasKey": (apiKey'="")}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: SetAPIKey
/// Description: Set API key for a specific provider
ClassMethod SetAPIKey(provider As %String, apiKey As %String, defaultModel As %String = "") As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Config).SetAPIKey(provider, apiKey, defaultModel)
        write {"provider": (provider), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: DeleteAPIKey
/// Description: Delete API key for a specific provider
ClassMethod DeleteAPIKey(provider As %String) As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Config).DeleteAPIKey(provider)
        write {"provider": (provider), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetAllProviderInfo
/// Description: Get information about all supported providers
ClassMethod GetAllProviderInfo() As %Status
{
    set sc = $$$OK
    try {
        set providers = ##class(AIHubStudio.Config).GetAllProviderInfo()
        write providers
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetProviderInfo
/// Description: Get information about a specific provider
ClassMethod GetProviderInfo(provider As %String) As %Status
{
    set sc = $$$OK
    try {
        set info = ##class(AIHubStudio.Config).GetProviderInfo(provider)
        write ##class(%Library.JSON).%ToJSON(info)
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: ValidateAPIKey
/// Description: Validate API key for a specific provider
ClassMethod ValidateAPIKey(provider As %String, apiKey As %String) As %Status
{
    set sc = $$$OK
    try {
        set isValid = ##class(AIHubStudio.Config).ValidateAPIKey(provider, apiKey)
        write {"provider": (provider), "isValid": (isValid)}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetSupportedProviders
/// Description: Get list of supported providers
ClassMethod GetSupportedProviders() As %Status
{
    set sc = $$$OK
    try {
        set providers = ##class(AIHubStudio.Config).#Providers
        set jsonArray = []
        for i = 1:1:providers.%Size() {
            do jsonArray.%Push(providers.%Get(i))
        }
        write ##class(%Library.JSON).%ToJSON(jsonArray)
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: InitializeConfig
/// Description: Initialize the configuration system
ClassMethod InitializeConfig() As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Config).Initialize()
        write {"status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

}
