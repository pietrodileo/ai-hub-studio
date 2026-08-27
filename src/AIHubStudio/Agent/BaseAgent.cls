/// Class: AIHubStudio.Agent.BaseAgent
/// Description: Base agent class extending %AI.Agent with Multi-Provider Support
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Agent.BaseAgent Extends %AI.Agent
{

/// Parameter: PROMPT
/// Description: Default system prompt for the agent
Parameter PROMPT = "You are a helpful AI assistant in the IRIS AI Hub Studio.";

/// Parameter: DefaultProvider
/// 
/// Description: Default AI provider for the agent
Parameter DefaultProvider = "openai";

/// Parameter: DefaultModel
/// Description: Default model for the agent
Parameter DefaultModel = "gpt-4o-mini";

/// Property: Name
/// Description: Name of the agent
Property Name As %String;

/// Property: Description
/// Description: Description of the agent
Property Description As %String;

/// Property: Model
/// Description: AI model to use
Property Model As %String;

/// Property: Temperature
/// Description: Temperature setting for the AI
Property Temperature As %Float;

/// Property: MaxTokens
/// Description: Maximum tokens for responses
Property MaxTokens As %Integer;

/// Property: State
/// Description: Agent state as dynamic object
Property State As %DynamicObject;

/// Property: Config
/// Description: Agent configuration as dynamic object
Property Config As %DynamicObject;

/// Property: Tools
/// Description: Collection of tools available to the agent
Property Tools As %String;

/// Property: Skills
/// Description: Collection of skills available to the agent
Property Skills As %String;

/// Property: Provider
/// Description: Current AI provider for this agent
Property Provider As %AI.Provider [ Required ];

/// Property: CustomModel
/// Description: Custom model override for this agent
Property CustomModel As %String;

/// Property: APIKey
/// Description: API key for the specific provider (optional, can use global config)
Property APIKey As %String;

/// Method: Chat
/// Description: Process user message and generate response
Method Chat(session As %AI.Agent.Session, message As %String, context As %RegisteredObject) As %AI.LLM.Response
{
    // Validate configuration
    Set sc = ..ValidateConfiguration()
    If $$$ISERR(sc) {
        Return sc
    }
    
    // Create and return a response object
    Set response = ##class(%AI.LLM.Response).%New()
    Set response.Text = "Response from " _ ..Name
    Quit response
}

/// Method: OnInit
/// Description: Custom initialization logic
Method OnInit() As %Status
{
    Set sc = $$$OK
    // Load provider-specific configuration
    Try {
        // If no custom API key, try to get from global config
        If ..APIKey = "" {
            Set ..APIKey = ##class(AIHubStudio.Config).GetAPIKey(..Provider)
        }
        
        // If no custom model, try to get default for provider
        If ..CustomModel = "" {
            Set ..CustomModel = ##class(AIHubStudio.Config).GetDefaultModel(..Provider)
        }
        
        // Use custom model if set, otherwise use default
        If ..CustomModel '= "" {
            Set ..Model = ..CustomModel
        }
        
        // Validate the configuration
        Set sc = ..ValidateConfiguration()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

/// Method: ValidateConfiguration
/// Description: Validate agent configuration
Method ValidateConfiguration() As %Status
{
    Set sc = $$$OK
    
    // Check if provider is supported
    Set providers = ##class(AIHubStudio.Config).#Providers
    Set isValidProvider = 0
    For i = 0:1:(providers.%Size() - 1) {
        If providers.%Get(i) = ..Provider {
            Set isValidProvider = 1
            Quit
        }
    }
    
    If 'isValidProvider {
        Return $$$ERROR($$$GeneralError, "Unsupported provider: " _ ..Provider)
    }
    
    // Check if API key is available (if required)
    If ..APIKey = "" {
        Set ..APIKey = ##class(AIHubStudio.Config).GetAPIKey(..Provider)
    }
    
    If ..APIKey = "" {
        // Check if provider requires a key
        Set providerInfo = ##class(AIHubStudio.Config).GetProviderInfo(..Provider)
        // For now, we'll allow it and let the actual API call fail
        // In production, you might want to be stricter
    }
    
    Return sc
}

/// Method: SwitchProvider
/// Description: Switch the AI provider for this agent
Method SwitchProvider(pProvider As %String, pModel As %String = "", pAPIKey As %String = "") As %Status
{
    // Validate provider
    Set providers = ##class(AIHubStudio.Config).#Providers
    Set isValidProvider = 0
    For i = 0:1:(providers.%Size() - 1) {
        If providers.%Get(i) = pProvider {
            Set isValidProvider = 1
            Quit
        }
    }
    
    If 'isValidProvider {
        Return $$$ERROR($$$GeneralError, "Unsupported provider: " _ pProvider)
    }
    
    // Set new provider
    Set ..Provider = pProvider
    
    // Set custom model if provided
    If pModel '= "" {
        Set ..CustomModel = pModel
        Set ..Model = pModel
    } Else {
        // Get default model for provider
        Set ..CustomModel = ""
        Set ..Model = ##class(AIHubStudio.Config).GetDefaultModel(pProvider)
    }
    
    // Set API key if provided
    If pAPIKey '= "" {
        Set ..APIKey = pAPIKey
    } Else {
        // Try to get from global config
        Set ..APIKey = ##class(AIHubStudio.Config).GetAPIKey(pProvider)
    }
    
    // Re-validate configuration
    Set sc = ..ValidateConfiguration()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: SwitchModel
/// Description: Switch the model for this agent
Method SwitchModel(pModel As %String) As %Status
{
    // Validate model for current provider
    Set providerInfo = ##class(AIHubStudio.Config).GetProviderInfo(..Provider)
    
    // Check if model is in the provider's supported models
    // Note: This is a simplified check - in production, you'd want to validate against actual API
    Set models = providerInfo.models
    Set isValidModel = 0
    For i = 0:1:(models.%Size() - 1) {
        If models.%Get(i) = pModel {
            Set isValidModel = 1
            Quit
        }
    }
    
    If 'isValidModel {
        Return $$$ERROR($$$GeneralError, "Model " _ pModel _ " is not supported by provider " _ ..Provider)
    }
    
    Set ..CustomModel = pModel
    Set ..Model = pModel
    
    Quit $$$OK
}

/// Method: GetAvailableModels
/// Description: Get available models for the current provider
Method GetAvailableModels() As %DynamicArray
{
    Set providerInfo = ##class(AIHubStudio.Config).GetProviderInfo(..Provider)
    
    // providerInfo is a dynamic object, get models array directly
    Set models = providerInfo.models
    
    Quit models
}



/// Method: AddCustomTool
/// Description: Add a custom tool to the agent
Method AddCustomTool(toolName As %String, toolClass As %String) As %Status
{
    Set id = ##class(AIHubStudio.Tool.Registry).Register(toolName, toolName _ " tool", toolClass, "function")
    Set status = $Select(id'="":$$$OK,1:$$$ERROR($$$GeneralError,"Tool registration failed"))
    
    Quit status
}

/// Method: AddCustomSkill
/// Description: Add a custom skill to the agent
Method AddCustomSkill(skillName As %String, skillClass As %String) As %Status
{
    Set id = ##class(AIHubStudio.Skill.Registry).Register(skillName, skillName _ " skill", skillClass, "knowledge")
    Set status = $Select(id'="":$$$OK,1:$$$ERROR($$$GeneralError,"Skill registration failed"))
    
    Quit status
}

/// Method: GetAgentInfo
/// Description: Get agent information
Method GetAgentInfo() As %DynamicObject
{
    Set info = {
        "name": (..Name),
        "description": (..Description),
        "model": (..Model),
        "provider": (..Provider),
        "customModel": (..CustomModel),
        "temperature": (..Temperature),
        "maxTokens": (..MaxTokens),
        "tools": [],
        "skills": [],
        "state": (..State),
        "hasAPIKey": (..APIKey '= "")
    }
    
    // Add tools
    For i = 1:1:..Tools.Count() {
        Do info.tools.%Push(..Tools.GetAt(i))
    }
    
    // Add skills
    For i = 1:1:..Skills.Count() {
        Do info.skills.%Push(..Skills.GetAt(i))
    }
    
    Quit info
}

/// Method: GetConfigurationSummary
/// Description: Get a summary of the agent's configuration
Method GetConfigurationSummary() As %String
{
    Set info = ..GetAgentInfo()
    
    Set summary = "Agent: " _ info.name _ 
                  ", Provider: " _ info.provider _ 
                  ", Model: " _ info.model
    
    If info.hasAPIKey {
        Set summary = summary _ ", API Key: Configured"
    } Else {
        Set summary = summary _ ", API Key: Using global config"
    }
    
    Quit summary
}

}
