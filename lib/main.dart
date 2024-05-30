import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proj/auth/auth.dart';
import 'package:proj/controller/dependency_injection.dart';
import 'package:proj/services/weatherservices.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await WeatherService.promptLocationService(); 
  DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const AuthPage(),
      
    );
    
  }
}




