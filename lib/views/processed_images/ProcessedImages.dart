import 'dart:convert';
import 'dart:io';

import 'package:bccapp/views/landingPages/DashBoard.dart';
import 'package:bccapp/views/processed_images/showProcessedImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ProcessedImagesScreen extends StatefulWidget {
  final String uid;
  const ProcessedImagesScreen({super.key, required this.uid});

  @override
  State<ProcessedImagesScreen> createState() => _ProcessedImagesScreenState();
}

class _ProcessedImagesScreenState extends State<ProcessedImagesScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _collectionStream;

  final CollectionReference processedColoniesReference =
      FirebaseFirestore.instance.collection("ProcessedColonies");

  Future<void> saveImage(String imgCode) async {
    try {
      final bytes = base64Decode(imgCode);
      final directory = (await getApplicationDocumentsDirectory()).path;
      final filename =
          DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
      final path = "$directory/$filename";
      final file = File(path);
      await file.writeAsBytes(bytes);
    } catch (error) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _collectionStream = FirebaseFirestore.instance
        .collection('ProcessedColonies')
        .where("uid", isEqualTo: widget.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Processed Images")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _collectionStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.docs.length == 0) {
              return Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 15, backgroundColor: Colors.lightBlueAccent),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => DashBoard()),
                          (route) => false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No image processed yet!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, // Adjust width as needed
                    childAspectRatio: 3 / 4, // Adjust aspect ratio as needed
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowProcessedImage(
                                      count: snapshot.data!.docs[index]
                                          ['colonies'],
                                      imageCode: snapshot.data!.docs[index]
                                          ['processed_image']),
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                boxShadow: [BoxShadow(blurRadius: 10)],
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.width / 3,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.memory(
                                    base64Decode(snapshot.data!.docs[index]
                                        ['processed_image']),
                                    height:
                                        MediaQuery.of(context).size.width / 4,
                                  ),
                                ),
                                Text(
                                  "Colony Count " +
                                      snapshot.data!.docs[index]['colonies']
                                          .toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                        Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return showDialogBox(
                                              snapshot.data!.docs[index].id);
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.delete)),
                                // IconButton(
                                //     onPressed: () {
                                //       saveImage(
                                //         snapshot.data!.docs[index]
                                //             ['processed_image'],
                                //       );
                                //     },
                                //     icon: Icon(Icons.download)),
                              ],
                            ))
                      ],
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }

  showDialogBox(String id) {
    return AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to Delete?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("No")),
        ElevatedButton(
            onPressed: () async {
              try {
                await processedColoniesReference.doc(id).delete();
                Navigator.of(context).pop(false);
              } catch (e) {
                print(e);
              }
            },
            child: Text("Yes")),
      ],
    );
  }
}
