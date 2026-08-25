/// Class: AIHubStudio.REST.StarterService
/// Description: REST API for My First Agent - End-To-End Starter
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.StarterService Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

/// Method: GetStarterGuide
/// Description: Get the complete starter guide
ClassMethod GetStarterGuide() As %Status
{
    Set sc = $$$OK
    try {
        set guide = ##class(AIHubStudio.Agent.Starter).GetStarterGuide()
        write guide
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetTemplates
/// Description: Get all available starter templates
ClassMethod GetTemplates() As %Status
{
    Set sc = $$$OK
    try {
        set templates = ##class(AIHubStudio.Agent.Starter).GetTemplates()
        write templates
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetTemplate
/// Description: Get a specific template by name
ClassMethod GetTemplate(name As %String) As %Status
{
    Set sc = $$$OK
    try {
        set template = ##class(AIHubStudio.Agent.Starter).GetTemplate(name)
        write template
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: CreateAgentFromTemplate
/// Description: Create a new agent from a template
ClassMethod CreateAgentFromTemplate(templateName As %String, agentName As %String, description As %String = "") As %Status
{
    Set sc = $$$OK
    try {
        set agentId = ##class(AIHubStudio.Agent.Starter).CreateAgentFromTemplate(templateName, agentName, description)
        
        if (agentId = "") {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Failed to create agent"))
        }
        
        write {"agentId": (agentId), "status": "success", "message": "Agent created successfully"}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetExampleConversation
/// Description: Get example conversation for a template
ClassMethod GetExampleConversation(templateName As %String) As %Status
{
    Set sc = $$$OK
    try {
        set conversation = ##class(AIHubStudio.Agent.Starter).GetExampleConversation(templateName)
        write conversation
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: OnPreDispatch
/// Description: Handle CORS preflight requests
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String) As %Status
{
    if pMethod = "OPTIONS" {
        do ..HandleCorsRequest()
        Return $$$OK
    }
    Return $$$OK
}

/// Method: HandleCorsRequest
/// Description: Handle CORS headers
ClassMethod HandleCorsRequest()
{
    set origin = $GET(%request.CgiEnvs("HTTP_ORIGIN"))
    if origin = "" { set origin = "*" }
    
    do %response.SetHeader("Access-Control-Allow-Origin", origin)
    do %response.SetHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    do %response.SetHeader("Access-Control-Allow-Credentials", "true")
    
    write ""
}

}
