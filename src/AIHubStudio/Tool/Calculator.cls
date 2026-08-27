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
    Set position = 1
    Set value = ..ParseExpression(expression, .position)
    If position <= $Length(expression) {
        $$$ThrowStatus($$$ERROR($$$GeneralError, "Unexpected token at position " _ position))
    }
    Quit value
}

ClassMethod ParseExpression(expression As %String, ByRef position As %Integer) As %Double
{
    Set value = ..ParseTerm(expression, .position)
    While position <= $Length(expression) {
        Set operator = $Extract(expression, position)
        If (operator '= "+") && (operator '= "-") Quit
        Set position = position + 1
        Set right = ..ParseTerm(expression, .position)
        If operator = "+" Set value = value + right
        Else  Set value = value - right
    }
    Quit value
}

ClassMethod ParseTerm(expression As %String, ByRef position As %Integer) As %Double
{
    Set value = ..ParsePower(expression, .position)
    While position <= $Length(expression) {
        Set operator = $Extract(expression, position)
        If (operator '= "*") && (operator '= "/") Quit
        Set position = position + 1
        Set right = ..ParsePower(expression, .position)
        If operator = "*" {
            Set value = value * right
        } Else {
            If right = 0 $$$ThrowStatus($$$ERROR($$$GeneralError, "Division by zero"))
            Set value = value / right
        }
    }
    Quit value
}

ClassMethod ParsePower(expression As %String, ByRef position As %Integer) As %Double
{
    Set value = ..ParseFactor(expression, .position)
    If $Extract(expression, position) = "^" {
        Set position = position + 1
        Set value = value ** ..ParsePower(expression, .position)
    }
    Quit value
}

ClassMethod ParseFactor(expression As %String, ByRef position As %Integer) As %Double
{
    Set character = $Extract(expression, position)
    If character = "+" {
        Set position = position + 1
        Quit ..ParseFactor(expression, .position)
    }
    If character = "-" {
        Set position = position + 1
        Quit -..ParseFactor(expression, .position)
    }
    If character = "(" {
        Set position = position + 1
        Set value = ..ParseExpression(expression, .position)
        If $Extract(expression, position) '= ")" {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Missing closing parenthesis"))
        }
        Set position = position + 1
        Quit value
    }
    Set start = position
    While position <= $Length(expression) {
        Set character = $Extract(expression, position)
        If "0123456789." '[ character Quit
        Set position = position + 1
    }
    If position = start {
        $$$ThrowStatus($$$ERROR($$$GeneralError, "Number expected at position " _ position))
    }
    Set number = $Extract(expression, start, position - 1)
    If $Length(number, ".") > 2 {
        $$$ThrowStatus($$$ERROR($$$GeneralError, "Invalid number " _ number))
    }
    Quit +number
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
    Set allowedChars = "0123456789+-*/().^"
    Set result = ""
    For i = 1:1:$Length(expression) {
        Set char = $Extract(expression, i)
        If (allowedChars [ char) {
            Set result = result _ char
        } ElseIf ($ASCII(char) '= 9) && ($ASCII(char) '= 10) && ($ASCII(char) '= 13) && (char '= " ") {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Invalid character at position " _ i))
        }
    }
    If result = "" $$$ThrowStatus($$$ERROR($$$GeneralError, "Expression is empty"))
    Return result
}

}
