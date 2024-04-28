import 'package:bccapp/helper/helper_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Future signInWithGoogle() async {
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount != null) {
    // executing our authentication
    try {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // signing to firebase user instance
      final User userDetails =
          (await firebaseAuth.signInWithCredential(credential)).user!;

      if (userDetails != null) {
        final userData = await FirebaseFirestore.instance
            .collection("users")
            .doc(userDetails.uid)
            .get();

        if (userData.data() == null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userDetails.uid)
              .set({
            "username": userDetails.displayName.toString(),
            "email": userDetails.email.toString(),
            "profileImage": userDetails.photoURL.toString(),
          });
        }

        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  } else {
    print("e.message");
  }
}

Future signOut() async {
  try {
    await HelperFunctions.saveUserLoggedInStatus(false);
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  } catch (e) {
    return null;
  }
}
