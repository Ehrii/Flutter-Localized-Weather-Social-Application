import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:proj/colors.dart';
import 'package:proj/component/comment.dart';
import 'package:proj/component/commentbutton.dart';
import 'package:proj/component/likebutton.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String cityname;
  final double temp;
  final Timestamp time;
  final String postid;
  final String username;
  final String condition;
  final int humidity;
  final double windspeed;
  final String email;
  final String desc;
  final double feelslike;
  final double tempMax;
  final double tempMin;
  final List<String> likes;
  final dynamic profilePic;

  final dynamic image;
  const WallPost({
    super.key,
    required this.message,
    required this.cityname,
    required this.temp,
    required this.time,
    this.profilePic,
    required this.windspeed,
    required this.condition,
    required this.feelslike,
    required this.desc,
    required this.email,
    required this.humidity,
    required this.username,
    required this.tempMax,
    required this.tempMin,
    required this.postid,
    required this.likes,
    this.image,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);

    getUserEmail();
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postid);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/clearday.json';
    // int hour = time.hour;
    // bool isDaytime = hour >= 6 && hour < 18;
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudyday.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainyday.json';
      case 'thunderstorm':
        return 'assets/thunderday.json';
      case 'clear':
        return 'assets/clearday.json';
      default:
        return 'assets/clearday.json';
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
        final userData = userSnapshot.data() as Map<String, dynamic>?;
        // Check if userData is not null before accessing its properties
        if (userData != null) {
          final profilepic = userData['imageUrl'];
          // Ensure profilepic is not null before returning it
          return profilepic ??
              ''; // Return imageUrl if available, or an empty string otherwise
        }
      }
      // Return an empty string if userSnapshot does not exist or userData is null
      return '';
    } catch (error) {
      // Handle any errors that occur during the query
      print('Error fetching user profile picture: $error');
      return ''; // Return an empty string in case of an error
    }
  }

  //add a comment method
  Future<void> addComment(String commentText) async {
    String? userEmail = await getUserEmail();
    if (userEmail != null) {
      String? userName = await getUserName(userEmail);
      FirebaseFirestore.instance
          .collection("User Posts")
          .doc(widget.postid)
          .collection("Comments")
          .add({
        "CommentText": commentText,
        "CommentedBy": userName,
        "CommentTime": Timestamp.now(),
        "Email": userEmail,
      });
    }
  }

  //show a dialog box
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Dark background color
        title: const Row(
          children: [
            Icon(
              Icons.add, // Icon you want to add
              color: ColorPalette.darkblue, // Icon color
            ),
            SizedBox(width: 5), // Add some spacing between the icon and text
            Text(
              "Add a Comment",
              style: TextStyle(
                color: ColorPalette.darkblue, // Text color
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _commentTextController,
          style:
              const TextStyle(color: ColorPalette.darkblue), // White text color
          decoration: InputDecoration(
            hintText: "Write a comment...",
            hintStyle: const TextStyle(color: Colors.grey), // Hint text color
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15.0), // Set border radius here
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorPalette.darkblue), // White border color
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.blue), // Custom focus border color
            ),
          ),
          maxLines: null, // Allow multiple lines for comments
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _commentTextController.clear(); // Clear the text field
            },
            child: const Text(
              "Cancel",
              style:
                  TextStyle(color: ColorPalette.darkblue), // White text color
            ),
          ),
          ElevatedButton(
            onPressed: () {
              addComment(_commentTextController.text); // Add comment
              Navigator.pop(context); // Close the dialog
              _commentTextController.clear(); // Clear the text field
            }, // White text color by default
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(
                  64, 115, 158, 1.0), // Custom button color
            ),
            child: const Text(
              "Post",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  void showWeatherDialog(
      BuildContext context,
      String cityName,
      String condition,
      String description,
      double feelsLike,
      int humidity,
      double tempMax,
      double tempMin,
      double temperature,
      double windSpeed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.cloud,
                    color: ColorPalette
                        .darkblue), // Example icon (replace with your desired icon)
                const SizedBox(
                    width: 8), // Adjust the width as needed for spacing
                Text(
                  // 'Weather Information - $cityName',
                  'Weather Information',
                  style: TextStyle(
                    color: ColorPalette.darkblue,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width:
                        double.infinity, // Match the width of the AlertDialog
                    child: Lottie.asset(
                      getWeatherAnimation(
                        widget.condition,
                      ), // Replace 'your_animation.json' with your animation file
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                _buildWeatherInfoRow('Condition', condition),
                _buildWeatherInfoRow('Description', description),
                _buildWeatherInfoRow('Feels Like', '$feelsLike °C'),
                _buildWeatherInfoRow('Humidity', '$humidity %'),
                _buildWeatherInfoRow('Max Temperature', '$tempMax °C'),
                _buildWeatherInfoRow('Min Temperature', '$tempMin °C'),
                _buildWeatherInfoRow('Temperature', '$temperature °C'),
                _buildWeatherInfoRow('Wind Speed', '$windSpeed m/s'),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorPalette.darkblue, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20), // Button border radius
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Adjust the font size as needed
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: ColorPalette.darkblue),
          ),
          Text(
            value,
            style: const TextStyle(color: ColorPalette.darkblue),
          ),
        ],
      ),
    );
  }

  Future<String> getUserBio(String email) async {
    try {
      // Retrieve the user document from the "Users" collection
      final userDoc =
          await FirebaseFirestore.instance.collection("Users").doc(email).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData["bio"] ??
            "No bio available"; // Return bio or a default message
      } else {
        return "No user data found"; // Return this if the document doesn't exist
      }
    } catch (e) {
      // Handle any errors
      return "Error retrieving user bio"; // Return error message if there's an exception
    }
  }

  Future<String> getUserProfImage(String email) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection("Users").doc(email).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData["imageUrl"] ??
            "assets/avatarplaceholder.png"; // Default to a placeholder
      } else {
        return "assets/avatarplaceholder.png"; // Placeholder if user document doesn't exist
      }
    } catch (e) {
      return "assets/avatarplaceholder.png"; // Placeholder in case of errors
    }
  }

  // add a comment
  @override
  Widget build(BuildContext context) {
    print('ProfilePic' + widget.profilePic);
    print('image url: ' + widget.image);

    DateTime dateTime = widget.time.toDate();
    String formattedTime = DateFormat.yMMMd().add_jm().format(dateTime);
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          margin: const EdgeInsets.only(top: 10, left: 0, right: 0),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Picture
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (currentUser.email != widget.email) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: ColorPalette.darkblue,
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .account_circle, // Add your desired icon
                                        color:
                                            ColorPalette.greyblue, // Icon color
                                      ),
                                      SizedBox(
                                          width:
                                              8), // Add some spacing between the icon and text
                                      Text(
                                        'User Profile',
                                        style: TextStyle(
                                            color: ColorPalette.greyblue),
                                      ),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FutureBuilder<String>(
                                          future: getUserProfImage(widget
                                              .email), // Fetch profile image URL
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              // Display a loading indicator while waiting
                                              return const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        ColorPalette.greyblue),
                                              );
                                            } else if (snapshot.hasError) {
                                              // Handle errors and return a placeholder
                                              return Image.asset(
                                                  "assets/avatarplaceholder.png",
                                                  fit: BoxFit.cover);
                                            } else if (snapshot.hasData) {
                                              final imageUrl = snapshot.data!;
                                              // If there's an image URL, load it; otherwise, show the placeholder
                                              if (imageUrl.isNotEmpty &&
                                                  imageUrl !=
                                                      "assets/avatarplaceholder.png") {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        "assets/avatarplaceholder.png",
                                                    image: imageUrl,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration:
                                                        Duration(seconds: 1),
                                                    imageErrorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                          "assets/avatarplaceholder.png",
                                                          fit: BoxFit.cover);
                                                    },
                                                  ),
                                                );
                                              } else {
                                                return Image.asset(
                                                    "assets/avatarplaceholder.png",
                                                    fit: BoxFit.cover);
                                              }
                                            } else {
                                              return Image.asset(
                                                  "assets/avatarplaceholder.png",
                                                  fit: BoxFit
                                                      .cover); // Default fallback
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        // Display the username
                                        const Text(
                                          "Username",
                                          style: TextStyle(
                                            color: ColorPalette.greyblue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          widget.username,
                                          style: const TextStyle(
                                            color: ColorPalette.greyblue,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Fetch and display the user bio
                                        FutureBuilder<String>(
                                          future: getUserBio(widget
                                              .email), // Use the function to get bio
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        ColorPalette.greyblue),
                                              ); // Loader while fetching
                                            }
                                            if (snapshot.hasError ||
                                                !snapshot.hasData) {
                                              return const Text(
                                                  "Error retrieving user bio."); // Error handling
                                            }
                                            final userBio = snapshot.data ??
                                                "No bio available";
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "User Bio",
                                                  style: TextStyle(
                                                    color:
                                                        ColorPalette.greyblue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  userBio,
                                                  style: const TextStyle(
                                                    color:
                                                        ColorPalette.greyblue,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ReportDialog(
                                                  postid: widget.postid,
                                                  username: widget.username,
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                Colors.blue, // Text color
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12), // Button padding
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8), // Button border radius
                                            ),
                                          ),
                                          child: const Text('Report'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                Colors.grey, // Text color
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12), // Button padding
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8), // Button border radius
                                            ),
                                          ),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: widget.profilePic != null &&
                                  widget.profilePic.isNotEmpty
                              ? CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      FadeInImage.assetNetwork(
                                    placeholder: 'assets/avatarplaceholder.png',
                                    image: url,
                                    width: 50,
                                    height: 50,
                                    fadeInDuration:
                                        const Duration(milliseconds: 500),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 500),
                                    fit: BoxFit.cover,
                                  ),
                                  imageUrl: widget.profilePic!,
                                  width: 50,
                                  height: 50,
                                  fadeInDuration:
                                      const Duration(milliseconds: 500),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 500),
                                  fit: BoxFit.cover,
                                  placeholderFadeInDuration:
                                      const Duration(milliseconds: 300),
                                )
                              : Image.asset(
                                  'assets/avatarplaceholder.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),
                  Expanded(
                    child: Row(
                      children: [
                        // First Column (aligned to the start)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username and Time
                            Text(
                              widget.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.darkblue,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Message
                            Text(
                              widget.cityname,
                              style: const TextStyle(
                                  color: ColorPalette.darkblue, fontSize: 12),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                        // Spacer between the columns
                        const Spacer(),
                        // Second Column (aligned to the end)
                        GestureDetector(
                          onTap: () {
                            showWeatherDialog(
                              context,
                              widget.cityname,
                              widget.condition,
                              widget.desc,
                              widget.feelslike,
                              widget.humidity,
                              widget.tempMax,
                              widget.tempMin,
                              widget.temp,
                              widget.windspeed,
                            );

                            // getWeatherAnimation(
                            //     widget.condition, DateTime.now());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: ColorPalette.darkblue, // Button color
                              borderRadius: BorderRadius.circular(
                                  8), // Button border radius
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Username and Time
                                Icon(
                                  Icons.wb_cloudy_sharp,
                                  color: Colors.white,
                                  size: 30, // Icon size
                                ),
                                Text(
                                  'Weather Info',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 10,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 5),
                                // Message
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // Image

              Text(
                widget.message,
                style: const TextStyle(color: ColorPalette.darkblue),
              ),
              const SizedBox(height: 10),
              // City Name
              if (widget.image != null &&
                  widget.image is String &&
                  Uri.parse(widget.image).isAbsolute)
                GestureDetector(
                  onTap: () {
                    // Show image preview
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color.fromRGBO(10, 61, 98, 1.0)
                            .withOpacity(
                                1), // Set background color of the AlertDialog
                        content: FittedBox(
                          fit: BoxFit.contain,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(50), // Rounded corners
                            child: Image.network(
                              widget.image,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/placeholder.png', // Placeholder image asset path
                              image: url,
                              width: MediaQuery.of(context).size.width -
                                  50, // Adjust width of image
                              fadeInDuration: const Duration(
                                  milliseconds:
                                      500), // Fixed typo: milliseconds
                              fadeOutDuration: const Duration(
                                  milliseconds:
                                      500), // Fixed typo: milliseconds
                              fit: BoxFit.cover,
                            ),
                            imageUrl: widget.image,
                            width: MediaQuery.of(context).size.width -
                                50, // Adjust width of image
                            fadeInDuration: const Duration(
                                milliseconds: 500), // Fixed typo: milliseconds
                            fadeOutDuration: const Duration(
                                milliseconds: 500), // Fixed typo: milliseconds
                            fit: BoxFit.cover,
                            fadeInCurve: Curves.easeInOut, // Fade in curve
                            fadeOutCurve: Curves.easeInOut, // Fade out curve
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 10),
              // Icon Buttons
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60), // Rounded corners
                  color: ColorPalette.blue.withOpacity(0.3),
                ),
                height: 1, // Adjust the height of the divider
              ),
              // const SizedBox(height: 10),
              const SizedBox(
                height: 8,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedTime,
                      style: const TextStyle(color: ColorPalette.darkblue),
                    ),
                    Row(
                      children: [
                        LikeButton(isLiked: isLiked, onTap: toggleLike),
                        const SizedBox(width: 5),
                        Text(
                          widget.likes.length.toString(),
                          style: const TextStyle(color: ColorPalette.darkblue),
                        ),
                        if (widget.email !=
                            currentUser
                                .email) // Check if it's not the current user's post
                          IconButton(
                            icon: const Icon(Icons.report_problem_rounded),
                            iconSize: 20,
                            color: ColorPalette.darkblue,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ReportDialog(
                                    postid: widget.postid,
                                    username: widget.username,
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommentButton(
                    onTap: showCommentDialog,
                  ),
                  Text(
                    'Comments',
                    style: TextStyle(
                        color: ColorPalette.darkblue.withOpacity(0.6)),
                  )
                ],
              ),
              const SizedBox(height: 10),

              Container(
                height: 170,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the value as needed
                  // Light blue-grey color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("User Posts")
                          .doc(widget.postid)
                          .collection("Comments")
                          .orderBy("CommentTime", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        // Show loading circle while data is loading
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        // Check if snapshot contains error
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        // Check if snapshot has data
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloudy_snowing,
                                  color: ColorPalette.darkblue,
                                  size: 50, // Adjust the size as needed
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "No comments found.",
                                  style:
                                      TextStyle(color: ColorPalette.darkblue),
                                ),
                              ],
                            ),
                          );
                        }
                        // Data has loaded, display comments
                        return Column(
                          children: [
                            LimitedBox(
                              child: ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: snapshot.data!.docs.map((doc) {
                                  final commentData =
                                      doc.data() as Map<String, dynamic>;
                                  // Check for null values and handle them
                                  final text = commentData["CommentText"] ?? "";
                                  final user = commentData["CommentedBy"] ?? "";
                                  final time = commentData["CommentTime"] ?? "";
                                  final useremail = commentData["Email"] ?? "";
                                  return UserComment(
                                    text: text.toString(),
                                    user: user.toString(),
                                    time: formatTimestamp(time),
                                    email: useremail,
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No More Comments To Show",
                                  style:
                                      TextStyle(color: ColorPalette.darkblue),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.no_accounts,
                                  color: ColorPalette.darkblue,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ReportDialog extends StatefulWidget {
  final String postid;
  final String username;
  ReportDialog({required this.postid, required this.username});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedOption;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorPalette.darkblue,
      title: Row(
        children: [
          Lottie.asset(
            'assets/warning.json', // Replace with your Lottie animation file path
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 10), // Adjust spacing as needed
          const Text(
            'Report User',
            style: TextStyle(color: ColorPalette.greyblue),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select a reason for reporting this user:",
              style: TextStyle(color: ColorPalette.greyblue),
            ),
            const SizedBox(
              height: 10,
            ),
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
            RadioListTile<String>(
              title: const Text('Misleading Content',
                  style: TextStyle(color: ColorPalette.greyblue)),
              value: 'Misleading Content',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors
                      .grey; // Change to the desired color for inactive radio button
                }
                return Colors.blue; // Use default color for active radio button
              }), // Set the background color of the tile
              // Set the color of the radio button
            ),
            RadioListTile<String>(
              title: const Text('Offensive Language',
                  style: TextStyle(color: ColorPalette.greyblue)),
              value: 'Offensive Language',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors
                      .grey; // Change to the desired color for inactive radio button
                }
                return Colors.blue; // Use default color for active radio button
              }),
            ),
            RadioListTile<String>(
              title: const Text('Spam or Advertising',
                  style: TextStyle(color: ColorPalette.greyblue)),
              value: 'Spam or Advertising',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors
                      .grey; // Change to the desired color for inactive radio button
                }
                return Colors.blue; // Use default color for active radio button
              }),
            ),
            RadioListTile<String>(
              title: const Text('False Informaton Sources',
                  style: TextStyle(color: ColorPalette.greyblue)),
              value: 'False Informaton Sources',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors
                      .grey; // Change to the desired color for inactive radio button
                }
                return Colors.blue; // Use default color for active radio button
              }),
            ),
            RadioListTile<String>(
              title: const Text('Violence or Threats',
                  style: TextStyle(color: ColorPalette.greyblue)),
              value: 'Violence or Threats',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors
                      .grey; // Change to the desired color for inactive radio button
                }
                return Colors.blue; // Use default color for active radio button
              }),
            ),
            RadioListTile<String>(
              title: const Text('Sexual Content',
                  style: TextStyle(color: ColorPalette.greyblue)),
              value: 'Sexual Content',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors
                      .grey; // Change to the desired color for inactive radio button
                }
                return Colors.blue; // Use default color for active radio button
              }),
            ),
            RadioListTile<String>(
              title: const Text('Improper Profile Picture',
                  style: TextStyle(color: ColorPalette.greyblue)),
              value: 'Improper Profile Picture',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors
                      .grey; // Change to the desired color for inactive radio button
                }
                return Colors.blue; // Use default color for active radio button
              }),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: ColorPalette.darkblue,
                backgroundColor: ColorPalette.greyblue, // Text color
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedOption!.isNotEmpty) {
                  fetchUserDataAndAddReportedUsersCollection(
                      context, widget.postid);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: ColorPalette.darkblue,
                backgroundColor: ColorPalette.greyblue, // Text color
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }

  void fetchUserDataAndAddReportedUsersCollection(
      BuildContext context, String postId) async {
    try {
      // Fetch the post document from the 'User Posts' collection
      DocumentSnapshot<Map<String, dynamic>> postSnapshot =
          await FirebaseFirestore.instance
              .collection('User Posts')
              .doc(postId)
              .get();
      Navigator.pop(context);
      if (postSnapshot.exists) {
        // Get user data from the post document
        Map<String, dynamic>? postData = postSnapshot.data();

        // Extract relevant user data
        String userName = postData?['UserName'];
        String userEmail = postData?['Email'];
        String userProfilePic = postData?['ProfilePic'];
        String userMessage = postData?['Message'];
        String postCategory = postData?['PostCategory'];
        String postImage = postData?['Image'];

        int currentReportCount = postData?['report_count'] ?? 0;

        int newReportCount = currentReportCount + 1;
        // Add reported users collection with post ID, user name, email, profile pic, message, post category, and image
        addReportedUsersCollection(postId, userName, userEmail, userProfilePic,
            userMessage, postCategory, postImage, newReportCount);

        showDialog(
          barrierColor: ColorPalette.darkblue,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.report,
                    color: Colors.red,
                  ),
                  SizedBox(
                      width: 8), // Add some spacing between the icon and text
                  Text(
                    'User Reported',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Your report for ${widget.username} has been submitted and will be reviewed by the Tropicool Administrators for  verfication. \n \nNote: Any false reporting committed by the users in the hub may violate the community guidelines.',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette
                        .darkblue, // Set the background color of the button here
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          15), // Optional: Add border radius
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                        color: Colors.white), // Set text color of the button
                  ),
                ),
              ],
            );
          },
          context: context,
        );
      } else {
        print('Post not found with ID: $postId');
      }
    } catch (e) {
      print(
          'Error fetching user data and adding reported users collection: $e');
    }
  }

  void addReportedUsersCollection(
      String postId,
      String userName,
      String userEmail,
      String userProfilePic,
      String userMessage,
      String postCategory,
      String postImage,
      int reportCount) async {
    // Reference to your Firestore database
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Reference to the new collection of reported users
      CollectionReference<Map<String, dynamic>> reportedUsersCollection =
          firestore.collection('reported_users');

      // Update the document instead of setting it to avoid overwriting existing fields
      await reportedUsersCollection.doc(postId).set(
          {
            'user_name': userName,
            'user_email': userEmail,
            'user_profile_pic': userProfilePic,
            'user_message': userMessage,
            'post_category': postCategory,
            'post_image': postImage,
            'report_date': DateTime.now(),
            'reason': FieldValue.arrayUnion([selectedOption.toString()]),
            'report_count': FieldValue.increment(1),
            'reporters': FieldValue.arrayUnion([
              currentUser.email.toString()
            ]), // Add the reported email to the array
            // Add more fields as needed
          },
          SetOptions(
              merge:
                  true)); // Use merge option to avoid overwriting existing data

      // Print message indicating that the reported users collection was added successfully
      print('Reported users collection added successfully!');
    } catch (e) {
      // If an error occurs, handle it here
      print('Error adding reported users collection: $e');
    }
  }
}
