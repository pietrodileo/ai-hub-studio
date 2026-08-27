Class AIHubStudio.Runtime.Chat Extends %RegisteredObject
{

ClassMethod Start(agentKey As %String, Output conversationId As %String, modelOverride As %String = "") As %Status
{
    Set sc = $$$OK, conversationId = ""
    Set sc = ##class(AIHubStudio.Runtime.AgentCatalog).CreateRuntime(agentKey,.agent)
    If $$$ISERR(sc) Quit sc
    If modelOverride '= "" Set agent.Model = modelOverride
    Try {
        Set session = agent.CreateSession()
        Set conversationId = $SYSTEM.Util.CreateGUID()
        Set conversation = ##class(AIHubStudio.Metadata.Conversation).%New()
        Set conversation.ConversationId = conversationId
        Set conversation.AgentKey = agentKey
        Set conversation.ModelOverride = modelOverride
        Set sc = conversation.SetSession(session)
        If $$$ISOK(sc) {
            Set sc = conversation.%Save()
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

ClassMethod Send(conversationId As %String, message As %String, Output result As %DynamicObject) As %Status
{
    Set sc = $$$OK, result = {}
    If message = "" Quit $$$ERROR($$$GeneralError,"Message is required")
    Set conversation = ##class(AIHubStudio.Metadata.Conversation).GetByConversationId(conversationId)
    If '$ISOBJECT(conversation) Quit $$$ERROR($$$GeneralError,"Conversation not found: "_conversationId)
    Set sc = ##class(AIHubStudio.Runtime.AgentCatalog).CreateRuntime(conversation.AgentKey,.agent)
    If $$$ISERR(sc) Quit sc
    If conversation.ModelOverride '= "" Set agent.Model = conversation.ModelOverride
    Set sc = conversation.RestoreSession(agent,.session)
    If $$$ISERR(sc) Quit sc
    Try {
        Set response = agent.Chat(session,message)
        Set sc = conversation.SetSession(session)
        If $$$ISOK(sc) Set sc = conversation.%Save()
        If $$$ISOK(sc) {
            Set stats = session.GetStats()
            Set result = {"conversationId":(conversationId),"content":(response.Content),"stats":(stats)}
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

ClassMethod Get(conversationId As %String, Output result As %DynamicObject) As %Status
{
    Set result = {}
    Set conversation = ##class(AIHubStudio.Metadata.Conversation).GetByConversationId(conversationId)
    If '$ISOBJECT(conversation) Quit $$$ERROR($$$GeneralError,"Conversation not found: "_conversationId)
    Set sc = ##class(AIHubStudio.Runtime.AgentCatalog).CreateRuntime(conversation.AgentKey,.agent)
    If $$$ISERR(sc) Quit sc
    Set sc = conversation.RestoreSession(agent,.session)
    If $$$ISERR(sc) Quit sc
    Set result = {"conversationId":(conversationId),"agentKey":(conversation.AgentKey),"modelOverride":(conversation.ModelOverride),"messages":(session.GetContext()),"stats":(session.GetStats()),"createdAt":(conversation.CreatedAt),"updatedAt":(conversation.UpdatedAt)}
    Quit $$$OK
}

ClassMethod Delete(conversationId As %String) As %Status
{
    Set conversation = ##class(AIHubStudio.Metadata.Conversation).GetByConversationId(conversationId)
    If '$ISOBJECT(conversation) Quit $$$ERROR($$$GeneralError,"Conversation not found: "_conversationId)
    Set conversationOid = conversation.%Oid()
    Set sc = ##class(AIHubStudio.Metadata.Conversation).%Delete(conversationOid)
    Quit sc
}

}
