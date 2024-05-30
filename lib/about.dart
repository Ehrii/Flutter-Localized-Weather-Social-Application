import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proj/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline), // Add the desired icon here
            SizedBox(width: 10),
            Text("About Us"),
          ],
        ),
        centerTitle: false,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(10, 61, 98, 1.0),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPANY INFO',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.darkblue,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/complogo.png', // Replace with the path to your first image
                        width: MediaQuery.of(context).size.width *
                            0.44, // Adjust the width as needed
                        height: MediaQuery.of(context).size.width *
                            0.4, // Adjust the height as needed
                      ),
                      const SizedBox(
                          width: 10), // Add spacing between the images
                      Image.asset(
                        'assets/Tropicool.png', // Replace with the path to your second image
                        width: MediaQuery.of(context).size.width *
                            0.5, // Adjust the width as needed
                        height: MediaQuery.of(context).size.width *
                            0.5, // Adjust the height as needed
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Version: 1.0.0',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'TROVACOM, is focused on revolutionizing the way individuals interact with weather information by providing innovative and user-friendly weather apps. Our goal is to empower people to make informed decisions and stay connected with their environment',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'TropiCool is the ultimate weather app with a unique blend of functionality and elegance. Explore real-time weather updates, personalized forecasts, and stunning visualizations.',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _launchEmail(
                              'trovacomtechnologies@gmail.com'); // Launch email
                        },
                        icon: const Icon(Icons.email), // Email icon
                      ),
                      TextButton(
                        onPressed: () {
                          _launchEmail(
                              'trovacomtechnologies@gmail.com'); // Launch email
                        },
                        child: Text(
                          'trovacomtechnologies@gmail.com',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _launchPhone('+639673411161'); // Launch phone call
                      },
                      icon: Icon(Icons.phone), // Phone icon
                    ),
                    TextButton(
                      onPressed: () {
                        _launchPhone('+639673411161'); // Launch phone call
                      },
                      child: Text(
                        'Phone: +(63)9673411161',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
                 Row(
                  children: [
                    IconButton(
                      onPressed: () {
                       _launchFB(); // Launch phone call
                      },
                      icon: const Icon(Icons.facebook), // Phone icon
                    ),
                    TextButton(
                      onPressed: () {
                       _launchFB(); // Launch phone call
                      },
                      child: Text(
                        'Trovacom',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
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
    );
  }
}

// Function to launch email
void _launchEmail(String email) async {
  final Uri _emailLaunchUri = Uri(
    scheme: 'mailto',
    path: email,
  );
  await launchUrl(_emailLaunchUri);
}

// Function to launch phone call
void _launchPhone(String phoneNumber) async {
  final Uri _phoneLaunchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(_phoneLaunchUri);
}

void _launchFB() async {
  const fbUrl = 'https://www.facebook.com/profile.php?id=61557091122191';
  final Uri uri = Uri.parse(fbUrl);
  if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
    throw "Can not launch url";
  }
}
