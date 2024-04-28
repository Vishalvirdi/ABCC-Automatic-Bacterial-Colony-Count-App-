import 'dart:async';

import 'package:bccapp/helper/helper_function.dart';
import 'package:bccapp/views/auth/singIn.dart';
import 'package:bccapp/views/landingPages/DashBoard.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isSignedIn = false;
  getMainScreen() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
    Timer(const Duration(seconds: 2), () async {
      _isSignedIn
          ? Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashBoard()),
              (route) => false)
          : Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
              (route) => false);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getMainScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.blue.shade200,
          child: Column(
            children: [
              Image.asset(
                "assets/s1.png",
                height: MediaQuery.of(context).size.height / 2.5,
              ),
              Image.asset(
                "assets/s2.png",
                height: MediaQuery.of(context).size.height / 2.5,
              ),
              Text(
                "Loading...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "KV²C²",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              )
            ],
          )),
    );
  }
}
