Class AIHubStudio.REST.ConversationService Extends %RegisteredObject
{
ClassMethod Start() As %Status
{
    Set body = ..ReadBody(.sc)
    If $$$ISERR(sc) Quit ..WriteError("invalid_json","Request body must be valid JSON",400)
    Set agentKey = body.%Get("agentKey",""), model = body.%Get("model","")
    If agentKey = "" Quit ..WriteError("agent_required","agentKey is required",400)
    Set sc = ##class(AIHubStudio.Runtime.Chat).Start(agentKey,.id,model)
    If $$$ISERR(sc) Quit ..WriteStatusError("conversation_start_failed",sc,400)
    Set %response.Status = "201 Created", %response.ContentType = "application/json"
    Write {"conversationId":(id),"agentKey":(agentKey),"modelOverride":(model)}.%ToJSON()
    Quit $$$OK
}
ClassMethod Send(id As %String) As %Status
{
    Set body = ..ReadBody(.sc)
    If $$$ISERR(sc) Quit ..WriteError("invalid_json","Request body must be valid JSON",400)
    Set sc = ##class(AIHubStudio.Runtime.Chat).Send(id,body.%Get("message",""),.result)
    If $$$ISERR(sc) Quit ..WriteStatusError("chat_failed",sc,$SELECT($SYSTEM.Status.GetErrorText(sc)["not found":404,1:400))
    Set %response.ContentType = "application/json"
    Write result.%ToJSON()
    Quit $$$OK
}
ClassMethod Get(id As %String) As %Status
{
    Set sc = ##class(AIHubStudio.Runtime.Chat).Get(id,.result)
    If $$$ISERR(sc) Quit ..WriteStatusError("conversation_not_found",sc,404)
    Set %response.ContentType = "application/json"
    Write result.%ToJSON()
    Quit $$$OK
}
ClassMethod Delete(id As %String) As %Status
{
    Set sc = ##class(AIHubStudio.Runtime.Chat).Delete(id)
    If $$$ISERR(sc) Quit ..WriteStatusError("conversation_not_found",sc,404)
    Set %response.Status = "204 No Content"
    Quit $$$OK
}
ClassMethod ReadBody(Output sc As %Status) As %DynamicObject
{
    Set sc = $$$OK, body = {}
    Try {
        Set body = {}.%FromJSON(%request.Content)
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit body
}
ClassMethod WriteStatusError(code As %String, sc As %Status, httpStatus As %Integer) As %Status
{
    Quit ..WriteError(code,$SYSTEM.Status.GetErrorText(sc),httpStatus)
}
ClassMethod WriteError(code As %String, message As %String, httpStatus As %Integer) As %Status
{
    Set %response.Status = httpStatus_$SELECT(httpStatus=400:" Bad Request",httpStatus=404:" Not Found",1:" Error")
    Set %response.ContentType = "application/json"
    Write {"error":(code),"message":(message)}.%ToJSON()
    Quit $$$OK
}
}
