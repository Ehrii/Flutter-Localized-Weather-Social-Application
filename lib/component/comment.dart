import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:proj/colors.dart';
import 'package:proj/component/wall.dart';

class UserComment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  final String email; // New field for post ID

  const UserComment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
    required this.email, // New field for post ID
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.mediumdarkblue
            .withOpacity(0.2), // Light blue-grey color
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      margin: const EdgeInsets.only(bottom: 10), // Add bottom margin
      padding: const EdgeInsets.all(15), // Add padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment text
          Text(
            text,
            style: const TextStyle(
              fontSize: 16, // Increase font size
              color: ColorPalette.darkblue, // Dark text color
              fontWeight: FontWeight.w500, // Medium font weight
            ),
          ),
          // User and Time
          const SizedBox(
              height: 8), // Add space between comment text and user/time
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: currentUser.email !=
                          email // Check if current user is not the same as the specified email
                      ? () => _showUserDialog(
                          context, email, text) // If true, set onTap to show dialog
                      : null, // If false, set onTap to null (non-interactive)
                  child: Text(
                    user,
                    style: const TextStyle(
                      color: ColorPalette.blue, // User text color
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Bold font weight
                    ),
                  ),
                ),
                const SizedBox(width: 4), // Add space between user and dot
                const Text(
                  " • ",
                  style: TextStyle(
                      color: ColorPalette.darkblue, fontSize: 12 // Dot color
                      ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                      color: ColorPalette.darkblue,
                      fontSize: 12 // Time text color
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showUserDialog(BuildContext context, String email, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return UserProfileDialog(
          email: email, text: text,); // Use the custom dialog to fetch and display user data
    },
  );
}

class UserProfileDialog extends StatelessWidget {
  final String email;
  final String text;

  const UserProfileDialog({required this.email, required this.text});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("Users").doc(email).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                  ColorPalette.greyblue), // Set the desired color
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return AlertDialog(
            title: const Text("User Profile"),
            content: const Text("Failed to fetch user data."),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl =
            userData["imageUrl"] ?? ""; // Get image URL from user data
        final userName =
            userData["username"] ?? "Unknown User"; // Get user name
        final bio = userData["bio"] ?? "";
        final email = userData["email"] ?? "";
        return AlertDialog(
          backgroundColor: ColorPalette.darkblue,
          title: const Row(
            children: [
              Icon(
                Icons.account_circle, // Add your desired icon
                color: ColorPalette.greyblue, // Icon color
              ),
              SizedBox(width: 8), // Add some spacing between the icon and text
              Text(
                'User Profile',
                style: TextStyle(color: ColorPalette.greyblue),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/placeholder.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Image.asset(
                    "assets/placeholder.png", // Use placeholder if the image URL is empty
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 10),
                const Text(
                  "Username",
                  style: TextStyle(
                      color: ColorPalette.greyblue,
                      fontWeight: FontWeight.bold),
                ), // Display the user's
                Text("$userName",
                    style: const TextStyle(
                        color:
                            ColorPalette.greyblue)), // Display the user's name
                const SizedBox(height: 20),
                const Text("User Bio",
                    style: TextStyle(
                        color: ColorPalette.greyblue,
                        fontWeight:
                            FontWeight.bold)), // Display the user's name
                Text("$bio",
                    style: const TextStyle(
                        color:
                            ColorPalette.greyblue)), // Display the user's name
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ReportDialog(
                          message: text,
                          username: userName,
                          email: email,
                          onReport: (email, reason) {},
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Button border radius
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
                    backgroundColor: Colors.grey, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Button border radius
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
}

// Reusable widget for reporting a user
class ReportDialog extends StatefulWidget {
  final String email; // Email of the user being reported
  final String username;
  final String message;
  final Function(String email, String reason)
      onReport; // Callback for handling report submission

  const ReportDialog({
    Key? key,
    required this.email,
    required this.message,
    required this.username,
    required this.onReport,
  }) : super(key: key);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason; // Store the selected reason for reporting

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorPalette.darkblue,
      title: Row(children: [
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
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select a reason for reporting this user:",
            style: TextStyle(color: ColorPalette.greyblue),
          ),
          RadioListTile<String>(
            title: const Text('Offensive Language',
                style: TextStyle(color: ColorPalette.greyblue)),
            value: 'Offensive Language',
            groupValue: selectedReason,
            onChanged: (value) {
              setState(() {
                selectedReason = value;
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
            title: const Text('Spam or Advertising',
                style: TextStyle(color: ColorPalette.greyblue)),
            value: 'Spam or Advertising',
            groupValue: selectedReason,
            onChanged: (value) {
              setState(() {
                selectedReason = value;
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
            groupValue: selectedReason,
            onChanged: (value) {
              setState(() {
                selectedReason = value;
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
            title: const Text('Harrassment',
                style: TextStyle(color: ColorPalette.greyblue)),
            value: 'Harassment',
            groupValue: selectedReason,
            onChanged: (value) {
              setState(() {
                selectedReason = value;
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
            groupValue: selectedReason,
            onChanged: (value) {
              setState(() {
                selectedReason = value;
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
                if (selectedReason != null) {
                  widget.onReport(
                      widget.email, selectedReason!); // Submit report
                  addReport(widget.email, selectedReason!, widget.message);
                  Navigator.of(context)
                      .pop(); // Close the dialog after submitting

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
                                width:
                                    8), // Add some spacing between the icon and text
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
                          'Your report for ${widget.username} has been submitted and will be reviewed by the Tropicool Administrators for verfication. \n \nNote: Any false reporting committed by the users in the hub may violate the community guidelines.',
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
                                  color: Colors
                                      .white), // Set text color of the button
                            ),
                          ),
                        ],
                      );
                    },
                    context: context,
                  );
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
}

void addReport(String email, String reason, String message) {
  FirebaseFirestore.instance.collection("Reportedusers_comment").add({
    "email": email,
    "reason": reason,
    "comment": message,
    "reportTime": Timestamp.now(),
    "reportedBy":
        FirebaseAuth.instance.currentUser?.email, // Current user's email
  });
}
