Class AIHubStudio.Tool.Starter Extends %AI.Tool
{

/// Evaluate a basic arithmetic expression.
Method Calculate(expression As %String) As %String [ WebMethod ]
{
    Set result = ##class(AIHubStudio.Tool.Calculator).Evaluate(expression)
    Set sc = ##class(AIHubStudio.Metadata.ToolAudit).Log("Calculate",{"expressionLength":($LENGTH(expression))}.%ToJSON(),$$$OK,1)
    Quit result
}

}
