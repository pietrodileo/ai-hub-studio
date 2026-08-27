Class AIHubStudio.Metadata.ToolAudit Extends %Persistent
{

Property ToolName As %String(MAXLEN = 200);
Property ArgumentsSummary As %String(MAXLEN = 1000);
Property DurationMs As %Numeric;
Property StatusCode As %String(MAXLEN = 500);
Property ResultCount As %Integer;
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

Index CreatedAtIndex On CreatedAt;

ClassMethod Log(toolName As %String, argumentsSummary As %String, status As %Status = 1, resultCount As %Integer = 0, durationMs As %Numeric = 0) As %Status
{
    Set record = ..%New()
    Set record.ToolName = toolName
    Set record.ArgumentsSummary = $EXTRACT(argumentsSummary,1,1000)
    Set record.DurationMs = durationMs
    Set record.StatusCode = $SYSTEM.Status.GetErrorText(status)
    Set record.ResultCount = resultCount
    Quit record.%Save()
}

Storage Default
{
<Data name="ToolAuditDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ToolName</Value>
</Value>
<Value name="3">
<Value>ArgumentsSummary</Value>
</Value>
<Value name="4">
<Value>DurationMs</Value>
</Value>
<Value name="5">
<Value>StatusCode</Value>
</Value>
<Value name="6">
<Value>ResultCount</Value>
</Value>
<Value name="7">
<Value>CreatedAt</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Meta6D8D.ToolAuditD</DataLocation>
<DefaultData>ToolAuditDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Meta6D8D.ToolAuditD</IdLocation>
<IndexLocation>^AIHubStudio.Meta6D8D.ToolAuditI</IndexLocation>
<StreamLocation>^AIHubStudio.Meta6D8D.ToolAuditS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
