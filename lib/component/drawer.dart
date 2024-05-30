import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj/colors.dart';
import 'package:proj/component/my_list_tile.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onCommunityTap;
  final void Function()? onNewsTap;
  final void Function()? onProfileTap;
  final void Function()? onSignOutTap;
 final void Function()? onAboutTap;

  const MyDrawer({
    Key? key,
    this.onCommunityTap,
    this.onNewsTap,
    this.onProfileTap,
    this.onSignOutTap,
    this.onAboutTap,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  String? profilePic;

  @override
  void initState() {
    super.initState();
    getProfilePic(userEmail);
  }

  Future<void> getProfilePic(String userEmail) async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final fetchedProfilePic = userData['imageUrl'];
        setState(() {
          profilePic = fetchedProfilePic;
        });
      } else {
        setState(() {
          profilePic = null;
        });
      }
    } catch (error) {
      print('Error fetching user profile pic: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorPalette.darkblue,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220, // Adjust the height as needed
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(
                      'assets/morning.gif'), // Replace with your image path
                  fit: BoxFit.cover, // Adjust the fit as needed
                  colorFilter: ColorFilter.mode(
                    ColorPalette.darkblue.withOpacity(
                        0.6), // Set your desired background color with opacity
                    BlendMode.srcATop, // Adjust the blend mode as needed
                  ),
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Stack(
                            children: [
                              if (profilePic != null && profilePic!.isNotEmpty)
                                CachedNetworkImage(
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  imageUrl: profilePic!,
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // Adjust the percentage as needed
                                  height: MediaQuery.of(context).size.width *
                                      0.5, // Adjust the percentage as needed
                                  fadeInDuration:
                                      const Duration(milliseconds: 500),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 500),
                                  fit: BoxFit.cover,
                                )
                              else
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              if (profilePic == null || profilePic!.isEmpty)
                                Center(
                                  child: Image.asset(
                                    'assets/avatarplaceholder.png',
                                    width: MediaQuery.of(context).size.width *
                                        0.5, // Adjust the percentage as needed
                                    height: MediaQuery.of(context).size.width *
                                        0.5, // Adjust the percentage as needed
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the contents horizontally

                        children: [
                          Icon(
                            Icons.wb_sunny, // Choose the appropriate icon
                            color: ColorPalette.greyblue,
                          ),
                          SizedBox(
                              width:
                                  5), // Add some spacing between the icon and text
                          Text(
                            'Welcome To TropiCool ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.greyblue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Email : ${currentUser!.email!}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15), // Add spacing between header and menu items
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home
                MyListTile(
                  icon: Icons.home,
                  text: 'H O M E',
                  onTap: () => Navigator.pop(context),
                ),

                // Community
                MyListTile(
                  icon: Icons.people,
                  text: 'C O M M U N I T Y',
                  onTap: widget.onCommunityTap, // Invoke the function here
                ),

                // News
                MyListTile(
                  icon: Icons.newspaper,
                  text: 'N E W S',
                  onTap: widget.onNewsTap, // Invoke the function here
                ),

                // Profile
                MyListTile(
                  icon: Icons.person,
                  text: 'P R O F I L E',
                  onTap: widget.onProfileTap, // Invoke the function here
                ),

                 MyListTile(
                  icon: Icons.info_rounded,
                  text: 'A B O U T',
                  onTap: widget.onAboutTap, // Invoke the function here
                ),
              ],
            ),
            // Sign Out
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2),
              child: MyListTile(
                icon: Icons.logout,
                text: 'S I G N - O U T',
                onTap: widget.onSignOutTap, // Invoke the function here
              ),
            )
          ],
        ),
      ),
    );
  }
}
