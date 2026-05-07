import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "20388c5b094a033e5fe0c2adb09ea8cd";

  Future<String> fetchWeather(String city) async {
    try {
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].round();
        final desc = data['weather'][0]['main'];
        return "$temp°C, $desc";
      }
      return "Weather unavailable";
    } catch (e) {
      return "Weather error";
    }
  }
}