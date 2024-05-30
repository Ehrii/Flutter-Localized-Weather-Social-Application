import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proj/about.dart';
import 'package:proj/colors.dart';
import 'package:proj/community.dart';
import 'package:proj/component/drawer.dart';
import 'package:proj/firstaidkit.dart';
import 'package:proj/hotline.dart';
import 'package:proj/news.dart';
import 'package:proj/profile.dart';
import 'dart:convert';
import 'package:proj/services/weatherservices.dart';
import 'package:proj/weathermodel/weathermodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> forecastData = [];
  List<dynamic>? dailyForecast;
  List<dynamic>? hourlyForecast;
  List<dynamic>? minuteForecast;

  //api key
  final WeatherService _weatherService =
      WeatherService('de1fa6f89e5e3630e563d7e8bcef4d22');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Weather? _weather;
  int? aqi;
  String? qualitativeName;
  String? aqiDesc;
  Color? qualitativeColor;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _data = [];
  bool showDrawer = true; // Initialize the variable to true initially
  bool isButtonEnabled = true; // Example condition

  // Function to save weather info

  void _closeDrawer(bool drawershown) {
    setState(() {
      showDrawer =
          drawershown; // Set showDrawer to false when closing the drawer
    });
  }

  Future<void> _getData() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('user_posts').get();
    setState(() {
      _data = querySnapshot.docs;
    });
  }

  //fetch weather
  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(context, cityName);
      setState(() {
        _weather = weather;
        _weatherFetched = true;
        _closeDrawer(true);
        isButtonEnabled = true;
      });

      // Show snackbar if data retrieved successfully
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Local Weather data retrieved successfully'),
          duration: Duration(seconds: 2), // Adjust duration as needed
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Widget _buildCircularButton(BuildContext context,
      {required IconData icon,
      required Color iconColor, // Added parameter for icon color
      required String text,
      required Function() onPressed}) {
    double iconSize = MediaQuery.of(context).size.width * 0.15;
    double textSize = MediaQuery.of(context).size.width * 0.05;

    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          IconButton(
            onPressed: null, // IconButton onPressed is set to null
            icon: Icon(icon, color: iconColor, size: iconSize),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: ColorPalette.darkblue,
                fontSize: textSize,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Define a function to show the bottom modal sheet
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              _buildCircularButton(
                context,
                icon: Icons.health_and_safety,
                iconColor: ColorPalette.darkblue, // Set the icon color to blue
                text: 'First-Aid Kit & Safety',
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(
                          milliseconds: 500), // Adjust the duration as needed
                      pageBuilder: (_, __, ___) => const FirstAid(
                          // cityName: widget.cityName,
                          ), //DITO
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut, // Use a smoother curve
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildCircularButton(
                context,
                icon: Icons.call,
                iconColor: ColorPalette.darkblue, // Set the icon color to blue
                text: 'Emergency Hotline',
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(
                          milliseconds: 500), // Adjust the duration as needed
                      pageBuilder: (_, __, ___) => const Hotline(
                          // cityName: widget.cityName,
                          ), //DITO
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut, // Use a smoother curve
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _fetchWeatherByCity(String cityName) async {
    try {
      final weather = await _weatherService.getWeather(context, cityName);
      setState(() {
        _weather = weather;
        _closeDrawer(false);
        isButtonEnabled = false;
      });
    } catch (e) {
      print(e);
    }
  }

  _fetchForecastByCity(String cityName) async {
    String apiKey = 'de1fa6f89e5e3630e563d7e8bcef4d22';
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        forecastData = jsonDecode(response.body)['list'];
      });
    }
  }

  String getAQIQualitativeName(int? aqiValue) {
    if (aqiValue != null) {
      if (aqiValue == 1) {
        return 'Good';
      } else if (aqiValue == 2) {
        return 'Fair';
      } else if (aqiValue == 3) {
        return 'Moderate';
      } else if (aqiValue == 4) {
        return 'Poor';
      } else if (aqiValue == 5) {
        return 'Very Poor';
      } else {
        return 'Unknown';
      }
    } else {
      return 'Unknown';
    }
  }

  String getAQIDescription(int? aqiValue) {
    if (aqiValue != null) {
      if (aqiValue == 1) {
        return 'Air quality is considered good. Air pollution poses little or no risk.';
      } else if (aqiValue == 2) {
        return 'Air quality is fair. Some pollutants may be a moderate health concern for sensitive individuals.';
      } else if (aqiValue == 3) {
        return 'Air quality is moderate. There may be a risk for some people, particularly those who are unusually sensitive to air pollution.';
      } else if (aqiValue == 4) {
        return 'Air quality is poor. People with respiratory or heart conditions, children, and older adults are at risk.';
      } else if (aqiValue == 5) {
        return 'Air quality is very poor. Everyone may experience health effects, and sensitive groups may experience more serious health effects.';
      } else {
        return 'Description not available';
      }
    } else {
      return 'Description not available';
    }
  }

  Color getAQIColor(int? aqiValue) {
    if (aqiValue != null) {
      if (aqiValue == 1) {
        return Colors.lightBlueAccent;
      } else if (aqiValue == 2) {
        return Colors.lightBlue;
      } else if (aqiValue == 3) {
        return Colors.blue;
      } else if (aqiValue == 4) {
        return Colors.indigo;
      } else if (aqiValue == 5) {
        return Colors.deepPurple;
      } else {
        return Colors.grey; // Default color if AQI is not within 1-5
      }
    } else {
      return Colors.grey; // Default color if AQI value is null
    }
  }

  Future<void> fetchOneCall() async {
    String apiKey = 'ba7afff4d5d9f491494294539cf1a370';
    try {
      String? cityName = await _weatherService.getCurrentCity();

      Coordinates? coordinates =
          await _weatherService.convertToCoordinates(cityName);
      if (coordinates != null) {
        Map<String, dynamic>? fetchedOneCall = await _weatherService
            .fetchOneCall(coordinates.latitude, coordinates.longitude, apiKey);
        if (fetchedOneCall != null) {
          setState(() {
            dailyForecast = fetchedOneCall['daily'];
            hourlyForecast = fetchedOneCall['hourly'];
            minuteForecast = fetchedOneCall['minutely'];
          });
        } else {
          print('Failed to fetch One Call API data');
        }
      }
    } catch (e) {
      print('Error fetching One Call API data: $e');
    }
  }

  _fetchOneCallByCity(String city) async {
    String apiKey = 'ba7afff4d5d9f491494294539cf1a370';
    try {
      Coordinates? coordinates =
          await _weatherService.convertToCoordinates(city);
      if (coordinates != null) {
        Map<String, dynamic>? fetchedOneCall =
            await _weatherService.fetchOneCall(
          coordinates.latitude,
          coordinates.longitude,
          apiKey,
        );
        if (fetchedOneCall != null) {
          setState(() {
            dailyForecast = fetchedOneCall['daily'];
            hourlyForecast = fetchedOneCall['hourly'];
            minuteForecast = fetchedOneCall['minutely'];
          });
        } else {
          print('Failed to fetch One Call API data');
        }
      }
    } catch (e) {
      print('Error fetching One Call API data: $e');
    }
  }

  Future<void> fetchAQI() async {
    String apiKey = 'de1fa6f89e5e3630e563d7e8bcef4d22';
    try {
      String? cityName = await _weatherService.getCurrentCity();
      print('Your city is: $cityName');

      Coordinates? coordinates =
          await _weatherService.convertToCoordinates(cityName);
      if (coordinates != null) {
        Map<String, dynamic>? fetchedAqi = await _weatherService.fetchAQI(
            coordinates.latitude, coordinates.longitude, apiKey);
        if (fetchedAqi != null) {
          int? aqiValue = fetchedAqi['list'][0]['main']['aqi'];
          setState(() {
            aqi = aqiValue;
            qualitativeName = getAQIQualitativeName(aqiValue);
            qualitativeColor = getAQIColor(aqiValue);
            aqiDesc = getAQIDescription(aqiValue);
          });
        } else {
          print('Failed to fetch AQI data');
        }
      }
    } catch (e) {
      print('Error fetching AQI data: $e');
    }
  }

  _fetchAQICity(String cityName) async {
    String apiKey = 'de1fa6f89e5e3630e563d7e8bcef4d22';
    try {
      Coordinates? coordinates =
          await _weatherService.convertToCoordinates(cityName);
      if (coordinates != null) {
        Map<String, dynamic>? fetchedAqi = await _weatherService.fetchAQI(
            coordinates.latitude, coordinates.longitude, apiKey);
        if (fetchedAqi != null) {
          int? aqiValue = fetchedAqi['list'][0]['main']['aqi'];
          setState(() {
            aqi = aqiValue;
            qualitativeName = getAQIQualitativeName(aqiValue);
            qualitativeColor = getAQIColor(aqiValue);
            aqiDesc = getAQIDescription(aqiValue);
          });
        } else {
          print('Failed to fetch AQI data for $cityName');
        }
      } else {
        print('Coordinates not found for $cityName');
      }
    } catch (e) {
      print('Error fetching AQI data for $cityName: $e');
    }
  }

  _fetchForecastData() async {
    String apiKey = 'de1fa6f89e5e3630e563d7e8bcef4d22';
    String cityName = await _weatherService.getCurrentCity();

    String apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        forecastData = jsonDecode(response.body)['list'];
      });
    } else {
      throw Exception('No Weather Data Found');
    }
  }

  //weather animations
  String getWeatherAnimation(String? mainCondition, DateTime time) {
    if (mainCondition == null) return 'assets/clearday.json';
    int hour = time.hour;
    bool isDaytime = hour >= 6 && hour < 18;
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return isDaytime ? 'assets/cloudyday.json' : 'assets/cloudynight.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return isDaytime ? 'assets/rainyday.json' : 'assets/rainynight.json';
      case 'thunderstorm':
        return isDaytime
            ? 'assets/thunderday.json'
            : 'assets/thundernight.json';
      case 'clear':
        return isDaytime ? 'assets/clearday.json' : 'assets/clearnight.json';
      default:
        return isDaytime ? 'assets/clearday.json' : 'assets/clearnight.json';
    }
  }

  String getUVIndexDescription(double? uvi) {
    if (uvi != null) {
      if (uvi < 3) {
        return "Low: UV index is low. Wear sunscreen for added protection and limit sun exposure.";
      } else if (uvi < 6) {
        return "Moderate: UV index is moderate. Wear protective clothing, sunglasses, and sunscreen.";
      } else if (uvi < 8) {
        return "High: UV index is high. Take extra precautions by seeking shade and wearing protective clothing, sunglasses, and sunscreen.";
      } else if (uvi < 11) {
        return "Very High: UV index is very high. Avoid prolonged sun exposure and take all precautions to protect your skin.";
      } else {
        return "Extreme: UV index is extreme. Minimize outdoor activities and take extensive precautions to avoid sunburn and skin damage.";
      }
    } else {
      return 'Loading...';
    }
  }

  String determineDirection(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) {
      return 'N';
    } else if (degrees >= 22.5 && degrees < 67.5) {
      return 'NE';
    } else if (degrees >= 67.5 && degrees < 112.5) {
      return 'E';
    } else if (degrees >= 112.5 && degrees < 157.5) {
      return 'SE';
    } else if (degrees >= 157.5 && degrees < 202.5) {
      return 'S';
    } else if (degrees >= 202.5 && degrees < 247.5) {
      return 'SW';
    } else if (degrees >= 247.5 && degrees < 292.5) {
      return 'W';
    } else {
      return 'NW';
    }
  }

  bool _weatherFetched = false;
  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _getData();
  }

  Future<void> clearCache() async {
    // Get the default cache manager
    DefaultCacheManager manager = DefaultCacheManager();
    // Clear the cache
    await manager.emptyCache();
  }

  Future<void> _fetchData() async {
    await _fetchWeather();
    await _fetchForecastData();
    await fetchAQI();
    await fetchOneCall();
    setState(() {});
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    clearCache();
  }

  final Map<String, IconData> activityIcon = {
    'Running': Icons.directions_run,
    'Biking & Cycling': Icons.directions_bike,
    'Beach & Pool': Icons.beach_access,
    'Stargazing': Icons.nightlight_round,
    'Indoor': Icons.house,
    'Air travel': Icons.airplanemode_active,
    'Driving': Icons.directions_car,
  };

  List<String> activities = [
    'Running',
    'Biking & Cycling',
    'Beach & Pool',
    'Stargazing',
    'Indoor',
    'Air travel',
    'Driving',
  ];
  String getActivitySuitability(String activity, int temp, double uvi,
      int cloudiness, int humidity, int time, int windspeed, String condition) {
    print(temp);
    print(uvi);
    print(cloudiness);
    print(humidity);
    print(time);
    print(windspeed);
    print(condition);

    if ((activity == 'Running') || (activity == 'Biking & Cycling')) {
      // Check if it's daytime (assuming daytime is defined as 6:00 AM to 6:00 PM)
      bool isDaytime = (time >= 6 && time < 18);

      // Adjust conditions based on whether it's daytime or nighttime
      if (isDaytime) {
        if (temp < 29 && uvi < 3 && cloudiness < 20 && humidity < 70) {
          return 'Ideal';
        } else if (temp < 30 && uvi < 6 && cloudiness < 30 && humidity < 80) {
          return 'Great';
        } else if (temp < 35 && uvi < 8 && cloudiness < 60 && humidity < 85) {
          return 'Good';
        } else if (temp < 40 && uvi < 11 && cloudiness < 100 && humidity < 90) {
          return 'Fair';
        } else {
          return 'Poor';
        }
      } else {
        return 'Good';
      }
    } else if (activity == 'Beach & Pool') {
      bool isDaytime = (time >= 6 && time < 18);

      if (isDaytime) {
        if (temp >= 36 && humidity < 70 && cloudiness < 50) {
          return 'Ideal';
        } else if (temp >= 30 && humidity < 90 && cloudiness < 70) {
          return 'Great';
        } else if (temp >= 25 && humidity < 95 && cloudiness < 80) {
          return 'Good';
        } else {
          return 'Fair'; // Change 'Poor' to 'Fair' for non-ideal conditions during daytime
        }
      } else {
        return 'Poor'; // Return 'Not Applicable' for night time conditions
      }
    } else if (activity == 'Stargazing') {
      bool isNighttime = (time < 6 || time >= 18);
      if (isNighttime) {
        if (cloudiness < 30) {
          return 'Ideal'; // Clear skies are ideal for stargazing
        } else if (cloudiness < 50) {
          return 'Good'; // Some clouds may still allow for decent stargazing
        } else if (cloudiness < 70) {
          return 'Fair'; // Moderate cloud cover may hinder visibility but still allow for stargazing
        } else {
          return 'Poor'; // Heavy cloud cover is not suitable for stargazing
        }
      } else {
        return 'Poor'; // Stargazing is not typically done during daytime hours
      }
    } else if ((activity == 'Air travel') || (activity == 'Driving')) {
      if ((condition.contains('clear sky') ||
              condition.contains('few clouds') ||
              condition.contains('scattered clouds') ||
              condition.contains('broken clouds')) &&
          windspeed < 20) {
        return 'Ideal';
      } else if ((condition.contains('few clouds') ||
              condition.contains('scattered clouds') ||
              condition.contains('broken clouds')) &&
          windspeed < 30) {
        return 'Great';
      } else if ((condition.contains('few clouds') ||
              condition.contains('scattered clouds') ||
              condition.contains('broken clouds') ||
              condition.contains('mist') ||
              condition.contains('smoke') ||
              condition.contains('haze') ||
              condition.contains('dust') ||
              condition.contains('fog')) ||
          (condition.contains('shower rain') || condition.contains('rain'))) {
        return 'Good';
      } else if (condition.contains('shower rain') ||
          condition.contains('rain') ||
          condition.contains('overcast clouds') ||
          condition.contains('thunderstorm')) {
        return 'Fair';
      } else {
        return 'Poor';
      }
    } else if (activity == 'Indoor') {
      if (humidity <= 40 && temp <= 24 && uvi < 2) {
        return 'Ideal';
      } else if (humidity <= 70 && temp <= 27 && uvi < 5) {
        return 'Great';
      } else if (humidity <= 80 && temp <= 30 && uvi < 7) {
        return 'Good';
      } else if (humidity <= 100 && temp <= 40 && uvi < 9) {
        return 'Fair';
      } else {
        return 'Poor';
      }
    }

    // Add conditions for other activities here
    return ''; // Default value if activity is not found
  }

  final List<String> categories = [
    'Weather Report',
    'Street Accidents',
    'Flash Flood',
    'Heat Waves',
    'Typhoon',
    'Thunderstorms',
    'Fire Incidents',
    'Tornado',
    'Earthquake',
  ];

  final Map<String, IconData> categoryIcons = {
    'Weather Report': Icons.wb_sunny,
    'Street Accidents': Icons.directions_car,
    'Flash Flood': Icons.waves,
    'Heat Waves': Icons.thermostat,
    'Typhoon': Icons.cloud,
    'Thunderstorms': Icons.flash_on,
    'Fire Incidents': Icons.local_fire_department,
    'Tornado': Icons.tornado,
    'Earthquake': Icons.landslide,
  };

  Future<int> getPostCount(String cityName, String category) async {
    // Get the current date and set it to start of the day (midnight)
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    // Query to get the posts in the specified city and category that were created today
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('User Posts')
        .where('CityName', isEqualTo: cityName) // Match the city name
        .where('PostCategory', isEqualTo: category) // Match the category
        .where('TimeStamp',
            isGreaterThanOrEqualTo: startOfDay) // After or on start of today
        .get();

    return snapshot.docs.length; // Return the count of matching documents
  }

  @override
  Widget build(BuildContext context) {
    String direction = determineDirection(_weather?.degrees ?? 0);
    String directionText = '$direction (${_weather?.degrees}' + "°)";
    double screenwidth = MediaQuery.of(context).size.width;
    double screeHeight = MediaQuery.of(context).size.height;
    DateTime currentTime = DateTime.now();
    String backgroundImage = BackgroundHelper.getBackground(currentTime);

    DateTime? sunriseTime = _weather?.sunriseDateTime;
    DateTime? sunsetTime = _weather?.sunsetDateTime; // Example sunrise time
    String formattedSunriseTime = '';
    String formattedSunsetTime = '';
    String formattedDtTime = '';

    if (sunriseTime != null && sunsetTime != null) {
      formattedSunriseTime = DateFormat('h:mm a').format(sunriseTime);
      formattedSunsetTime = DateFormat('h:mm a').format(sunsetTime);
    } else {
      formattedSunriseTime = 'N/A';
      formattedSunsetTime = 'N/A';
    }
    DateTime? dtTime = _weather?.datacalc;
    if (dtTime != null) {
      formattedDtTime = DateFormat('h:mm a').format(dtTime!);
    } else {
      // Handle the case where dtTime is null
      formattedDtTime = 'Updating..';
    }

//Navigate to Community
    void goToCommunityPage() {
      // Show loading dialog
      showDialog(
        barrierDismissible: false, // Prevent user from dismissing the dialog
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add Lottie animation above the text
              SizedBox(
                height: 100, // Adjust height as needed
                width: double.infinity,
                child: Lottie.asset(
                    'assets/loader.json'), // Replace 'assets/loading_animation.json' with your animation file path
              ),
              const SizedBox(height: 20), // Add spacing
              const Text("Loading Feed.."),
              const SizedBox(height: 20), // Add spacing
              const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    ColorPalette.darkblue), // Change the color here
              ),
            ],
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        // Navigate to Community page
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(
                milliseconds: 500), // Adjust the duration as needed
            pageBuilder: (_, __, ___) => Community(
              cityName: _weather!.cityName.toString(),
            ), //DITO
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut, // Use a smoother curve
                ),
                child: child,
              );
            },
          ),
        );
      });
    }

    void goToNewsPage() {
      Navigator.pop(context);
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(
              milliseconds: 500), // Adjust the duration as needed
          pageBuilder: (_, __, ___) => News(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut, // Use a smoother curve
              ),
              child: child,
            );
          },
        ),
      );
    }

    void goToProfilePage() {
      Navigator.pop(context);
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(
              milliseconds: 500), // Adjust the duration as needed
          pageBuilder: (_, __, ___) => const Profile(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut, // Use a smoother curve
              ),
              child: child,
            );
          },
        ),
      );
    }

    void goToAboutPage() {
      Navigator.pop(context);
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(
              milliseconds: 500), // Adjust the duration as needed
          pageBuilder: (_, __, ___) => const About(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut, // Use a smoother curve
              ),
              child: child,
            );
          },
        ),
      );
    }

    void _launchWeatherMapUrl() async {
      const weatherMapUrl = 'https://www.ventusky.com/';
      final Uri uri = Uri.parse(weatherMapUrl);
      if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
        throw "Can not launch url";
      }
    }

    Size size = MediaQuery.of(context).size;
    String formattedDate =
        DateFormat('EE, MMMM d, yyyy').format(DateTime.now());
    return Scaffold(
      key: _scaffoldKey,
      drawer: _weather?.cityName != null && showDrawer
          ? MyDrawer(
              onCommunityTap: goToCommunityPage,
              onNewsTap: goToNewsPage,
              onProfileTap: goToProfilePage,
              onSignOutTap: signOut,
              onAboutTap: goToAboutPage,
            )
          : null,
      backgroundColor: ColorPalette.greyblue.withOpacity(0.7),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: ColorPalette.greyblue,
        backgroundColor: ColorPalette.darkblue,
        title: Text(
          'Last Update: $formattedDtTime',
          style: TextStyle(
            color: ColorPalette.greyblue,
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        centerTitle: true,
        actions: _weather?.cityName != null
            ? [
                IconButton(
                  icon: const Icon(Icons.search, color: ColorPalette.greyblue),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(
                        fetchWeather: _fetchWeatherByCity,
                        fetchForecast: _fetchForecastByCity,
                        fetchCurrentLoc: _fetchData,
                        fetchAQICity: _fetchAQICity,
                        fetchOneCallByCity: _fetchOneCallByCity,
                      ),
                    );
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.refresh, color: ColorPalette.greyblue),
                  onPressed: _fetchData,
                ),
              ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () => _fetchData(),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: _weather == null
                        ? const CircularProgressIndicator(
                            backgroundColor: ColorPalette.darkblue,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          )
                        // Show loading indicator while _weather is null
                        : Container(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // City name
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        backgroundImage,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5, // Adjusted height
                                      ),
                                      Positioned(
                                        bottom:
                                            10, // Adjust the position of the row
                                        left: 10,
                                        right:
                                            10, // To make the row span the entire width of the image
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.explore,
                                                            size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.1,
                                                            color: ColorPalette
                                                                .darkblue,
                                                          ), // Replace 'your_icon' with the desired icon
                                                          const SizedBox(
                                                              width:
                                                                  12), // Adjust the width according to your preference
                                                          Text(
                                                            'Activities',
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.07, // Adjust the font size as needed
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: activities
                                                              .map((activity) {
                                                            String suitability = getActivitySuitability(
                                                                activity,
                                                                _weather!
                                                                    .temperature
                                                                    .round(),
                                                                hourlyForecast !=
                                                                            null &&
                                                                        hourlyForecast!
                                                                            .isNotEmpty
                                                                    ? (hourlyForecast![0]['uvi']
                                                                            is int
                                                                        ? (hourlyForecast![0]['uvi']
                                                                                as int)
                                                                            .toDouble()
                                                                        : hourlyForecast![0]['uvi']
                                                                                as double? ??
                                                                            0.0)
                                                                    : 0.0,
                                                                _weather!
                                                                    .cloudiness,
                                                                _weather!
                                                                    .humidity,
                                                                DateTime.now()
                                                                    .hour,
                                                                _weather!
                                                                    .windspeed
                                                                    .round(),
                                                                _weather!
                                                                    .maindesc);
                                                            IconData iconData =
                                                                activityIcon[
                                                                        activity] ??
                                                                    Icons
                                                                        .error; // Get the icon data

                                                            Color textColor;
                                                            String status;
                                                            switch (
                                                                suitability) {
                                                              case 'Ideal':
                                                              case 'Great':
                                                                textColor =
                                                                    Colors
                                                                        .green;
                                                                status =
                                                                    'Very Satisfied';
                                                                break;
                                                              case 'Good':
                                                                textColor =
                                                                    Colors
                                                                        .orange;
                                                                status =
                                                                    'Satisfied';
                                                                break;
                                                              case 'Fair':
                                                                textColor = Colors
                                                                    .deepOrange;
                                                                status =
                                                                    'Neutral';
                                                                break;
                                                              case 'Poor':
                                                                textColor =
                                                                    Colors.red;
                                                                status =
                                                                    'Dissatisfied'; // Assign 'Not suitable' for 'Poor' condition
                                                                break;
                                                              default:
                                                                textColor =
                                                                    Colors
                                                                        .black;
                                                                status =
                                                                    'Unknown';
                                                                break;
                                                            }
                                                            return ListTile(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5.0), // Adjust the horizontal padding as needed
                                                              leading: Icon(
                                                                  iconData,
                                                                  color:
                                                                      textColor),
                                                              title: Text(
                                                                activity,
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.035),
                                                              ),
                                                              trailing: Text(
                                                                suitability,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.04,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                status,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                      actions: [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty.all(
                                                                    ColorPalette
                                                                        .darkblue), // Change the button's background color
                                                            padding: MaterialStateProperty.all(
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        12,
                                                                    horizontal:
                                                                        24)), // Adjust the button's padding
                                                            shape: MaterialStateProperty
                                                                .all(
                                                                    RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8), // Adjust the button's border radius
                                                            )),
                                                          ),
                                                          child: const Text(
                                                            'Close',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  16, // Adjust the text font size
                                                              color: Colors
                                                                  .white, // Change the text color
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.travel_explore,
                                                color: ColorPalette.darkblue,
                                              ),
                                              label: const Text(
                                                'To-Do',
                                                style: TextStyle(
                                                  color: ColorPalette.darkblue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    ColorPalette.greyblue,
                                                elevation: 4,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: ColorPalette.darkblue,
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  _showBottomSheet(context);
                                                },
                                                icon: Icon(
                                                  Icons.emergency,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  color: ColorPalette.greyblue,
                                                ),
                                                padding: EdgeInsets
                                                    .zero, // Remove padding around the icon
                                              ),
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                _launchWeatherMapUrl();
                                              },
                                              icon: const Icon(
                                                Icons.map,
                                                color: ColorPalette.darkblue,
                                              ),
                                              label: const Text(
                                                'Map',
                                                style: TextStyle(
                                                  color: ColorPalette.darkblue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    ColorPalette.greyblue,
                                                elevation: 4,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: ColorPalette.greyblue
                                                    .withOpacity(1),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .location_city_rounded,
                                                        color: ColorPalette.blue
                                                            .withOpacity(0.8),
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            //CITY DITO
                                                            _weather?.cityName
                                                                    .toUpperCase() ??
                                                                "Loading city...",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: ColorPalette
                                                                  .darkblue
                                                                  .withOpacity(
                                                                      0.8),
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.06,
                                                            ),
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                          Text(
                                                            formattedDate,
                                                            style: TextStyle(
                                                              color: ColorPalette
                                                                  .darkblue
                                                                  .withOpacity(
                                                                      0.6),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.04,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                      children: [
                                        
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: ColorPalette
                                                  .darkblue, // Same color as the text
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05, // Adjust size as needed
                                            ),
                                            Text(
                                              "What's Happening?",
                                              style: TextStyle(
                                                color: ColorPalette.darkblue
                                                    .withOpacity(0.8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                            ),
                                            isButtonEnabled
                                                ? IconButton(
                                                    icon: Icon(
                                                      Icons.arrow_forward,
                                                      color: ColorPalette
                                                          .darkblue, // Same color as the text
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.06,
                                                    ),
                                                    onPressed: () {
                                                      goToCommunityPage();
                                                    },
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "As of $formattedDate",
                                        style: TextStyle(
                                          color: ColorPalette.darkblue
                                              .withOpacity(0.8),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (String category
                                          in categories) // Loop through each category
                                        FutureBuilder<int>(
                                          future: getPostCount(
                                              _weather!.cityName.toString(),
                                              category), // Get the count of posts
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<
                                                        Color>(
                                                    ColorPalette.darkblue
                                                        .withOpacity(
                                                            0.5)), // Set the color
                                              ); // Show loading indicator while waiting
                                            }
                                            int count = snapshot.data ??
                                                0; // Default to 0 if data is null
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                decoration: BoxDecoration(
                                                  color: ColorPalette.greyblue,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          categoryIcons[
                                                              category], // Get the icon from the map
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.06,
                                                        ),
                                                        Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            category,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: ColorPalette
                                                                    .darkblue
                                                                    .withOpacity(
                                                                        0.8))), // Display category name
                                                        const SizedBox(
                                                            height:
                                                                8), // Space between texts
                                                        Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            count.toString() + " Reports",
                                                            style: TextStyle(
                                                                fontSize:MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.035 ,
                                                                color: ColorPalette
                                                                    .darkblue
                                                                    .withOpacity(
                                                                        0.8))), // Display count
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.cloudy_snowing,
                                              color: ColorPalette
                                                  .darkblue, // Same color as the text
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05, // Adjust size as needed
                                            ),
                                            Text(
                                              "Weather Information",
                                              style: TextStyle(
                                                color: ColorPalette.darkblue
                                                    .withOpacity(0.8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildColumn(
                                      image: "assets/visibility.png",
                                      text:
                                          '${(_weather?.visible ?? 0) / 1000.0} km',
                                      imagewidth:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      imageheight:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      context: context,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildColumn(
                                      image: "assets/max.png",
                                      text:
                                          'Max: ${_weather?.tempmax.round()} °C',
                                      imagewidth:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      imageheight:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      context: context,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildColumn(
                                      image: "assets/min.png",
                                      text:
                                          'Min: ${_weather?.tempmin.round()} °C',
                                      imagewidth:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      imageheight:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      context: context,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildColumn(
                                      image: "assets/sunrise.png",
                                      text: 'Sunrise: $formattedSunriseTime',
                                      imagewidth:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      imageheight:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      context: context,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildColumn(
                                      image: "assets/sunset.png",
                                      text: 'Sunset: $formattedSunsetTime',
                                      imagewidth:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      imageheight:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      context: context,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorPalette.greyblue,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.wb_sunny,
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.15, // Adjust size as needed
                                                    color: ColorPalette.blue,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Center(
                                                      child: Text(
                                                        '${dailyForecast != null && dailyForecast!.isNotEmpty ? dailyForecast![0]['summary'] + "." : 'Loading...'}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: ColorPalette
                                                              .darkblue
                                                              .withOpacity(0.8),
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.040,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorPalette.greyblue,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: SingleChildScrollView(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.solar_power,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                          color:
                                                              ColorPalette.blue,
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Center(
                                                            child: Text(
                                                              dailyForecast !=
                                                                          null &&
                                                                      dailyForecast!
                                                                          .isNotEmpty
                                                                  ? "UV Index  •  ${hourlyForecast![0]['uvi'].toStringAsFixed(2)}"
                                                                  : 'Loading...',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: ColorPalette
                                                                    .darkblue
                                                                    .withOpacity(
                                                                        0.8),
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.070,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                            height: 2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Center(
                                                            child: Container(
                                                              constraints: BoxConstraints(
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8), // Limiting max width
                                                              child: Text(
                                                                dailyForecast !=
                                                                            null &&
                                                                        dailyForecast!
                                                                            .isNotEmpty
                                                                    ? getUVIndexDescription(double.parse(hourlyForecast![0]
                                                                            [
                                                                            'uvi']
                                                                        .toString()))
                                                                    : 'Loading...',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: ColorPalette
                                                                      .darkblue
                                                                      .withOpacity(
                                                                          0.8),
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.040,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                                softWrap:
                                                                    true, // Enable soft wrap
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    width: size.width,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: ColorPalette.greyblue
                                          .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: SizedBox(
                                              width:
                                                  100, // Adjust the width as needed
                                              child: Lottie.asset(
                                                getWeatherAnimation(
                                                  '${_weather?.mainCondition}',
                                                  DateTime.now(),
                                                ),
                                                fit: BoxFit
                                                    .contain, // Ensure the animation fits within the given width
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15.0),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        // Icon(
                                                        //   Icons
                                                        //       .thermostat_outlined,
                                                        //   color: Colors
                                                        //       .blue, // Adjust icon color as needed
                                                        //   size: MediaQuery.of(
                                                        //               context)
                                                        //           .size
                                                        //           .width *
                                                        //       0.06,
                                                        // ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          '${_weather?.temperature.round()} °C',
                                                          style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.130,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: ColorPalette
                                                                .darkblue
                                                                .withOpacity(
                                                                    0.8),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Icon(
                                                          Icons.cloud_outlined,
                                                          color: Colors
                                                              .blue, // Adjust icon color as needed
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.06,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          _weather?.maindesc
                                                                  .toUpperCase() ??
                                                              '',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis, // You can use another overflow option if preferred
                                                          textAlign: TextAlign
                                                              .center, // Align text to the center

                                                          style: TextStyle(
                                                            color: ColorPalette
                                                                .darkblue
                                                                .withOpacity(
                                                                    0.8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.035,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        const SizedBox(
                                                            width: 5),
                                                        Row(
                                                          children: [
                                                            SingleChildScrollView(
                                                              child: Text(
                                                                'Feels Like: ${_weather?.feelslike.round()} °C ',
                                                                style:
                                                                    TextStyle(
                                                                  color: ColorPalette
                                                                      .darkblue,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.045,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  width: size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.43,
                                  decoration: BoxDecoration(
                                    color:
                                        ColorPalette.greyblue.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 30),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildWeatherInfo(
                                              title: 'Wind Speed',
                                              iconPath: 'assets/windspeed.png',
                                              value:
                                                  '${_weather?.windspeed} m/s',
                                              context: context,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildWeatherInfo(
                                              title: 'Wind Deg',
                                              iconPath: 'assets/winddeg.png',
                                              value: directionText,
                                              context: context,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildWeatherInfo(
                                              title: 'Wind Gust',
                                              iconPath: 'assets/windgust.png',
                                              value:
                                                  '${_weather?.windgust.round()} m/s',
                                              context: context,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height:
                                                12), // Adjust spacing between rows
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: _buildWeatherInfo(
                                                title: 'Humidity',
                                                iconPath: 'assets/humidity.png',
                                                value: '${_weather?.humidity}%',
                                                context: context,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildWeatherInfo(
                                                title: 'Pressure',
                                                iconPath: 'assets/pressure.png',
                                                value:
                                                    '${_weather?.pressure} hPa',
                                                context: context,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildWeatherInfo(
                                                title: 'Cloudiness',
                                                iconPath:
                                                    'assets/cloudiness.png',
                                                value:
                                                    '${_weather?.cloudiness}%',
                                                context: context,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 30,
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: size.width,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: ColorPalette.greyblue,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: size.width,
                                                height: 200,
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: aqi != null
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                'Air Quality Index (AQI):  ',
                                                                            style:
                                                                                TextStyle(
                                                                              color: ColorPalette.darkblue.withOpacity(0.8),
                                                                              fontSize: MediaQuery.of(context).size.width * 0.04,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                '$qualitativeName',
                                                                            style:
                                                                                TextStyle(
                                                                              color: qualitativeColor ?? Colors.white,
                                                                              fontSize: MediaQuery.of(context).size.width * 0.05,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.1,
                                                                            height:
                                                                                MediaQuery.of(context).size.width * 0.1,
                                                                            child:
                                                                                Icon(
                                                                              Icons.air,
                                                                              color: qualitativeColor ?? Colors.white,
                                                                              size: MediaQuery.of(context).size.width * 0.1,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                          Text(
                                                                            '${aqi ?? 'N/A'}',
                                                                            style:
                                                                                TextStyle(
                                                                              color: qualitativeColor ?? Colors.white,
                                                                              fontSize: MediaQuery.of(context).size.width * 0.12,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Center(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.vertical,
                                                                  child: Center(
                                                                    child: Text(
                                                                      aqiDesc ??
                                                                          'Description not available',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ColorPalette
                                                                            .darkblue
                                                                            .withOpacity(0.8),
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width *
                                                                                0.035,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const Column(
                                                        // Use a Column instead of CircularProgressIndicator
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    ColorPalette
                                                                        .darkblue),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(
                                                            'Loading AQI...', // Display a loading message
                                                            style: TextStyle(
                                                                color: ColorPalette
                                                                    .darkblue),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .analytics, // Choose your desired icon
                                              color: ColorPalette.blue,
                                            ),
                                            SizedBox(
                                                width:
                                                    5), // Adjust the width as needed for spacing
                                            Text(
                                              'Minute Local Forecast',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: ColorPalette.darkblue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  width: size.width,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: minuteForecast != null
                                      ? ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: minuteForecast!.length,
                                          itemBuilder: (context, index) {
                                            var humidity =
                                                minuteForecast![index]
                                                    ['humidity'];
                                            var precipitation =
                                                minuteForecast![index]
                                                    ['precipitation'];

                                            var dateTime = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    minuteForecast![index]
                                                            ['dt'] *
                                                        1000);
                                            var formattedDate =
                                                DateFormat('EE h:mm a')
                                                    .format(dateTime);
                                            String lottieJsonPath = BackgroundHelper
                                                .getPreciIcon(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        minuteForecast![index]
                                                                ['dt'] *
                                                            1000)); // Function that returns the appropriate Lottie JSON path
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: ColorPalette
                                                    .mediumdarkblue
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Lottie.asset(
                                                      lottieJsonPath,
                                                      height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.2, // Adjust height as needed
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                    ),
                                                    Text(
                                                      'Precipitation: $precipitation mm',
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Column(
                                          // Use a Column instead of CircularProgressIndicator
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      ColorPalette.darkblue),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Loading Minute Local Forecast...', // Display a loading message
                                              style: TextStyle(
                                                  color: ColorPalette.darkblue),
                                            ),
                                          ],
                                        ),
                                ),

                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .analytics, // Choose your desired icon
                                              color: ColorPalette.blue,
                                            ),
                                            SizedBox(
                                                width:
                                                    5), // Adjust the width as needed for spacing
                                            Text(
                                              'Hourly Local Forecast',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: ColorPalette.darkblue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                //HOURLY FORECAST

                                Container(
                                  width: size.width,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: hourlyForecast != null
                                      ? ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: hourlyForecast!.length,
                                          itemBuilder: (context, index) {
                                            var humidity =
                                                hourlyForecast![index]
                                                    ['humidity'];
                                            var TempKelvin =
                                                hourlyForecast![index]['temp'];

                                            double TempCelsius =
                                                TempKelvin - 273.15;

                                            var dateTime = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    hourlyForecast![index]
                                                            ['dt'] *
                                                        1000);
                                            var formattedDate =
                                                DateFormat('EE h a')
                                                    .format(dateTime);
                                            String lottieJsonPath = BackgroundHelper
                                                .getWeatherIcon(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        hourlyForecast![index]
                                                                ['dt'] *
                                                            1000)); // Function that returns the appropriate Lottie JSON path

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: ColorPalette
                                                    .mediumdarkblue
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Lottie.asset(
                                                      lottieJsonPath,
                                                      height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.2, // Adjust height as needed
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                    ),
                                                    Text(
                                                      'Temp: ' +
                                                          '${TempCelsius.round()} °C',
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue),
                                                    ),
                                                    Text(
                                                      'Humidity: ' +
                                                          '${humidity} %',
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Column(
                                          // Use a Column instead of CircularProgressIndicator
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      ColorPalette.darkblue),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Loading Hourly Forecast...', // Display a loading message
                                              style: TextStyle(
                                                  color: ColorPalette.darkblue),
                                            ),
                                          ],
                                        ),
                                ),

                                const SizedBox(
                                  height: 30,
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .analytics, // Choose your desired icon
                                              color: ColorPalette.blue,
                                            ),
                                            SizedBox(
                                                width:
                                                    5), // Adjust the width as needed for spacing
                                            Text(
                                              '8-Day Local Forecast',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: ColorPalette.darkblue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 30,
                                ),

                                //8 DAY FORECAST
                                Container(
                                  width: size.width,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: dailyForecast != null
                                      ? ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: dailyForecast!.length,
                                          itemBuilder: (context, index) {
                                            var MinTempKelvin =
                                                dailyForecast![index]['temp']
                                                    ['min'];
                                            double MinTempCelsius =
                                                MinTempKelvin - 273.15;

                                            var MaxTempKelvin =
                                                dailyForecast![index]['temp']
                                                    ['max'];
                                            double MaxTempCelsius =
                                                MaxTempKelvin - 273.15;

                                            var dateTime = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    dailyForecast![index]
                                                            ['dt'] *
                                                        1000);
                                            var formattedDate =
                                                DateFormat('EE h a')
                                                    .format(dateTime);
                                            String lottieJsonPath = BackgroundHelper
                                                .getWeatherIcon(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        dailyForecast![index]
                                                                ['dt'] *
                                                            1000)); // Function that returns the appropriate Lottie JSON path

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: ColorPalette
                                                    .mediumdarkblue
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Lottie.asset(
                                                      lottieJsonPath,
                                                      height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.2, // Adjust height as needed
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                    ),
                                                    Text(
                                                      'Min Temp: ' +
                                                          '${MinTempCelsius.round()} °C',
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue),
                                                    ),
                                                    Text(
                                                      'Max Temp: ' +
                                                          '${MaxTempCelsius.round()} °C',
                                                      style: const TextStyle(
                                                          color: ColorPalette
                                                              .darkblue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Column(
                                          // Use a Column instead of CircularProgressIndicator
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      ColorPalette.darkblue),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Loading 8-Day Local Forecast...', // Display a loading message
                                              style: TextStyle(
                                                  color: ColorPalette.darkblue),
                                            ),
                                          ],
                                        ),
                                ),

                                const SizedBox(
                                  height: 30,
                                ),
                                //5 DAY FORECAST
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .analytics, // Choose your desired icon
                                              color: ColorPalette.blue,
                                            ),
                                            SizedBox(
                                                width:
                                                    5), // Adjust the width as needed for spacing
                                            Text(
                                              '5 Day / 3 Hour Forecast',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: ColorPalette.darkblue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  width: size.width,
                                  height: 400,
                                  decoration: BoxDecoration(
                                    color: ColorPalette.greyblue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 30),
                                  child: forecastData.isEmpty
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        ColorPalette.darkblue),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Loading 5-Day / 3-Hour Local Forecast...', // Display a loading message
                                                style: TextStyle(
                                                    color:
                                                        ColorPalette.darkblue),
                                              ),
                                            ],
                                          ), // Display the circular progress indicator while loading
                                        )
                                      : ListView.builder(
                                          itemCount: forecastData.length,
                                          itemBuilder: (context, index) {
                                            // Check if forecast data is null
                                            var forecast = forecastData[index];
                                            dynamic temperatureKelvinValue =
                                                forecast['main']['temp'];
                                            double temperatureKelvin;
                                            double temperatureCelsius;
                                            if (temperatureKelvinValue is int) {
                                              temperatureKelvin =
                                                  temperatureKelvinValue
                                                      .toDouble();
                                            } else if (temperatureKelvinValue
                                                is double) {
                                              temperatureKelvin =
                                                  temperatureKelvinValue;
                                            } else {
                                              temperatureKelvin = 0.0;
                                            }
                                            temperatureCelsius =
                                                temperatureKelvin - 273.15;
                                            var dateTime = DateTime.parse(forecast[
                                                'dt_txt']); // Convert string to DateTime
                                            var formattedDate =
                                                DateFormat('EE h:mm a')
                                                    .format(dateTime);
                                            String weatherDescription =
                                                forecast['weather'][0]
                                                    ['description'];
                                            int humidity =
                                                forecast['main']['humidity'];
                                            String forecastImage =
                                                BackgroundHelper()
                                                    .getWeatherForecastIcon(
                                                        weatherDescription);
                                            var preci = forecast['pop'] ?? 0.0;
                                            double preciPercentage =
                                                preci.toDouble() * 100;

                                            return Container(
                                              height: 200,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 0),
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                color: ColorPalette
                                                    .mediumdarkblue
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: SingleChildScrollView(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Lottie.asset(
                                                            forecastImage,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.5,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            formattedDate,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  ColorPalette
                                                                      .darkblue,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Text(
                                                            '${temperatureCelsius.round()}°C',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  ColorPalette
                                                                      .darkblue,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Text(
                                                            weatherDescription,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  ColorPalette
                                                                      .darkblue,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Text(
                                                            'Rain: ${preciPercentage.toStringAsFixed(0)}%',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  ColorPalette
                                                                      .darkblue,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Text(
                                                            'Humidity: ${humidity.round()}%',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  ColorPalette
                                                                      .darkblue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                )
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildWeatherInfo({
  required String title,
  required String iconPath,
  required String value,
  required BuildContext context,
}) {
  return Column(
    children: [
      Text(
        title.toUpperCase(),
        style: TextStyle(
            color: ColorPalette.darkblue.withOpacity(0.8),
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(5.0),
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          color: ColorPalette.mediumdarkblue,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Image.asset(
          iconPath,
          width: 400,
          fit: BoxFit.cover,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorPalette.darkblue.withOpacity(0.8),
        ),
      ),
      const SizedBox(height: 15),
    ],
  );
}

Widget _buildColumn({
  required String image,
  required String text,
  required double imagewidth,
  required double imageheight,
  required double fontSize, // Added parameter for font size
  required BuildContext context,
}) {
  return Expanded(
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
        maxHeight: MediaQuery.of(context).size.width * 0.33,
      ),
      decoration: BoxDecoration(
        color: ColorPalette.greyblue,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: imagewidth,
              height: imageheight,
              color: ColorPalette.blue,
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                color: ColorPalette.darkblue.withOpacity(0.8),
                fontSize: fontSize, // Set font size using the parameter
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class BackgroundHelper {
  String getWeatherForecastIcon(String weatherDescription) {
    String lowercaseDescription = weatherDescription.toLowerCase();

    if (lowercaseDescription.contains('cloud')) {
      return 'assets/cloudyday.json';
    } else if (lowercaseDescription.contains('rain') ||
        lowercaseDescription.contains('drizzle') ||
        lowercaseDescription.contains('shower')) {
      return 'assets/rainyday.json';
    } else if (lowercaseDescription.contains('thunderstorm')) {
      return 'assets/thunderday.json';
    } else if (lowercaseDescription.contains('clear')) {
      return 'assets/clearday.json';
    } else {
      return 'assets/clearday.json'; // Default icon
    }
  }

  static String getWeatherIcon(DateTime dateTime) {
    int hour = dateTime.hour;

    if (hour >= 6 && hour < 18) {
      // Daytime (6:00 AM to 5:59 PM)
      return 'assets/clearday.json'; // Path to your clearday.json file
    } else {
      // Nighttime
      return 'assets/clearnight.json'; // Path to your clearnight.json file
    }
  }

  static String getPreciIcon(DateTime dateTime) {
    int hour = dateTime.hour;

    if (hour >= 6 && hour < 18) {
      // Daytime (6:00 AM to 5:59 PM)
      return 'assets/rainyday.json'; // Path to your clearday.json file
    } else {
      // Nighttime
      return 'assets/rainynight.json'; // Path to your clearnight.json file
    }
  }

  static String getBackground(DateTime dateTime) {
    // Extract the hour from the DateTime object
    int hour = dateTime.hour;

    // Determine the time of day based on the hour
    String timeOfDay;
    if (hour >= 6 && hour < 12) {
      timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 18) {
      timeOfDay = 'afternoon';
    } else if (hour >= 18 && hour < 20) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }
    // Return the appropriate background image path based on the time of day
    return "assets/$timeOfDay.gif";
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final Function(String) fetchWeather;
  final Function(String) fetchForecast;
  final Function() fetchCurrentLoc;
  final Function(String) fetchAQICity;
  final Function(String)
      fetchOneCallByCity; // Add this function for searching AQI

  CustomSearchDelegate({
    required this.fetchWeather,
    required this.fetchForecast,
    required this.fetchCurrentLoc,
    required this.fetchAQICity,
    required this.fetchOneCallByCity,
  });

  final List<String> cities = [];

  @override
  List<Widget>? buildActions(Object context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var city in cities) {
      if (city.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(city);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  Future<List<String>> fetchLocationSuggestions(
      String query, BuildContext context) async {
    String username = 'erie7';
    String apiUrl =
        'http://api.geonames.org/searchJSON?q=$query&country=PH&maxRows=10&featureClass=P&username=$username';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> suggestions = data['geonames'];
        // Filter the suggestions to include only cities or villages
        List<String> filteredSuggestions = [];
        for (var suggestion in suggestions) {
          if (suggestion['fcode'].startsWith('PPL')) {
            // Concatenate city name with region name
            String cityName = suggestion['name'] as String;
            String regionName = suggestion['adminName1'] as String;
            String suggestionWithRegion = '$cityName, $regionName';
            filteredSuggestions.add(suggestionWithRegion);
          }
        }

        return filteredSuggestions;
      } else {
        throw Exception('Location Not Found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please check your Internet/Mobile connection. You are in offline mode.'),
        ),
      );
      return [];
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchLocationSuggestions(query, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<String> suggestions = snapshot.data ?? [];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: ColorPalette.darkblue
                    .withOpacity(1), // Example color, change as needed
                width: MediaQuery.of(context)
                    .size
                    .width, // Set the width to the screen width
                child: TextButton.icon(
                  onPressed: () {
                    fetchCurrentLoc();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.location_on, // Example icon, change as needed
                    color: Colors.white,
                  ),
                  label: Text(
                    'Use Current Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: ColorPalette.greyblue,
                  child: ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      String suggestion = suggestions[index];
                      List<String> parts =
                          suggestion.split(','); // Split suggestion by comma
                      String cityName = parts[0]
                          .trim(); // First part is city name, remove leading and trailing spaces
                      String regionName = parts.length > 1
                          ? parts[1].trim()
                          : ''; // Second part is region name if available, remove leading and trailing spaces
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorPalette.mediumdarkblue.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.location_city,
                                color: ColorPalette.darkblue),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cityName,
                                  style: const TextStyle(
                                      color: ColorPalette.darkblue,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (regionName
                                    .isNotEmpty) // Display region name only if available
                                  Text(
                                    regionName,
                                    style: TextStyle(
                                        color: ColorPalette.darkblue
                                            .withOpacity(0.7)),
                                  ),
                              ],
                            ),
                            onTap: () {
                              fetchWeather(cityName);
                              fetchForecast(cityName);
                              fetchAQICity(cityName);
                              fetchOneCallByCity(cityName);
                              close(context, cityName);
                              DialogUtils.showInfoDialog(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class DialogUtils {
  static void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: ColorPalette.darkblue,
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
                child: Column(
              children: [
                Text(
                  'You Are In Location View Mode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.greyblue,
                  ),
                ),
                const SizedBox(height: 16),
                Lottie.asset(
                  'assets/map.json', // Replace with your Lottie animation file path
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                Text(
                  'Click the magnifying glass 🔍 button to search for locations. \n\nClick the Use Current Location button to retrieve your original location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: ColorPalette.greyblue,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        ColorPalette.greyblue), // Change the color here
                  ),
                  child: const Text(
                    'I Agree',
                    style: TextStyle(color: ColorPalette.darkblue),
                  ),
                ),
              ],
            )),
          ),
        );
      },
    );
  }
}

// Function to retrieve a Weather object from Shared Preferences
Future<Weather?> getSavedWeather() async {
  final prefs = await SharedPreferences.getInstance();

  // Get the JSON string from Shared Preferences
  String? weatherJson = prefs.getString('weatherData');

  // Return null if there's no saved data
  if (weatherJson == null) {
    return null;
  }

  // Convert the JSON string back to a Weather object
  Map<String, dynamic> weatherMap = json.decode(weatherJson);

  return Weather.fromJson(weatherMap);
}

// Function to save a Weather object to Shared Preferences
Future<void> saveWeather(Weather weather) async {
  final prefs = await SharedPreferences.getInstance();

  // Convert the Weather object to a JSON string
  String weatherJson = json.encode(weather.toJson());

  // Save the JSON string to Shared Preferences
  await prefs.setString('weatherData', weatherJson);
}
