Class AIHubStudio.Policy.DataAuthorization Extends %AI.Policy.Authorization
{

Method %CanExecute(tool As %String, call As %DynamicObject, metadata As %DynamicObject) As %Status
{
    Set toolName = tool
    If $EXTRACT(tool,1) = "{" {
        Try {
            Set toolInfo = {}.%FromJSON(tool)
            Set toolName = toolInfo.%Get("name",tool)
        } Catch ex {
            Set toolName = tool
        }
    }
    Set allowed = $LISTBUILD("ListDataResources","FindCustomers","ReadSampleGlobal","Calculate")
    If '$LISTFIND(allowed,toolName) {
        Set denied = $$$ERROR($$$AICoreToolAccessDenied,"Tool is not allowlisted: "_toolName)
        Set audit = ##class(AIHubStudio.Metadata.ToolAudit).Log(toolName,"{}",denied)
        Quit denied
    }
    If '$ISOBJECT(call) Quit $$$ERROR($$$AICoreToolAccessDenied,"Invalid tool call")
    Set args = call.%Get("arguments",{})
    If toolName = "FindCustomers" {
        Set limit = +args.%Get("limit",20)
        If limit < 1 Set limit = 1
        If limit > 50 Set limit = 50
        Do args.%Set("limit",limit)
    }
    If toolName = "ReadSampleGlobal" {
        Set path = args.%Get("path","")
        Set depth = +args.%Get("depth",2)
        Set limit = +args.%Get("limit",20)
        If $EXTRACT(path,1,17) '= "^AIHubStudio.Sample" {
            Set denied = $$$ERROR($$$AICoreToolAccessDenied,"Global path is not allowlisted")
            Set audit = ##class(AIHubStudio.Metadata.ToolAudit).Log(toolName,{"path":(path)}.%ToJSON(),denied)
            Quit denied
        }
        If depth < 0 Set depth = 0
        If depth > 3 Set depth = 3
        If limit < 1 Set limit = 1
        If limit > 50 Set limit = 50
        Do args.%Set("depth",depth), args.%Set("limit",limit)
    }
    Quit $$$OK
}

}
