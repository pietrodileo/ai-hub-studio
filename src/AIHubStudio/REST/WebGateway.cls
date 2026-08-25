/// Class: AIHubStudio.REST.WebGateway
/// Description: Main Web Gateway for AI Hub REST API
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.WebGateway Extends %CSP.REST
{

XData UrlMap
{
<Routes>

<!-- Configuration Routes -->
<Route Url="/config" Method="GET" Call="AIHubStudio.REST.ConfigService:GetAllConfig" />
<Route Url="/config/:key" Method="GET" Call="AIHubStudio.REST.ConfigService:GetConfig" />
<Route Url="/config" Method="POST" Call="AIHubStudio.REST.ConfigService:SetConfig" />

<!-- API Key Management Routes -->
<Route Url="/config/apikeys" Method="GET" Call="AIHubStudio.REST.ConfigService:GetAllAPIKeys" />
<Route Url="/config/apikeys/:provider" Method="GET" Call="AIHubStudio.REST.ConfigService:GetAPIKeyInfo" />
<Route Url="/config/apikeys/:provider" Method="POST" Call="AIHubStudio.REST.ConfigService:SetAPIKey" />
<Route Url="/config/apikeys/:provider" Method="DELETE" Call="AIHubStudio.REST.ConfigService:DeleteAPIKey" />
<Route Url="/config/apikeys/validate/:provider" Method="POST" Call="AIHubStudio.REST.ConfigService:ValidateAPIKey" />
<Route Url="/config/providers" Method="GET" Call="AIHubStudio.REST.ConfigService:GetProviders" />
<Route Url="/config/providers/:provider/models" Method="GET" Call="AIHubStudio.REST.ConfigService:GetProviderModels" />
<Route Url="/config/default-provider" Method="GET" Call="AIHubStudio.REST.ConfigService:GetDefaultProvider" />
<Route Url="/config/default-provider" Method="POST" Call="AIHubStudio.REST.ConfigService:SetDefaultProvider" />

<!-- Agent Routes -->
<Route Url="/agents" Method="GET" Call="AIHubStudio.REST.AgentService:ListAgents" />
<Route Url="/agents/:id" Method="GET" Call="AIHubStudio.REST.AgentService:GetAgent" />
<Route Url="/agents" Method="POST" Call="AIHubStudio.REST.AgentService:RegisterAgent" />
<Route Url="/agents/:id" Method="PUT" Call="AIHubStudio.REST.AgentService:UpdateAgent" />
<Route Url="/agents/:id" Method="DELETE" Call="AIHubStudio.REST.AgentService:DeleteAgent" />
<Route Url="/agents/search/:pattern" Method="GET" Call="AIHubStudio.REST.AgentService:SearchAgents" />
<Route Url="/agents/:id/message" Method="POST" Call="AIHubStudio.REST.AgentMessageService:SendMessage" />
<Route Url="/agents/:id/conversation" Method="POST" Call="AIHubStudio.REST.AgentMessageService:StartConversation" />

<!-- Tool Routes -->
<Route Url="/tools" Method="GET" Call="AIHubStudio.REST.ToolService:ListTools" />
<Route Url="/tools/:id" Method="GET" Call="AIHubStudio.REST.ToolService:GetTool" />
<Route Url="/tools" Method="POST" Call="AIHubStudio.REST.ToolService:RegisterTool" />
<Route Url="/tools/:id" Method="PUT" Call="AIHubStudio.REST.ToolService:UpdateTool" />
<Route Url="/tools/:id" Method="DELETE" Call="AIHubStudio.REST.ToolService:DeleteTool" />
<Route Url="/tools/search/:pattern" Method="GET" Call="AIHubStudio.REST.ToolService:SearchTools" />

<!-- Skill Routes -->
<Route Url="/skills" Method="GET" Call="AIHubStudio.REST.SkillService:ListSkills" />
<Route Url="/skills/:id" Method="GET" Call="AIHubStudio.REST.SkillService:GetSkill" />
<Route Url="/skills" Method="POST" Call="AIHubStudio.REST.SkillService:RegisterSkill" />
<Route Url="/skills/:id" Method="PUT" Call="AIHubStudio.REST.SkillService:UpdateSkill" />
<Route Url="/skills/:id" Method="DELETE" Call="AIHubStudio.REST.SkillService:DeleteSkill" />
<Route Url="/skills/search/:pattern" Method="GET" Call="AIHubStudio.REST.SkillService:SearchSkills" />

<!-- Status Routes -->
<Route Url="/status" Method="GET" Call="AIHubStudio.REST.StatusService:GetStatus" />
<Route Url="/status/detailed" Method="GET" Call="AIHubStudio.REST.StatusService:GetDetailedStatus" />
<Route Url="/status/database" Method="GET" Call="AIHubStudio.REST.StatusService:CheckDatabase" />

<!-- Starter Routes -->
<Route Url="/starter/guide" Method="GET" Call="AIHubStudio.REST.StarterService:GetStarterGuide" />
<Route Url="/starter/templates" Method="GET" Call="AIHubStudio.REST.StarterService:GetTemplates" />
<Route Url="/starter/templates/:name" Method="GET" Call="AIHubStudio.REST.StarterService:GetTemplate" />
<Route Url="/starter/create" Method="POST" Call="AIHubStudio.REST.StarterService:CreateAgentFromTemplate" />
<Route Url="/starter/conversation/:templateName" Method="GET" Call="AIHubStudio.REST.StarterService:GetExampleConversation" />

</Routes>
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
    do %response.SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    do %response.SetHeader("Access-Control-Allow-Credentials", "true")
    
    write ""
}

/// Method: GetAPIInfo
/// Description: Get API information and documentation
ClassMethod GetAPIInfo() As %Status
{
    Set sc = $$$OK
    try {
        set apiInfo = {
            "name": "IRIS AI Hub Studio API",
            "version": "1.0.0",
            "description": "REST API for IRIS AI Hub Studio - Unified AI Development Platform",
            "endpoints": [
                {
                    "path": "/config",
                    "methods": ["GET", "POST"],
                    "description": "Configuration management"
                },
                {
                    "path": "/agents",
                    "methods": ["GET", "POST"],
                    "description": "Agent management"
                },
                {
                    "path": "/agents/:id/message",
                    "methods": ["POST"],
                    "description": "Send messages to agents"
                },
                {
                    "path": "/tools",
                    "methods": ["GET", "POST"],
                    "description": "Tool management"
                },
                {
                    "path": "/skills",
                    "methods": ["GET", "POST"],
                    "description": "Skill management"
                },
                {
                    "path": "/status",
                    "methods": ["GET"],
                    "description": "System status"
                },
                {
                    "path": "/starter",
                    "methods": ["GET", "POST"],
                    "description": "My First Agent - End-to-End Starter Guide"
                }
            ]
        }
        
        write apiInfo
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

}
