/// Class: AIHubStudio.Agent.MathHelper
/// Description: Math Helper Agent - Assists with mathematical calculations
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Agent.MathHelper Extends AIHubStudio.Agent.BaseAgent
{

/// Parameter: PROMPT
/// Description: System prompt for the Math Helper agent
Parameter PROMPT = "You are a mathematics assistant. Help users solve math problems, explain concepts, 
and perform calculations. For complex calculations, use the calculator tool. Be patient and explain 
steps clearly. If you're unsure about a complex problem, admit it and suggest alternative approaches.";

/// Method: OnInit
/// Description: Initialize the Math Helper agent
Method OnInit() As %Status
{
    // Set agent properties
    Set ..Name = "Math Helper"
    Set ..Description = "An agent that helps with mathematical calculations and concepts"
    
    // Add math-specific tools and skills
    Set status = ..AddCustomTool("calculator", "AIHubStudio.Tool.Calculator")
    Set status = status && ..AddCustomSkill("mathematics", "AIHubStudio.Skill.Mathematics")
    Set status = status && ..AddCustomSkill("problem_solving", "AIHubStudio.Skill.ProblemSolving")
    
    Quit status
}

/// Method: Chat
/// Description: Process user message and generate response
Method Chat(session As %AI.Agent.Session, message As %String, context As %RegisteredObject) As %AI.LLM.Response
{
    // Check for math-related patterns
    Set lowerMsg = $ZCONVERT(message, "L")
    
    If (lowerMsg [ "calculate" || lowerMsg [ "what is" || lowerMsg [ "solve" || lowerMsg [ "math" || lowerMsg [ "+" || lowerMsg [ "-" || lowerMsg [ "*" || lowerMsg [ "/") {
        // Try to extract mathematical expression
        Set expression = ..ExtractMathExpression(message)
        
        If (expression '= "") {
            // Use the calculator tool
            Set result = ..CalculateExpression(expression)
            
            If ($Data(result.error)) {
                Set response = ##class(%AI.LLM.Response).%New()
                Set response.Text = "I couldn't calculate that expression: " _ result.error _ ". Let me try to explain it instead."
                Quit response
            }
            
            Set response = ##class(%AI.LLM.Response).%New()
            Set response.Text = "The result of " _ expression _ " is: " _ result.value
            Quit response
        }
        Else {
            // Provide explanation instead
            Set responseText = ..ExplainMathConcept(message)
            Set response = ##class(%AI.LLM.Response).%New()
            Set response.Text = responseText
            Quit response
        }
    }
    Else {
        // Use parent chat method for other messages
        Quit ..Chat(session, message, context)
    }
}

/// Method: ExtractMathExpression
/// Description: Extract mathematical expression from user message
Method ExtractMathExpression(message As %String) As %String
{
    // Remove common phrases
    Set msg = message
    Set msg = $Replace(msg, "calculate", "")
    Set msg = $Replace(msg, "what is", "")
    Set msg = $Replace(msg, "solve", "")
    Set msg = $Replace(msg, "math problem", "")
    Set msg = $Replace(msg, "please", "")
    Set msg = $ZTRIM(msg, " ")
    
    // Check if the remaining text looks like a math expression
    If (msg?.1N || msg [ "+" || msg [ "-" || msg [ "*" || msg [ "/" || msg [ "^" || msg [ "(" || msg [ ")") {
        Quit msg
    }
    
    Quit ""
}

/// Method: CalculateExpression
/// Description: Calculate mathematical expression using calculator tool
Method CalculateExpression(expression As %String) As %DynamicObject
{
    // Create request for calculator
    Set request = {
        "expression": (expression)
    }
    
    // Call the calculator tool
    Set calcTool = ##class(AIHubStudio.Tool.Calculator).%New()
    Set response = calcTool.Execute(request)
    
    Quit response
}

/// Method: ExplainMathConcept
/// Description: Explain a mathematical concept
Method ExplainMathConcept(topic As %String) As %String
{
    Set lowerTopic = $ZCONVERT(topic, "L")
    
    If (lowerTopic [ "quadratic" || lowerTopic [ "equation") {
        Quit "A quadratic equation is an equation of the form ax² + bx + c = 0, where a, b, and c are numbers. " _
              "You can solve it using the quadratic formula: x = [-b ± √(b²-4ac)] / (2a)."
    }
    ElseIf (lowerTopic [ "pythagorean" || lowerTopic [ "theorem") {
        Quit "The Pythagorean theorem states that in a right-angled triangle, the square of the hypotenuse " _
              "(the side opposite the right angle) is equal to the sum of the squares of the other two sides. " _
              "Formula: a² + b² = c²."
    }
    ElseIf (lowerTopic [ "derivative" || lowerTopic [ "calculus") {
        Quit "A derivative represents the rate at which a function is changing at any given point. " _
              "It's a fundamental concept in calculus used to find slopes of curves and rates of change."
    }
    ElseIf (lowerTopic [ "integral") {
        Quit "An integral calculates the area under a curve. It's the reverse operation of differentiation " _
              "and is used to compute areas, volumes, and other quantities that add up over a range."
    }
    Else {
        Quit "I'd be happy to explain math concepts! Could you be more specific about what " _
              "you'd like to learn? I can help with algebra, geometry, calculus, and more."
    }
}

}
