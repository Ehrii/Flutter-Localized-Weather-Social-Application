import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:proj/colors.dart';
import 'package:proj/component/button.dart';

class SignUpScreen extends StatefulWidget {
  final Function()? onTap;
  const SignUpScreen({super.key, required this.onTap});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void signUp(BuildContext context) async {
    // Show the loading dialog
    showDialog(
      barrierDismissible: false, // Prevent user from dismissing the dialog
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Creating Account..."),
            const SizedBox(height: 20),
            // Add your Lottie animation here
            Lottie.asset(
              'assets/loader.json', // Replace with your Lottie animation asset path
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.darkblue),
            ),
          ],
        ),
      ),
    );

    // Add a delay to close the dialog after a certain time (e.g., 3 seconds)
    await Future.delayed(const Duration(seconds: 5));
    FocusScope.of(context).unfocus();

    // Close the dialog
    Navigator.pop(context);

    // Simulate sign-up process (replace with your actual sign-up logic)
    try {
      bool isValidEmail(String email) {
        // Define allowed email domains
        List<String> allowedDomains = ['gmail.com', 'yahoo.com'];

        // Check email format
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          return false;
        }
        // Extract domain from email
        String domain = email.split('@')[1];
        // Check if domain is allowed
        return allowedDomains.contains(domain);
      }

      bool isStrongPassword(String password) {
        return password.length >= 8 &&
            RegExp(r'[A-Za-z]').hasMatch(password) &&
            RegExp(r'\d').hasMatch(password) &&
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      }

      // Check if passwords match
      if (password.text != confirmPassword.text) {
        throw Exception("Passwords don't match");
      }

      // Check if email is valid
      if (!isValidEmail(email.text)) {
        throw Exception("Invalid email format");
      }

      // Check if password meets minimum strength requirements
      if (!isStrongPassword(password.text)) {
        throw Exception(
            "Password must be at least 8 characters long and contain letters, numbers, and special characters");
      }

      // Attempt to create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text);

      // If user creation is successful, add user data to Firestore
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': email.text.split('@')[0],
        'email': email.text,
        'bio': 'Empty Bio..'
      });

      // Reset focus and display success message
      FocusScope.of(context).unfocus();
      displayMessage("Sign-up successful");
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      FocusScope.of(context).unfocus();
      displayMessage(e.code);
    } on Exception catch (e) {
      // Handle other exceptions
      FocusScope.of(context).unfocus();
      displayMessage(e.toString());
    }
  }

  void displayMessage(String message) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue[100],
        title: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: ColorPalette.darkblue,
            ),
            SizedBox(width: screenWidth * 0.01), // Adjust spacing here
            Text(
              'Sign-Up Error',
              style: TextStyle(
                  color: ColorPalette.darkblue,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold // Adjust font size here
                  ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.blue[900],
            fontSize: screenWidth * 0.04, // Adjust font size here
          ),
        ),
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
                borderRadius:
                    BorderRadius.circular(10), // Rounded corners for the button
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
  }

  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //SingleChildScrollView
      body: Stack(
        children: [
          Opacity(
            opacity: 0.95,
            child: Image.asset(
              'assets/signupbg.png', // Replace with your background image asset
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/SignUp.png",
                        fit: BoxFit.contain,
                      ),
                      const ListTile(
                        title: Text(
                          "Register New Account",
                          style: TextStyle(
                              fontSize: 27, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Join us and be a member of the Tropicool Community.",
                          style: TextStyle(
                              fontSize:
                                  13), // You can customize the style as needed
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.withOpacity(.7)),
                        child: TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Email is required";
                            } else if (!value.contains('@gmail.com') &&
                                !value.contains('@yahoo.com')) {
                              return "Only Gmail and Yahoo emails are allowed";
                            }
                            return null;
                          },
                          style: const TextStyle(
                              color: Colors.white), // Text color when typing
                          cursorColor: Colors.white, // Cursor color when typing
                          decoration: InputDecoration(
                              icon: Icon(Icons.email),
                              iconColor: Colors.white,
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7))),
                        ),
                      ),

                      //Password field
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.withOpacity(.7)),
                        child: TextFormField(
                          controller: password,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Password is required";
                            }
                            return null;
                          },
                          style: const TextStyle(
                              color: Colors.white), // Text color when typing
                          cursorColor: Colors.white, // Cursor color when typing
                          obscureText: !isVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            iconColor: Colors.white,
                            border: InputBorder.none,
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                            hintText: "Password",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisible = !isVisible;
                                  });
                                },
                                icon: Icon(
                                  isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ),
                      //Confirm Password Field
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.withOpacity(.7)),
                        child: TextFormField(
                          controller: confirmPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Password is required";
                            } else if (password.text != confirmPassword.text) {
                              return "Passwords don't match";
                            }
                            return null;
                          },
                          style: const TextStyle(
                              color: Colors.white), // Text color when typing
                          cursorColor: Colors.white, // Cursor color when typing
                          obscureText: !isVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            iconColor: Colors.white,
                            border: InputBorder.none,
                            hintText: " Confirm Password",
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  //click to show
                                  setState(() {
                                    //toggle button
                                    isVisible = !isVisible;
                                  });
                                },
                                icon: Icon(
                                  isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      MyButton(
                        onTap: () => signUp(context),
                        text: 'SIGN-UP',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              'Login Now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
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
