import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proj/colors.dart';
import 'package:proj/component/text_box.dart';
import 'package:proj/utils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _imageUrl;

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  Uint8List? _image;

  Future<void> getUserPicture(String email) async {
    final storeImage = StoreImage();
    final imageUrl = await storeImage.getUserProfilePictureUrl(email);
    if (imageUrl != null) {
      setState(() {
        _imageUrl = imageUrl; // Store the fetched image URL
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Call the function to fetch the user's profile picture URL
    getUserPicture(currentUser.email!);
  }

  Future<void> updateField(String field, String newValue) async {
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  // edit field
  Future<void> editName(String field) async {
    String newValue = "";
    int maxLength = 12;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    size: MediaQuery.of(context).size.width * 0.1,
                  ), // Add the desired icon here
                  const SizedBox(width: 2), // A
                  Text(
                    "Edit $field",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              content: TextField(
                  autofocus: true,
                  maxLength: maxLength, // Set the maximum length
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter new $field",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ColorPalette
                              .darkblue), // Customize the border color here
                      borderRadius: BorderRadius.circular(
                          8.0), // Add border radius if needed
                    ),
                  ),
                  onChanged: (value) {
                    newValue = value;
                  }),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.darkblue,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 3), // Add some spacing between buttons
                ElevatedButton(
                  onPressed: () {
                    updateField(field, newValue);
                    Navigator.of(context).pop(newValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.darkblue,
                  ),
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ));
  }

  // edit field
  Future<void> editBio(String field) async {
    String newValue = "";
    int maxLength = 100;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    size: MediaQuery.of(context).size.width * 0.1,
                  ), // Add the desired icon here
                  const SizedBox(width: 2), // A
                  Text(
                    "Edit $field",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              content: TextField(
                  autofocus: true,
                  maxLength: maxLength, // Set the maximum length
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter new $field",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ColorPalette
                              .darkblue), // Customize the border color here
                      borderRadius: BorderRadius.circular(
                          8.0), // Add border radius if needed
                    ),
                  ),
                  onChanged: (value) {
                    newValue = value;
                  }),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.darkblue,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 3), // Add some spacing between buttons
                ElevatedButton(
                  onPressed: () {
                    updateField(field, newValue);
                    Navigator.of(context).pop(newValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.darkblue,
                  ),
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ));
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    File? _imageFile;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentUserEmail = currentUser.email;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Center the contents horizontally
          children: [
            Icon(Icons.person), // Add the desired icon here
            SizedBox(
                width: 10), // Add some spacing between the icon and the text
            Text("Profile"), // Add the text here
          ],
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(10, 61, 98, 1.0),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 25, top: 25),
                  child: Text('My Avatar',
                      style: TextStyle(
                          color: ColorPalette.darkblue,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 25,
                ),
                // Get the screen size
                Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundColor: const Color.fromRGBO(10, 61, 98, 1.0),
                        backgroundImage: _image != null
                            ? MemoryImage(_image!) as ImageProvider<Object>
                            : _imageUrl != null && _imageUrl!.isNotEmpty
                                ? NetworkImage(
                                    _imageUrl!) // Use fetched image URL
                                : const AssetImage(
                                        'assets/avatarplaceholder.png')
                                    as ImageProvider<Object>,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.white, size: 36),
                            onPressed: () async {
                              // Show the alert dialog immediately when the button is pressed
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    title: Text('Updating Image'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Set the column size to minimize
                                      children: [
                                        Text(
                                            'Please wait while the image is being uploaded...'),
                                        SizedBox(
                                            height:
                                                16), // Add some space between text and loading indicator
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Colors
                                                  .blue), // Set the value color to blue
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              final bytes =
                                  await pickImage(ImageSource.camera);
                              if (bytes != null) {
                                setState(() {
                                  _image = bytes;
                                });
                                // Upload the image to Firebase Storage
                                final storeImage = StoreImage();
                                final imageUrl =
                                    await storeImage.uploadImageToStorage(bytes,
                                        'profile_images/${DateTime.now().millisecondsSinceEpoch}');
                                if (imageUrl != null) {
                                  // Add the image URL to Firestore
                                  await storeImage.addImageUrlToFirestore(
                                      currentUserEmail!, imageUrl);
                                }
                              }

                              // After upload, dismiss the dialog
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),
                // user email
                Text(currentUser.email!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: ColorPalette.darkblue)),

                const SizedBox(
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text('My Details',
                      style: TextStyle(
                          color: ColorPalette.darkblue,
                          fontWeight: FontWeight.bold)),
                ),

                MyTextBox(
                  text: userData['username'],
                  sectionName: 'Username',
                  onPressed: () => editName('username'),
                ),
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'Bio',
                  onPressed: () => editBio('bio'),
                ),

                const SizedBox(
                  height: 50,
                ),
                //posts
                const Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text('My Posts',
                      style: TextStyle(
                          color: ColorPalette.darkblue,
                          fontWeight: FontWeight.bold)),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .where("Email", isEqualTo: currentUserEmail)
                      .orderBy("TimeStamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.data == null ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No posts available'),
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.docs.map((doc) {
                          var post = doc.data() as Map<String, dynamic>;
                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(
                                            0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                post['PostCategory'] ?? '',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    color:
                                                        ColorPalette.darkblue),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              // Show a confirmation dialog before deleting the post
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                            size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.07,
                                                          ),
                                                          onPressed: () {},
                                                        ),
                                                        Text(
                                                          "Delete Post?",
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.05, fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    content: const Text(
                                                        "Are you sure you want to delete this post?"),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          // Dismiss the dialog
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              ColorPalette
                                                                  .darkblue,
                                                        ),
                                                        child: const Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          // Get the reference to the document you want to delete
                                                          DocumentReference
                                                              postRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "User Posts")
                                                                  .doc(doc
                                                                      .id); // Assuming doc.id is the ID of the post document
                                                          // Delete the post document from Firestore
                                                          postRef
                                                              .delete()
                                                              .then((value) =>
                                                                  print(
                                                                      "Post deleted successfully"))
                                                              .catchError(
                                                                  (error) => print(
                                                                      "Failed to delete post: $error"));
                                                          // Dismiss the dialog
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              ColorPalette
                                                                  .darkblue,
                                                        ),
                                                        child: const Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        post['Message'] ?? '',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      if (post.containsKey('Image') &&
                                          post['Image'] != null &&
                                          post['Image'].isNotEmpty)
                                        CachedNetworkImage(
                                          imageUrl: post['Image'],
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) =>
                                              const LinearProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    ColorPalette.darkblue),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Adjust the border radius as needed
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 8.0),
                                       Text(
                                        post['CityName'],
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMMd('en_US')
                                            .add_jm()
                                            .format(post['TimeStamp'].toDate()),
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    }
                  },
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
