/// Class: AIHubStudio.Metadata.Tool
/// Description: Persistent tool definition for AI Hub
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.Tool Extends %Persistent
{

/// Property: Name
/// Description: Unique name of the tool
Property Name As %String(MAXLEN = 100) [ Required ];

/// Property: Description
/// Description: Description of what the tool does
Property Description As %String(MAXLEN = 1000);

/// Property: ImplementationClass
/// Description: Class that implements this tool
Property ImplementationClass As %String(MAXLEN = 200);

/// Property: ImplementationMethod
/// Description: Method in the implementation class
Property ImplementationMethod As %String(MAXLEN = 200);

/// Property: Enabled
/// Description: Whether this tool is enabled
Property Enabled As %Boolean [ InitialExpression = 1 ];

/// Property: CreatedAt
/// Description: When this tool was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Property: UpdatedAt
/// Description: When this tool was last updated
Property UpdatedAt As %TimeStamp;

/// Index: NameIndex
/// Description: Unique index on Name
Index NameIndex On Name [ Unique, PrimaryKey ];

/// Index: EnabledIndex
/// Description: Index on Enabled for filtering
Index EnabledIndex On Enabled;

/// Index: ImplementationIndex
/// Description: Index on ImplementationClass and Method for lookup
Index ImplementationIndex On (ImplementationClass, ImplementationMethod);

/// Method: OnBeforeSave
/// Description: Update timestamp before saving
Method %OnBeforeSave(insert As %Boolean) As %Status
{
    Set sc = ..Validate()
    If $$$ISERR(sc) Quit sc
    Set ..UpdatedAt = $ZDATETIME($HOROLOG, 3)
    Quit $$$OK
}

/// Method: Validate
/// Description: Validate tool configuration
Method Validate() As %Status
{
    Set sc = $$$OK
    If ..Name = "" {
        Quit $$$ERROR($$$GeneralError, "Tool name is required")
    }
    Try {
        If ..ImplementationClass '= "" {
            If '##class(%Dictionary.CompiledClass).%ExistsId(..ImplementationClass) {
                Set sc = $$$ERROR($$$GeneralError, "Implementation class '" _ ..ImplementationClass _ "' not found or not accessible")
            } ElseIf ..ImplementationMethod '= "" {
                Set methodId = ..ImplementationClass _ "||" _ ..ImplementationMethod
                If '##class(%Dictionary.CompiledMethod).%ExistsId(methodId) {
                    Set sc = $$$ERROR($$$GeneralError, "Method '" _ ..ImplementationMethod _ "' not found in class '" _ ..ImplementationClass _ "'")
                }
            }
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

/// Method: GetFullImplementation
/// Description: Get the full implementation reference (Class.Method)
Method GetFullImplementation() As %String
{
    If ..ImplementationClass = "" {
        Quit ""
    }
    
    If ..ImplementationMethod = "" {
        Quit ..ImplementationClass
    }
    
    Quit ..ImplementationClass _ "." _ ..ImplementationMethod
}

/// Method: Invoke
/// Description: Invoke the tool with given parameters
Method Invoke(pParams As %DynamicObject) As %DynamicObject
{
    Set result = {}
    
    // Check if implementation is configured
    If ..ImplementationClass = "" {
        Set result.error = "Tool has no implementation configured"
        Quit result
    }
    
    // Check if method exists
    Try {
        // If method is specified, call it
        If ..ImplementationMethod '= "" {
            // Check if method exists
            Set methodId = ..ImplementationClass _ "||" _ ..ImplementationMethod
            If ##class(%Dictionary.CompiledMethod).%ExistsId(methodId) {
                Set result = $CLASSMETHOD(..ImplementationClass, ..ImplementationMethod, pParams)
            } Else {
                Set result.error = "Method '_..ImplementationMethod_' not found in class '_..ImplementationClass_'"
            }
        } Else {
            // No method specified, try to use the class as a tool
            // This assumes the class extends %AI.Tool or similar
            Try {
                Set toolObject = $CLASSMETHOD(..ImplementationClass, "%New")
                Set result = $METHOD(toolObject, "Execute", pParams)
            } Catch ex {
                Set result.error = ex.DisplayString()
            }
        }
    } Catch ex {
        Set result.error = ex.DisplayString()
    }
    
    Quit result
}

/// Method: GetToolInfo
/// Description: Get comprehensive tool information including introspected parameters
Method GetToolInfo() As %DynamicObject
{
    Set info = {
        "name": (..Name),
        "description": (..Description),
        "implementationClass": (..ImplementationClass),
        "implementationMethod": (..ImplementationMethod),
        "fullImplementation": (..GetFullImplementation()),
        "enabled": (..Enabled)
    }
    
    // Try to introspect parameters from method signature
    If ..ImplementationClass '= "" && ..ImplementationMethod '= "" {
        Try {
            // Get method signature
            Set methodRef = ..ImplementationClass _ ":" _ ..ImplementationMethod
            
            // Get parameter information
            // This is a simplified approach - in production, use %Library.RoutineMgr
            Set params = []
            
            // For now, we'll use a basic approach
            // In a real implementation, we'd use reflection to get parameter names and types
            
            Set info.parameters = params
            Set info.parameterSchema = {}
        } Catch ex {
            // If introspection fails, just continue without parameter info
        }
    }
    
    Quit info
}

/// Method: ToJSON
/// Description: Export tool as JSON
Method ToJSON() As %String
{
    Set obj = {
        "name": (..Name),
        "description": (..Description),
        "implementationClass": (..ImplementationClass),
        "implementationMethod": (..ImplementationMethod),
        "fullImplementation": (..GetFullImplementation()),
        "enabled": (..Enabled),
        "createdAt": (..CreatedAt),
        "updatedAt": (..UpdatedAt)
    }
    Quit obj.%ToJSON()
}

/// Method: Show
/// Description: Display tool information
Method Show() As %Status
{
    Write !, "Tool: ", ..Name
    Write !, "Description: ", ..Description
    Write !, "Implementation: ", ..GetFullImplementation()
    Write !, "Enabled: ", ..Enabled
    Write !, "Created: ", ..CreatedAt
    Write !, "Updated: ", ..UpdatedAt
    
    Quit $$$OK
}

/// ClassMethod: GetByName
/// Description: Get tool by name
ClassMethod GetByName(pName As %String) As AIHubStudio.Metadata.Tool
{
    Set tool = $$$NULLOREF
    Try {
        Set tool = ##class(AIHubStudio.Metadata.Tool).NameIndexOpen(pName)
    } Catch ex {
        Set tool = $$$NULLOREF
    }
    Quit tool
}

/// ClassMethod: GetByImplementation
/// Description: Get tool by implementation class and method
ClassMethod GetByImplementation(pClass As %String, pMethod As %String) As AIHubStudio.Metadata.Tool
{
    Set tool = $$$NULLOREF
    Try {
        Set tool = ##class(AIHubStudio.Metadata.Tool).ImplementationIndexOpen(pClass, pMethod)
    } Catch ex {
        Set tool = $$$NULLOREF
    }
    Quit tool
}

/// ClassMethod: ListAll
/// Description: List all tools as JSON array
ClassMethod ListAll() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description, ImplementationClass, ImplementationMethod, Enabled FROM AIHubStudio_Metadata.Tool ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description),
            "implementationClass": (result.ImplementationClass),
            "implementationMethod": (result.ImplementationMethod),
            "enabled": (result.Enabled)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: ListEnabled
/// Description: List all enabled tools
ClassMethod ListEnabled() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description, ImplementationClass, ImplementationMethod FROM AIHubStudio_Metadata.Tool WHERE Enabled = 1 ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description),
            "implementation": (result.ImplementationClass _ $SELECT(result.ImplementationMethod'="": "." _ result.ImplementationMethod, 1: ""))
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: Exists
/// Description: Check if a tool exists
ClassMethod Exists(pName As %String) As %Boolean
{
    Set tool = ..GetByName(pName)
    Quit $ISOBJECT(tool)
}

Storage Default
{
<Data name="ToolDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>ImplementationClass</Value>
</Value>
<Value name="5">
<Value>ImplementationMethod</Value>
</Value>
<Value name="6">
<Value>Enabled</Value>
</Value>
<Value name="7">
<Value>CreatedAt</Value>
</Value>
<Value name="8">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Metadata.ToolD</DataLocation>
<DefaultData>ToolDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Metadata.ToolD</IdLocation>
<IndexLocation>^AIHubStudio.Metadata.ToolI</IndexLocation>
<StreamLocation>^AIHubStudio.Metadata.ToolS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
