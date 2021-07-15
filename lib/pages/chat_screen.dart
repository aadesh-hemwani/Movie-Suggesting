import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/size_config/size_config.dart';

class ChatScreen extends StatefulWidget {
  final String chattingUserName;
  final String chattingUserId;
  final String chattingUserProfile;

  ChatScreen({
    this.chattingUserId,
    this.chattingUserName,
    this.chattingUserProfile
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final baseUrl = "https://image.tmdb.org/t/p/w500";
  getShares(){
    Future<QuerySnapshot> chats = friendsRef.document(currentUID).collection("userFriends")
        .document(widget.chattingUserId).collection("chat").orderBy("timestamp", descending: true).getDocuments();

    return chats;
  }

  @override
  void initState() {
    getShares();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.chattingUserProfile),
            ),
            SizedBox(width:10 ,),
            Text(widget.chattingUserName)
          ],
        ),
        elevation: 0,
      ),

      body: Container(
        width: double.infinity,
        height: SizeConfig.blockSizeVertical*100,
        child: FutureBuilder(
          future: getShares(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Center(child: CupertinoActivityIndicator());
            }
            return ListView.builder(
              reverse: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, i){
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: snapshot.data.documents[i]["sent"] ? Alignment.centerRight:Alignment.centerLeft ,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: snapshot.data.documents[i]["sent"] ?Colors.green.withOpacity(0.2): Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: snapshot.data.documents[i]["sent"] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl:baseUrl + snapshot.data.documents[i]["posterUrl"],
                                  height: SizeConfig.blockSizeVertical*30,
                                ),
                              ),
                              Text(
                                snapshot.data.documents[i]["title"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical*2,)
                  ],
                );
              },
            );
          },
        )
      )
    );
  }
}
