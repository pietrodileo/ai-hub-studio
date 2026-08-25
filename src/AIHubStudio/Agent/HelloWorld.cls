/// Class: AIHubStudio.Agent.HelloWorld
/// Description: Hello World Agent - Simple greeting agent
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Agent.HelloWorld Extends AIHubStudio.Agent.BaseAgent
{

/// Parameter: PROMPT
/// Description: System prompt for the Hello World agent
Parameter PROMPT = "You are a friendly greeting agent. Respond to user greetings with warm welcome messages. 
Be concise and friendly. If the user asks for something other than greetings, politely redirect them to greeting-related topics.";

/// Method: OnInit
/// Description: Initialize the Hello World agent
Method OnInit() As %Status
{
    // Set agent properties
    Set ..Name = "Hello World Agent"
    Set ..Description = "A simple agent that greets users and responds to friendly messages"
    
    // Add any specific tools or skills
    Set status = ..AddCustomSkill("basic_conversation", "AIHubStudio.Skill.BasicConversation")
    
    Quit status
}

/// Method: Chat
/// Description: Process user message and generate response
Method Chat(session As %AI.Agent.Session, message As %String, context As %RegisteredObject) As %AI.LLM.Response
{
    // For now, just pass through to parent
    // TODO: Add custom greeting logic
    Quit ..Chat(session, message, context)
}

}
