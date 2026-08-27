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
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit 0 }
    
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
    set jsonArray = []
    Try {
        set stmt = ##class(%SQL.Statement).%New()
        set status = stmt.%Prepare("SELECT AgentID, AgentName, Description, ClassName, Provider, Model, CreatedAt FROM AIHubStudio_Agents ORDER BY AgentName")
        if $$$ISERR(status) {
            set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status))
            $$$ThrowOnError(sc)
        }

        set result = stmt.%Execute()

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
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
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
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit "" }
    
    set status = stmt.%Execute(agentID, pAgentName, pDescription, pClassName, pProvider, pModel, $ZDATETIME($HOROLOG,3))
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Execute failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit "" }
    
    quit agentID
}

/// Method: Get
/// Description: Get agent details by ID as JSON
ClassMethod Get(pAgentID As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT AgentID, AgentName, Description, ClassName, Provider, Model, CreatedAt FROM AIHubStudio_Agents WHERE AgentID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit "{}" }
    
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
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute(pAgentName)
    if result.%Next() {
        quit ..Get(result.AgentID)
    }
    quit "{}"
}

/// Method: Update
/// Description: Update agent details with provider and model support
ClassMethod Update(pAgentID As %String, pAgentName As %String, pDescription As %String, pClassName As %String, pProvider As %String = "", pModel As %String = "") As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("UPDATE AIHubStudio_Agents SET AgentName = ?, Description = ?, ClassName = ?, Provider = ?, Model = ? WHERE AgentID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit 0 }
    
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
    if '$LISTFIND($LISTBUILD("AgentName","Description","ClassName","Provider","Model","CreatedAt"), pField) quit ""
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT " _ pField _ " FROM AIHubStudio_Agents WHERE AgentID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit "" }
    
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
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pAgentID)
    quit status
}

/// Method: Initialize
/// Description: Initialize agent registry and create table
ClassMethod Initialize() As %Boolean
{
    if '$DATA(^AIHubStudio.Agent.Counter) {
        set ^AIHubStudio.Agent.Counter = 0
    }
    if ..TableExists("AIHubStudio_Agents") quit 1
    set status = ##class(%SQL.Statement).%ExecDirect(, "CREATE TABLE AIHubStudio_Agents (AgentID INTEGER PRIMARY KEY, AgentName VARCHAR(255) NOT NULL, Description VARCHAR(1000), ClassName VARCHAR(255) NOT NULL, Provider VARCHAR(50) DEFAULT 'openai', Model VARCHAR(100) DEFAULT 'gpt-4o-mini', CreatedAt TIMESTAMP)")
    quit $$$ISOK(status)
}

ClassMethod TableExists(tableName As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE UPPER(TABLE_NAME) = UPPER(?)")
    if $$$ISERR(status) quit 0
    set result = stmt.%Execute(tableName)
    if result.%Next() quit result.cnt > 0
    quit 0
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
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_$SYSTEM.Status.GetErrorText(status)) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute("%" _ pPattern _ "%")
    set jsonArray = []
    
    while result.%Next() {
        do jsonArray.%Push(##class(%DynamicObject).%FromJSON(..Get(result.AgentID)))
    }
    
    quit jsonArray.%ToJSON()
}

}
