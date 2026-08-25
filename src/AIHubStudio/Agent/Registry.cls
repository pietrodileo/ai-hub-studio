/// Class: AIHubStudio.Agent.Registry
/// Description: Agent Registry Manager
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Agent.Registry
{

/// Method: Count
/// Description: Get count of registered agents
ClassMethod Count() As %Integer
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT COUNT(*) as cnt FROM AIHubStudio_Agents")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set result = stmt.%Execute()
    if result.%Next() {
        quit result.cnt
    }
    quit 0
}

/// Method: List
/// Description: List all registered agents as JSON array
ClassMethod List() As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT AgentID, AgentName, Description, ClassName, Provider, Model, CreatedAt FROM AIHubStudio_Agents ORDER BY AgentName")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute()
    set jsonArray = []
    
    while result.%Next() {
        set obj = {
            "AgentID": (result.AgentID),
            "AgentName": (result.AgentName),
            "Description": (result.Description),
            "ClassName": (result.ClassName),
            "Provider": (result.Provider),
            "Model": (result.Model),
            "CreatedAt": (result.CreatedAt)
        }
        do jsonArray.%Push(obj)
    }
    
    quit jsonArray.%ToJSON()
}

/// Method: Register
/// Description: Register a new agent with provider and model support
ClassMethod Register(pAgentName As %String, pDescription As %String, pClassName As %String, pProvider As %String = "openai", pModel As %String = "gpt-4o-mini") As %String
{
    #; Generate unique AgentID
    set agentID = $INCREMENT(^AIHubStudio.Agent.Counter)
    if agentID = "" { set agentID = 1 }
    
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("INSERT INTO AIHubStudio_Agents (AgentID, AgentName, Description, ClassName, Provider, Model, CreatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set status = stmt.%Execute(agentID, pAgentName, pDescription, pClassName, pProvider, pModel, $ZDATE($HOROLOG,"YYYY-MM-DD HH:MM:SS"))
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Execute failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    quit agentID
}

/// Method: Get
/// Description: Get agent details by ID as JSON
ClassMethod Get(pAgentID As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT AgentID, AgentName, Description, ClassName, Provider, Model, CreatedAt FROM AIHubStudio_Agents WHERE AgentID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute(pAgentID)
    Set obj = {}
    if result.%Next() {
        set obj = {
            "AgentID": (result.AgentID),
            "AgentName": (result.AgentName),
            "Description": (result.Description),
            "ClassName": (result.ClassName),
            "Provider": (result.Provider),
            "Model": (result.Model),
            "CreatedAt": (result.CreatedAt)
        }
    }
    quit obj.%ToJSON()
}

/// Method: GetByName
/// Description: Get agent details by name
ClassMethod GetByName(pAgentName As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT AgentID FROM AIHubStudio_Agents WHERE AgentName = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute(pAgentName)
    Set obj = {}
    if result.%Next() {
        set obj = ..Get(result.AgentID)
    }
    quit obj.%ToJSON()
}

/// Method: Update
/// Description: Update agent details with provider and model support
ClassMethod Update(pAgentID As %String, pAgentName As %String, pDescription As %String, pClassName As %String, pProvider As %String = "", pModel As %String = "") As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("UPDATE AIHubStudio_Agents SET AgentName = ?, Description = ?, ClassName = ?, Provider = ?, Model = ? WHERE AgentID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    // Use existing values if new ones are not provided
    if pProvider = "" { set pProvider = ..GetFieldValue(pAgentID, "Provider") }
    if pModel = "" { set pModel = ..GetFieldValue(pAgentID, "Model") }
    
    set status = stmt.%Execute(pAgentName, pDescription, pClassName, pProvider, pModel, pAgentID)
    quit status
}

/// Method: GetFieldValue
/// Description: Helper method to get a field value from an agent by ID
ClassMethod GetFieldValue(pAgentID As %String, pField As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT " _ pField _ " FROM AIHubStudio_Agents WHERE AgentID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set result = stmt.%Execute(pAgentID)
    if result.%Next() {
        quit result.%Get(pField)
    }
    quit ""
}

/// Method: Delete
/// Description: Delete an agent by ID
ClassMethod Delete(pAgentID As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("DELETE FROM AIHubStudio_Agents WHERE AgentID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pAgentID)
    quit status
}

/// Method: Initialize
/// Description: Initialize agent registry and create table
ClassMethod Initialize() As %Boolean
{
    #; Create counter global if not exists
    if '$DATA(^AIHubStudio.Agent.Counter) {
        set ^AIHubStudio.Agent.Counter = 0
    }
    
    #; Create table if not exists
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("CREATE TABLE IF NOT EXISTS AIHubStudio_Agents (AgentID INTEGER PRIMARY KEY, AgentName VARCHAR(255) NOT NULL, Description TEXT, ClassName VARCHAR(255) NOT NULL, Provider VARCHAR(50) DEFAULT 'openai', Model VARCHAR(100) DEFAULT 'gpt-4o-mini', CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute()
    
    // Add Provider and Model columns if they don't exist (for existing tables)
    set stmt2 = ##class(%SQL.Statement).%New()
    set status = stmt2.%Prepare("PRAGMA table_info(AIHubStudio_Agents)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt2.%Message) $$$ThrowOnError(sc) }
    
    set result = stmt2.%Execute()
    set hasProvider = 0
    set hasModel = 0
    while result.%Next() {
        if result.name = "Provider" { set hasProvider = 1 }
        if result.name = "Model" { set hasModel = 1 }
    }
    
    if 'hasProvider {
        set stmt3 = ##class(%SQL.Statement).%New()
        set status = stmt3.%Prepare("ALTER TABLE AIHubStudio_Agents ADD COLUMN Provider VARCHAR(50) DEFAULT 'openai'")
        if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Alter failed: "_stmt3.%Message) $$$ThrowOnError(sc) }
        set status = stmt3.%Execute()
    }
    
    if 'hasModel {
        set stmt4 = ##class(%SQL.Statement).%New()
        set status = stmt4.%Prepare("ALTER TABLE AIHubStudio_Agents ADD COLUMN Model VARCHAR(100) DEFAULT 'gpt-4o-mini'")
        if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Alter failed: "_stmt4.%Message) $$$ThrowOnError(sc) }
        set status = stmt4.%Execute()
    }
    
    quit status
}

/// Method: GetStatus
/// Description: Get agent registry status
ClassMethod GetStatus() As %String
{
    set statusObj = {
        "count": (..Count()),
        "initialized": ($DATA(^AIHubStudio.Agent.Counter))
    }
    quit statusObj.%ToJSON()
}

/// Method: Search
/// Description: Search agents by name pattern
ClassMethod Search(pPattern As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT AgentID, AgentName, Description, ClassName, Provider, Model, CreatedAt FROM AIHubStudio_Agents WHERE AgentName LIKE ? ORDER BY AgentName")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute("%" _ pPattern _ "%")
    set jsonArray = []
    
    while result.%Next() {
        do jsonArray.%Push(..Get(result.AgentID))
    }
    
    quit jsonArray.%ToJSON()
}

}
