Class AIHubStudio.Policy.ToolAudit Extends %AI.Policy.Audit
{

Method %LogExecution(call As %DynamicObject, metadata As %DynamicObject, result As %DynamicObject, duration As %Integer, status As %Status) As %Status
{
    Set record = ##class(AIHubStudio.Metadata.ToolAudit).%New()
    Set record.ToolName = $GET(call.name)
    Set record.DurationMs = duration
    Set record.StatusCode = $SYSTEM.Status.GetErrorText(status)
    Set record.ResultCount = 0
    If $ISOBJECT(result) Set record.ResultCount = +result.%Get("row_count",result.%Get("count",0))
    If $ISOBJECT(call), $ISOBJECT(call.arguments) {
        Set safe = {}
        For key="name","path","depth","limit" {
            If call.arguments.%IsDefined(key) Do safe.%Set(key,call.arguments.%Get(key))
        }
        Set record.ArgumentsSummary = safe.%ToJSON()
    }
    Set sc = record.%Save()
    Quit sc
}

}
