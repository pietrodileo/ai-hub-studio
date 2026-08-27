/// Class: AIHubStudio.AI.Provider
/// Description: Facade API for Provider management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0
/// Purpose: Simple API for managing AI providers from IRIS Terminal

Class AIHubStudio.AI.Provider Extends %RegisteredObject
{

/// Property: Metadata
/// Description: Reference to the underlying metadata object
Property Metadata As AIHubStudio.Metadata.Provider;

/// Property: Name
/// Description: Name of the provider
Property Name As %String;

/// Property: Type
/// Description: Type of the provider
Property Type As %String;

/// Property: Endpoint
/// Description: Endpoint URL
Property Endpoint As %String;

/// Property: CredentialName
/// Description: Name of credential configuration
Property CredentialName As %String;

/// Property: APIKey
/// Description: API key (use environment variables in production)
Property APIKey As %String;

/// Property: DefaultModel
/// Description: Default model for this provider
Property DefaultModel As %String;

/// Property: Enabled
/// Description: Whether the provider is enabled
Property Enabled As %Boolean;

/// Property: IsNew
/// Description: Flag indicating if this is a new unsaved provider
Property IsNew As %Boolean [ InitialExpression = 1 ];

/// Method: Create
/// Description: Static method to create a new provider
ClassMethod Create(name As %String, type As %String = "") As AIHubStudio.AI.Provider
{
    Set provider = ..%New()
    Set provider.Name = name
    Set provider.Type = type
    Set provider.Enabled = 1
    Set provider.IsNew = 1
    Quit provider
}

/// Method: Open
/// Description: Static method to open an existing provider
ClassMethod Open(name As %String) As AIHubStudio.AI.Provider
{
    Set metadata = ##class(AIHubStudio.Metadata.Provider).GetByName(name)
    If '$ISOBJECT(metadata) {
        Quit $$$NULLOREF
    }
    
    Set provider = ..%New()
    Set provider.Metadata = metadata
    Set provider.Name = metadata.Name
    Set provider.Type = metadata.Type
    Set provider.Endpoint = metadata.Endpoint
    Set provider.CredentialName = metadata.CredentialName
    Set provider.DefaultModel = metadata.DefaultModel
    Set provider.Enabled = metadata.Enabled
    Set provider.IsNew = 0
    
    Quit provider
}

/// Method: Exists
/// Description: Check if a provider exists
ClassMethod Exists(name As %String) As %Boolean
{
    Quit ##class(AIHubStudio.Metadata.Provider).Exists(name)
}

/// Method: List
/// Description: List all providers
ClassMethod List() As %String
{
    Quit ##class(AIHubStudio.Metadata.Provider).ListAll()
}

/// Method: Delete
/// Description: Delete a provider
ClassMethod Delete(name As %String) As %Status
{
    Set metadata = ##class(AIHubStudio.Metadata.Provider).GetByName(name)
    If '$ISOBJECT(metadata) {
        Return $$$ERROR($$$GeneralError, "Provider '_name_' not found")
    }
    
    Set sc = metadata.%Delete()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: Type
/// Description: Set the provider type
Method Type(value As %String) As AIHubStudio.AI.Provider
{
    Set ..Type = value
    If '..IsNew {
        Set ..Metadata.Type = value
    }
    Quit $this
}

/// Method: Endpoint
/// Description: Set the endpoint
Method Endpoint(value As %String) As AIHubStudio.AI.Provider
{
    Set ..Endpoint = value
    If '..IsNew {
        Set ..Metadata.Endpoint = value
    }
    Quit $this
}

/// Method: Credential
/// Description: Set the credential name
Method Credential(name As %String) As AIHubStudio.AI.Provider
{
    Set ..CredentialName = name
    If '..IsNew {
        Set ..Metadata.CredentialName = name
    }
    Quit $this
}

/// Method: APIKeyFromEnvironment
/// Description: Configure to use an environment variable for API key
Method APIKeyFromEnvironment(envVar As %String) As AIHubStudio.AI.Provider
{
    Set ..CredentialName = envVar
    If '..IsNew {
        Set ..Metadata.CredentialName = envVar
    }
    Quit $this
}

/// Method: APIKey
/// Description: Set the API key directly (not recommended for production)
Method APIKey(value As %String) As AIHubStudio.AI.Provider
{
    Set ..APIKey = value
    Quit $this
}

/// Method: DefaultModel
/// Description: Set the default model
Method DefaultModel(value As %String) As AIHubStudio.AI.Provider
{
    Set ..DefaultModel = value
    If '..IsNew {
        Set ..Metadata.DefaultModel = value
    }
    Quit $this
}

/// Method: Enabled
/// Description: Set whether the provider is enabled
Method Enabled(value As %Boolean) As AIHubStudio.AI.Provider
{
    Set ..Enabled = value
    If '..IsNew {
        Set ..Metadata.Enabled = value
    }
    Quit $this
}

/// Method: Save
/// Description: Save the provider
Method Save() As %Status
{
    // Validate
    Set sc = ..Validate()
    If $$$ISERR(sc) {
        Return sc
    }
    
    // Sync properties to metadata
    If ..IsNew {
        Set ..Metadata = ##class(AIHubStudio.Metadata.Provider).%New()
    }
    
    Set ..Metadata.Name = ..Name
    Set ..Metadata.Type = ..Type
    Set ..Metadata.Endpoint = ..Endpoint
    Set ..Metadata.CredentialName = ..CredentialName
    Set ..Metadata.DefaultModel = ..DefaultModel
    Set ..Metadata.Enabled = ..Enabled
    
    Set sc = ..Metadata.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Set ..IsNew = 0
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

/// Method: Show
/// Description: Display provider information
Method Show() As %Status
{
    Write !, "Provider: ", ..Name
    Write !, "Type: ", ..Type
    If ..Endpoint '= "" {
        Write !, "Endpoint: ", ..Endpoint
    }
    If ..CredentialName '= "" {
        Write !, "Credential: ", ..CredentialName
    }
    If ..DefaultModel '= "" {
        Write !, "Default Model: ", ..DefaultModel
    }
    Write !, "Enabled: ", ..Enabled
    
    Quit $$$OK
}

/// Method: GetProviderInfo
/// Description: Get comprehensive provider information
Method GetProviderInfo() As %DynamicObject
{
    If '..IsNew && $ISOBJECT(..Metadata) {
        Quit ..Metadata.GetProviderInfo()
    }
    
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
    }
    ElseIf ..Type = "openai" {
        Set info.models = ["gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo"]
    }
    ElseIf ..Type = "openai-compatible" {
        Set info.models = []
        Set info.customEndpoint = 1
    }
    ElseIf ..Type = "azure" {
        Set info.models = ["gpt-4o", "gpt-35-turbo"]
    }
    ElseIf ..Type = "google" {
        Set info.models = ["gemini-1.5-pro", "gemini-1.5-flash"]
    }
    ElseIf ..Type = "local" {
        Set info.models = ["llama3.2", "mistral", "phi3"]
    }
    ElseIf ..Type = "ollama" {
        Set info.models = []
        Set info.requiresKey = 0
        Set info.customEndpoint = 1
        Set info.sdkProvider = "openai"
    }
    
    Quit info
}

}
