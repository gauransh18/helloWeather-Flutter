import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hello_weather/api_key.dart';
import 'package:hello_weather/service/weatherService.dart';
import 'package:lottie/lottie.dart';

import '../models/weatherModel.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(_weather?.cityName ?? "loading city.."),
              Spacer(),
              Lottie.asset(
                '${_getWeatherAnimation(_weather?.mainCondition, dayOrNight)}',
              ),
              Spacer(),
              Text("${_weather?.temperature.round().toString()} °C",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    
                  )),
              Text("${_weather?.mainCondition ?? "loading.."}"),
              SizedBox(height: 50),
            ]),
      ),
    ));
  }
}
