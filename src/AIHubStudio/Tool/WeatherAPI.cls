/// Class: AIHubStudio.Tool.WeatherAPI
/// Description: Weather API tool for retrieving weather data
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Tool.WeatherAPI Extends %AI.Tool
{

/// Property: MockData
/// Description: Mock weather data for testing
Property MockData As %Library.DynamicObject;

/// Method: OnInit
/// Description: Initialize the tool
Method OnInit() As %Status
{
    // Initialize mock data for testing
    Set ..MockData("New York") = {
        "location": "New York",
        "temperature": 22,
        "conditions": "Partly Cloudy",
        "humidity": 65,
        "windSpeed": 10,
        "forecast": "Expect partly cloudy skies with temperatures ranging from 18°C to 25°C."
    }
    
    Set ..MockData("London") = {
        "location": "London",
        "temperature": 18,
        "conditions": "Rain",
        "humidity": 80,
        "windSpeed": 15,
        "forecast": "Expect rain throughout the day with temperatures around 16-19°C."
    }
    
    Set ..MockData("Tokyo") = {
        "location": "Tokyo",
        "temperature": 28,
        "conditions": "Sunny",
        "humidity": 70,
        "windSpeed": 8,
        "forecast": "Sunny skies with hot temperatures reaching 32°C in the afternoon."
    }
    
    Quit $$$OK
}

/// Method: Execute
/// Description: Execute the weather API tool
Method Execute(request As %DynamicObject) As %DynamicObject
{
    Set response = {}
    
    // Validate input
    If '$Data(request.location) {
        Set response.error = ("Location parameter is required")
        Quit response
    }
    
    Set location = request.location
    
    // Check if we have mock data for this location
    If $Data(..MockData(location)) {
        // Return mock data for testing
        Merge response = ..MockData(location)
        Set response.source = "mock"
        Set response.timestamp = $ZDATETIME($HOROLOG, 3)
    }
    Else {
        // In a real implementation, this would call an actual weather API
        // For now, return generic mock data
        Set response = {
            "location": (location),
            "temperature": (20 + $Random(15)),
            "conditions": ($Select($Random(3): "Sunny", 1: "Partly Cloudy", 2: "Rain")),
            "humidity": (50 + $Random(40)),
            "windSpeed": (5 + $Random(15)),
            "forecast": ("Weather conditions for " _ location _ " are typical for this time of year."),
            "source": "mock",
            "timestamp": ($ZDATETIME($HOROLOG, 3))
        }
    }
    
    Quit response
}

/// Method: GetToolInfo
/// Description: Get tool information
Method GetToolInfo() As %DynamicObject
{
    Set info = {
        "name": "WeatherAPI",
        "description": "A tool for retrieving current weather data for locations worldwide",
        "parameters": {
            "location": {
                "type": "string",
                "description": "Location to get weather for (city, region, or coordinates)",
                "required": 1
            },
            "units": {
                "type": "string",
                "description": "Units for temperature (metric, imperial, or standard)",
                "required": 0,
                "default": "metric"
            }
        },
        "returns": {
            "location": {
                "type": "string",
                "description": "Location name"
            },
            "temperature": {
                "type": "number",
                "description": "Current temperature"
            },
            "conditions": {
                "type": "string",
                "description": "Current weather conditions"
            },
            "humidity": {
                "type": "number",
                "description": "Relative humidity percentage"
            },
            "windSpeed": {
                "type": "number",
                "description": "Wind speed"
            },
            "forecast": {
                "type": "string",
                "description": "Weather forecast"
            },
            "source": {
                "type": "string",
                "description": "Data source (mock or API)"
            },
            "timestamp": {
                "type": "string",
                "description": "Data timestamp"
            }
        }
    }
    
    Quit info
}

/// Method: AddMockData
/// Description: Add mock weather data for testing
Method AddMockData(location As %String, data As %DynamicObject) As %Status
{
    Merge ..MockData(location) = data
    Quit $$$OK
}

}
