/// Class: AIHubStudio.Init
/// Description: Initialization class for AI Hub Studio
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Init
{

/// Method: InitializeSystem
/// Description: Initialize the entire AI Hub system
ClassMethod InitializeSystem() As %Status
{
    try {
        write "Initializing AI Hub Studio...",!
        
        #; Initialize configuration
        write "Initializing configuration...",!
        set status = ##class(AIHubStudio.Config).Initialize()
        if $$$ISERR(status) { write "Configuration initialization FAILED",! set sc = $$$ERROR($$$GeneralError, "Config init failed") $$$ThrowOnError(sc) }
        
        #; Initialize agent registry
        write "Initializing agent registry...",!
        set status = ##class(AIHubStudio.Agent.Registry).Initialize()
        if $$$ISERR(status) { write "Agent registry initialization FAILED",! set sc = $$$ERROR($$$GeneralError, "Agent registry init failed") $$$ThrowOnError(sc) }
        
        #; Initialize tool registry
        write "Initializing tool registry...",!
        set status = ##class(AIHubStudio.Tool.Registry).Initialize()
        if $$$ISERR(status) { write "Tool registry initialization FAILED",! set sc = $$$ERROR($$$GeneralError, "Tool registry init failed") $$$ThrowOnError(sc) }
        
        #; Initialize skill registry
        write "Initializing skill registry...",!
        set status = ##class(AIHubStudio.Skill.Registry).Initialize()
        if $$$ISERR(status) { write "Skill registry initialization FAILED",! set sc = $$$ERROR($$$GeneralError, "Skill registry init failed") $$$ThrowOnError(sc) }
        
        #; Initialize starter templates
        write "Initializing starter templates...",!
        set status = ##class(AIHubStudio.Agent.Starter).Initialize()
        if $$$ISERR(status) { write "Starter templates initialization FAILED",! set sc = $$$ERROR($$$GeneralError, "Starter init failed") $$$ThrowOnError(sc) }
        
        write "AI Hub Studio initialized successfully!",!
    } catch ex {
        Set sc = ex.AsStatus()
        write "ERROR: " _ ($SYSTEM.Status.GetErrorText(sc)),!
    }
    Return sc
}

}
