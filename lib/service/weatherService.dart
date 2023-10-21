import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weatherModel.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse("$BASE_URL?q=$cityName&appid=$apiKey&units=metric"),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error getting weather T_T");
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      //getting permission
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      //if permission denied forever
      throw Exception("Location permission denied");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;

    return city ?? "";
  }

  Future<String> checkDayOrNight() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double latitude = position.latitude;
    double longitude = position.longitude;
    try {
      // Step 1: Fetch timezone_id using the first API
      final whereTheIssUrl =
          'https://api.wheretheiss.at/v1/coordinates/$latitude,$longitude';
      final whereTheIssResponse = await http.get(Uri.parse(whereTheIssUrl));

      if (whereTheIssResponse.statusCode == 200) {
        final whereTheIssData = json.decode(whereTheIssResponse.body);
        final timezoneId = whereTheIssData['timezone_id'];

        // Step 2: Fetch time information using the second API
        final worldTimeApiUrl =
            'http://worldtimeapi.org/api/timezone/$timezoneId';
        final worldTimeApiResponse = await http.get(Uri.parse(worldTimeApiUrl));

        if (worldTimeApiResponse.statusCode == 200) {
          final worldTimeData = json.decode(worldTimeApiResponse.body);
          final time = worldTimeData['datetime'].split('T')[1].split(':')[0];

          // Step 3: Determine day or night based on time
          final int hour = int.parse(time);
          if (hour >= 6 && hour < 18) {
            return 'day';
          } else {
            return 'night';
          }
        }
      }
    } catch (e) {
      // Handle errors or exceptions here
    }

    // Return a default value in case of errors
    return 'unknown';
  }
}
