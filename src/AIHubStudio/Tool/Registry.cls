/// Class: AIHubStudio.Tool.Registry
/// Description: Tool Registry Manager
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Tool.Registry
{

/// Method: Count
/// Description: Get count of registered tools
ClassMethod Count() As %Integer
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT COUNT(*) as cnt FROM AIHubStudio_Tools")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set result = stmt.%Execute()
    if result.%Next() {
        quit result.cnt
    }
    quit 0
}

/// Method: List
/// Description: List all registered tools as JSON array
ClassMethod List() As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT ToolID, ToolName, Description, ClassName, ToolType, CreatedAt FROM AIHubStudio_Tools ORDER BY ToolName")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute()
    set jsonArray = []
    
    while result.%Next() {
        set obj = {
            "ToolID": (result.ToolID),
            "ToolName": (result.ToolName),
            "Description": (result.Description),
            "ClassName": (result.ClassName),
            "ToolType": (result.ToolType),
            "CreatedAt": (result.CreatedAt)
        }
        do jsonArray.%Push(obj)
    }
    
    Return jsonArray.%ToJSON()
}

/// Method: Register
/// Description: Register a new tool
ClassMethod Register(pToolName As %String, pDescription As %String, pClassName As %String, pToolType As %String = "function") As %String
{
    #; Generate unique ToolID
    set toolID = $INCREMENT(^AIHubStudio.Tool.Counter)
    if toolID = "" { set toolID = 1 }
    
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("INSERT INTO AIHubStudio_Tools (ToolID, ToolName, Description, ClassName, ToolType, CreatedAt) VALUES (?, ?, ?, ?, ?, ?)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set status = stmt.%Execute(toolID, pToolName, pDescription, pClassName, pToolType, $ZDATE($HOROLOG,"YYYY-MM-DD HH:MM:SS"))
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Execute failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    quit toolID
}

/// Method: Get
/// Description: Get tool details by ID as JSON
ClassMethod Get(pToolID As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT ToolID, ToolName, Description, ClassName, ToolType, CreatedAt FROM AIHubStudio_Tools WHERE ToolID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute(pToolID)
    Set obj = {}
    if result.%Next() {
        set obj = {
            "ToolID": (result.ToolID),
            "ToolName": (result.ToolName),
            "Description": (result.Description),
            "ClassName": (result.ClassName),
            "ToolType": (result.ToolType),
            "CreatedAt": (result.CreatedAt)
        }
    }
    Return obj.%ToJSON()
}

/// Method: GetByName
/// Description: Get tool details by name
ClassMethod GetByName(pToolName As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT ToolID FROM AIHubStudio_Tools WHERE ToolName = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute(pToolName)
    if result.%Next() {
        quit ##class(AIHubStudio.Tool.Registry).Get(result.ToolID)
    }
    quit "{}"
}

/// Method: Update
/// Description: Update tool details
ClassMethod Update(pToolID As %String, pToolName As %String, pDescription As %String, pClassName As %String, pToolType As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("UPDATE AIHubStudio_Tools SET ToolName = ?, Description = ?, ClassName = ?, ToolType = ? WHERE ToolID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pToolName, pDescription, pClassName, pToolType, pToolID)
    quit status
}

/// Method: GetFieldValue
/// Description: Helper method to get a field value from a tool by ID
ClassMethod GetFieldValue(pToolID As %String, pField As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT " _ pField _ " FROM AIHubStudio_Tools WHERE ToolID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set result = stmt.%Execute(pToolID)
    if result.%Next() {
        quit result.%Get(pField)
    }
    quit ""
}

/// Method: Delete
/// Description: Delete a tool by ID
ClassMethod Delete(pToolID As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("DELETE FROM AIHubStudio_Tools WHERE ToolID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pToolID)
    quit status
}

/// Method: Initialize
/// Description: Initialize tool registry and create table
ClassMethod Initialize() As %Boolean
{
    #; Create counter global if not exists
    if '$DATA(^AIHubStudio.Tool.Counter) {
        set ^AIHubStudio.Tool.Counter = 0
    }
    
    #; Create table if not exists
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("CREATE TABLE IF NOT EXISTS AIHubStudio_Tools (ToolID INTEGER PRIMARY KEY, ToolName VARCHAR(255) NOT NULL, Description TEXT, ClassName VARCHAR(255) NOT NULL, ToolType VARCHAR(50) DEFAULT 'function', CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute()
    quit status
}

/// Method: GetStatus
/// Description: Get tool registry status
ClassMethod GetStatus() As %String
{
    set statusObj = {
        "count": (..Count()),
        "initialized": ($DATA(^AIHubStudio.Tool.Counter))
    }
    Return statusObj.%ToJSON()
}

/// Method: Search
/// Description: Search tools by name pattern
ClassMethod Search(pPattern As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT ToolID, ToolName, Description, ClassName, ToolType, CreatedAt FROM AIHubStudio_Tools WHERE ToolName LIKE ? ORDER BY ToolName")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute("%" _ pPattern _ "%")
    set jsonArray = []
    
    while result.%Next() {
        do jsonArray.%Push(..Get(result.ToolID))
    }
    
    Return jsonArray.%ToJSON()
}

}
