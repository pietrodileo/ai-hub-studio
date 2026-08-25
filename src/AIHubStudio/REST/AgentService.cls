/// Class: AIHubStudio.REST.AgentService
/// Description: REST API for Agent Management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.AgentService Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

/// Method: ListAgents
/// Description: List all registered agents
ClassMethod ListAgents() As %Status
{
    Set sc = $$$OK
    try {
        set agents = ##class(AIHubStudio.Agent.Registry).List()
        write agents
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetAgent
/// Description: Get agent details by ID
ClassMethod GetAgent(id As %String) As %Status
{
    Set sc = $$$OK
    try {
        set agent = ##class(AIHubStudio.Agent.Registry).Get(id)
        write agent
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: RegisterAgent
/// Description: Register a new agent with provider and model support
ClassMethod RegisterAgent(name As %String, description As %String, className As %String, provider As %String = "openai", model As %String = "gpt-4o-mini") As %Status
{
    Set sc = $$$OK
    try {
        set agentId = ##class(AIHubStudio.Agent.Registry).Register(name, description, className, provider, model)
        write {"agentId": (agentId), "status": ($SELECT(agentId'="": "success", 1: "failed")), "provider": (provider), "model": (model)}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: UpdateAgent
/// Description: Update agent details with provider and model support
ClassMethod UpdateAgent(id As %String, name As %String, description As %String, className As %String, provider As %String = "", model As %String = "") As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Agent.Registry).Update(id, name, description, className, provider, model)
        write {"agentId": (id), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: DeleteAgent
/// Description: Delete an agent
ClassMethod DeleteAgent(id As %String) As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Agent.Registry).Delete(id)
        write {"agentId": (id), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: SearchAgents
/// Description: Search agents by name pattern
ClassMethod SearchAgents(pattern As %String) As %Status
{
    Set sc = $$$OK
    try {
        set agents = ##class(AIHubStudio.Agent.Registry).Search(pattern)
        write agents
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
    do %response.SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    do %response.SetHeader("Access-Control-Allow-Credentials", "true")
    
    write ""
}

}
