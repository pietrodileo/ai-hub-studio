Class AIHubStudio.Metadata.Conversation Extends %Persistent
{

Property ConversationId As %String(MAXLEN = 64) [ Required ];
Property AgentKey As %String(MAXLEN = 300) [ Required ];
/// Serialized %AI.Agent.Session. Used because this EAP build limits persisted
/// Session.Model to 50 characters while local model identifiers can be longer.
Property SessionData As %Stream.GlobalCharacter;
Property ModelOverride As %String(MAXLEN = 200);
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
Property UpdatedAt As %TimeStamp;

Index ConversationIdIndex On ConversationId [ Unique, PrimaryKey ];

Method SetSession(session As %AI.Agent.Session) As %Status
{
    Set ..SessionData = ##class(%Stream.GlobalCharacter).%New()
    Do ..SessionData.Write(session.Export())
    Quit $$$OK
}

Method RestoreSession(agent As %AI.Agent, Output session As %AI.Agent.Session) As %Status
{
    Set sc = $$$OK, session = $$$NULLOREF
    Try {
        Set session = agent.CreateSession()
        Do ..SessionData.Rewind()
        Set json = ..SessionData.Read()
        Set sc = session.Import(json)
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

Method %OnBeforeSave(insert As %Boolean) As %Status
{
    Set ..UpdatedAt = $ZDATETIME($HOROLOG,3)
    Quit $$$OK
}

ClassMethod GetByConversationId(id As %String) As AIHubStudio.Metadata.Conversation
{
    Set conversation = $$$NULLOREF
    Try {
        Set conversation = ..ConversationIdIndexOpen(id)
    } Catch ex {
        Set conversation = $$$NULLOREF
    }
    Quit conversation
}

Storage Default
{
<Data name="ConversationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ConversationId</Value>
</Value>
<Value name="3">
<Value>AgentKey</Value>
</Value>
<Value name="4">
<Value>SessionId</Value>
</Value>
<Value name="5">
<Value>ModelOverride</Value>
</Value>
<Value name="6">
<Value>CreatedAt</Value>
</Value>
<Value name="7">
<Value>UpdatedAt</Value>
</Value>
<Value name="8">
<Value>SessionData</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.M6D8D.ConversationD</DataLocation>
<DefaultData>ConversationDefaultData</DefaultData>
<IdLocation>^AIHubStudio.M6D8D.ConversationD</IdLocation>
<IndexLocation>^AIHubStudio.M6D8D.ConversationI</IndexLocation>
<StreamLocation>^AIHubStudio.M6D8D.ConversationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
