import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/pages/profilePage.dart';
import 'package:moviesapp/size_config/size_config.dart';

class FriendsList extends StatefulWidget {
  final String userId;
  final bool isShareScreen;
  final String movieId;
  final String posterUrl;
  final String title;

  FriendsList({this.userId, this.isShareScreen, this.movieId, this.title, this.posterUrl});

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  Future<QuerySnapshot> friendsList;
  final DateTime time = DateTime.now();

  getFriendsList(){
    Future<QuerySnapshot> friends = friendsRef.document(widget.userId).collection("userFriends").getDocuments();
    setState(() {
      friendsList = friends;
    });
  }

  createChatFirebase(String userId){
    friendsRef.document(currentUID)
        .collection("userFriends")
        .document(userId)
        .collection("chat")
        .document(widget.movieId)
        .setData({
          "posterUrl":  widget.posterUrl,
          "title": widget.title,
          "sent": true,
          "received": false,
          "timestamp": time
        }).whenComplete(() => print("sent"));

    friendsRef.document(userId)
        .collection("userFriends")
        .document(currentUID)
        .collection("chat")
        .document(widget.movieId)
        .setData({
      "posterUrl":  widget.posterUrl,
      "title": widget.title,
      "received": true,
      "sent": false,
      "timestamp": time
    });

  Navigator.pop(context);
  }


  @override
  void initState() {
    getFriendsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: FutureBuilder(
        future: friendsList,
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(child: Text("Loading Search Results..."));
          }
          return Container(
            height: SizeConfig.blockSizeVertical*100,
            child: ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index){
                var user = snapshot.data.documents[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                            CupertinoPageRoute(
                                builder: (_)=>Profile(
                                  displayName: user["displayName"],
                                  photoUrl: user["photoUrl"],
                                  profileId: user["id"],
                                  username: user["username"],
                                )
                            )
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Hero(
                                  tag: user["username"],
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(user["photoUrl"]),
                                    backgroundColor: Theme.of(context).accentColor,
                                    radius: SizeConfig.blockSizeVertical*3.5,
                                  ),
                                ),
                                SizedBox(width: SizeConfig.blockSizeHorizontal*4,),
                                Text(
                                  user['username'],
                                  style: TextStyle(
                                      fontSize: SizeConfig.blockSizeHorizontal*4.5
                                  ),
                                ),
                              ],
                            ),

                            if(widget.isShareScreen)
                              IconButton(
                              icon: Icon(MdiIcons.send),
                              onPressed: (){
                                createChatFirebase(user["id"]);
                              },
                              tooltip: "Send",
                              enableFeedback: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 0,
                      thickness: 0.8,
                    )
                  ],
                );
              },
            ),
          );
        },
      )
    );
  }
}
