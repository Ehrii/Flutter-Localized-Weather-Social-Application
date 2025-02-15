import "package:flutter/material.dart";
import "package:introduction_screen/introduction_screen.dart";
import 'package:proj/login_screen.dart';
import "package:proj/auth/login_or_register.dart";
import "package:proj/desc.dart";

class IntroScreen extends StatelessWidget {
  IntroScreen({super.key});

  final List<PageViewModel> pages = [
    PageViewModel(
      title: 'Welcome to TropiCool',
      body: desc1,
      useScrollView: true,
      footer: Align(
        alignment: Alignment.center,
        child: Container(
          width: 150,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets
                  .zero, // Remove padding to make the button size determined by its child
              backgroundColor: Colors.blue,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(
                    width: 5), // Adjust the spacing between the icon and text
                Text(
                  "Let's Go",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      image: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 0), // Adjust padding as needed
          child: Image.asset(
            'assets/1.gif',
            //  width: 250, // Increase width to make the image larger
            //  height:250, // Increase height to make the image larger
            fit: BoxFit.contain,
          ),
        ),
      ),
      decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 27.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.blue,
          ),
          pageMargin: EdgeInsets.all(15),
          imagePadding: EdgeInsets.only(bottom: 0),
          imageFlex: 1,
          bodyFlex: 1,
          contentMargin: EdgeInsets.only(bottom: 0)),
    ),
    PageViewModel(
      title: 'Connect and Share',
      body: desc2,
      useScrollView: true,
      footer: Align(
        alignment: Alignment.center,
        child: Container(
          width: 150,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets
                  .zero, // Remove padding to make the button size determined by its child
              backgroundColor: Colors.blue,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(
                    width: 5), // Adjust the spacing between the icon and text
                Text(
                  "Let's Go",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      image: Center(
        child: Image.asset(
          'assets/2.gif',
          // width: 260,
          // height: 260,
          //width: 225, // Increase width to make the image larger
          //height: 225, // Increase height to make the image larger
          fit: BoxFit.contain,
        ),
      ),
      decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 27.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.blue,
          ),
          pageMargin: EdgeInsets.all(20),
          imagePadding: EdgeInsets.only(bottom: 0),
          imageFlex: 1,
          bodyFlex: 1,
          contentMargin: EdgeInsets.only(bottom: 0)),
    ),
    PageViewModel(
      title: 'Your Journey Begins Here ',
      body: desc3,
      useScrollView: true,
      footer: Align(
        alignment: Alignment.center,
        child: Container(
          width: 150,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets
                  .zero, 
              backgroundColor: Colors.blue,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(
                    width: 5), 
                Text(
                  "Let's Go",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      image: Center(
        child: Image.asset(
          'assets/3.gif',
          // width: 240, // Increase width to make the image larger
          // height: 240, // Increase height to make the image larger
          fit: BoxFit.contain,
        ),
      ),
      decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 27.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.blue,
          ),
          pageMargin: EdgeInsets.all(15),
          imagePadding: EdgeInsets.only(bottom: 0),
          imageFlex: 1,
          bodyFlex: 1,
          contentMargin: EdgeInsets.only(bottom: 0)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                width: 15), // Adjust spacing between text and icon as needed
            Icon(
              Icons.cloud_done_sharp, // Change the icon as needed
              color: Colors.white, // Change the icon color if needed
            ),
            Text(
              '  GETTING STARTED',
              style: TextStyle(
                color: Color.fromARGB(237, 255, 255, 255),
                fontSize: 20.0,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        centerTitle:
            true, // Center the entire AppBar title including text and icon
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      // body: Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 15),
      //   child:
      // ));
      body: Container(
          margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          child: IntroductionScreen(
            pages: pages,
            dotsDecorator: const DotsDecorator(
              size: Size(15, 15),
              color: Colors.blueGrey,
              activeSize: Size.square(20),
              activeColor: Colors.blue,
            ),
            showDoneButton: true,
            done: const Text(
              'Done',
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
            showSkipButton: true,
            skip: const Text(
              'Skip',
              style: TextStyle(fontSize: 20, color: Colors.blueAccent),
            ),
            showNextButton: true,
            next: const Icon(
              Icons.arrow_forward,
              color: Colors.blue,
              size: 25,
            ),
            onDone: () => onDone(context),
            curve: Curves.bounceOut,
          )),
    );
  }


void onDone(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.lightBlue), // Adjust color as needed
            ),
            SizedBox(height: 8), // Add space
          ],
        ),
      );
    },
  );

  // Simulate some delay to mimic loading
  Future.delayed(const Duration(milliseconds: 500), () {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginOrRegister(),
        transitionsBuilder: (_, animation, __, child) {
          const curve = Curves.easeInOut;
          var curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );
        },
      ),
    );
  });
}


}
