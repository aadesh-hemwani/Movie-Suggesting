import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviesapp/pages/first_page.dart';

class RegisterUser{
  final DateTime time = DateTime.now();

  Future<String> createAccount(BuildContext context, String email, String password, String displayName, String username, String photoUrl) async{
    try{
      AuthResult result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if(result != null){
        UserUpdateInfo updateInfo = UserUpdateInfo();
        updateInfo.displayName = displayName;
        FirebaseUser firebaseUser = result.user;

        if(firebaseUser != null){
          await firebaseUser.updateProfile(updateInfo);
          await firebaseUser.reload();
          final QuerySnapshot result = await Firestore.instance.collection("users").where("id", isEqualTo: firebaseUser.uid).getDocuments();
          List<DocumentSnapshot> documents = result.documents;
          if(documents.length == 0){
            Firestore.instance.collection("users").document(firebaseUser.uid).setData({
              'id': firebaseUser.uid,
              'displayName': displayName,
              'email': firebaseUser.email,
              'bio': "",
              'username': username,
              "timestamp" : time,
              "photoUrl": photoUrl,

            });
          }
        }
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (_)=>FirstPage(),
            )
        );
      }
    }
    catch(error){
      switch (error.code) {
        case "ERROR_OPERATION_NOT_ALLOWED":
          return "Anonymous accounts are not enabled";

        case "ERROR_WEAK_PASSWORD":
          return "Your password is too weak";

        case "ERROR_INVALID_EMAIL":
          return "Your email is invalid";

        case "ERROR_EMAIL_ALREADY_IN_USE":
          return "Email is already in use on different account";

        case "ERROR_INVALID_CREDENTIAL":
          return "Your email is invalid";

        default:
          return "An undefined Error happened.";
      }
    }
    return "All Done";
  }

}