import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main(List<String> args) {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Map'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select a Weather Map:'),
            const SizedBox(height: 20),
            WeatherMapButton(
              title: 'Windy.com',
              url: 'https://www.windy.com',
            ),
            WeatherMapButton(
              title: 'Meteoblue',
              url: 'https://www.meteoblue.com/en/weather/maps',
            ),
            WeatherMapButton(
              title: 'EarthSchool.net',
              url: 'https://www.earthschool.net',
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherMapButton extends StatelessWidget {
  final String title;
  final String url;

  const WeatherMapButton({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _launchWeatherMapUrl(url, context),
      child: Text(title),
    );
  }

  Future<void> _launchWeatherMapUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
        ),
      );
      throw 'Could not launch $url';
    }
    await launch(url, forceWebView: true);
  }
}
