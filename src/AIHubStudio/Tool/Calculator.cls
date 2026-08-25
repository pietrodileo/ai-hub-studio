/// Class: AIHubStudio.Tool.Calculator
/// Description: Calculator tool for evaluating mathematical expressions
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Tool.Calculator
{

/// Method: Evaluate
/// Description: Evaluate a mathematical expression
ClassMethod Evaluate(expression As %String) As %String
{
    Set result = ""
    Try {
        Set cleanExpr = ..CleanExpression(expression)
        Set result = ..EvaluateExpression(cleanExpr)
        Set result = "Result: " _ result
    } Catch ex {
        Set result = "Error: Invalid expression"
    }
    Return result
}

/// Method: EvaluateExpression
/// Description: Evaluate a mathematical expression string
ClassMethod EvaluateExpression(expression As %String) As %Double
{
    // Use a simple parser for basic arithmetic
    // This handles +, -, *, /, ^ with proper precedence
    
    // First, handle parentheses
    While (expression [ "(") {
        Set openPos = $Find(expression, "(")
        Set closePos = ..FindMatchingParen(expression, openPos)
        If (closePos = 0) {
            Return 0
        }
        
        Set inner = $Extract(expression, openPos + 1, closePos - openPos - 1)
        Set innerResult = ..EvaluateExpression(inner)
        
        Set expression = $Extract(expression, 1, openPos - 1) _ innerResult _ $Extract(expression, closePos + 1, *)
    }
    
    // Evaluate with operator precedence: ^, * /, + -
    Set expression = ..EvaluateOperator(expression, "^")
    Set expression = ..EvaluateOperator(expression, "* /")
    Set expression = ..EvaluateOperator(expression, "+ -")
    
    Quit +expression
}

/// Method: FindMatchingParen
/// Description: Find the matching closing parenthesis
ClassMethod FindMatchingParen(expr As %String, openPos As %Integer) As %Integer
{
    Set depth = 1
    Set i = openPos + 1
    
    While (i <= $Length(expr)) {
        Set char = $Extract(expr, i)
        If (char = "(") {
            Set depth = depth + 1
        } ElseIf (char = ")") {
            Set depth = depth - 1
        }
        If (depth = 0) {
            Return i
        }
        Set i = i + 1
    }
    
    Return 0
}

/// Method: EvaluateOperator
/// Description: Evaluate all occurrences of specified operators
ClassMethod EvaluateOperator(expr As %String, operators As %String) As %String
{
    Set i = 1
    Set result = ""
    Set current = ""
    
    While (i <= $Length(expr)) {
        Set char = $Extract(expr, i)
        
        If (operators [ char) {
            // Found an operator - evaluate left and right
            Set left = +current
            Set i = i + 1
            Set rightStart = i
            Set right = ""
            
            // Get the right operand
            While (i <= $Length(expr)) {
                Set char = $Extract(expr, i)
                If (operators [ char || char = "(" || char = ")") {
                    Quit
                }
                Set right = right _ char
                Set i = i + 1
            }
            
            Set right = +right
            Set result = result _ ..ApplyOp(left, char, right)
            Set current = ""
        } Else {
            Set current = current _ char
            Set i = i + 1
        }
    }
    
    If (current '= "") {
        Set result = result _ current
    }
    
    Return result
}

/// Method: ApplyOp
/// Description: Apply an operator to two values
ClassMethod ApplyOp(left As %Double, op As %String, right As %Double) As %Double
{
    If (op = "+") {
        Return left + right
    }
    If (op = "-") {
        Return left - right
    }
    If (op = "*") {
        Return left * right
    }
    If (op = "/") {
        If (right = 0) {
            Return 0
        }
        Return left / right
    }
    If (op = "^") {
        Return left ** right
    }
    Return 0
}

/// Method: CleanExpression
/// Description: Clean the expression for safe evaluation
ClassMethod CleanExpression(expression As %String) As %String
{
    // Remove potentially dangerous characters
    Set cleanExpr = expression
    
    // Remove whitespace
    Set cleanExpr = $Translate(cleanExpr, " ", "")
    
    // Remove any non-math characters (basic safety)
    Set allowedChars = "0123456789+-*/().^,"
    Set result = ""
    
    For i = 1:1:$Length(cleanExpr) {
        Set char = $Extract(cleanExpr, i)
        If (allowedChars [ char) {
            Set result = result _ char
        }
    }
    
    Return result
}

}
