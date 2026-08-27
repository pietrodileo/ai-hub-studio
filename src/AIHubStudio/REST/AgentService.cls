Class AIHubStudio.REST.AgentService Extends %RegisteredObject
{
ClassMethod ListAgents() As %Status
{
    Set %response.ContentType = "application/json"
    Write ##class(AIHubStudio.Runtime.AgentCatalog).List().%ToJSON()
    Quit $$$OK
}
ClassMethod GetAgent(key As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set item = ##class(AIHubStudio.Runtime.AgentCatalog).Get(key)
    If item.%Size() = 0 {
        Set %response.Status = "404 Not Found"
        Write {"error":"agent_not_found","message":("Agent not found: "_key)}.%ToJSON()
        Quit $$$OK
    }
    Write item.%ToJSON()
    Quit $$$OK
}
}
