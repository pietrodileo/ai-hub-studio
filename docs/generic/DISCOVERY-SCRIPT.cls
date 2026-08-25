// =============================================================================
// AI Hub Discovery Script for InterSystems IRIS
// 
// Purpose: Discover and document the actual implementation of AI Hub
//          in InterSystems IRIS (2026)
// 
// Usage: Run this in an IRIS terminal with AI Hub installed
// 
// Author: AI Assistant for Pietro Dileo
// Date: July 2026
// =============================================================================

// Note: This is a .cls file that can be imported and executed in IRIS
// To use: Import into IRIS and run: Do ##class(AIHub.Discovery).Run()

Class AIHub.Discovery Extends %RegisteredObject
{
    /// Main entry point - runs all discovery tasks
    ClassMethod Run() As %Status
    {
        Write !, "=========================================="
        Write !, "AI Hub Discovery Script"
        Write !, "=========================================="
        Write !
        
        // Check if AI Hub is available
        If '##class(AIHub.Discovery).CheckAIHub() {
            Write !, "AI Hub not found. Exiting."
            Quit $$$ERROR($$$GeneralError, "AI Hub not installed")
        }
        
        // Run all discovery tasks
        Do ##class(AIHub.Discovery).DiscoverAIPackage()
        Do ##class(AIHub.Discovery).DiscoverAgentClass()
        Do ##class(AIHub.Discovery).DiscoverMCPPackage()
        Do ##class(AIHub.Discovery).DiscoverAPIs()
        Do ##class(AIHub.Discovery).CreateTestAgent()
        
        Write !, "=========================================="
        Write !, "Discovery Complete!"
        Write !, "=========================================="
        Write !
        
        Quit $$$OK
    }
    
    /// Check if AI Hub is installed
    ClassMethod CheckAIHub() As %Boolean
    {
        Write !, "Checking AI Hub installation..."
        
        // Check for %AI package
        Set aiPackageExists = $System.OBJ.CheckPackageExists("%AI")
        Write !, "  %AI package exists: ", aiPackageExists
        
        // Check for %AI.Agent class
        Set agentClassExists = $System.OBJ.CheckClassExists("%AI.Agent")
        Write !, "  %AI.Agent class exists: ", agentClassExists
        
        // Check for %AI.MCP package
        Set mcpPackageExists = $System.OBJ.CheckPackageExists("%AI.MCP")
        Write !, "  %AI.MCP package exists: ", mcpPackageExists
        
        Quit aiPackageExists && agentClassExists
    }
    
    /// Discover all classes in %AI package
    ClassMethod DiscoverAIPackage() As %Status
    {
        Write !, "=========================================="
        Write !, "Discovering %AI Package"
        Write !, "=========================================="
        Write !
        
        // List all classes in %AI package
        Write !, "Classes in %AI package:"
        Set status = $System.OBJ.Inspect("%AI", .classes)
        If $$$ISERR(status) {
            Write !, "  Error: ", $System.Status.GetErrorText(status)
            Quit status
        }
        
        // classes should be a $List
        For i = 1:1:classes.Count() {
            Set className = classes.GetAt(i)
            Write !, "  - ", className
        }
        Write !
        
        // List all classes in %AI.Agent subpackage
        Write !, "Classes in %AI.Agent subpackage:"
        Set status = $System.OBJ.Inspect("%AI.Agent", .agentClasses)
        If '$$$ISERR(status) {
            For i = 1:1:agentClasses.Count() {
                Set className = agentClasses.GetAt(i)
                Write !, "  - ", className
            }
        }
        Write !
        
        // List all classes in %AI.MCP subpackage
        Write !, "Classes in %AI.MCP subpackage:"
        Set status = $System.OBJ.Inspect("%AI.MCP", .mcpClasses)
        If '$$$ISERR(status) {
            For i = 1:1:mcpClasses.Count() {
                Set className = mcpClasses.GetAt(i)
                Write !, "  - ", className
            }
        }
        Write !
        
        Quit $$$OK
    }
    
    /// Discover %AI.Agent class details
    ClassMethod DiscoverAgentClass() As %Status
    {
        Write !, "=========================================="
        Write !, "Discovering %AI.Agent Class"
        Write !, "=========================================="
        Write !
        
        // Get class definition
        Try {
            Set classDef = ##class(%Dictionary.ClassDefinition).Open("%AI.Agent")
            
            Write !, "Class: ", classDef.Name
            Write !, "Extends: ", classDef.Super
            Write !, "Description: ", classDef.Description
            Write !
            
            // List properties
            Write !, "Properties:"
            For i = 1:1:classDef.Properties.Count() {
                Set prop = classDef.Properties.GetAt(i)
                Write !, "  - ", prop.Name, " (", prop.Type, ")"
                If $Length(prop.InitialExpression) {
                    Write !, "    Initial: ", prop.InitialExpression
                }
            }
            Write !
            
            // List methods
            Write !, "Methods:"
            For i = 1:1:classDef.Methods.Count() {
                Set method = classDef.Methods.GetAt(i)
                Write !, "  - ", method.Name, "()"
                If $Length(method.ReturnType) {
                    Write !, "    Returns: ", method.ReturnType
                }
                
                // List parameters
                If method.Parameters.Count() > 0 {
                    Write !, "    Parameters:"
                    For j = 1:1:method.Parameters.Count() {
                        Set param = method.Parameters.GetAt(j)
                        Write !, "      - ", param.Name, " (", param.Type, ")"
                        If param.Required {
                            Write " [Required]"
                        }
                    }
                }
            }
            Write !
            
            // List indexes
            Write !, "Indexes:"
            For i = 1:1:classDef.Indexes.Count() {
                Set index = classDef.Indexes.GetAt(i)
                Write !, "  - ", index.Name
            }
            Write !
            
        } Catch ex {
            Write !, "Error discovering %AI.Agent: ", ex.DisplayString()
            Quit $$$ERROR($$$GeneralError, ex.DisplayString())
        }
        
        Quit $$$OK
    }
    
    /// Discover %AI.MCP package
    ClassMethod DiscoverMCPPackage() As %Status
    {
        Write !, "=========================================="
        Write !, "Discovering %AI.MCP Package"
        Write !, "=========================================="
        Write !
        
        // Check if %AI.MCP exists
        If '$System.OBJ.CheckPackageExists("%AI.MCP") {
            Write !, "%AI.MCP package not found."
            Quit $$$OK
        }
        
        // List all classes in %AI.MCP
        Write !, "Classes in %AI.MCP package:"
        Set status = $System.OBJ.Inspect("%AI.MCP", .mcpClasses)
        If '$$$ISERR(status) {
            For i = 1:1:mcpClasses.Count() {
                Set className = mcpClasses.GetAt(i)
                Write !, "  - ", className
                
                // Get class details
                Try {
                    Set classDef = ##class(%Dictionary.ClassDefinition).Open(className)
                    Write !, "    Extends: ", classDef.Super
                    Write !, "    Description: ", classDef.Description
                } Catch ex {
                    Write !, "    Error: ", ex.DisplayString()
                }
            }
        }
        Write !
        
        Quit $$$OK
    }
    
    /// Discover REST/WebSocket APIs
    ClassMethod DiscoverAPIs() As %Status
    {
        Write !, "=========================================="
        Write !, "Discovering AI Hub APIs"
        Write !, "=========================================="
        Write !
        
        // Check for REST API classes
        Write !, "Looking for REST API classes..."
        
        // Common patterns for REST APIs in IRIS
        Set apiClasses = $ListFromString("%AI.REST,%AI.API,%AI.Web,%AI.HTTP")
        
        For i = 1:1:apiClasses.Count() {
            Set className = apiClasses.GetAt(i)
            If $System.OBJ.CheckClassExists(className) {
                Write !, "Found: ", className
                
                Try {
                    Set classDef = ##class(%Dictionary.ClassDefinition).Open(className)
                    Write !, "  Extends: ", classDef.Super
                    Write !, "  Methods:"
                    For j = 1:1:classDef.Methods.Count() {
                        Set method = classDef.Methods.GetAt(j)
                        Write !, "    - ", method.Name
                    }
                } Catch ex {
                    Write !, "  Error: ", ex.DisplayString()
                }
            }
        }
        Write !
        
        // Check for WebSocket API
        Write !, "Looking for WebSocket API classes..."
        Set wsClasses = $ListFromString("%AI.WebSocket,%AI.WS,%AI.Chat")
        
        For i = 1:1:wsClasses.Count() {
            Set className = wsClasses.GetAt(i)
            If $System.OBJ.CheckClassExists(className) {
                Write !, "Found: ", className
            }
        }
        Write !
        
        // Try to find API documentation
        Write !, "Looking for API documentation..."
        Set docClasses = $ListFromString("%AI.Doc,%AI.Help,%AI.Info")
        
        For i = 1:1:docClasses.Count() {
            Set className = docClasses.GetAt(i)
            If $System.OBJ.CheckClassExists(className) {
                Write !, "Found: ", className
            }
        }
        Write !
        
        Quit $$$OK
    }
    
    /// Create a test agent to understand the API
    ClassMethod CreateTestAgent() As %Status
    {
        Write !, "=========================================="
        Write !, "Creating Test Agent"
        Write !, "=========================================="
        Write !
        
        // Try to create a minimal agent
        Try {
            // Create a test agent class
            Set className = "AIHub.TestAgent"
            
            // Check if class already exists
            If $System.OBJ.CheckClassExists(className) {
                Write !, "Test agent already exists. Skipping creation."
                Quit $$$OK
            }
            
            Write !, "Creating test agent class: ", className
            
            // Use %Dictionary to create class programmatically
            Set classDef = ##class(%Dictionary.ClassDefinition).%New()
            Set classDef.Name = className
            Set classDef.Super = "%AI.Agent"
            Set classDef.Description = "Test agent for AI Hub discovery"
            
            // Add a property
            Set prop = ##class(%Dictionary.PropertyDefinition).%New()
            Set prop.Name = "TestProperty"
            Set prop.Type = "%String"
            Set prop.InitialExpression = "Test Value"
            Do classDef.Properties.Insert(prop)
            
            // Add a method
            Set method = ##class(%Dictionary.MethodDefinition).%New()
            Set method.Name = "TestMethod"
            Set method.ReturnType = "%String"
            Set method.Code = "TestMethod() Public { Quit _""Test Method Result"" }"
            Do classDef.Methods.Insert(method)
            
            // Compile the class
            Set status = classDef.%Save()
            If $$$ISERR(status) {
                Write !, "Error creating class: ", $System.Status.GetErrorText(status)
                Quit status
            }
            
            Write !, "Test agent class created successfully!"
            
            // Try to instantiate the agent
            Write !, "Attempting to instantiate agent..."
            Try {
                Set agent = ##class(AIHub.TestAgent).%New()
                Write !, "Agent instantiated successfully!"
                Write !, "Agent.Name: ", agent.Name
                Write !, "Agent.Description: ", agent.Description
                Write !, "Agent.Model: ", $Get(agent.Model, "Not set")
                
                // Try to chat with the agent
                Write !, "Attempting to chat with agent..."
                Try {
                    Set response = agent.Chat("Hello, test agent!")
                    Write !, "Agent response: ", response
                } Catch chatEx {
                    Write !, "Chat error: ", chatEx.DisplayString()
                }
                
            } Catch instEx {
                Write !, "Instantiation error: ", instEx.DisplayString()
            }
            
        } Catch ex {
            Write !, "Error in CreateTestAgent: ", ex.DisplayString()
            Quit $$$ERROR($$$GeneralError, ex.DisplayString())
        }
        
        Write !
        Quit $$$OK
    }
    
    /// Discover tool system
    ClassMethod DiscoverTools() As %Status
    {
        Write !, "=========================================="
        Write !, "Discovering Tool System"
        Write !, "=========================================="
        Write !
        
        // Look for tool-related classes
        Write !, "Looking for tool classes..."
        Set toolPatterns = $ListFromString("%AI.Tool,%AI.Agent.Tool,%Tool")
        
        For i = 1:1:toolPatterns.Count() {
            Set pattern = toolPatterns.GetAt(i)
            Set status = $System.OBJ.Inspect(pattern, .classes)
            If '$$$ISERR(status) {
                For j = 1:1:classes.Count() {
                    Set className = classes.GetAt(j)
                    Write !, "  Found: ", className
                }
            }
        }
        Write !
        
        Quit $$$OK
    }
    
    /// Discover skill system
    ClassMethod DiscoverSkills() As %Status
    {
        Write !, "=========================================="
        Write !, "Discovering Skill System"
        Write !, "=========================================="
        Write !
        
        // Look for skill-related classes
        Write !, "Looking for skill classes..."
        Set skillPatterns = $ListFromString("%AI.Skill,%AI.Agent.Skill,%Skill")
        
        For i = 1:1:skillPatterns.Count() {
            Set pattern = skillPatterns.GetAt(i)
            Set status = $System.OBJ.Inspect(pattern, .classes)
            If '$$$ISERR(status) {
                For j = 1:1:classes.Count() {
                    Set className = classes.GetAt(j)
                    Write !, "  Found: ", className
                }
            }
        }
        Write !
        
        Quit $$$OK
    }
    
    /// Test MCP functionality
    ClassMethod TestMCP() As %Status
    {
        Write !, "=========================================="
        Write !, "Testing MCP Functionality"
        Write !, "=========================================="
        Write !
        
        // Try to create a simple MCP server
        Try {
            Write !, "Attempting to create MCP server..."
            
            // Check if %AI.MCP.Server exists
            If '$System.OBJ.CheckClassExists("%AI.MCP.Server") {
                Write !, "%AI.MCP.Server class not found."
                Quit $$$OK
            }
            
            // Try to create an MCP server instance
            Set server = ##class(%AI.MCP.Server).%New()
            Write !, "MCP server created successfully!"
            
            // Try to configure it
            Write !, "Server properties:"
            Write !, "  Name: ", $Get(server.Name, "Not set")
            Write !, "  Description: ", $Get(server.Description, "Not set")
            
            // Try to start it
            Try {
                Set status = server.Start()
                If $$$ISERR(status) {
                    Write !, "Error starting server: ", $System.Status.GetErrorText(status)
                } Else {
                    Write !, "Server started successfully!"
                }
            } Catch startEx {
                Write !, "Start error: ", startEx.DisplayString()
            }
            
        } Catch ex {
            Write !, "Error in TestMCP: ", ex.DisplayString()
        }
        
        Write !
        Quit $$$OK
    }
    
    /// Export discovery results to file
    ClassMethod ExportResults(filename As %String = "AIHub-Discovery-Results.txt") As %Status
    {
        Write !, "Exporting discovery results to ", filename, "..."
        
        // Create a stream for output
        Set stream = ##class(%Stream.FileCharacterStream).%New()
        Set stream.Filename = filename
        Set stream.CharacterSet = "UTF-8"
        
        // Open for writing
        Set status = stream.Open("WNS")
        If $$$ISERR(status) {
            Write !, "Error opening file: ", $System.Status.GetErrorText(status)
            Quit status
        }
        
        // Write header
        Do stream.WriteLine("========================================")
        Do stream.WriteLine("AI Hub Discovery Results")
        Do stream.WriteLine("Generated: ", $ZDateTime($Now, 3))
        Do stream.WriteLine("========================================")
        Do stream.WriteLine()
        
        // Run all discovery methods and capture output
        // (This would require redirecting output to the stream)
        // For now, just write a placeholder
        Do stream.WriteLine("Discovery results will be written here...")
        
        // Close the stream
        Do stream.Close()
        
        Write !, "Results exported to ", filename
        Quit $$$OK
    }
}

// =============================================================================
// Utility Methods
// =============================================================================

/// List all methods of a class with details
ClassMethod ListClassMethods(className As %String) As %Status
{
    Write !, "Methods of ", className, ":"
    
    Try {
        Set classDef = ##class(%Dictionary.ClassDefinition).Open(className)
        
        For i = 1:1:classDef.Methods.Count() {
            Set method = classDef.Methods.GetAt(i)
            Write !, "  ", method.Name, "()"
            
            // Write parameters
            If method.Parameters.Count() > 0 {
                Write "    Parameters: ("
                For j = 1:1:method.Parameters.Count() {
                    Set param = method.Parameters.GetAt(j)
                    Write param.Name, ":", param.Type
                    If j < method.Parameters.Count() {
                        Write ", "
                    }
                }
                Write ")"
            }
            Write !
            
            // Write return type
            If $Length(method.ReturnType) {
                Write !, "    Returns: ", method.ReturnType
            }
            
            // Write description
            If $Length(method.Description) {
                Write !, "    Description: ", method.Description
            }
            Write !
        }
        
    } Catch ex {
        Write !, "Error: ", ex.DisplayString()
        Quit $$$ERROR($$$GeneralError, ex.DisplayString())
    }
    
    Quit $$$OK
}

/// List all properties of a class
ClassMethod ListClassProperties(className As %String) As %Status
{
    Write !, "Properties of ", className, ":"
    
    Try {
        Set classDef = ##class(%Dictionary.ClassDefinition).Open(className)
        
        For i = 1:1:classDef.Properties.Count() {
            Set prop = classDef.Properties.GetAt(i)
            Write !, "  ", prop.Name, " (", prop.Type, ")"
            
            If $Length(prop.InitialExpression) {
                Write "    Initial: ", prop.InitialExpression
            }
            If prop.Required {
                Write " [Required]"
            }
            Write !
        }
        
    } Catch ex {
        Write !, "Error: ", ex.DisplayString()
        Quit $$$ERROR($$$GeneralError, ex.DisplayString())
    }
    
    Quit $$$OK
}

// =============================================================================
// Example: Minimal Agent Implementation
// =============================================================================

/// Example of a minimal agent class
/// This can be used as a template for creating agents
Class AIHub.MinimalAgent Extends %AI.Agent
{
    /// Agent name
    Property Name As %String [ InitialExpression = "MinimalAgent" ];
    
    /// Agent description
    Property Description As %String [ InitialExpression = "A minimal AI agent for testing" ];
    
    /// System prompt
    Property SystemPrompt As %String [ InitialExpression = "You are a helpful AI assistant." ];
    
    /// Model to use
    Property Model As %String [ InitialExpression = "gpt-4" ];
    
    /// Initialize the agent
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Call parent constructor
        Quit ##super()
    }
    
    /// Custom initialization
    Method Initialize() As %Status
    {
        // This method can be called after creation
        // to set up tools, skills, etc.
        
        // Example: Add a simple tool
        // Set tool = ##class(AIHub.Tools.EchoTool).%New()
        // Set status = ..AddTool(tool)
        
        Quit $$$OK
    }
    
    /// Example of a custom method
    Method Greet(name As %String) As %String
    {
        Quit "Hello, " _ name _ "! I am " _ ..Name
    }
}

/// Example of a simple tool
Class AIHub.Tools.EchoTool Extends %AI.Agent.Tool
{
    Property Name As %String [ InitialExpression = "EchoTool" ];
    Property Description As %String [ InitialExpression = "Echoes back the input" ];
    
    Method Execute(input As %DynamicObject) As %DynamicObject
    {
        Quit {"output": input.input, "message": "Echo: " _ input.input}
    }
}

// =============================================================================
// Instructions for Use
// =============================================================================

/*
To use this discovery script:

1. Make sure you have IRIS with AI Hub installed
2. Import this file into your IRIS namespace
3. Run the discovery:
   
   Do ##class(AIHub.Discovery).Run()

4. For specific tasks:
   
   // Discover %AI.Agent class
   Do ##class(AIHub.Discovery).DiscoverAgentClass()
   
   // Discover %AI.MCP package
   Do ##class(AIHub.Discovery).DiscoverMCPPackage()
   
   // List methods of a specific class
   Do ##class(AIHub.Discovery).ListClassMethods("%AI.Agent")
   
   // List properties of a specific class
   Do ##class(AIHub.Discovery).ListClassProperties("%AI.Agent")
   
   // Create test agent
   Do ##class(AIHub.Discovery).CreateTestAgent()

5. Export results:
   Do ##class(AIHub.Discovery).ExportResults()

Note: This script contains hypotheses about the AI Hub implementation.
      Some methods and classes may not exist or may have different names.
      The script will report errors for non-existent items, which helps
      us understand the actual implementation.
*/
