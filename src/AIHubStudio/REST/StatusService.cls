/// Class: AIHubStudio.REST.StatusService
/// Description: REST API for System Status
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.StatusService Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

/// Method: GetStatus
/// Description: Get system status
ClassMethod GetStatus() As %Status
{
    Set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Status).HealthCheck()
        write status.%ToJSON()
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetDetailedStatus
/// Description: Get detailed system status
ClassMethod GetDetailedStatus() As %Status
{
    Set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Status).GetDetailedStatus()
        write status.%ToJSON()
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: CheckDatabase
/// Description: Check database connectivity
ClassMethod CheckDatabase() As %Status
{
    Set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Status).CheckDatabase()
        write {"databaseStatus": ($SELECT(status: "healthy", 1: "unhealthy"))}
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
    do %response.SetHeader("Access-Control-Allow-Methods", "GET, OPTIONS")
    do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    do %response.SetHeader("Access-Control-Allow-Credentials", "true")
    
    write ""
}

}
