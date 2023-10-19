// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:hello_weather/api_key.dart';
import 'package:hello_weather/service/weatherService.dart';
import 'package:lottie/lottie.dart';

import '../models/weatherModel.dart';
import 'dart:io' show Platform;

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final _weatherService = WeatherService(apiKey);
  Weather? _weather;
  String dayOrNight = "";

  _fetchWeather() async {
    final cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      final don = await _weatherService.checkDayOrNight();
      setState(() {
        _weather = weather;
        dayOrNight = don;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  String _getWeatherAnimation(String? mainCondition, String dayOrNight) {
    if (mainCondition == null) return "assets/sun.json";

    final isNight = dayOrNight.toLowerCase() == "night";
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return isNight ? "assets/cloudy-night.json" : "assets/cloudy-day.json";
      case 'rain':
        return isNight ? "assets/rainy-night.json" : "assets/rainy-day.json";
      case 'smoke':
        return "assets/cloudy.json";
      case 'haze':
        return "assets/cloudy-butnot.json";
      case 'dust':
        return "assets/cloudy-butnot.json";
      case 'fog':
        return "assets/cloudy-butnot.json";
      case 'drizzle':
        return "assets/cloudy-butnot.json";
      case 'shower rain':
        return "assets/rainy.json";
      case 'thunderstorm':
        return "assets/thunder.json";
      case 'clear':
        return isNight ? "assets/clear-night.json" : "assets/sun.json";
      default:
        return isNight ? "assets/clear-night.json" : "assets/sun.json";
    }
  }

  Future<void> _launchURL() async {
    final url = "https://github.com/gauransh18/helloWeather-Flutter.git";
    final Uri uri = Uri(
        scheme: 'https',
        host: 'github.com',
        path: '/gauransh18/helloWeather-Flutter.git');
    if (Platform.isAndroid) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 16, 16, 16),
        body: SafeArea(
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 134, 134, 134),
                    size: 20,
                  ),
                  Text(_weather?.cityName.toUpperCase() ?? "loading city..",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 134, 134, 134),
                      )),
                  Spacer(),
                  Lottie.asset(
                    '${_getWeatherAnimation(_weather?.mainCondition, dayOrNight)}',
                  ),
                  Text("${_weather?.mainCondition ?? "loading.."}",
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 230, 230, 230),
                      )),
                  Spacer(),
                  Text("${_weather?.temperature.round().toString()}°",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 230, 230, 230),
                      )),
                  SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      _launchURL();
                    },
                    child: Text(
                      'Visit our GitHub repository',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 121, 121, 121),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                
                ]),
          ),
        ));
  }
}
