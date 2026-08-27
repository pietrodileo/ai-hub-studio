Class AIHubStudio.Runtime.AgentCatalog Extends %RegisteredObject
{

ClassMethod List() As %DynamicArray
{
    Set items = []
    Do ..AddMetadataAgents(items)
    Do ..AddNativeAgents(items)
    Quit items
}

ClassMethod Get(key As %String) As %DynamicObject
{
    Set item = {}
    If $EXTRACT(key,1,9) = "metadata:" {
        Set agent = ##class(AIHubStudio.AI.Agent).Open($EXTRACT(key,10,*))
        If $ISOBJECT(agent) Set item = ..MetadataItem(agent)
        Quit item
    }
    If $EXTRACT(key,1,7) = "native:" {
        Set className = $EXTRACT(key,8,*)
        If ..IsRunnableAgentClass(className) Set item = ..NativeItem(className)
    }
    Quit item
}

ClassMethod CreateRuntime(key As %String, Output agent As %AI.Agent) As %Status
{
    Set sc = $$$OK, agent = $$$NULLOREF
    If $EXTRACT(key,1,9) = "metadata:" {
        Set saved = ##class(AIHubStudio.AI.Agent).Open($EXTRACT(key,10,*))
        If '$ISOBJECT(saved) Quit $$$ERROR($$$GeneralError,"Metadata agent not found: "_key)
        Quit saved.CreateRuntime(.agent)
    }
    If $EXTRACT(key,1,7) '= "native:" Quit $$$ERROR($$$GeneralError,"Invalid agent key: "_key)
    Set className = $EXTRACT(key,8,*)
    If '..IsRunnableAgentClass(className) Quit $$$ERROR($$$GeneralError,"Native agent is not runnable: "_className)
    Try {
        Set agent = $CLASSMETHOD(className,"%New")
        Set sc = agent.%Init()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

ClassMethod AddMetadataAgents(items As %DynamicArray)
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Name FROM AIHubStudio_Metadata.Agent WHERE Enabled=1 ORDER BY Name")
    If $$$ISERR(sc) Quit
    Set rs = stmt.%Execute()
    While rs.%Next() {
        Set agent = ##class(AIHubStudio.AI.Agent).Open(rs.Name)
        If $ISOBJECT(agent) Do items.%Push(..MetadataItem(agent))
    }
}

ClassMethod AddNativeAgents(items As %DynamicArray)
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Name FROM %Dictionary.CompiledClass WHERE Name <> '%AI.Agent' ORDER BY Name")
    If $$$ISERR(sc) Quit
    Set rs = stmt.%Execute()
    While rs.%Next() {
        If ($EXTRACT(rs.Name,1) '= "%") && ..IsRunnableAgentClass(rs.Name) Do items.%Push(..NativeItem(rs.Name))
    }
}

ClassMethod IsRunnableAgentClass(className As %String) As %Boolean
{
    Set runnable = 0
    Try {
        If $CLASSMETHOD(className,"%Extends","%AI.Agent") {
            Set definition = ##class(%Dictionary.CompiledClass).%OpenId(className)
            If $ISOBJECT(definition), 'definition.Abstract Set runnable = 1
        }
    } Catch ex {
        Set runnable = 0
    }
    Quit runnable
}

ClassMethod MetadataItem(agent As AIHubStudio.AI.Agent) As %DynamicObject
{
    Set tools = [], toolSets = []
    If $ISOBJECT(agent.Metadata) {
        Set tools = agent.Metadata.GetToolNames()
        Set toolSets = agent.Metadata.GetToolSetNames()
    }
    Quit {"key":("metadata:"_agent.Name),"source":"metadata","name":(agent.Name),"className":"%AI.Agent","description":(agent.Description),"provider":(agent.Provider),"model":(agent.Model),"tools":(tools),"toolSets":(toolSets),"skills":[],"available":true}
}

ClassMethod NativeItem(className As %String) As %DynamicObject
{
    Set model = $CLASSMETHOD(className,"%GetParameter","MODEL")
    Set provider = $CLASSMETHOD(className,"%GetParameter","PROVIDER")
    Set toolSetsText = $CLASSMETHOD(className,"%GetParameter","TOOLSETS")
    Set skillsText = $CLASSMETHOD(className,"%GetParameter","SKILLS")
    Set toolSets = ..CsvArray(toolSetsText), skills = ..CsvArray(skillsText)
    Quit {"key":("native:"_className),"source":"native","name":(className),"className":(className),"description":"Native %AI.Agent class","provider":(provider),"model":(model),"tools":[],"toolSets":(toolSets),"skills":(skills),"available":true}
}

ClassMethod CsvArray(value As %String) As %DynamicArray
{
    Set result = []
    For index=1:1:$LENGTH(value,",") {
        Set item = $ZSTRIP($PIECE(value,",",index),"<W")
        If item '= "" Do result.%Push(item)
    }
    Quit result
}

}
