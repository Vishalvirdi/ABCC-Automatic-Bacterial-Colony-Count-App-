import 'dart:convert';
import 'package:flutter/material.dart';

class ShowProcessedImage extends StatefulWidget {
  final String imageCode;
  final int count;
  const ShowProcessedImage(
      {super.key, required this.count, required this.imageCode});

  @override
  State<ShowProcessedImage> createState() => _ShowProcessedImageState();
}

class _ShowProcessedImageState extends State<ShowProcessedImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Full View")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Processed Image",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue.shade200),
                      height: 450,
                      child: Image.memory(
                        base64Decode(widget.imageCode),
                        height: 425,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: Text(
                      "Colony count  " + widget.count.toString(),
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    )),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Gray Scale Image",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 450,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue.shade200),
                      width: MediaQuery.of(context).size.width,
                      child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(<double>[
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0
                          ]),
                          child: Image.memory(
                            base64Decode(widget.imageCode),
                            height: 425,
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: Text(
                      "Colony count  " + widget.count.toString(),
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
