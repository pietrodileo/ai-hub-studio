/// Class: AIHubStudio.Skill.BasicConversation
/// Description: Basic conversation skill
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Skill.BasicConversation Extends %AI.Agent.Skill
{

/// Method: Apply
/// Description: Apply the basic conversation skill
Method Apply(context As %DynamicObject) As %DynamicObject
{
    Set result = {}
    
    // Add basic conversation capabilities
    Set result.canHandleGreetings = 1
    Set result.canHandleSmallTalk = 1
    Set result.canMaintainContext = 1
    
    Set result.skillName = "BasicConversation"
    Set result.description = "Provides basic conversation capabilities including greetings and small talk"
    
    Quit result
}

/// Method: ProcessGreeting
/// Description: Process greeting messages
Method ProcessGreeting(message As %String) As %String
{
    Set lowerMsg = $ZCONVERT(message, "L")
    
    If (lowerMsg [ "hello" || lowerMsg [ "hi" || lowerMsg [ "hey") {
        Quit $Select($Random(2): "Hello there! How can I help you today?", 1: "Hi! It's great to see you!")
    }
    ElseIf (lowerMsg [ "good morning") {
        Quit "Good morning! I hope you're having a wonderful day!"
    }
    ElseIf (lowerMsg [ "good afternoon") {
        Quit "Good afternoon! How can I assist you this afternoon?"
    }
    ElseIf (lowerMsg [ "good evening") {
        Quit "Good evening! Is there something I can help you with tonight?"
    }
    
    Quit "Nice to meet you! How can I assist you?"
}

/// Method: ProcessSmallTalk
/// Description: Process small talk messages
Method ProcessSmallTalk(message As %String) As %String
{
    Set lowerMsg = $ZCONVERT(message, "L")
    
    If (lowerMsg [ "how are you") {
        Quit "I'm just a virtual assistant, but I'm functioning well! How about you?"
    }
    ElseIf (lowerMsg [ "what's up" || lowerMsg [ "what is up") {
        Quit "Just here and ready to help you! What can I do for you?"
    }
    ElseIf (lowerMsg [ "thank" || lowerMsg [ "thanks") {
        Quit $Select($Random(2): "You're welcome! Happy to help!", 1: "My pleasure! Let me know if you need anything else.")
    }
    ElseIf (lowerMsg [ "bye" || lowerMsg [ "goodbye") {
        Quit "Goodbye! Have a great day!"
    }
    
    Quit "That's interesting! I'm here to help with any questions you might have."
}

}
