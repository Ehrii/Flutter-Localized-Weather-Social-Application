import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:proj/weathermodel/weathermodel.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class WeatherService {
  // ignore: constant_identifier_names
  static const String CURRENT_WEATHER_BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  // ignore: constant_identifier_names
  static const String FORECAST_BASE_URL = "https://api.openweathermap.org/data/2.5/forecast";
  final String apiKey;

  WeatherService(this.apiKey);

Future<Weather> getWeather(BuildContext context, String cityName) async {
  final response = await http.get(Uri.parse('$CURRENT_WEATHER_BASE_URL?q=$cityName&appid=$apiKey&units=metric'));
  
  if (response.statusCode == 200) {
    return Weather.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 404) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No weather data found for $cityName'),
      ),
    );
    throw Exception('No weather data found for $cityName');
  } else {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No weather data found on search'),
      ),
    );
    throw Exception('No weather data found on search');
  }
}





  // enable location services
static Future<void> promptLocationService() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permission is denied, stop the app.
      SystemNavigator.pop();
      return;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permission is denied forever, open app settings then stop the app.
    Geolocator.openAppSettings();
    SystemNavigator.pop();
  }
  // If permission is granted, or any other state, proceed with your app's logic.
}

  // get current city
  Future<String> getCurrentCity() async {
    // fetch current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //convert the location into a list of placemark objects
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    //extract the city name from the first placemark
    String? city = placemarks[0].locality;
    return city ?? "";
  }


Future<Coordinates?> convertToCoordinates(String cityName) async {
  try {
    List<Location> locations = await locationFromAddress(cityName);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      print('Coordinates for $cityName: ${location.latitude}, ${location.longitude}');
      return Coordinates(location.latitude, location.longitude);
    } else {
      print('No coordinates found for $cityName');
      return null;
    }
  } catch (e) {
    print('Error converting city name to coordinates: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchAQIByCity(String cityName) async {
  try {
    Coordinates? coordinates = await convertToCoordinates(cityName);
    
    if (coordinates != null) {
      // Fetch AQI using coordinates
      Map<String, dynamic>? aqi = await fetchAQI(coordinates.latitude, coordinates.longitude, apiKey);
      return aqi;
    } else {
      print('Coordinates not found for $cityName');
      return null;
    }
  } catch (e) {
    print('Error fetching AQI for $cityName: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchAQI(double latitude, double longitude, String apiKey) async {
  try {
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch air quality data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching air quality data: $e');
      return null;
    }
  }


Future<Map<String, dynamic>?> fetchOneCallByCity(String cityName) async {
  try {
    Coordinates? coordinates = await convertToCoordinates(cityName);
    
    if (coordinates != null) {
      // Fetch AQI using coordinates
      Map<String, dynamic>? dailyforecast = await fetchOneCall(coordinates.latitude, coordinates.longitude, apiKey);
      return dailyforecast;
    } else {
      print('Coordinates not found for $cityName');
      return null;
    }
  } catch (e) {
    print('Error fetching daily forecast for $cityName: $e');
    return null;
  }
}


  Future<Map<String, dynamic>?> fetchOneCall(double latitude, double longitude, String apiKey) async {
  try {
    String apiUrl =
        'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch one call  api data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching one call api data: $e');
      return null;
    } 
  }
}

class AirQualityData {
  final int? aqi;
  AirQualityData({this.aqi});
}


class Coordinates {
  final double latitude;
  final double longitude;
  Coordinates(this.latitude, this.longitude);
}

void main() async {
  String apiKey = 'de1fa6f89e5e3630e563d7e8bcef4d22';
  WeatherService weatherService = WeatherService(apiKey);
  String currentCityName = await weatherService.getCurrentCity();


  Coordinates? coordinates = await weatherService.convertToCoordinates(currentCityName);
  if (coordinates != null) {
    Map<String, dynamic>? aqi = await weatherService.fetchAQI(coordinates.latitude, coordinates.longitude, apiKey);
  }
}
