import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/pages/postMovies.dart';
import 'package:moviesapp/size_config/size_config.dart';

class Feeds extends StatefulWidget {
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  List<Post> feeds;
  var baseUrl = "https://image.tmdb.org/t/p/w500";
  void initState(){
    super.initState();
    getTimelineFeeds();
  }

  getTimelineFeeds()async{
    QuerySnapshot snapshot = await timelineRef.document(currentUID).collection("timelinePosts")
                                          .orderBy('timestamp', descending: true)
                                          .getDocuments();
    List<Post> feeds = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      this.feeds = feeds;
    });
  }

  buildTimeline(){
    if(feeds == null){
      return Center(child: CupertinoActivityIndicator());
    }
    else{
      return ListView(
        children: feeds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ()=>getTimelineFeeds(),
        child: buildTimeline(),
      )
    );
  }
}
