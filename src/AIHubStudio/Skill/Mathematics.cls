/// Class: AIHubStudio.Skill.Mathematics
/// Description: Mathematics skill
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Skill.Mathematics Extends %AI.Agent.Skill
{

/// Method: Apply
/// Description: Apply the mathematics skill
Method Apply(context As %DynamicObject) As %DynamicObject
{
    Set result = {}
    
    // Add mathematics capabilities
    Set result.canSolveEquations = 1
    Set result.canExplainConcepts = 1
    Set result.canPerformCalculations = 1
    
    Set result.skillName = "Mathematics"
    Set result.description = "Provides mathematical problem solving and concept explanation capabilities"
    
    Quit result
}

/// Method: SolveEquation
/// Description: Solve mathematical equations
Method SolveEquation(equation As %String) As %String
{
    Set lowerEq = $ZCONVERT(equation, "L")
    
    If (lowerEq [ "quadratic" || lowerEq [ "ax² + bx + c") {
        Quit "To solve a quadratic equation ax² + bx + c = 0, use the quadratic formula: x = [-b ± √(b²-4ac)] / (2a). " _
              "First identify a, b, and c, then substitute them into the formula."
    }
    ElseIf (lowerEq [ "linear" || lowerEq [ "ax + b") {
        Quit "To solve a linear equation ax + b = 0: 1) Subtract b from both sides: ax = -b, 2) Divide by a: x = -b/a."
    }
    ElseIf (lowerEq [ "system" || lowerEq [ "simultaneous") {
        Quit "To solve a system of equations, you can use substitution, elimination, or matrix methods. " _
              "For two equations with two variables, substitution often works well."
    }
    
    Quit "I can help solve various types of equations. Could you provide more details about the equation you're working with?"
}

/// Method: ExplainConcept
/// Description: Explain mathematical concepts
Method ExplainConcept(concept As %String) As %String
{
    Set lowerConcept = $ZCONVERT(concept, "L")
    
    If (lowerConcept [ "derivative") {
        Quit "A derivative represents the rate at which a function is changing at any given point. " _
              "It's a fundamental concept in calculus that measures how a function's output changes as its input changes."
    }
    ElseIf (lowerConcept [ "integral") {
        Quit "An integral calculates the area under a curve. It's the reverse operation of differentiation " _
              "and is used to compute areas, volumes, and other quantities that accumulate over a range."
    }
    ElseIf (lowerConcept [ "limit") {
        Quit "A limit describes the value that a function approaches as the input approaches some value. " _
              "Limits are essential for defining derivatives and integrals in calculus."
    }
    ElseIf (lowerConcept [ "matrix") {
        Quit "A matrix is a rectangular array of numbers arranged in rows and columns. " _
              "Matrices are used to represent and solve systems of linear equations, among other applications."
    }
    ElseIf (lowerConcept [ "vector") {
        Quit "A vector is a mathematical object that has both magnitude and direction. " _
              "Vectors are used in physics to represent quantities like force and velocity."
    }
    Else {
        Quit "I can explain various mathematical concepts including calculus, algebra, geometry, and more. " _
              "What specific concept would you like to learn about?"
    }
}

/// Method: Calculate
/// Description: Perform mathematical calculations
Method Calculate(expression As %String) As %String
{
    // This would use the calculator tool in a real implementation
    // For now, we'll provide guidance
    
    Quit "I can help you calculate mathematical expressions. The expression '" _ expression _ "' " _
          "would be evaluated using standard mathematical order of operations: parentheses first, then exponents, " _
          "then multiplication and division, and finally addition and subtraction."
}

}
