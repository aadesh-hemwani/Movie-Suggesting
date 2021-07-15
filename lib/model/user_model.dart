import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String bio;
  final String photoUrl;
  final int followers;
  final int following;


  User({
    this.id,
    this.username,
    this.email,
    this.displayName,
    this.bio,
    this.photoUrl,
    this.followers,
    this.following
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
    );
  }

}