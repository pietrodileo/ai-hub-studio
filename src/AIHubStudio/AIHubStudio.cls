/// Class: AIHubStudio
/// Description: AI Hub Studio - Main Package Class
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.AIHubStudio
{

/// Method: OnStart
/// Description: Initialize AI Hub Studio on startup
ClassMethod OnStart() As %Status
{
    #; Initialize all components
    quit ##class(AIHubStudio.Init).InitializeSystem()
}

/// Method: OnStop
/// Description: Cleanup AI Hub Studio on shutdown
ClassMethod OnStop() As %Status
{
    #; Cleanup resources
    quit $$$OK
}

/// Method: GetVersion
/// Description: Get AI Hub Studio version
ClassMethod GetVersion() As %String
{
    quit "1.0.0"
}

/// Method: GetStatus
/// Description: Get overall AI Hub Studio status
ClassMethod GetStatus() As %String
{
    quit ##class(AIHubStudio.Status).HealthCheck()
}

}
