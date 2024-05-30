import 'dart:convert';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:proj/dashboard.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proj/colors.dart';
import 'package:proj/component/wall.dart';
import 'package:proj/services/weatherservices.dart';
import 'package:proj/weathermodel/weathermodel.dart';

class Community extends StatefulWidget {
  String cityName = '';
  Community({super.key, required this.cityName});

  @override
  State<Community> createState() => _CommunityState();
}

String imageUrl = '';
XFile? selectedImage;
final List<String> cities = [];
// String _getcityname = '';
String dropdownValue = 'Weather Report';
String dropdownValue2 = 'Select a Posting Topic';
String? selectedImageFileName = 'None';

bool _loaderShown = false; // Initially, loader is not shown
// bool _firstClick = true; // Initially, it's the first click

class _CommunityState extends State<Community> {
  Weather? _weather;

  final currentUser = FirebaseAuth.instance.currentUser;
  //text controller
  final textController = TextEditingController();

  final WeatherService _weatherService =
      WeatherService('de1fa6f89e5e3630e563d7e8bcef4d22');

  @override
  void initState() {
    super.initState();
    _fetchData(context);
    _loaderShown = false;
    print(widget.cityName.toString());
  }

  Future<void> _fetchData(BuildContext context) async {
    await _fetchWeather(context);
    setState(() {});
  }

  _fetchWeather(BuildContext context) async {
    // Get current city
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(context, cityName);
      // DialogUtils.showInfoDialog(context);
      setState(() {
        _weather = weather;
        _loaderShown = true;
        // _getcityname = cityName;
      });
    } catch (e) {
      print(e);
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Loading indicator
              SizedBox(height: 10),
              Text('Uploading image...'), // Text indicating upload status
            ],
          ),
        );
      },
    );
  }

  void showLoaderAndPostMessage(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return DropdownButton<String>(
                            value: dropdownValue2,
                            onChanged: (String? newValue2) {
                              setState(() {
                                dropdownValue2 = newValue2!;
                              });
                            },
                            items: <String>[
                              'Select a Posting Topic',
                              'Weather Report',
                              'Street Accidents',
                              'Flash Flood',
                              'Heat Waves',
                              'Typhoon',
                              'Thunderstorms',
                              'Fire Incidents',
                              'Tornado',
                              'Earthquake',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          );
                        }),
                        TextFormField(
                          cursorColor: ColorPalette.darkblue,
                          style: const TextStyle(color: ColorPalette.darkblue),
                          controller: textController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "What's New? ",
                            hintStyle:
                                const TextStyle(color: ColorPalette.darkblue),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorPalette
                                      .darkblue), // White border color
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: ColorPalette.darkblue,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 20.0,
                            ),
                          ),
                          obscureText: false,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Expanded(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final XFile? image = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.camera);
                                      if (image == null) return;
                                      setState(() {
                                        // Store the selected image and its file name
                                        selectedImage = image;
                                        selectedImageFileName = image.path
                                            .split('/')
                                            .last; // Extract file name
                                      });

                                      try {
                                        imageUrl =
                                            await uploadImageToFirebaseStorage(
                                                image, context);
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        ColorPalette.darkblue,
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: ColorPalette.blue,
                                    ),
                                    label: const Text(
                                      'Take a Photo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              barrierDismissible:
                                  false, // Prevent user from dismissing the dialog
                              context: context,
                              builder: (context) => PopScope(
                                canPop: false,
                                child: AlertDialog(
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
                                      const Text("Posting Message.."),
                                      const SizedBox(height: 20), // Add spacing
                                      const LinearProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                            ColorPalette
                                                .darkblue), // Change the color here
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            // Add a delay of 2 seconds (for example)
                            Future.delayed(const Duration(seconds: 2), () {
                              // Call your postMessage function
                              postMessage();
                              // Clear the selected image
                              clearImage();

                              // showPostingMessageDialog(context); // Show dialog if text field is empty
                              // Dismiss the loading dialog
                              Navigator.pop(context);
                              // // Close the current screen
                              Navigator.pop(context);
                            });
                          },

                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              ColorPalette.darkblue,
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.check_circle,
                            color: ColorPalette.blue,
                          ), // Icon added here
                          label: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'POST',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                            'Previous Selected Image: ${selectedImageFileName!}',
                            style: const TextStyle(
                              color: ColorPalette.darkblue,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // logged in as
  // Text("Logged in as: ${currentUser!.email!}"),

  Future<String> uploadImageToFirebaseStorage(
      XFile imageFile, BuildContext context) async {
    try {
      // Show loading dialog
      showLoadingDialog(context);

      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDireImages = referenceRoot.child('images');
      Reference referenceImageToUpload = referenceDireImages.child(fileName);

      // Upload the image file to Firebase Storage
      UploadTask uploadTask =
          referenceImageToUpload.putFile(File(imageFile.path));

      // Use whenComplete to dismiss the loading dialog when upload is complete
      await uploadTask.whenComplete(() {
        // Dismiss loading dialog
        Navigator.of(context).pop();
      });

      // Retrieve the download URL of the uploaded image
      String imageUrl = await referenceImageToUpload.getDownloadURL();

      return imageUrl; // Return the download URL of the uploaded image
    } catch (e) {
      print('Error uploading image: $e');
      // Dismiss loading dialog if upload fails
      Navigator.of(context).pop();
      return ''; // Return empty string if upload fails
    }
  }

  Future<String?> getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.email;
    } else {
      return null;
    }
  }

  Future<String> getUserName(String userEmail) async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail) // Query by document ID (user's email)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final username = userData['username'];
        return username ??
            ''; // Return username if available, or an empty string otherwise
      } else {
        return ''; // User document does not exist, handle accordingly
      }
    } catch (error) {
      // Handle any errors that occur during the query
      print('Error fetching user name: $error');
      return ''; // You can modify this to handle errors differently
    }
  }

  Future<String> getProfilePic(String userEmail) async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail) // Query by document ID (user's email)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final profilepic = userData['imageUrl'];
        return profilepic ??
            ''; // Return username if available, or an empty string otherwise
      } else {
        return ''; // User document does not exist, handle accordingly
      }
    } catch (error) {
      // Handle any errors that occur during the query
      print('Error fetching user name: $error');
      return ''; // You can modify this to handle errors differently
    }
  }

  void pickImage() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      // Store the selected image and its file name
      selectedImage = image;
      selectedImageFileName = image.path.split('/').last; // Extract file name
    });

    try {
      imageUrl = await uploadImageToFirebaseStorage(image, context);
    } catch (e) {
      print(e);
    }
  }

  void clearImage() {
    setState(() {
      // Clear the selected image and its file name
      selectedImage = null;
      selectedImageFileName = 'None';
    });
  }

  Future<void> postMessage() async {
    String? userEmail = await getUserEmail();
    print('User Email: $userEmail');
    if (userEmail != null) {
      String? userName = await getUserName(userEmail);
      String? profilepic = await getProfilePic(userEmail);
      print('Retrieved UserName: $userName');
      try {
        if (dropdownValue2 == 'Select a Posting Topic') {
          // Show an error dialog if the dropdown value is "Select a Posting Topic"
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error,
                      color:
                          ColorPalette.darkblue), // Icon for the error message
                  SizedBox(
                      width: 10), // SizedBox for spacing between icon and text
                  Text('Message Error'), // Text for the title
                ],
              ),
              content: const Text('Please select a posting topic.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        ColorPalette.darkblue, // Background color of the button
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10), // Padding around the button text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Rounded corners for the button
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          );
          return; // Return from the function without posting the message
        }
        if (textController.text.isNotEmpty &&
            _weather != null && // Check if _weather is not null
            _weather?.cityName != null && // Check if cityName is not null
            _weather?.temperature != null && // Check if temperature is not null
            _weather?.mainCondition !=
                null && // Check if mainCondition is not null
            _weather?.humidity != null && // Check if humidity is not null
            _weather?.windspeed != null && // Check if windspeed is not null
            _weather?.maindesc != null && // Check if maindesc is not null
            _weather?.feelslike != null && // Check if feelslike is not null
            _weather?.tempmax != null && // Check if tempmax is not null
            _weather?.tempmin != null && // Check if tempmin is not null
            currentUser?.email != null) {
          await FirebaseFirestore.instance.collection("User Posts").add({
            'UserName': userName,
            'PostCategory': dropdownValue2,
            'Message': textController.text,
            'ProfilePic': profilepic,
            'TimeStamp': Timestamp.now(),
            'Temperature': _weather?.temperature,
            'Condition': _weather?.mainCondition,
            'Humidity': _weather?.humidity,
            'WindSpeed': _weather?.windspeed,
            'CityName': _weather?.cityName,
            'Description': _weather?.maindesc,
            'FeelsLike': _weather?.feelslike,
            'TempMax': _weather?.tempmax,
            'TempMin': _weather?.tempmin,
            'Image': imageUrl,
            'Email': currentUser?.email,
            'Likes': [],
          });
          print(
              'Message posted successfully'); // Debugging: Print success message
          imageUrl = '';
        } else {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error,
                      color:
                          ColorPalette.darkblue), // Icon for the error message
                  SizedBox(
                      width: 10), // SizedBox for spacing between icon and text
                  Text('Message Error'), // Text for the title
                ],
              ),
              content: const Text(
                  'Message cannot be empty and location must be turned on.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        ColorPalette.darkblue, // Background color of the button
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10), // Padding around the button text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Rounded corners for the button
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          );
          return; // Return from the function without posting the message
        }
      } catch (error) {
        print(
            'Error posting message: $error'); // Debugging: Print error message
      }
    }
    setState(() {
      textController.clear();
    });
  }

  Widget buildUserPosts(String filterValue, String cityName) {
    if (widget.cityName.isEmpty) {
      // Return a widget indicating that the city name is required
      return const Center(
        child: Text(
          'Please select a city.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    if (filterValue.isEmpty) {
      // Return a widget indicating that the filter value is required
      return const Center(
        child: Text(
          'Please select a filter value.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("User Posts")
          .where("CityName", isEqualTo: widget.cityName.toString())
          .where("PostCategory", isEqualTo: filterValue)
          .orderBy("TimeStamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PaginateFirestore(
            query: FirebaseFirestore.instance
                .collection('User Posts')
                .where("CityName", isEqualTo: widget.cityName.toString())
                .where("PostCategory", isEqualTo: filterValue)
                .orderBy('TimeStamp', descending: true),
            itemBuilderType: PaginateBuilderType.listView,
            itemsPerPage: 3,
            isLive: true,
            initialLoader:
                const Center(child: CircularProgressIndicator.adaptive()),
            onEmpty: const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      size: 50,
                      color: ColorPalette.darkblue,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No weather updates, just clear skies and a blank feed.',
                      style: TextStyle(
                        color: ColorPalette.darkblue,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            onError: (e) => const Center(child: Text('Error Loading Data')),
            bottomLoader: const Center(child: CircularProgressIndicator()),
            itemBuilder: (context, snapshot, index) {
              final Map<String, dynamic> json =
                  snapshot[index].data() as Map<String, dynamic>;
              dynamic image = json['Image'];
              dynamic profpic = json['ProfilePic'];
              return WallPost(
                message: json['Message'] ?? '',
                username: json['UserName'] ?? '',
                profilePic: profpic,
                cityname: json['CityName'] ?? '',
                condition: json['Condition'] ?? '',
                humidity: json['Humidity'] ?? '',
                temp: json['Temperature'] ?? '',
                windspeed: json['WindSpeed'] ?? '',
                feelslike: json['FeelsLike'] ?? '',
                time: json['TimeStamp'] ?? '',
                desc: json['Description'] ?? '',
                tempMax: json['TempMax'] ?? '',
                email: json['Email'],
                tempMin: json['TempMin'] ?? '',
                postid: snapshot[index].id,
                likes: List<String>.from(json['Likes'] ?? []),
                image: image,
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error${snapshot.error}'),
          );
        }
        // Show circular progress indicator while loading
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.greyblue,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.people),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Community"),
                Text(
                  widget.cityName.toString(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        foregroundColor: ColorPalette.greyblue,
        backgroundColor: ColorPalette.darkblue,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  DialogUtils.showInfoDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: 40, // Adjust the height as needed
              color: ColorPalette.darkblue
                  .withOpacity(0.95), // Adjust the color as needed
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Posts',
                        style: TextStyle(
                            color: ColorPalette.greyblue, fontSize: 15),
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return DropdownButton<String>(
                            dropdownColor:
                                ColorPalette.darkblue.withOpacity(0.95),
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_drop_down_rounded,
                                color: ColorPalette.greyblue),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(
                                color: ColorPalette.greyblue, fontSize: 15),
                            underline: Container(
                              height: 2,
                              color: ColorPalette.greyblue,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          Community(
                                    cityName: widget.cityName.toString(),
                                    // cityName: _weather?.cityName,
                                  ),
                                  transitionsBuilder:
                                      (context, animation1, animation2, child) {
                                    return FadeTransition(
                                      opacity: animation1,
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            items: <String>[
                              'Weather Report',
                              'Street Accidents',
                              'Flash Flood',
                              'Heat Waves',
                              'Typhoon',
                              'Thunderstorms',
                              'Fire Incidents',
                              'Tornado',
                              'Earthquake',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(
                                        color: ColorPalette.greyblue)),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // the wall

            Expanded(child: buildUserPosts(dropdownValue, widget.cityName)),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!_loaderShown) {
                            setState(() {
                              _loaderShown =
                                  true; // Update flag to indicate loader is shown
                            });
                            showDialog(
                              barrierDismissible:
                                  false, // Prevent user from dismissing the dialog
                              context: context,
                              builder: (context) {
                                // Start a timer to automatically dismiss the dialog after 5 seconds
                                Future.delayed(const Duration(seconds: 8), () {
                                  // Dismiss the dialog
                                  Navigator.pop(context);
                                });

                                // Build and return the AlertDialog with the loader
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 100, // Adjust height as needed
                                        width: double.infinity,
                                        child: Lottie.asset(
                                            'assets/loader.json'), // Replace 'assets/loading_animation.json' with your animation file path
                                      ),
                                      const SizedBox(height: 20),
                                      const LinearProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                            ColorPalette
                                                .darkblue), // Change the color here
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Fetching Weather Data, Make sure you are connected to the internet.",
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            // DialogUtils.showInfoDialog(context);
                            showLoaderAndPostMessage(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: ColorPalette.darkblue,
                          // Text color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12), // Button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Button border radius
                          ),
                        ),
                        icon: const Icon(Icons.send), // Icon added here
                        label: const Text('POST UPDATE?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> guidelines = [
  "Be respectful and courteous to other users.",
  "Post only weather-related content.",
  "Avoid spamming or posting irrelevant content.",
  "Refrain from using offensive language or behavior.",
  "Follow the guidelines provided by the moderators.",
  "Report any inappropriate content or behavior.",
  "Failure to comply with guidelines may result in a ban."
];

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
                  'Community Guidelines',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.greyblue,
                  ),
                ),
                const SizedBox(height: 16),
                Lottie.asset(
                  'assets/warning.json', // Replace with your Lottie animation file path
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scroll down to view more',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.greyblue,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_downward,
                      color: ColorPalette.greyblue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: guidelines.length,
                  itemBuilder: (context, index) {
                    final guideline = guidelines[index];
                    return ListTile(
                      leading: Text(
                        '${index + 1}.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: ColorPalette.greyblue,
                        ),
                      ),
                      title: Text(
                        guideline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: ColorPalette.greyblue,
                        ),
                      ),
                    );
                  },
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

// class CustomSearchDelegate extends SearchDelegate {
//   CustomSearchDelegate({
//     required this.onCitySelected,
//   });

//   final Function(String) onCitySelected; // Callback to handle city selection

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // Create a list to store matching city suggestions
//     List<String> matchQuery = [];
//     for (var city in cities) {
//       if (city.toLowerCase().contains(query.toLowerCase())) {
//         matchQuery.add(city);
//       }
//     }
//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index) {
//         var result = matchQuery[index];
//         return ListTile(
//           title: Text(result),
//           onTap: () {
//             onCitySelected(
//                 result); // Call the callback with the selected city name
//             close(context, result); // Close the search delegate
//             Navigator.pushReplacement(
//               context,
//               PageRouteBuilder(
//                 pageBuilder: (context, animation1, animation2) => Community(
//                   cityName: result,
//                 ),
//                 transitionsBuilder: (context, animation1, animation2, child) {
//                   return FadeTransition(
//                     opacity: animation1,
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 300),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return FutureBuilder<List<String>>(
//       future: fetchLocationSuggestions(query, context),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else {
//           List<String> suggestions = snapshot.data ?? [];
//           return Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 color: ColorPalette.darkblue
//                     .withOpacity(1), // Example color, change as needed
//                 width: MediaQuery.of(context)
//                     .size
//                     .width, // Set the width to the screen width
//                 child: TextButton.icon(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   icon: const Icon(
//                     Icons.location_on, // Example icon, change as needed
//                     color: Colors.white,
//                   ),
//                   label: Text(
//                     'Use Current Location',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: MediaQuery.of(context).size.width * 0.04,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   color: ColorPalette.greyblue,
//                   child: ListView.builder(
//                     itemCount: suggestions.length,
//                     itemBuilder: (context, index) {
//                       String suggestion = suggestions[index];
//                       List<String> parts =
//                           suggestion.split(','); // Split suggestion by comma
//                       String cityName = parts[0]
//                           .trim(); // First part is city name, remove leading and trailing spaces
//                       String regionName = parts.length > 1
//                           ? parts[1].trim()
//                           : ''; // Second part is region name if available, remove leading and trailing spaces
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 20.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: ColorPalette.mediumdarkblue.withOpacity(0.4),
//                             borderRadius: BorderRadius.circular(4.0),
//                           ),
//                           child: ListTile(
//                             leading: const Icon(Icons.location_city,
//                                 color: ColorPalette.darkblue),
//                             title: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   cityName,
//                                   style: const TextStyle(
//                                       color: ColorPalette.darkblue,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 if (regionName
//                                     .isNotEmpty) // Display region name only if available
//                                   Text(
//                                     regionName,
//                                     style: TextStyle(
//                                         color: ColorPalette.darkblue
//                                             .withOpacity(0.7)),
//                                   ),
//                               ],
//                             ),
//                             onTap: () {
//                               onCitySelected(cityName);
//                               close(context, cityName);
//                               _CommunityState()
//                                   .buildUserPosts(dropdownValue, cityName);
//                               DialogUtils.showInfoDialog(context);
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }
// }

// Future<List<String>> fetchLocationSuggestions(
//     String query, BuildContext context) async {
//   String username = 'erie7';
//   String apiUrl =
//       'http://api.geonames.org/searchJSON?q=$query&country=PH&maxRows=10&featureClass=P&username=$username';

//   try {
//     final response = await http.get(Uri.parse(apiUrl));
//     if (response.statusCode == 200) {
//       Map<String, dynamic> data = jsonDecode(response.body);
//       List<dynamic> suggestions = data['geonames'];
//       // Filter the suggestions to include only cities or villages
//       List<String> filteredSuggestions = [];
//       for (var suggestion in suggestions) {
//         if (suggestion['fcode'].startsWith('PPL')) {
//           // Concatenate city name with region name
//           String cityName = suggestion['name'] as String;
//           String regionName = suggestion['adminName1'] as String;
//           String suggestionWithRegion = '$cityName, $regionName';
//           filteredSuggestions.add(suggestionWithRegion);
//         }
//       }

//       return filteredSuggestions;
//     } else {
//       throw Exception('Location Not Found');
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//             'Please check your Internet/Mobile connection. You are in offline mode.'),
//       ),
//     );
//     return [];
//   }
// }
