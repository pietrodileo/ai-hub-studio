/// Class: AIHubStudio.Agent.WeatherBot
/// Description: Weather Bot Agent - Provides weather information
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Agent.WeatherBot Extends AIHubStudio.Agent.BaseAgent
{

/// Parameter: PROMPT
/// Description: System prompt for the Weather Bot agent
Parameter PROMPT = "You are a weather information agent. Provide accurate and helpful weather information 
based on user requests. When users ask about weather, use the weather_api tool to get current data. 
Be concise but informative, and always include the location and time in your responses.";

/// Method: OnInit
/// Description: Initialize the Weather Bot agent
Method OnInit() As %Status
{
    // Set agent properties
    Set ..Name = "Weather Bot"
    Set ..Description = "An agent that provides weather information for locations worldwide"
    
    // Add weather-specific tools and skills
    Set status = ..AddCustomTool("weather_api", "AIHubStudio.Tool.WeatherAPI")
    Set status = status && ..AddCustomSkill("weather_knowledge", "AIHubStudio.Skill.WeatherKnowledge")
    Set status = status && ..AddCustomSkill("location_understanding", "AIHubStudio.Skill.LocationUnderstanding")
    
    Quit status
}

/// Method: Chat
/// Description: Process user message and generate response
Method Chat(session As %AI.Agent.Session, message As %String, context As %RegisteredObject) As %AI.LLM.Response
{
    // Check for weather-related patterns
    Set lowerMsg = $ZCONVERT(message, "L")
    
    If (lowerMsg [ "weather" || lowerMsg [ "temperature" || lowerMsg [ "forecast" || lowerMsg [ "rain" || lowerMsg [ "snow") {
        // Extract location from message
        Set location = ..ExtractLocation(message)
        
        If (location = "") {
            Set response = ##class(%AI.LLM.Response).%New()
            Set response.Text = "I can provide weather information, but I need a location. Could you please specify a city or region?"
            Quit response
        }
        
        // Use the weather API tool
        Set weatherData = ..GetWeatherData(location)
        
        If ($Data(weatherData.error)) {
            Set response = ##class(%AI.LLM.Response).%New()
            Set response.Text = "Sorry, I couldn't retrieve weather data for " _ location _ ". " _ weatherData.error
            Quit response
        }
        
        // Format the weather response
        Set responseText = ..FormatWeatherResponse(weatherData)
        Set response = ##class(%AI.LLM.Response).%New()
        Set response.Text = responseText
        Quit response
    }
    Else {
        // Use parent chat method for other messages
        Quit ..Chat(session, message, context)
    }
}

/// Method: ExtractLocation
/// Description: Extract location from user message
Method ExtractLocation(message As %String) As %String
{
    // Simple location extraction - would use NLP in production
    Set lowerMsg = $ZCONVERT(message, "L")
    
    // Check for patterns like "weather in [location]"
    If (lowerMsg [ "weather in ") {
        Set location = $Piece(message, " in ", 2)
        Return (location)
    }
    ElseIf (lowerMsg [ "forecast for ") {
        Set location = $Piece(message, " for ", 2)
        Return (location)
    }
    
    // Check for city names
    Set cities = ["new york", "london", "paris", "tokyo", "berlin", "sydney", "moscow", "beijing", "rome", "madrid"]
    
    For i = 0:1:(cities.%Size() - 1) {
        If (lowerMsg [ cities.%Get(i)) {
            Set location = cities.%Get(i)
            Return $ZCONVERT(location, "T")
        }
    }
    
    Quit ""
}

/// Method: GetWeatherData
/// Description: Get weather data using the weather API tool
Method GetWeatherData(location As %String) As %DynamicObject
{
    // Create request for weather API
    Set request = {
        "location": (location),
        "units": "metric"
    }
    
    // Call the weather API tool
    Set weatherTool = ##class(AIHubStudio.Tool.WeatherAPI).%New()
    Set response = weatherTool.Execute(request)
    
    Quit response
}

/// Method: FormatWeatherResponse
/// Description: Format weather data into user-friendly response
Method FormatWeatherResponse(weatherData As %DynamicObject) As %String
{
    Set response = "Here's the current weather for " _ weatherData.location _ ": "
    
    Set response = response _ weatherData.temperature _ "°C, " _ weatherData.conditions _ ". "
    
    If ($Data(weatherData.humidity)) {
        Set response = response _ "Humidity: " _ weatherData.humidity _ "%. "
    }
    
    If ($Data(weatherData.windSpeed)) {
        Set response = response _ "Wind: " _ weatherData.windSpeed _ " km/h. "
    }
    
    If ($Data(weatherData.forecast)) {
        Set response = response _ " Forecast: " _ weatherData.forecast _ "."
    }
    
    Quit response
}

}
