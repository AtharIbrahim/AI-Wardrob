import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';
import 'location_service.dart';

class WeatherService {
  // Get API keys from environment variables
  static String get openWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static String get weatherApiKey => dotenv.env['WEATHERAPI_KEY'] ?? '';
  static String get weatherService => dotenv.env['WEATHER_SERVICE'] ?? 'open-meteo';
  
  // API URLs
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1/current.json';
  
  final LocationService _locationService = LocationService();

  /// Get weather for current user location using the selected service
  Future<Weather?> getCurrentLocationWeather() async {
    try {
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        return await getCurrentWeatherByCoordinates(position.latitude, position.longitude);
      } else {
        Position defaultPosition = _locationService.getDefaultLocation();
        return await getCurrentWeatherByCoordinates(defaultPosition.latitude, defaultPosition.longitude);
      }
    } catch (e) {
      print('Error getting current location weather: $e');
      return getMockWeather();
    }
  }

  /// Get weather by city name
  Future<Weather?> getCurrentWeather(String city) async {
    switch (weatherService.toLowerCase()) {
      case 'open-meteo':
        return await _getOpenMeteoWeatherByCity(city);
      case 'weatherapi':
        return await _getWeatherApiByCity(city);
      case 'openweather':
      default:
        return await _getOpenWeatherByCity(city);
    }
  }

  /// Get weather by coordinates
  Future<Weather?> getCurrentWeatherByCoordinates(double lat, double lon) async {
    switch (weatherService.toLowerCase()) {
      case 'open-meteo':
        return await _getOpenMeteoWeather(lat, lon);
      case 'weatherapi':
        return await _getWeatherApiByCoordinates(lat, lon);
      case 'openweather':
      default:
        return await _getOpenWeatherByCoordinates(lat, lon);
    }
  }

  /// OpenWeather API implementation
  Future<Weather?> _getOpenWeatherByCity(String city) async {
    if (openWeatherApiKey.isEmpty || openWeatherApiKey == 'YOUR_OPENWEATHER_API_KEY') {
      print('Warning: No valid OpenWeather API key found. Using mock data.');
      return getMockWeather();
    }

    try {
      final response = await http.get(
        Uri.parse('$openWeatherBaseUrl?q=$city&appid=$openWeatherApiKey&units=metric'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        print('OpenWeather API error: ${response.statusCode}');
        return getMockWeather();
      }
    } catch (e) {
      print('Error fetching OpenWeather data: $e');
      return getMockWeather();
    }
  }

  Future<Weather?> _getOpenWeatherByCoordinates(double lat, double lon) async {
    if (openWeatherApiKey.isEmpty || openWeatherApiKey == 'YOUR_OPENWEATHER_API_KEY') {
      print('Warning: No valid OpenWeather API key found. Using mock data.');
      return getMockWeather();
    }

    try {
      final response = await http.get(
        Uri.parse('$openWeatherBaseUrl?lat=$lat&lon=$lon&appid=$openWeatherApiKey&units=metric'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        print('OpenWeather API error: ${response.statusCode}');
        return getMockWeather();
      }
    } catch (e) {
      print('Error fetching OpenWeather data by coordinates: $e');
      return getMockWeather();
    }
  }

  /// Open-Meteo API implementation (completely free, no API key required!)
  Future<Weather?> _getOpenMeteoWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$openMeteoBaseUrl?latitude=$lat&longitude=$lon&current_weather=true&temperature_unit=celsius'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseOpenMeteoResponse(data, lat, lon);
      } else {
        print('Open-Meteo API error: ${response.statusCode}');
        return getMockWeather();
      }
    } catch (e) {
      print('Error fetching Open-Meteo data: $e');
      return getMockWeather();
    }
  }

  Future<Weather?> _getOpenMeteoWeatherByCity(String city) async {
    // For Open-Meteo, we need coordinates, so get them first (using a simple geocoding)
    try {
      // Simple city to coordinates mapping for major cities
      Map<String, List<double>> cityCoords = {
        'new york': [40.7128, -74.0060],
        'london': [51.5074, -0.1278],
        'paris': [48.8566, 2.3522],
        'tokyo': [35.6762, 139.6503],
        'sydney': [-33.8688, 151.2093],
        'dubai': [25.2048, 55.2708],
        'berlin': [52.5200, 13.4050],
        'toronto': [43.6532, -79.3832],
      };
      
      List<double>? coords = cityCoords[city.toLowerCase()];
      if (coords != null) {
        return await _getOpenMeteoWeather(coords[0], coords[1]);
      } else {
        // Fallback to default location
        Position defaultPosition = _locationService.getDefaultLocation();
        return await _getOpenMeteoWeather(defaultPosition.latitude, defaultPosition.longitude);
      }
    } catch (e) {
      print('Error getting Open-Meteo weather by city: $e');
      return getMockWeather();
    }
  }

  Weather _parseOpenMeteoResponse(Map<String, dynamic> data, double lat, double lon) {
    final currentWeather = data['current_weather'];
    double temperature = currentWeather['temperature'].toDouble();
    int weatherCode = currentWeather['weathercode'];
    
    // Convert weather codes to conditions
    String condition = _getConditionFromWeatherCode(weatherCode);
    String description = _getDescriptionFromWeatherCode(weatherCode);
    String icon = _getIconFromWeatherCode(weatherCode);
    
    return Weather(
      location: 'Lat: ${lat.toStringAsFixed(2)}, Lon: ${lon.toStringAsFixed(2)}',
      condition: condition,
      temperature: temperature, // Already in Celsius
      humidity: 65, // Open-Meteo doesn't provide humidity in free tier
      description: description,
      icon: icon,
    );
  }

  /// WeatherAPI implementation (free tier: 1M calls/month)
  Future<Weather?> _getWeatherApiByCity(String city) async {
    if (weatherApiKey.isEmpty || weatherApiKey == 'YOUR_WEATHERAPI_KEY_HERE') {
      print('Warning: No valid WeatherAPI key found. Using mock data.');
      return getMockWeather();
    }

    try {
      final response = await http.get(
        Uri.parse('$weatherApiBaseUrl?key=$weatherApiKey&q=$city&aqi=no'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherApiResponse(data);
      } else {
        print('WeatherAPI error: ${response.statusCode}');
        return getMockWeather();
      }
    } catch (e) {
      print('Error fetching WeatherAPI data: $e');
      return getMockWeather();
    }
  }

  Future<Weather?> _getWeatherApiByCoordinates(double lat, double lon) async {
    if (weatherApiKey.isEmpty || weatherApiKey == 'YOUR_WEATHERAPI_KEY_HERE') {
      print('Warning: No valid WeatherAPI key found. Using mock data.');
      return getMockWeather();
    }

    try {
      final response = await http.get(
        Uri.parse('$weatherApiBaseUrl?key=$weatherApiKey&q=$lat,$lon&aqi=no'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherApiResponse(data);
      } else {
        print('WeatherAPI error: ${response.statusCode}');
        return getMockWeather();
      }
    } catch (e) {
      print('Error fetching WeatherAPI data by coordinates: $e');
      return getMockWeather();
    }
  }

  Weather _parseWeatherApiResponse(Map<String, dynamic> data) {
    final location = data['location'];
    final current = data['current'];
    
    return Weather(
      location: location['name'] ?? 'Unknown Location',
      condition: current['condition']['text'] ?? 'Unknown',
      temperature: current['temp_c'].toDouble(), // Already in Celsius
      humidity: current['humidity'] ?? 0,
      description: current['condition']['text'] ?? '',
      icon: current['condition']['icon'] ?? '',
    );
  }

  /// Helper methods for Open-Meteo weather codes
  String _getConditionFromWeatherCode(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Clouds';
    if (code <= 48) return 'Fog';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain';
    if (code <= 86) return 'Snow';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  String _getDescriptionFromWeatherCode(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: return 'Mainly clear';
      case 2: return 'Partly cloudy';
      case 3: return 'Overcast';
      case 45: return 'Fog';
      case 48: return 'Depositing rime fog';
      case 51: return 'Light drizzle';
      case 53: return 'Moderate drizzle';
      case 55: return 'Dense drizzle';
      case 61: return 'Slight rain';
      case 63: return 'Moderate rain';
      case 65: return 'Heavy rain';
      case 71: return 'Slight snow fall';
      case 73: return 'Moderate snow fall';
      case 75: return 'Heavy snow fall';
      case 95: return 'Thunderstorm';
      default: return 'Weather condition';
    }
  }

  String _getIconFromWeatherCode(int code) {
    if (code == 0) return '01d';
    if (code <= 3) return '02d';
    if (code <= 48) return '50d';
    if (code <= 67) return '10d';
    if (code <= 77) return '13d';
    if (code <= 82) return '09d';
    if (code <= 86) return '13d';
    if (code <= 99) return '11d';
    return '01d';
  }

  /// Get weather with automatic location detection
  Future<Weather?> getWeatherWithLocation() async {
    try {
      // Try to get weather for current location first
      Weather? locationWeather = await getCurrentLocationWeather();
      if (locationWeather != null) {
        return locationWeather;
      }
      
      // If location fails, try to get mock weather with realistic data
      return getMockWeather();
    } catch (e) {
      print('Error getting weather with location: $e');
      return getMockWeather();
    }
  }

  // Mock weather data for demonstration (when API key is not available)
  Weather getMockWeather() {
    final now = DateTime.now();
    final month = now.month;
    
    // Generate weather based on current season and time
    String condition;
    double temperature;
    String description;
    String icon;
    int humidity;
    
    // Winter months (Dec, Jan, Feb)
    if (month == 12 || month <= 2) {
      condition = 'Clouds';
      temperature = 278.15; // 5°C
      description = 'Partly cloudy';
      icon = '02d';
      humidity = 70;
    }
    // Spring months (Mar, Apr, May)
    else if (month >= 3 && month <= 5) {
      condition = 'Clear';
      temperature = 288.15; // 15°C
      description = 'Clear sky';
      icon = '01d';
      humidity = 60;
    }
    // Summer months (Jun, Jul, Aug)
    else if (month >= 6 && month <= 8) {
      condition = 'Clear';
      temperature = 298.15; // 25°C
      description = 'Sunny';
      icon = '01d';
      humidity = 50;
    }
    // Autumn months (Sep, Oct, Nov)
    else {
      condition = 'Rain';
      temperature = 283.15; // 10°C
      description = 'Light rain';
      icon = '10d';
      humidity = 80;
    }

    return Weather(
      location: 'Current Location',
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      description: description,
      icon: icon,
    );
  }

  /// Check if weather service is properly configured
  bool isConfigured() {
    switch (weatherService.toLowerCase()) {
      case 'open-meteo':
        return true; // Always available, no API key needed
      case 'weatherapi':
        return weatherApiKey.isNotEmpty && weatherApiKey != 'YOUR_WEATHERAPI_KEY_HERE';
      case 'openweather':
      default:
        return openWeatherApiKey.isNotEmpty && openWeatherApiKey != 'YOUR_OPENWEATHER_API_KEY';
    }
  }

  /// Get weather status message
  String getStatusMessage() {
    switch (weatherService.toLowerCase()) {
      case 'open-meteo':
        return 'Using Open-Meteo (Free weather service)';
      case 'weatherapi':
        if (weatherApiKey.isNotEmpty && weatherApiKey != 'YOUR_WEATHERAPI_KEY_HERE') {
          return 'Connected to WeatherAPI';
        } else {
          return 'WeatherAPI key needed or using mock data';
        }
      case 'openweather':
      default:
        if (openWeatherApiKey.isNotEmpty && openWeatherApiKey != 'YOUR_OPENWEATHER_API_KEY') {
          return 'Connected to OpenWeather API';
        } else {
          return 'OpenWeather API key needed or using mock data';
        }
    }
  }
}
