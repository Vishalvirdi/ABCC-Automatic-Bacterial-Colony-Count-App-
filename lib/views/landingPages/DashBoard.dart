import 'dart:io';
import 'package:bccapp/views/auth/googleAuthService.dart';
import 'package:bccapp/views/auth/singIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:bccapp/views/about/About.dart';
import 'package:bccapp/views/processed_images/ProcessedImages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:star_menu/star_menu.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool isProcessing = false;
  bool enableUpload = false;
  final CollectionReference processedColoniesReference =
      FirebaseFirestore.instance.collection("ProcessedColonies");
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  File? _imageFile;
  String _apiUrl =
      'https://project-phase.vercel.app/'; // Replace with your actual Vercel API URL
  String _uploadMessage = '';
  dynamic responseData;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    picker
        .pickImage(
            source:
                selectedIndex == 1 ? ImageSource.camera : ImageSource.gallery)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
    setState(() {
      selectedIndex = 0;
      enableUpload = true;
    });
  }

  Future<void> _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      cropStyle: CropStyle.circle,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );
    if (croppedFile != null) {
      imageCache.clear();
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  int selectedIndex = 0;

  Future<void> _uploadImage() async {
    setState(() {
      isProcessing = true;
      enableUpload = false;
    });
    if (_imageFile == null) {
      setState(() {
        _uploadMessage = 'Please select an image first.';
      });
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
    request.files
        .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          responseData = data;
          saveDataToFirebase();
          _uploadMessage = 'Image uploaded successfully!';
        });
      } else {
        setState(() {
          _uploadMessage =
              'Error uploading image. Status code: ${response.statusCode}';
        });
      }
      setState(() {
        isProcessing = false;
      });
    } on SocketException catch (e) {
      print('Error: Socket exception: $e');
      setState(() {
        _uploadMessage = 'Connection error: Failed to connect to API.';
        isProcessing = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _uploadMessage = 'An unexpected error occurred.';
        isProcessing = false;
      });
    }
  }

  final backgroundStarMenuController = StarMenuController();

  final otherEntries = <Widget>[
    Container(
      height: 60,
      width: 120,
    ),
    Chip(
      backgroundColor: Colors.lightBlue.shade200,
      label: Container(
        width: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Camera"),
            Icon(Icons.camera_alt),
          ],
        ),
      ),
    ),
    Chip(
      backgroundColor: Colors.lightBlue.shade200,
      label: Container(
        width: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Gallery"),
            Icon(Icons.image),
          ],
        ),
      ),
    ),
  ];

  String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveDataToFirebase() async {
    try {
      final response = await processedColoniesReference.add({
        "colonies": responseData["colony_count"],
        "processed_image": responseData["processed_image"],
        "uid": uid,
      });
    } catch (e) {
      print(e);
    }
  }

  bool isGranted = false;

  getPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage, Permission.camera].request();
    if (statuses[Permission.storage]!.isGranted ||
        statuses[Permission.camera]!.isGranted) {
      setState(() {
        isGranted = true;
      });
    } else {
      print("no permissions provided");
    }
  }

  Future<void> saveImageToSystemDownloads(String imgCode) async {
    try {
      final bytes = base64Decode(imgCode);

      // Request storage permission (Android only)
      final storageStatus = await Permission.storage.status;
      if (storageStatus != PermissionStatus.granted) {
        final permissionRequestResult = await Permission.storage.request();
        if (permissionRequestResult != PermissionStatus.granted) {
          throw Exception("Storage permission not granted");
        }
      }

      final directory = await getTemporaryDirectory();
      if (directory != null) {
        final filename =
            DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
        final path = '$directory/$filename';
        final file = File(path);
        await file.writeAsBytes(bytes);
      } else {
        throw Exception("Downloads folder not found");
      }
    } catch (error) {
      // Handle errors appropriately
      print(error);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageFile = null;
    responseData = null;
    enableUpload = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Show dialog box when the user tries to exit the app
          bool exit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Exit App'),
              content: Text('Are you sure you want to exit?'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
              ],
            ),
          );

          return exit ??
              false; // Return false to prevent exiting if exit is null
        },
        child: Scaffold(
          key: _key,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // getPermissions();
            },
            child: Icon(Icons.file_upload_outlined),
          ).addStarMenu(
            items: otherEntries,
            onItemTapped: (index, c) {
              setState(() {
                selectedIndex = index;
              });
              if (index != 0) {
                getPermissions();

                if (isGranted) {
                  _selectImage();
                }
              }
              c.closeMenu!();
            },
            params: StarMenuParameters.dropdown(context).copyWith(
                useTouchAsCenter: true,
                linearShapeParams: LinearShapeParams(
                  space: 20,
                ),
                boundaryBackground:
                    BoundaryBackground(color: Colors.transparent)),
            controller: backgroundStarMenuController,
          ),
          appBar: AppBar(
            title: Text(
              "KV²C²",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            centerTitle: true,
          ),
          drawer: Drawer(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.blue.shade200,
                  child: Image.asset("assets/tenor.gif"),
                ),
                ListTile(
                  onTap: () {
                    _key.currentState!.closeDrawer();
                  },
                  leading: Icon(Icons.home_filled),
                  title: Text("Home"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProcessedImagesScreen(
                                  uid: uid,
                                )));
                  },
                  leading: Icon(Icons.save_rounded),
                  title: Text("Processed Images"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()));
                  },
                  leading: Icon(Icons.person),
                  title: Text("About Us"),
                ),
                ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return showDialogBox();
                      },
                    );
                  },
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text("Logout"),
                ),
              ],
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        getPermissions();
                        if (isGranted) {
                          _selectImage();
                        }
                      },
                      child: Container(
                        height: 400,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20)),
                        child: _imageFile == null
                            ? Center(
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Select Image',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(_imageFile!)),
                      ),
                    ),
                    SizedBox(height: 20),
                    enableUpload
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 15,
                                backgroundColor: Colors.blue.shade200,
                                minimumSize:
                                    Size(MediaQuery.of(context).size.width, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            onPressed: _uploadImage,
                            child: Text(
                              'Upload Image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _uploadMessage,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 20),
                      ),
                    ),
                    !isProcessing
                        ? responseData != null
                            ? Column(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 400,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 5,
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            responseData['processed_image'] !=
                                                    null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.memory(
                                                      base64Decode(responseData[
                                                          'processed_image']!),
                                                      height: 300,
                                                    ))
                                                : Center(
                                                    child: Text(
                                                    'Processed Image',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  )),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total colony counts: " +
                                                      responseData[
                                                              'colony_count']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                // IconButton(
                                                //     onPressed: () {
                                                //       // saveDecodedData();
                                                //       saveImageToSystemDownloads(
                                                //           responseData[
                                                //               'processed_image']!);
                                                //     },
                                                //     icon: Icon(Icons.download))
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 400,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 5,
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            responseData['processed_image'] !=
                                                    null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: ColorFiltered(
                                                        colorFilter: ColorFilter
                                                            .matrix(<double>[
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
                                                          base64Decode(
                                                            responseData[
                                                                'processed_image']!,
                                                          ),
                                                          height: 300,
                                                        )),
                                                  )
                                                : Center(
                                                    child: Text(
                                                    'Processed Image',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  )),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total colony counts: " +
                                                      responseData[
                                                              'colony_count']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                // IconButton(
                                                //     onPressed: () {
                                                //       //  saveImageToSystemDownloads()
                                                //     },
                                                //     icon: Icon(Icons.download))
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              )
                            : Container()
                        : Center(child: CircularProgressIndicator()),
                    SizedBox(
                      height: 150,
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  showDialogBox() {
    return AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to exit?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("No")),
        ElevatedButton(
            onPressed: () async {
              try {
                signOut().whenComplete(() => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen())));
              } catch (e) {
                print(e);
              }
            },
            child: Text("Yes")),
      ],
    );
  }
}

// class IconMenu extends StatelessWidget {
//   const IconMenu({
//     required this.icon,
//     required this.text,
//     super.key,
//   });

//   final IconData icon;
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 32),
//         const SizedBox(height: 6),
//         Text(text),
//       ],
//     );
//   }
// }


