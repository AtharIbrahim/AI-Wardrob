class Weather {
  final String location;
  final String condition;
  final double temperature;
  final int humidity;
  final String description;
  final String icon;

  Weather({
    required this.location,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Temperature can come in Celsius (when units=metric) or Kelvin (default)
    double temp = (json['main']['temp'] as num).toDouble();
    
    return Weather(
      location: json['name'] ?? 'Unknown Location',
      condition: json['weather'][0]['main'] ?? 'Unknown',
      temperature: temp,
      humidity: json['main']['humidity'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
    );
  }

  String get temperatureInCelsius {
    // If temperature is in Kelvin (> 100), convert to Celsius
    // If already in Celsius (< 100), use as is
    if (temperature > 100) {
      return '${(temperature - 273.15).round()}°C';
    } else {
      return '${temperature.round()}°C';
    }
  }

  String get temperatureInFahrenheit {
    double celsius;
    if (temperature > 100) {
      celsius = temperature - 273.15;
    } else {
      celsius = temperature;
    }
    return '${(celsius * 9/5 + 32).round()}°F';
  }

  bool get isCold {
    double celsius = temperature > 100 ? temperature - 273.15 : temperature;
    return celsius < 10; // Below 10°C
  }
  bool get isHot {
    double celsius = temperature > 100 ? temperature - 273.15 : temperature;
    return celsius > 25; // Above 25°C
  }

  bool get isRainy => condition.toLowerCase().contains('rain') || description.toLowerCase().contains('rain');
  bool get isSnowy => condition.toLowerCase().contains('snow') || description.toLowerCase().contains('snow');
  bool get isCloudy => condition.toLowerCase().contains('cloud');
  bool get isSunny => condition.toLowerCase().contains('clear') || condition.toLowerCase().contains('sun');

  /// Get the actual temperature in Celsius for calculations
  double get temperatureCelsius {
    return temperature > 100 ? temperature - 273.15 : temperature;
  }

  /// Get weather emoji
  String get emoji {
    if (isSunny) return '☀️';
    if (isRainy) return '🌧️';
    if (isSnowy) return '❄️';
    if (isCloudy) return '☁️';
    return '🌤️';
  }

  /// Get weather advice for clothing
  String get clothingAdvice {
    if (temperatureCelsius < 0) {
      return 'Very cold! Layer up with warm coat, gloves, and scarf.';
    } else if (temperatureCelsius < 10) {
      return 'Cold weather. Wear a jacket or warm sweater.';
    } else if (temperatureCelsius < 20) {
      return 'Cool weather. A light jacket or sweater is recommended.';
    } else if (temperatureCelsius < 30) {
      return 'Pleasant weather. Light clothing is perfect.';
    } else {
      return 'Hot weather! Choose light, breathable fabrics.';
    }
  }
}
