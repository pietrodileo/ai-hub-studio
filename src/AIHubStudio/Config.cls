/// Class: AIHubStudio.Config
/// Description: AI Hub Configuration Manager with Multi-Provider Support
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Config
{

/// Property: Settings
/// Description: Cached configuration settings
Property Settings As %Library.DynamicObject;

/// Parameter: Supported AI Providers
Parameter Providers = {($lb("openai","azure","anthropic","google","local"))};

/// Method: Initialize
/// Description: Initialize configuration system
ClassMethod Initialize() As %Boolean
{
    #; Create configuration table if not exists
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("CREATE TABLE IF NOT EXISTS AIHubStudio_Config (ConfigKey VARCHAR(255) PRIMARY KEY, ConfigValue VARCHAR(255), Description VARCHAR(500))")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) }
    set status = stmt.%Execute()
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Execute failed: "_stmt.%Message) $$$ThrowOnError(sc) }
    
    #; Create API keys table if not exists
    set stmt2 = ##class(%SQL.Statement).%New()
    set status = stmt2.%Prepare("CREATE TABLE IF NOT EXISTS AIHubStudio_APIKeys (Provider VARCHAR(50) PRIMARY KEY, APIKey VARCHAR(500), DefaultModel VARCHAR(100), IsActive BOOLEAN DEFAULT 1, CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt2.%Message) $$$ThrowOnError(sc) }
    set status = stmt2.%Execute()
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Execute failed: "_stmt2.%Message) $$$ThrowOnError(sc) }
    
    #; Insert default values if not exists
    set stmt3 = ##class(%SQL.Statement).%New()
    set status = stmt3.%Prepare("INSERT OR IGNORE INTO AIHubStudio_Config (ConfigKey, ConfigValue, Description) VALUES (?, ?, ?)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt3.%Message) $$$ThrowOnError(sc) }
    
    set status = stmt3.%Execute("Enabled","1","Enable AI Hub features")
    set status = status && stmt3.%Execute("MaxAgents","100","Maximum number of agents")
    set status = status && stmt3.%Execute("MaxTools","500","Maximum number of tools")
    set status = status && stmt3.%Execute("MaxSkills","200","Maximum number of skills")
    set status = status && stmt3.%Execute("WebSocketPort","53773","AI Hub WebSocket port")
    set status = status && stmt3.%Execute("RESTPort","54773","AI Hub REST port")
    set status = status && stmt3.%Execute("DefaultProvider","openai","Default AI provider")
    
    quit status
}

/// Method: GetConfig
/// Description: Get configuration value by key
ClassMethod GetConfig(pKey As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT ConfigValue FROM AIHubStudio_Config WHERE ConfigKey = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set result = stmt.%Execute(pKey)
    if result.%Next() {
        quit result.ConfigValue
    }
    quit ""
}

/// Method: SetConfig
/// Description: Set configuration value by key
ClassMethod SetConfig(pKey As %String, pValue As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("INSERT OR REPLACE INTO AIHubStudio_Config (ConfigKey, ConfigValue) VALUES (?, ?)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pKey, pValue)
    quit status
}

/// Method: GetAllConfig
/// Description: Get all configuration as JSON
ClassMethod GetAllConfig() As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT ConfigKey, ConfigValue, Description FROM AIHubStudio_Config ORDER BY ConfigKey")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute()
    set jsonArray = []
    
    while result.%Next() {
        set obj = {
            "ConfigKey": (result.ConfigKey),
            "ConfigValue": (result.ConfigValue),
            "Description": (result.Description)
        }
        do jsonArray.%Push(obj)
    }
    
    quit ##class(%Library.JSON).%ToJSON(jsonArray)
}

/// Method: DeleteConfig
/// Description: Delete configuration by key
ClassMethod DeleteConfig(pKey As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("DELETE FROM AIHubStudio_Config WHERE ConfigKey = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pKey)
    quit status
}

/// Method: SetAPIKey
/// Description: Set API key for a specific provider
ClassMethod SetAPIKey(pProvider As %String, pAPIKey As %String, pDefaultModel As %String = "") As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("INSERT OR REPLACE INTO AIHubStudio_APIKeys (Provider, APIKey, DefaultModel, IsActive) VALUES (?, ?, ?, 1)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pProvider, pAPIKey, pDefaultModel)
    quit status
}

/// Method: GetAPIKey
/// Description: Get API key for a specific provider
ClassMethod GetAPIKey(pProvider As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT APIKey FROM AIHubStudio_APIKeys WHERE Provider = ? AND IsActive = 1")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set result = stmt.%Execute(pProvider)
    if result.%Next() {
        quit result.APIKey
    }
    quit ""
}

/// Method: GetDefaultModel
/// Description: Get default model for a specific provider
ClassMethod GetDefaultModel(pProvider As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT DefaultModel FROM AIHubStudio_APIKeys WHERE Provider = ? AND IsActive = 1")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set result = stmt.%Execute(pProvider)
    if result.%Next() {
        quit result.DefaultModel
    }
    
    // Return default based on provider
    if pProvider = "openai" { quit "gpt-4o-mini" }
    if pProvider = "azure" { quit "gpt-4o" }
    if pProvider = "anthropic" { quit "claude-3-haiku" }
    if pProvider = "google" { quit "gemini-1.5-flash" }
    if pProvider = "local" { quit "llama3.2" }
    
    quit "gpt-4o-mini"
}

/// Method: GetAllAPIKeys
/// Description: Get all API keys as JSON
ClassMethod GetAllAPIKeys() As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT Provider, DefaultModel, IsActive FROM AIHubStudio_APIKeys ORDER BY Provider")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute()
    set jsonArray = []
    
    while result.%Next() {
        set obj = {
            "provider": (result.Provider),
            "defaultModel": (result.DefaultModel),
            "isActive": (result.IsActive)
        }
        do jsonArray.%Push(obj)
    }
    
    quit ##class(%Library.JSON).%ToJSON(jsonArray)
}

/// Method: DeleteAPIKey
/// Description: Delete API key for a specific provider
ClassMethod DeleteAPIKey(pProvider As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("DELETE FROM AIHubStudio_APIKeys WHERE Provider = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pProvider)
    quit status
}

/// Method: ValidateAPIKey
/// Description: Validate API key for a specific provider
ClassMethod ValidateAPIKey(pProvider As %String, pAPIKey As %String) As %Boolean
{
    // This is a placeholder for actual validation
    // In production, this would make a test API call
    
    // For now, just check that the key is not empty
    if pAPIKey = "" { quit 0 }
    
    // Provider-specific validation
    if pProvider = "openai" {
        // OpenAI keys start with "sk-"
        if $EXTRACT(pAPIKey, 1, 3) = "sk-" { quit 1 }
    }
    if pProvider = "anthropic" {
        // Anthropic keys start with "sk-ant-"
        if $EXTRACT(pAPIKey, 1, 7) = "sk-ant-" { quit 1 }
    }
    if pProvider = "azure" {
        // Azure keys are longer and alphanumeric
        if $LENGTH(pAPIKey) > 30 { quit 1 }
    }
    if pProvider = "google" {
        // Google keys are base64-like
        if $LENGTH(pAPIKey) > 20 { quit 1 }
    }
    if pProvider = "local" {
        // Local doesn't need a key
        quit 1
    }
    
    // If we can't validate the format, assume it's valid
    quit 1
}

/// Method: GetProviderInfo
/// Description: Get information about a specific provider as a dynamic object
ClassMethod GetProviderInfo(pProvider As %String) As %DynamicObject
{
    set info = {}
    
    if pProvider = "openai" {
        Set info = {
            "name": ("OpenAI"),
            "models": (["gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo"]),
            "apiKeyFormat": ("sk-..."),
            "requiresKey": (1)
        }
    }
    if pProvider = "azure" {
        Set info = {
            "name": ("Azure OpenAI"),
            "models": (["gpt-4o", "gpt-35-turbo"]),
            "apiKeyFormat": ("alphanumeric"),
            "requiresKey": (1)
        }
    }
    if pProvider = "anthropic" {
        Set info = {
            "name": ("Anthropic"),
            "models": (["claude-3-sonnet", "claude-3-haiku", "claude-3-opus"]),
            "apiKeyFormat": ("sk-ant-..."),
            "requiresKey": (1)
        }
    }
    if pProvider = "google" {
        Set info = {
            "name": ("Google"),
            "models": (["gemini-1.5-pro", "gemini-1.5-flash"]),
            "apiKeyFormat": ("base64-like"),
            "requiresKey": (1)
        }
    }
    if pProvider = "local" {
        Set info = {
            "name": ("Local (Ollama)"),
            "models": (["llama3.2", "mistral", "phi3"]),
            "apiKeyFormat": ("none"),
            "requiresKey": (0)
        }
    }
    
    quit info
}

/// Method: GetAllProviderInfo
/// Description: Get information about all providers
ClassMethod GetAllProviderInfo() As %String
{
    set providers = ..#Providers
    set jsonArray = []
    
    for i = 1:1:providers.%Size() {
        set provider = providers.%Get(i)
        do jsonArray.%Push(..GetProviderInfo(provider))
    }
    
    quit ##class(%Library.JSON).%ToJSON(jsonArray)
}

}
