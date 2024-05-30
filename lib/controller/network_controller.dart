import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proj/colors.dart';
import 'package:proj/weathermodel/weathermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late RxBool _hasInternet;

  @override
  void onInit() {
    super.onInit();
    _hasInternet = false.obs;
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void showWeatherInfoDialog(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String cityName = prefs.getString('cityName') ?? 'Unknown City';
    double temperature = prefs.getDouble('temperature') ?? 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Weather Info"),
          content: Text(
              "City: $cityName\nTemperature: ${temperature.toStringAsFixed(1)} °C"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult != ConnectivityResult.none) {
      _hasInternet.value = true;
      if (Get.isDialogOpen!) {
        Get.back(); // Dismiss the currently shown dialog
      }
      if (connectivityResult == ConnectivityResult.mobile) {
        // Connected via mobile data
        Get.defaultDialog(
          title: 'Mobile Data Connected',
          titlePadding: const EdgeInsets.only(top: 20.0),
          titleStyle: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18), // Custom title style
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_rounded,
                  color: Colors.green,
                  size: 80,
                ), // Add an icon besides the title
                const SizedBox(
                    height:
                        10), // Add some space between the icon and the title
                const Text(
                  'Mobile Data Connected Successfully. Click the Ok button to proceed.',
                  style: TextStyle(
                      color: ColorPalette.darkblue,
                      fontSize: 16), // Custom content text style
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // Increased vertical spacing
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Dismiss the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorPalette.darkblue, // Button text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Button border radius
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontSize: 16), // Button text style
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: ColorPalette.greyblue,
          barrierDismissible: false,
        );
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // Connected via WiFi
        Get.defaultDialog(
          title: 'WiFi Connected',
          titlePadding: const EdgeInsets.only(top: 20.0),
          titleStyle: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18), // Custom title style
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_rounded,
                  color: Colors.green,
                  size: 80,
                ), // Add an icon besides the title
                const SizedBox(
                    height:
                        10), // Add some space between the icon and the title
                const Text(
                  'WiFi Connected Successfully. Click the Ok button to proceed.',
                  style: TextStyle(
                      color: ColorPalette.darkblue,
                      fontSize: 16), // Custom content text style
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // Increased vertical spacing
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Dismiss the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorPalette.darkblue, // Button text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Button border radius
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontSize: 16), // Button text style
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: ColorPalette.greyblue,
          barrierDismissible: false,
        );
      }
    } else {
      _hasInternet.value = false;
      if (!Get.isDialogOpen!) {
        Get.defaultDialog(
          title: 'No Internet Connection',
          titlePadding: const EdgeInsets.only(top: 20.0),
          titleStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18), // Custom title style
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.red,
                  size: 80,
                ), // Add an icon besides the title
                const SizedBox(
                    height:
                        10), // Add some space between the icon and the title
                const Text(
                  'Please connect to the WiFi or Mobile Data to proceed.',
                  style: TextStyle(
                      color: ColorPalette.darkblue,
                      fontSize: 16), // Custom content text style
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // Increased vertical spacing
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Dismiss the dialog
                    // Retry connecting to the internet
                    _connectivity.checkConnectivity().then((result) {
                      _updateConnectionStatus(result);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorPalette.darkblue, // Button text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Button border radius
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 16), // Button text style
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {

                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorPalette.darkblue, // Button text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Button border radius
                    ),
                  ),
                  child: const Text(
                    'Saved Info',
                    style: TextStyle(fontSize: 16), // Button text style
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: ColorPalette.greyblue,
          barrierDismissible: false,
        );
      }
    }
  }
}
