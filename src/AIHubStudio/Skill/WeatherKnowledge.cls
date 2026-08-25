/// Class: AIHubStudio.Skill.WeatherKnowledge
/// Description: Weather knowledge skill
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Skill.WeatherKnowledge Extends %AI.Agent.Skill
{

/// Method: Apply
/// Description: Apply the weather knowledge skill
Method Apply(context As %DynamicObject) As %DynamicObject
{
    Set result = {}
    
    // Add weather knowledge capabilities
    Set result.canExplainWeatherConcepts = 1
    Set result.canInterpretForecasts = 1
    Set result.canProvideSafetyTips = 1
    
    Set result.skillName = "WeatherKnowledge"
    Set result.description = "Provides expert knowledge about weather concepts, forecasts, and safety"
    
    Quit result
}

/// Method: ExplainWeatherConcept
/// Description: Explain weather concepts
Method ExplainWeatherConcept(concept As %String) As %String
{
    Set lowerConcept = $ZCONVERT(concept, "L")
    
    If (lowerConcept [ "temperature") {
        Quit "Temperature measures how hot or cold the atmosphere is. It's typically measured in degrees Celsius (°C) or Fahrenheit (°F)."
    }
    ElseIf (lowerConcept [ "humidity") {
        Quit "Humidity refers to the amount of water vapor in the air. High humidity can make temperatures feel warmer than they actually are."
    }
    ElseIf (lowerConcept [ "pressure" || lowerConcept [ "barometric") {
        Quit "Atmospheric pressure is the force exerted by the weight of air above a point. Changes in pressure often indicate weather changes."
    }
    ElseIf (lowerConcept [ "forecast") {
        Quit "A weather forecast is a prediction of future weather conditions based on meteorological data and computer models."
    }
    ElseIf (lowerConcept [ "storm" || lowerConcept [ "thunderstorm") {
        Quit "A storm is a disturbed state of the atmosphere with strong winds, rain, thunder, lightning, or snow. Thunderstorms are characterized by thunder and lightning."
    }
    Else {
        Quit "I can explain various weather concepts. Temperature, humidity, pressure, and storms are some common topics I can help with."
    }
}

/// Method: InterpretForecast
/// Description: Interpret weather forecast
Method InterpretForecast(forecast As %DynamicObject) As %String
{
    Set response = "Based on the forecast for " _ forecast.location _ ": "
    
    Set response = response _ "Current conditions: " _ forecast.current.conditions _ ", " _ forecast.current.temperature _ "°C. "
    
    If ($Data(forecast.today)) {
        Set response = response _ "Today: " _ forecast.today.conditions _ ", high of " _ forecast.today.high _ "°C, low of " _ forecast.today.low _ "°C. "
    }
    
    If ($Data(forecast.alerts) && forecast.alerts.%Size() > 0) {
        Set response = response _ "Alerts: " _ forecast.alerts.%Get(1) _ ". "
    }
    
    Quit response
}

/// Method: GetSafetyTips
/// Description: Get weather safety tips
Method GetSafetyTips(conditions As %String) As %String
{
    Set lowerCond = $ZCONVERT(conditions, "L")
    
    If (lowerCond [ "thunderstorm" || lowerCond [ "lightning") {
        Quit "During thunderstorms: Stay indoors, avoid using electrical equipment, and stay away from windows and doors."
    }
    ElseIf (lowerCond [ "tornado") {
        Quit "During a tornado: Seek shelter immediately in a basement or interior room on the lowest floor. Protect your head and neck."
    }
    ElseIf (lowerCond [ "hurricane" || lowerCond [ "cyclone") {
        Quit "During hurricanes: Evacuate if instructed, stay indoors away from windows, and have an emergency kit ready."
    }
    ElseIf (lowerCond [ "extreme heat") {
        Quit "During extreme heat: Stay hydrated, avoid strenuous activities, wear light clothing, and check on vulnerable individuals."
    }
    ElseIf (lowerCond [ "extreme cold" || lowerCond [ "blizzard") {
        Quit "During extreme cold: Dress in layers, cover exposed skin, stay dry, and avoid prolonged exposure to cold temperatures."
    }
    Else {
        Quit "Always stay informed about weather conditions and follow local safety guidelines for your area."
    }
}

}
