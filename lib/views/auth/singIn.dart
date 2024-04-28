import 'package:bccapp/helper/helper_function.dart';
import 'package:bccapp/views/auth/googleAuthService.dart';
import 'package:bccapp/views/landingPages/DashBoard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  Future handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });
    await signInWithGoogle().then((value) async {
      if (value == true) {
        final user = FirebaseAuth.instance.currentUser;
        await HelperFunctions.saveUserLoggedInStatus(true);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashBoard()),
            (route) => false);
      } else {
        // openSnackbar(context, value, primaryColor);
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign In with Google!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 20, backgroundColor: Colors.lightBlueAccent),
                  onPressed: () {
                    handleGoogleSignIn();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/goog.png",
                        height: 22,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Google",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
