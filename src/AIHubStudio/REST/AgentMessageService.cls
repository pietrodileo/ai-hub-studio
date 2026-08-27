/// Class: AIHubStudio.REST.AgentMessageService
/// Description: REST API for Agent Messaging
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.AgentMessageService Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

/// Method: SendMessage
/// Description: Send message to an agent and get response
ClassMethod SendMessage(id As %String, message As %String) As %Status
{
    Set sc = $$$OK
    try {
        // Get agent information
        set agentInfo = ##class(AIHubStudio.Agent.Registry).Get(id)
        set agentObj = ##class(%DynamicObject).%FromJSON(agentInfo)
        
        if (agentObj = {}) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Agent not found"))
        }
        
        // Get the agent class
        set agentClass = agentObj.ClassName
        
        // Create agent instance
        set agent = $ClassMethod(agentClass, "%New")
        if '$IsObject(agent) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Failed to create agent"))
        }
        
        // Initialize the agent
        set status = agent.OnInit()
        if $$$ISERR(status) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Failed to initialize agent"))
        }
        
        // Process the message
        set response = agent.Chat(message)
        
        // Return the response
        write {
            "agentId": (id),
            "message": (message),
            "response": (response),
            "timestamp": ($ZDATETIME($HOROLOG, 3)),
            "agentName": (agentObj.AgentName)
        }
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: StartConversation
/// Description: Start a new conversation with an agent
ClassMethod StartConversation(id As %String) As %Status
{
    Set sc = $$$OK
    try {
        // Get agent information
        set agentInfo = ##class(AIHubStudio.Agent.Registry).Get(id)
        set agentObj = ##class(%DynamicObject).%FromJSON(agentInfo)
        
        if (agentObj = {}) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Agent not found"))
        }
        
        // Generate conversation ID
        set conversationId = $system.Util.CreateGUID()
        
        write {
            "agentId": (id),
            "conversationId": (conversationId),
            "status": "started",
            "timestamp": ($ZDATETIME($HOROLOG, 3))
        }
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: HandleCorsRequest
/// Description: Handle CORS headers
ClassMethod HandleCorsRequest()
{
    set origin = $GET(%request.CgiEnvs("HTTP_ORIGIN"))
    if origin = "" { set origin = "*" }
    
    do %response.SetHeader("Access-Control-Allow-Origin", origin)
    do %response.SetHeader("Access-Control-Allow-Methods", "POST, OPTIONS")
    do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    do %response.SetHeader("Access-Control-Allow-Credentials", "true")
    
    write ""
}

}
