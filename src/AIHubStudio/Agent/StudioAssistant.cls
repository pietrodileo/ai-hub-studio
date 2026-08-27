Class AIHubStudio.Agent.StudioAssistant Extends %AI.Agent
{

Parameter TOOLSETS = "AIHubStudio.ToolSet.Starter";
Parameter SKILLS = "AIHubStudio.Skill.DataGuide";

XData INSTRUCTIONS [ MimeType = "text/markdown" ]
{
You are IRIS AI Hub Studio starter assistant. Be concise. Use tools for calculations and sample-data questions. Never claim access outside allowlisted resources.
}

Method %OnInit() As %Status
{
    Set sc = $$$OK
    If '$ISOBJECT(..Provider) {
        Set savedProvider = ##class(AIHubStudio.AI.Provider).Open("LocalOllama")
        If '$ISOBJECT(savedProvider) Quit $$$ERROR($$$GeneralError,"Provider 'LocalOllama' is not registered")
        Set sc = savedProvider.CreateRuntime(.runtimeProvider)
        If $$$ISERR(sc) Quit sc
        Set ..Provider = runtimeProvider
        Set ..Model = savedProvider.DefaultModel
    }
    If ..Model = "" Quit $$$ERROR($$$GeneralError,"LocalOllama has no default model")
    Set sc = ..ToolManager.SetAuthPolicy(##class(AIHubStudio.Policy.DataAuthorization).%New())
    If $$$ISERR(sc) Quit sc
    Set sc = ..ToolManager.SetAuditPolicy(##class(AIHubStudio.Policy.ToolAudit).%New())
    Quit sc
}

}
