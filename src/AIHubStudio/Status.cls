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
ClassMethod HealthCheck() As %String
{
    set health = "healthy"
    quit { "status": (health),
          "timestamp": ($ZDATE($HOROLOG,"YYYY-MM-DD HH:MM:SS")),
          "version": (##class(AIHubStudio).GetVersion()),
          "agents": (##class(AIHubStudio.Agent.Registry).Count()),
          "tools": (##class(AIHubStudio.Tool.Registry).Count()),
          "skills": (##class(AIHubStudio.Skill.Registry).Count()) }
}

/// Method: GetDetailedStatus
/// Description: Get detailed status with component information
ClassMethod GetDetailedStatus() As %String
{
    set status = ##class(AIHubStudio.Agent.Registry).GetStatus()
    set tools = ##class(AIHubStudio.Tool.Registry).GetStatus()
    set skills = ##class(AIHubStudio.Skill.Registry).GetStatus()
    
    quit { "overall": (..HealthCheck()),
          "agents": (status),
          "tools": (tools),
          "skills": (skills) }
}

/// Method: CheckDatabase
/// Description: Check database connectivity and tables
ClassMethod CheckDatabase() As %Boolean
{
    #; Check if configuration table exists
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AIHubStudio_Config'")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set result = stmt.%Execute()
    if result.%Next() && (result.cnt > 0) {
        quit 1
    }
    quit 0
}

}
