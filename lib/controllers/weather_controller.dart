import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherController extends GetxController {
  // ⚠️ अपनी वास्तविक API Key से बदलें
  final String apiKey = '3d9b81063814692edb20759729cb46ad';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Observable Data
  final locationName = 'Loading...'.obs;
  final temperature = '--°C'.obs;
  final weatherIcon = '🌤️'.obs; // Default icon
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    isLoading.value = true;
    try {
      // 1. Get Location (Latitude and Longitude)
      Position position = await _determinePosition();

      final lat = position.latitude;
      final lon = position.longitude;

      // 2. Fetch Weather Data
      final url = '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 3. Update Observable Variables
        temperature.value = '${data['main']['temp'].round()}°C';
        locationName.value = data['name'] ?? 'Unknown Location';
        weatherIcon.value = _getWeatherIcon(data['weather'][0]['icon']);

      } else {
        locationName.value = 'API Error';
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      locationName.value = 'Location Off';
      temperature.value = 'N/A';
      weatherIcon.value = '⚠️';
      print("Weather fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🛠️ Location Permission and Position Logic
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Helper to convert OpenWeatherMap icon code to Emoji
  String _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return '☀️'; // clear sky day
      case '01n': return '🌙'; // clear sky night
      case '02d':
      case '03d': return '🌤️'; // few clouds day
      case '04d': return '☁️'; // broken clouds
      case '09d': return '🌧️'; // shower rain
      case '10d': return '☔'; // rain day
      case '13d': return '❄️'; // snow
      case '50d': return '🌫️'; // mist
      default: return '❓';
    }
  }
}