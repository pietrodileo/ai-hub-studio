Class AIHubStudio.Status
{
ClassMethod HealthCheck() As %DynamicObject
{
    Set catalog = ##class(AIHubStudio.Runtime.AgentCatalog).List()
    Quit {"status":"healthy","timestamp":($ZDATETIME($HOROLOG,3)),"version":"2.0.0","agents":(catalog.%Size())}
}
}
