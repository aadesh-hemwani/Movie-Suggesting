import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviesapp/home.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SignInProvider{
  bool isLoggedIn = false;
  SharedPreferences prefs;
  String errorMessage = "";

  Future<String> emailSignIn(BuildContext context, String userEmail, String userPassword) async{
    prefs = await SharedPreferences.getInstance();
    try{
      AuthResult result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: userEmail, password: userPassword);
      FirebaseUser firebaseUser = result.user;

      if(firebaseUser != null){
        QuerySnapshot query = await Firestore.instance.collection("users").where("id", isEqualTo: firebaseUser.uid).getDocuments();
        List<DocumentSnapshot> documents = query.documents;
        query = await Firestore.instance.collection("users").where("id", isEqualTo: firebaseUser.uid).getDocuments();
        await prefs.setString('id', firebaseUser.uid);
        await prefs.setString('displayName', firebaseUser.displayName);
        await prefs.setString('email', firebaseUser.email);
        await prefs.setString('username', documents[0]['username']);
        await prefs.setString('bio', documents[0]['bio']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setInt('followers', documents[0]["followers"]);
        await prefs.setInt('following', documents[0]["following"]);

        await prefs.setBool('isSignedIn', true);

        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (_)=> Home(),
            )
        );
      }
    }
    catch(error){
      switch (error.code) {
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Anonymous accounts are not enabled";
          return errorMessage;

        case "ERROR_WEAK_PASSWORD":
          errorMessage = "Your password is too weak";
          return errorMessage;

        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email is invalid";
          return errorMessage;

        case "ERROR_EMAIL_ALREADY_IN_USE":
          errorMessage = "Email is already in use on different account";
          return errorMessage;

        case "ERROR_INVALID_CREDENTIAL":
          errorMessage = "Your email is invalid";
          return errorMessage;

        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Wrong Password";
          return errorMessage;

        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User Not Found";
          return errorMessage;

        default:
          errorMessage = "An undefined Error happened.";
          return errorMessage;
      }
    }
    return "All Done";
  }
}
