/// Class: AIHubStudio.REST.ToolService
/// Description: REST API for Tool Management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.ToolService Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

/// Method: ListTools
/// Description: List all registered tools
ClassMethod ListTools() As %Status
{
    Set sc = $$$OK
    try {
        set tools = ##class(AIHubStudio.Tool.Registry).List()
        write tools
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetTool
/// Description: Get tool details by ID
ClassMethod GetTool(id As %String) As %Status
{
    Set sc = $$$OK
    try {
        set tool = ##class(AIHubStudio.Tool.Registry).Get(id)
        write tool
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: RegisterTool
/// Description: Register a new tool
ClassMethod RegisterTool(name As %String, description As %String, className As %String, toolType As %String = "function") As %Status
{
    Set sc = $$$OK
    try {
        set toolId = ##class(AIHubStudio.Tool.Registry).Register(name, description, className, toolType)
        write {"toolId": (toolId), "status": ($SELECT(toolId'="": "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: UpdateTool
/// Description: Update tool details
ClassMethod UpdateTool(id As %String, name As %String, description As %String, className As %String, toolType As %String) As %Status
{
    Set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Tool.Registry).Update(id, name, description, className, toolType)
        write {"toolId": (id), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: DeleteTool
/// Description: Delete a tool
ClassMethod DeleteTool(id As %String) As %Status
{
    Set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Tool.Registry).Delete(id)
        write {"toolId": (id), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: SearchTools
/// Description: Search tools by name pattern
ClassMethod SearchTools(pattern As %String) As %Status
{
    Set sc = $$$OK
    try {
        set tools = ##class(AIHubStudio.Tool.Registry).Search(pattern)
        write tools
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
    do %response.SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    do %response.SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    do %response.SetHeader("Access-Control-Allow-Credentials", "true")
    
    write ""
}

}
