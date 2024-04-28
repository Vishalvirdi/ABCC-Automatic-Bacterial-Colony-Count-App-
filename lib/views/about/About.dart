import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About us")),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      """This app is Automatic Microbial Colony Count Android Application. This application has been successfully developed by a team of developers named Kapil Kumar, Vishal Chandral and Vishal Virdi final year students of Indian Institute of Information Technology, Una (Himachal Pradesh) under the guidance of Miss Prachi Arora as our supervisor (faculty of IIITUNA).

This application will count bacterial colonies just within seconds just by selecting and uploading the image to the api then this image will be processed and then give the counts as the result.

This application used flask as api provider. On api we have used image processing algorithm of python in order to count the number of colonies. 

Our application is developed using Flutter as a UI framework of Dart Language and Firebase(backend) as a server there we are storing processed image processed by authenticated users and It has Google authentication enabled using Firebase as a database.
                      """,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          fontSize: 17, letterSpacing: .5, height: 1.5),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blue.shade200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                          "\u00a9 Copyright ${DateTime.now().year} - ${DateTime.now().year + 1}"),
                    ),
                    const Text("Designed & Developed by KV²C² (IITUNA)")
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
