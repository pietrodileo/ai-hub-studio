/// Class: AIHubStudio.Metadata.ToolSetTool
/// Description: Relationship between ToolSet and Tool (many-to-many)
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.ToolSetTool Extends %Persistent
{

/// Property: ToolSet
/// Description: Reference to the ToolSet
Property ToolSet As AIHubStudio.Metadata.ToolSet;

/// Property: Tool
/// Description: Reference to the Tool
Property Tool As AIHubStudio.Metadata.Tool;

/// Index: ToolSetIndex
/// Description: Index on ToolSet
Index ToolSetIndex On ToolSet;

/// Index: ToolIndex
/// Description: Index on Tool
Index ToolIndex On Tool;

/// Index: PrimaryKey
/// Description: Unique index on ToolSet and Tool
Index PrimaryKey On (ToolSet, Tool) [ Unique, PrimaryKey ];

/// Method: OnBeforeSave
/// Description: Validate before saving
Method %OnBeforeSave(insert As %Boolean) As %Status
{
    If '$ISOBJECT(..ToolSet) {
        Return $$$ERROR($$$GeneralError, "ToolSet is required")
    }
    If '$ISOBJECT(..Tool) {
        Return $$$ERROR($$$GeneralError, "Tool is required")
    }
    Quit $$$OK
}

/// Method: GetToolSet
/// Description: Get the ToolSet object
Method GetToolSet() As AIHubStudio.Metadata.ToolSet
{
    If '$ISOBJECT(..ToolSet) {
        Quit $$$NULLOREF
    }
    Quit ..ToolSet
}

/// Method: GetTool
/// Description: Get the Tool object
Method GetTool() As AIHubStudio.Metadata.Tool
{
    If '$ISOBJECT(..Tool) {
        Quit $$$NULLOREF
    }
    Quit ..Tool
}

Storage Default
{
<Data name="ToolSetToolDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ToolSet</Value>
</Value>
<Value name="3">
<Value>Tool</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Me6D8D.ToolSetToolD</DataLocation>
<DefaultData>ToolSetToolDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Me6D8D.ToolSetToolD</IdLocation>
<IndexLocation>^AIHubStudio.Me6D8D.ToolSetToolI</IndexLocation>
<StreamLocation>^AIHubStudio.Me6D8D.ToolSetToolS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
