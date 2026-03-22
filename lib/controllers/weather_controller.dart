import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherController extends GetxController {
  // ⚠️ Replace with your actual OpenWeatherMap API Key
  final String apiKey = '20388c5b094a033e5fe0c2adb09ea8cd';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Observable Data
  final locationName = 'Loading...'.obs;
  final temperature = '--°C'.obs;
  final weatherIcon = '🌤️'.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    isLoading.value = true;
    try {
      // 1. Get Location
      Position position = await _determinePosition();

      final lat = position.latitude;
      final lon = position.longitude;

      // 2. Fetch Weather Data
      final url = '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update Observables
        locationName.value = data['name'] ?? "Unknown";
        temperature.value = "${data['main']['temp'].round()}°C";

        // Get icon code from API and convert to emoji
        String iconCode = data['weather'][0]['icon'];
        weatherIcon.value = _getWeatherIcon(iconCode);
      } else {
        locationName.value = "Error";
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      locationName.value = "Offline";
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
      case '01d': return '☀️';
      case '01n': return '🌙';
      case '02d':
      case '03d': return '🌤️';
      case '04d': return '☁️';
      case '09d':
      case '10d': return '🌧️';
      case '11d': return '⛈️';
      case '13d': return '❄️';
      case '50d': return '🌫️';
      default: return '🌤️';
    }
  }
}