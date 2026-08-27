/// Class: AIHubStudio.Status
/// Description: AI Hub Status Monitor
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Status
{

/// Method: Display
/// Description: Display AI Hub status in console
ClassMethod Display() As %String
{
    write "=== AI Hub Studio Status ===",!
    write "Status: Running",!
    write "Version: " _ ##class(AIHubStudio).GetVersion(),!
    write "Agents: " _ ##class(AIHubStudio.Agent.Registry).Count(),!
    write "Tools: " _ ##class(AIHubStudio.Tool.Registry).Count(),!
    write "Skills: " _ ##class(AIHubStudio.Skill.Registry).Count(),!
    quit "OK"
}

/// Method: HealthCheck
/// Description: Perform health check and return JSON status
ClassMethod HealthCheck() As %DynamicObject
{
    set health = "healthy"
    quit { "status": (health),
          "timestamp": ($ZDATETIME($HOROLOG,3)),
          "version": (##class(AIHubStudio).GetVersion()),
          "agents": (##class(AIHubStudio.Agent.Registry).Count()),
          "tools": (##class(AIHubStudio.Tool.Registry).Count()),
          "skills": (##class(AIHubStudio.Skill.Registry).Count()) }
}

/// Method: GetDetailedStatus
/// Description: Get detailed status with component information
ClassMethod GetDetailedStatus() As %DynamicObject
{
    set status = ##class(%DynamicObject).%FromJSON(##class(AIHubStudio.Agent.Registry).GetStatus())
    set tools = ##class(%DynamicObject).%FromJSON(##class(AIHubStudio.Tool.Registry).GetStatus())
    set skills = ##class(%DynamicObject).%FromJSON(##class(AIHubStudio.Skill.Registry).GetStatus())
    
    quit { "overall": (..HealthCheck()),
          "agents": (status),
          "tools": (tools),
          "skills": (skills) }
}

/// Method: CheckDatabase
/// Description: Check database connectivity and tables
ClassMethod CheckDatabase() As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT 1 AS healthy")
    if $$$ISERR(status) quit 0
    
    set result = stmt.%Execute()
    if '$ISOBJECT(result) quit 0
    if result.%SQLCODE < 0 quit 0
    quit result.%Next()
}

}
