Class AIHubStudio.REST.WebGateway Extends %CSP.REST
{
XData UrlMap
{
<Routes>
<Route Url="/agents" Method="GET" Call="AIHubStudio.REST.AgentService:ListAgents" />
<Route Url="/agents/:key" Method="GET" Call="AIHubStudio.REST.AgentService:GetAgent" />
<Route Url="/conversations" Method="POST" Call="AIHubStudio.REST.ConversationService:Start" />
<Route Url="/conversations/:id" Method="GET" Call="AIHubStudio.REST.ConversationService:Get" />
<Route Url="/conversations/:id" Method="DELETE" Call="AIHubStudio.REST.ConversationService:Delete" />
<Route Url="/conversations/:id/messages" Method="POST" Call="AIHubStudio.REST.ConversationService:Send" />
<Route Url="/status" Method="GET" Call="AIHubStudio.REST.StatusService:GetStatus" />
</Routes>
}
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Do %response.SetHeader("Access-Control-Allow-Origin","*")
    Do %response.SetHeader("Access-Control-Allow-Methods","GET, POST, DELETE, OPTIONS")
    Do %response.SetHeader("Access-Control-Allow-Headers","Content-Type")
    Quit $$$OK
}
}
