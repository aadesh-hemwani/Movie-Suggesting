import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/pages/profilePage.dart';
import 'package:moviesapp/size_config/size_config.dart';

class Post extends StatefulWidget {
  final String movieId;
  final String ownerId;
  final String ownerProfile;
  final String username;
  final String title;
  final String posterUrl;


  Post({
    this.title,
    this.username,
    this.movieId,
    this.ownerId,
    this.ownerProfile,
    this.posterUrl
  });

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      movieId: doc["movieId"],
      title: doc["title"],
      username: doc["username"],
      ownerId: doc["ownerId"],
      ownerProfile: doc["ownerProfile"],
      posterUrl: doc["posterUrl"],
    );
  }

  @override
  _PostState createState() => _PostState(
    title: this.title,
    movieId: this.movieId,
    ownerId: this.ownerId,
    ownerProfile: this.ownerProfile,
    posterUrl: this.posterUrl,
    username: this.username
  );
}

class _PostState extends State<Post> {
  var baseUrl = "https://image.tmdb.org/t/p/w500";
  final String movieId;
  final String ownerId;
  final String ownerProfile;
  final String username;
  final String title;
  final String posterUrl;


  _PostState({
    this.title,
    this.username,
    this.movieId,
    this.ownerId,
    this.ownerProfile,
    this.posterUrl
  });



  buildHeader(){
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: ownerProfile != null ? CachedNetworkImageProvider(ownerProfile): null,
        backgroundColor: Theme.of(context).accentColor,
      ),
      title: GestureDetector(
        onTap: (){
          Navigator.push(context,
            CupertinoPageRoute(
              builder: (_)=>Profile(username: username,profileId: ownerId, photoUrl: ownerProfile,)
            )
          );
        },
        child: Text(
            username,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
        ),
      ),
    );
  }

  buildPostImage(){
    return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(baseUrl + posterUrl, height: SizeConfig.blockSizeVertical*50,)
    );
  }

  buildPostFooter(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30
            ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          buildHeader(),
          buildPostImage(),
          buildPostFooter(),
          Divider(
            color: isDark ? Colors.white: Colors.grey,
            indent: 30,
            endIndent: 30,
          ),
        ],
      ),
    );
  }
}
