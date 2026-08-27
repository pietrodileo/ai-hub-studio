/// Class: AIHubStudio.Metadata.Provider
/// Description: Persistent provider configuration for AI Hub agents
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.Provider Extends %Persistent
{

/// Property: Name
/// Description: Unique name of the provider (e.g., "anthropic", "openai")
Property Name As %String(MAXLEN = 100) [ Required ];

/// Property: Type
/// Description: Type of provider (e.g., "anthropic", "openai-compatible", "azure")
Property Type As %String(MAXLEN = 100);

/// Property: Endpoint
/// Description: API endpoint URL (optional for custom providers)
Property Endpoint As %String(MAXLEN = 500);

/// Property: CredentialName
/// Description: Name of credential configuration to use
Property CredentialName As %String(MAXLEN = 200);

/// Property: DefaultModel
/// Description: Default model for this provider
Property DefaultModel As %String(MAXLEN = 200);

/// Property: Enabled
/// Description: Whether this provider is enabled
Property Enabled As %Boolean [ InitialExpression = 1 ];

/// Property: CreatedAt
/// Description: When this provider was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Property: UpdatedAt
/// Description: When this provider was last updated
Property UpdatedAt As %TimeStamp;

/// Index: NameIndex
/// Description: Unique index on Name
Index NameIndex On Name [ Unique, PrimaryKey ];

/// Index: TypeIndex
/// Description: Index on Type for filtering
Index TypeIndex On Type;

/// Index: EnabledIndex
/// Description: Index on Enabled for filtering
Index EnabledIndex On Enabled;

/// Method: OnBeforeSave
/// Description: Update timestamp before saving
Method %OnBeforeSave(insert As %Boolean) As %Status
{
    Set sc = ..Validate()
    If $$$ISERR(sc) Quit sc
    Set ..UpdatedAt = $ZDATETIME($HOROLOG, 3)
    Quit $$$OK
}

/// Method: GetAPIKey
/// Description: Get the API key, preferring CredentialName lookup
Method GetAPIKey() As %String
{
    // If CredentialName is set, try to get from environment or credential store
    If ..CredentialName '= "" {
        // Try environment variable
        Set apiKey = $SYSTEM.Util.GetEnviron(..CredentialName)
        If apiKey '= "" {
            Quit apiKey
        }
        
    }
    Quit ""
}

/// Method: SetAPIKeyFromEnvironment
/// Description: Configure this provider to use an environment variable
Method SetAPIKeyFromEnvironment(pEnvVar As %String) As %Status
{
    Set ..CredentialName = pEnvVar
    Quit $$$OK
}

/// Method: Validate
/// Description: Validate provider configuration
Method Validate() As %Status
{
    If ..Name = "" {
        Return $$$ERROR($$$GeneralError, "Provider name is required")
    }
    
    // OpenAI-compatible and Ollama providers require a custom endpoint.
    If ((..Type [ "openai-compatible") || (..Type = "ollama")) && (..Endpoint = "") {
        Return $$$ERROR($$$GeneralError, "Endpoint is required for openai-compatible providers")
    }
    
    Quit $$$OK
}

/// Method: ToJSON
/// Description: Export provider as JSON
Method ToJSON() As %String
{
    Set obj = {
        "name": (..Name),
        "type": (..Type),
        "endpoint": (..Endpoint),
        "credentialName": (..CredentialName),
        "defaultModel": (..DefaultModel),
        "enabled": (..Enabled),
        "createdAt": (..CreatedAt),
        "updatedAt": (..UpdatedAt)
    }
    Quit obj.%ToJSON()
}

/// Method: GetProviderInfo
/// Description: Get comprehensive provider information including defaults
Method GetProviderInfo() As %DynamicObject
{
    Set info = {
        "name": (..Name),
        "type": (..Type),
        "endpoint": (..Endpoint),
        "credentialName": (..CredentialName),
        "defaultModel": (..DefaultModel),
        "enabled": (..Enabled)
    }
    
    // Add models based on type
    If ..Type = "anthropic" {
        Set info.models = ["claude-3-sonnet", "claude-3-haiku", "claude-3-opus", "claude-2"]
        Set info.apiKeyFormat = "sk-ant-..."
        Set info.requiresKey = 1
    }
    ElseIf ..Type = "openai" {
        Set info.models = ["gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo"]
        Set info.apiKeyFormat = "sk-..."
        Set info.requiresKey = 1
    }
    ElseIf ..Type = "openai-compatible" {
        Set info.models = []
        Set info.apiKeyFormat = "varies"
        Set info.requiresKey = 1
        Set info.customEndpoint = 1
    }
    ElseIf ..Type = "azure" {
        Set info.models = ["gpt-4o", "gpt-35-turbo"]
        Set info.apiKeyFormat = "alphanumeric"
        Set info.requiresKey = 1
    }
    ElseIf ..Type = "google" {
        Set info.models = ["gemini-1.5-pro", "gemini-1.5-flash"]
        Set info.apiKeyFormat = "base64-like"
        Set info.requiresKey = 1
    }
    ElseIf ..Type = "local" {
        Set info.models = ["llama3.2", "mistral", "phi3"]
        Set info.apiKeyFormat = "none"
        Set info.requiresKey = 0
    }
    ElseIf ..Type = "ollama" {
        Set info.models = []
        Set info.apiKeyFormat = "none"
        Set info.requiresKey = 0
        Set info.customEndpoint = 1
        Set info.sdkProvider = "openai"
    }
    
    Quit info
}

/// ClassMethod: GetByName
/// Description: Get provider by name
ClassMethod GetByName(pName As %String) As AIHubStudio.Metadata.Provider
{
    Set provider = $$$NULLOREF
    Try {
        Set provider = ##class(AIHubStudio.Metadata.Provider).NameIndexOpen(pName)
    } Catch ex {
        Set provider = $$$NULLOREF
    }
    Quit provider
}

/// ClassMethod: ListAll
/// Description: List all providers as JSON array
ClassMethod ListAll() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Type, Endpoint, DefaultModel, Enabled FROM AIHubStudio_Metadata.Provider ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "type": (result.Type),
            "endpoint": (result.Endpoint),
            "defaultModel": (result.DefaultModel),
            "enabled": (result.Enabled)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: ListEnabled
/// Description: List all enabled providers
ClassMethod ListEnabled() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Type, DefaultModel FROM AIHubStudio_Metadata.Provider WHERE Enabled = 1 ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "type": (result.Type),
            "defaultModel": (result.DefaultModel)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

Storage Default
{
<Data name="ProviderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Type</Value>
</Value>
<Value name="4">
<Value>Endpoint</Value>
</Value>
<Value name="5">
<Value>CredentialName</Value>
</Value>
<Value name="6">
<Value>DefaultModel</Value>
</Value>
<Value name="7">
<Value>Enabled</Value>
</Value>
<Value name="8">
<Value>CreatedAt</Value>
</Value>
<Value name="9">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Metadata.ProviderD</DataLocation>
<DefaultData>ProviderDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Metadata.ProviderD</IdLocation>
<IndexLocation>^AIHubStudio.Metadata.ProviderI</IndexLocation>
<StreamLocation>^AIHubStudio.Metadata.ProviderS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
