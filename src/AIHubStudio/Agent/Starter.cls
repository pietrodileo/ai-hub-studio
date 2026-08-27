/// Class: AIHubStudio.Agent.Starter
/// Description: My First Agent - End-To-End Starter Guide
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Agent.Starter
{

/// Method: GetTemplatesObject
/// Description: Get the templates as a dynamic object
ClassMethod GetTemplatesObject() As %Library.DynamicObject
{
    set templates = {}
    do templates.%Set("hello_world", {
        "name": "Hello World Agent",
        "description": "A simple agent that greets users",
        "className": "AIHubStudio.Agent.HelloWorld",
        "skills": ["basic_conversation"],
        "tools": [],
        "prompt": "You are a friendly greeting agent. Respond to user greetings with a warm welcome message.",
        "exampleInputs": ["Hello", "Hi there", "Greetings"]
    })
    do templates.%Set("weather_bot", {
        "name": "Weather Bot",
        "description": "An agent that provides weather information",
        "className": "AIHubStudio.Agent.WeatherBot",
        "skills": ["weather_knowledge", "api_integration"],
        "tools": ["weather_api"],
        "prompt": "You are a weather information agent. Provide accurate weather information based on user location requests.",
        "exampleInputs": ["What's the weather in New York?", "Will it rain in London tomorrow?"]
    })
    do templates.%Set("math_helper", {
        "name": "Math Helper",
        "description": "An agent that helps with mathematical calculations",
        "className": "AIHubStudio.Agent.MathHelper",
        "skills": ["mathematics", "problem_solving"],
        "tools": ["calculator"],
        "prompt": "You are a mathematics assistant. Help users solve math problems and explain concepts.",
        "exampleInputs": ["What is 25 * 4 + 10?", "How do I solve quadratic equations?"]
    })
    quit templates
}

/// Method: Initialize
/// Description: Initialize the starter templates
ClassMethod Initialize() As %Boolean
{
    set status = ##class(AIHubStudio.Agent.Registry).Initialize()
    if 'status quit 0
    set status = ##class(AIHubStudio.Tool.Registry).Initialize()
    if 'status quit 0
    quit ##class(AIHubStudio.Skill.Registry).Initialize()
}

/// Method: GetTemplates
/// Description: Get all available starter templates
ClassMethod GetTemplates() As %String
{
    set templates = ..GetTemplatesObject()
    set result = []
    set iterator = templates.%GetIterator()
    while iterator.%GetNext(.key, .template) {
        do result.%Push(template)
    }
    
    quit result.%ToJSON()
}

/// Method: GetTemplate
/// Description: Get a specific template by name
ClassMethod GetTemplate(templateName As %String) As %String
{
    set templates = ..GetTemplatesObject()
    if templates.%IsDefined(templateName) {
        quit templates.%Get(templateName).%ToJSON()
    }
    quit "{}"
}

/// Method: CreateAgentFromTemplate
/// Description: Create a new agent from a template
ClassMethod CreateAgentFromTemplate(templateName As %String, agentName As %String, description As %String = "") As %String
{
    set templates = ..GetTemplatesObject()
    if 'templates.%IsDefined(templateName) {
        quit ""
    }
    
    set template = templates.%Get(templateName)
    
    #; Use provided description or default from template
    if (description = "") {
        set description = template.description
    }
    
    #; Map template names to actual agent classes
    set agentClassMap = {
        "hello_world": "AIHubStudio.Agent.HelloWorld",
        "weather_bot": "AIHubStudio.Agent.WeatherBot",
        "math_helper": "AIHubStudio.Agent.MathHelper"
    }
    
    set agentClass = agentClassMap.%Get(templateName, "AIHubStudio.Agent.HelloWorld")
    
    #; Register the agent
    set agentId = ##class(AIHubStudio.Agent.Registry).Register(agentName, description, agentClass)
    
    if (agentId = "") {
        quit ""
    }
    
    #; Register required skills
    for i=0:1:(template.skills.%Size()-1) {
        set skillName = template.skills.%Get(i)
        do ##class(AIHubStudio.Skill.Registry).Register(skillName, skillName _ " skill", "AIHubStudio.Skill." _ skillName, "knowledge")
    }
    
    #; Register required tools
    for i=0:1:(template.tools.%Size()-1) {
        set toolName = template.tools.%Get(i)
        do ##class(AIHubStudio.Tool.Registry).Register(toolName, toolName _ " tool", "AIHubStudio.Tool." _ toolName, "function")
    }
    
    #; Initialize the agent to set up its tools and skills
    set agent = $ClassMethod(agentClass, "%New")
    if '$IsObject(agent) {
        quit ""
    }
    
    set status = agent.OnInit()
    if $$$ISERR(status) {
        quit ""
    }
    
    quit agentId
}

/// Method: GetStarterGuide
/// Description: Get the complete starter guide
ClassMethod GetStarterGuide() As %String
{
    set guide = {
        "title": "My First Agent - End-to-End Starter Guide",
        "description": "A guided experience to help you create your first AI agent in IRIS AI Hub Studio",
        "steps": [
            {
                "step": 1,
                "title": "Choose a Template",
                "description": "Select from our pre-built agent templates to get started quickly",
                "action": "GET /starter/templates"
            },
            {
                "step": 2,
                "title": "Customize Your Agent",
                "description": "Personalize your agent with a unique name and description",
                "action": "POST /starter/create"
            },
            {
                "step": 3,
                "title": "Test Your Agent",
                "description": "Interact with your new agent to see it in action",
                "action": "POST /agents/:id/message"
            },
            {
                "step": 4,
                "title": "Enhance Your Agent",
                "description": "Add skills, tools, and customize the behavior",
                "action": "PUT /agents/:id"
            },
            {
                "step": 5,
                "title": "Deploy Your Agent",
                "description": "Make your agent available for production use",
                "action": "POST /agents/:id/deploy"
            }
        ],
        "templates": (..GetTemplates())
    }
    
    quit guide.%ToJSON()
}

/// Method: GetExampleConversation
/// Description: Get example conversation for a template
ClassMethod GetExampleConversation(templateName As %String) As %String
{
    set templates = ..GetTemplatesObject()
    if 'templates.%IsDefined(templateName) {
        quit "[]"
    }
    
    set template = templates.%Get(templateName)
    set conversation = []
    
    for i=0:1:(template.exampleInputs.%Size()-1) {
        set userInput = template.exampleInputs.%Get(i)
        set response = "Example response to: " _ userInput
        
        do conversation.%Push({
            "role": "user",
            "content": (userInput)
        })
        
        do conversation.%Push({
            "role": "agent",
            "content": (response)
        })
    }
    
    quit conversation.%ToJSON()
}

}
