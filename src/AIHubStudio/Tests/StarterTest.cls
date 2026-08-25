/// Class: AIHubStudio.Tests.StarterTest
/// Description: Test class for My First Agent - End-To-End Starter
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Tests.StarterTest
{

/// Method: RunAllTests
/// Description: Run all starter tests
ClassMethod RunAllTests() As %Status
{
    Set sc = $$$OK
    try {
        write "=== My First Agent - End-to-End Starter Tests ===",!
        
        set status = 1
        
        set status = status && ..TestStarterInitialization()
        set status = status && ..TestTemplateRetrieval()
        set status = status && ..TestAgentCreation()
        set status = status && ..TestExampleConversations()
        set status = status && ..TestStarterGuide()
        
        if $$$ISOK(status) {
            write "All tests PASSED!",!
        } else {
            write "Some tests FAILED!",!
            $$$ThrowOnError(sc)
        }
    } catch ex {
        Set sc = ex.AsStatus()
        write "ERROR: " _ ($SYSTEM.Status.GetErrorText(sc)),!
    }
    Return sc
}

/// Method: TestStarterInitialization
/// Description: Test starter initialization
ClassMethod TestStarterInitialization() As %Boolean
{
    write "Testing starter initialization... "
    
    set status = ##class(AIHubStudio.Agent.Starter).Initialize()
    
    if status {
        write "PASSED",!
    } else {
        write "FAILED",!
    }
    
    quit status
}

/// Method: TestTemplateRetrieval
/// Description: Test template retrieval
ClassMethod TestTemplateRetrieval() As %Boolean
{
    Set status = $$$YES
    write "Testing template retrieval... "
    
    set templates = ##class(AIHubStudio.Agent.Starter).GetTemplates()
    set templateList = templates.%FromJSON()
    
    if (templateList.%Size() = 3) {
        write "PASSED (Found " _ templateList.%Size() _ " templates)",!
        
        #; Test individual template access
        set helloTemplate = ##class(AIHubStudio.Agent.Starter).GetTemplate("hello_world")
        set helloObj = helloTemplate.%FromJSON()
        
        if (helloObj.name = "Hello World Agent") {
            write "  Individual template access: PASSED",!
            set status = $$$YES
        } else {
            write "  Individual template access: FAILED",!
            set status = $$$NO
        }
    } else {
        write "FAILED (Expected 3 templates, got " _ templateList.%Size() _ ")",!
        set status = $$$NO
    }
    Return status
}

/// Method: TestAgentCreation
/// Description: Test agent creation from template
ClassMethod TestAgentCreation() As %Boolean
{
    Set status = $$$YES
    write "Testing agent creation from template... "
    
    #; Create agent from hello_world template
    set agentId = ##class(AIHubStudio.Agent.Starter).CreateAgentFromTemplate("hello_world", "Test Hello Agent", "Test agent for starter functionality")
    
    if (agentId '= "") {
        write "PASSED (Created agent ID: " _ agentId _ ")",!
        
        #; Verify agent was registered
        set agent = ##class(AIHubStudio.Agent.Registry).Get(agentId)
        set agentObj = agent.%FromJSON()
        
        if (agentObj.AgentName = "Test Hello Agent") {
            write "  Agent registration: PASSED",!
            Set status = $$$YES
        } else {
            write "  Agent registration: FAILED",!
            Set status = $$$NO
        }
    } else {
        write "FAILED (Agent ID is empty)",!
        Set status = $$$NO
    }
    Return status
}

/// Method: TestExampleConversations
/// Description: Test example conversation generation
ClassMethod TestExampleConversations() As %Boolean
{
    Set status = $$$YES
    write "Testing example conversations... "
    
    set conversation = ##class(AIHubStudio.Agent.Starter).GetExampleConversation("hello_world")
    set convList = conversation.%FromJSON()
    
    if (convList.%Size() >= 2) {
        write "PASSED (Generated " _ convList.%Size() _ " conversation turns)",!
        set status = $$$YES
    } else {
        write "FAILED (Expected at least 2 turns, got " _ convList.%Size() _ ")",!
        set status = $$$NO
    }
    Return status
}

/// Method: TestStarterGuide
/// Description: Test starter guide generation
ClassMethod TestStarterGuide() As %Boolean
{
    Set status = $$$YES
    write "Testing starter guide generation... "
    
    set guide = ##class(AIHubStudio.Agent.Starter).GetStarterGuide()
    set guideObj = guide.%FromJSON()
    
    if (guideObj.steps.%Size() = 5) {
        write "PASSED (Guide has " _ guideObj.steps.%Size() _ " steps)",!
        set status = $$$YES
    } else {
        write "FAILED (Expected 5 steps, got " _ guideObj.steps.%Size() _ ")",!
        set status = $$$NO
    }
    Return status
}

/// Method: TestRESTEndpoints
/// Description: Test REST endpoints
ClassMethod TestRESTEndpoints() As %Status
{
    Set sc = $$$OK
    write "=== Testing REST Endpoints ===",!
    write "Testing REST endpoints...",!
    Try {        
        #; Test guide endpoint
        set sc = ##class(%CSP.REST).Dispatch("/starter/guide", "GET")
        if 'sc { write "  Guide endpoint: FAILED",! $$$ThrowOnError(sc) }
        write "  Guide endpoint: PASSED",!
        
        #; Test templates endpoint
        set sc = ##class(%CSP.REST).Dispatch("/starter/templates", "GET")
        if 'sc { write "  Templates endpoint: FAILED",! $$$ThrowOnError(sc) }
        write "  Templates endpoint: PASSED",!
        
        #; Test template endpoint
        set sc = ##class(%CSP.REST).Dispatch("/starter/templates/hello_world", "GET")
        if 'sc { write "  Template endpoint: FAILED",! $$$ThrowOnError(sc) }
        write "  Template endpoint: PASSED",!
    } Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

}
