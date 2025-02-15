import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:proj/colors.dart';
import 'package:proj/signup_screen.dart';
import 'package:proj/component/button.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Text editing controller to control the text
  final email = TextEditingController();
  final password = TextEditingController();

  //Boolean variable for showing and hiding password
  bool isVisible = false;
  void signIn(BuildContext context) async {
    showDialog(
      barrierDismissible: false, // Prevent user from dismissing the dialog
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Signing in..."),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      // Close the dialog only after successful login
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      displayMessage(context, e.code);
    }
  }

  void displayMessage(BuildContext context, String message) {
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
              'Login Error',
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

  //Global Key of the form
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.95,
            child: Image.asset(
              'assets/loginbg.png', // Replace with your background image asset
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                //Putting the textfield in the form
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      //Email field
                      Image.asset(
                        "assets/Tropicool.png",
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
                            }
                            return null;
                          },
                          style: const TextStyle(
                              color: Colors.white), // Text color when typing
                          cursorColor: Colors.white, // Cursor color when typing
                          decoration: InputDecoration(
                              icon: const Icon(Icons.email),
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                              iconColor: Colors.white),
                        ),
                      ),

                      //Password field
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.withOpacity(0.7)),
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
                          cursorColor: Colors.white, // Cursor
                          obscureText: !isVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            iconColor: Colors.white,
                            border: InputBorder.none,
                            hintText: "Password",
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
                                  color: Colors.white, // Change icon color here
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyButton(onTap: () => signIn(context), text: 'LOG-IN'),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              'Register Now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          )
                        ],
                      )
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
