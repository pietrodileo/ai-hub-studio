/// Class: AIHubStudio.Skill.Registry
/// Description: Skill Registry Manager
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Skill.Registry
{

/// Method: Count
/// Description: Get count of registered skills
ClassMethod Count() As %Integer
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT COUNT(*) as cnt FROM AIHubStudio_Skills")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set result = stmt.%Execute()
    if result.%Next() {
        quit result.cnt
    }
    quit 0
}

/// Method: List
/// Description: List all registered skills as JSON array
ClassMethod List() As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT SkillID, SkillName, Description, ClassName, SkillType, CreatedAt FROM AIHubStudio_Skills ORDER BY SkillName")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute()
    set jsonArray = []
    
    while result.%Next() {
        set obj = {
            "SkillID": (result.SkillID),
            "SkillName": (result.SkillName),
            "Description": (result.Description),
            "ClassName": (result.ClassName),
            "SkillType": (result.SkillType),
            "CreatedAt": (result.CreatedAt)
        }
        do jsonArray.%Push(obj)
    }
    
    quit jsonArray.%ToJSON()
}

/// Method: Register
/// Description: Register a new skill
ClassMethod Register(pSkillName As %String, pDescription As %String, pClassName As %String, pSkillType As %String = "knowledge") As %String
{
    #; Generate unique SkillID
    set skillID = $INCREMENT(^AIHubStudio.Skill.Counter)
    if skillID = "" { set skillID = 1 }
    
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("INSERT INTO AIHubStudio_Skills (SkillID, SkillName, Description, ClassName, SkillType, CreatedAt) VALUES (?, ?, ?, ?, ?, ?)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set status = stmt.%Execute(skillID, pSkillName, pDescription, pClassName, pSkillType, $ZDATE($HOROLOG,"YYYY-MM-DD HH:MM:SS"))
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Execute failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    quit skillID
}

/// Method: Get
/// Description: Get skill details by ID as JSON
ClassMethod Get(pSkillID As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT SkillID, SkillName, Description, ClassName, SkillType, CreatedAt FROM AIHubStudio_Skills WHERE SkillID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute(pSkillID)
    Set obj = {}
    if result.%Next() {
        set obj = {
            "SkillID": (result.SkillID),
            "SkillName": (result.SkillName),
            "Description": (result.Description),
            "ClassName": (result.ClassName),
            "SkillType": (result.SkillType),
            "CreatedAt": (result.CreatedAt)
        }
    }
    quit obj.%ToJSON()
}   

/// Method: GetByName
/// Description: Get skill details by name
ClassMethod GetByName(pSkillName As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT SkillID FROM AIHubStudio_Skills WHERE SkillName = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "{}" }
    
    set result = stmt.%Execute(pSkillName)
    Set obj = {}
    if result.%Next() {
        Set obj = ..Get(result.SkillID)
    }
    quit obj.%ToJSON()
}

/// Method: Update
/// Description: Update skill details
ClassMethod Update(pSkillID As %String, pSkillName As %String, pDescription As %String, pClassName As %String, pSkillType As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("UPDATE AIHubStudio_Skills SET SkillName = ?, Description = ?, ClassName = ?, SkillType = ? WHERE SkillID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pSkillName, pDescription, pClassName, pSkillType, pSkillID)
    quit status
}

/// Method: GetFieldValue
/// Description: Helper method to get a field value from a skill by ID
ClassMethod GetFieldValue(pSkillID As %String, pField As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT " _ pField _ " FROM AIHubStudio_Skills WHERE SkillID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "" }
    
    set result = stmt.%Execute(pSkillID)
    if result.%Next() {
        quit result.%Get(pField)
    }
    quit ""
}

/// Method: Delete
/// Description: Delete a skill by ID
ClassMethod Delete(pSkillID As %String) As %Boolean
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("DELETE FROM AIHubStudio_Skills WHERE SkillID = ?")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute(pSkillID)
    quit status
}

/// Method: Initialize
/// Description: Initialize skill registry and create table
ClassMethod Initialize() As %Boolean
{
    #; Create counter global if not exists
    if '$DATA(^AIHubStudio.Skill.Counter) {
        set ^AIHubStudio.Skill.Counter = 0
    }
    
    #; Create table if not exists
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("CREATE TABLE IF NOT EXISTS AIHubStudio_Skills (SkillID INTEGER PRIMARY KEY, SkillName VARCHAR(255) NOT NULL, Description TEXT, ClassName VARCHAR(255) NOT NULL, SkillType VARCHAR(50) DEFAULT 'knowledge', CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit 0 }
    
    set status = stmt.%Execute()
    quit status
}

/// Method: GetStatus
/// Description: Get skill registry status
ClassMethod GetStatus() As %String
{
    set statusObj = {
        "count": (..Count()),
        "initialized": ($DATA(^AIHubStudio.Skill.Counter))
    }
    quit statusObj.%ToJSON()
}

/// Method: Search
/// Description: Search skills by name pattern
ClassMethod Search(pPattern As %String) As %String
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%Prepare("SELECT SkillID, SkillName, Description, ClassName, SkillType, CreatedAt FROM AIHubStudio_Skills WHERE SkillName LIKE ? ORDER BY SkillName")
    if $$$ISERR(status) { set sc = $$$ERROR($$$GeneralError, "SQL Prepare failed: "_stmt.%Message) $$$ThrowOnError(sc) quit "[]" }
    
    set result = stmt.%Execute("%" _ pPattern _ "%")
    set jsonArray = []
    
    while result.%Next() {
        do jsonArray.%Push(..Get(result.SkillID))
    }
    
    quit jsonArray.%ToJSON()
}

}
