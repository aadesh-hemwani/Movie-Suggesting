import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/pages/chat_screen.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/size_config/size_config.dart';

class ChatsList extends StatefulWidget {
  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  Future<QuerySnapshot> friendsList;

  getFriendsList(){
    Future<QuerySnapshot> friends = friendsRef.document(currentUID).collection("userFriends").getDocuments();
    print(friends);
    setState(() {
      friendsList = friends;
    });
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
        appBar: AppBar(
          title: Text("Shares"),
          elevation: 0,
        ),
        body: FutureBuilder(
          future: friendsList,
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Center(child: Text("Loading Chats"));
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
                              builder: (_)=> ChatScreen(
                                chattingUserId: user["id"],
                                chattingUserName: user["username"],
                                chattingUserProfile: user["photoUrl"],
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
