import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weatherModel.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';


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

  // Future<String> checkDayOrNight() async {
  //   // Get the user's current location (you can replace this with any location)
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);

  //   // Make an API request to the Sunrise-Sunset API
  //   String apiUrl =
  //       'https://api.sunrise-sunset.org/json?lat=${position.latitude}&lng=${position.longitude}';
  //   var response = await http.get(Uri.parse(apiUrl));

  //   if (response.statusCode == 200) {
  //     Map data = json.decode(response.body);
  //     String sunriseTime = data['results']['sunrise'];
  //     String sunsetTime = data['results']['sunset'];

  //     DateTime currentTime = DateTime.now();
  //     DateTime sunrise = DateTime.parse(sunriseTime);
  //     DateTime sunset = DateTime.parse(sunsetTime);

  //     if (currentTime.isAfter(sunrise) && currentTime.isBefore(sunset)) {
  //       return "day";
  //     } else {
  //       return "night";
  //     }
  //   } else {
  //     return "day";
  //   }
  // }



// ...

Future<String> checkDayOrNight() async {
  // Get the user's current location (you can replace this with any location)
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  // Make an API request to the Sunrise-Sunset API
  String apiUrl =
      'https://api.sunrise-sunset.org/json?lat=${position.latitude}&lng=${position.longitude}';
  var response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    Map data = json.decode(response.body);
    String sunriseTime = data['results']['sunrise'];
    String sunsetTime = data['results']['sunset'];

    // Regular expressions to match different date formats
    RegExp amPmRegex = RegExp(r'\d+:\d+:\d+ (AM|PM)');
    RegExp iso8601Regex = RegExp(r'\d{4}-\d{2}-\d{2}T\d+:\d+:\d+\+\d+:\d+');

    DateTime currentTime = DateTime.now();
    DateTime sunrise;
    DateTime sunset;

    if (amPmRegex.hasMatch(sunriseTime) && amPmRegex.hasMatch(sunsetTime)) {
      // Handle AM/PM date format
      sunrise = DateFormat('h:mm:ss a').parse(sunriseTime);
      sunset = DateFormat('h:mm:ss a').parse(sunsetTime);
    } else if (iso8601Regex.hasMatch(sunriseTime) && iso8601Regex.hasMatch(sunsetTime)) {
      // Handle ISO 8601 date format
      sunrise = DateTime.parse(sunriseTime);
      sunset = DateTime.parse(sunsetTime);
    } else {
      // Unable to parse the date, assume it's day
      return "day";
    }

    if (currentTime.isAfter(sunrise) && currentTime.isBefore(sunset)) {
      return "day";
    } else {
      return "night";
    }
  } else {
    return "day";
  }
}


}
