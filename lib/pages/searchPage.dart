import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/pages/profilePage.dart';
import 'package:moviesapp/size_config/size_config.dart';


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query){
    Future<QuerySnapshot> users = userRef.where("username", isGreaterThanOrEqualTo: query)
    .getDocuments();

    setState(() {
      searchResultsFuture = users;
    });
  }

  Widget buildSearchResults(){
    return FutureBuilder(
      future: searchResultsFuture,
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
                return GestureDetector(
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
                        )
                      ],
                    ),
                  ),
                );
              },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).scaffoldBackgroundColor == Color.fromRGBO(1, 1, 1, 1);
    SizeConfig().init(context);
    return Container(
      height: SizeConfig.blockSizeVertical*100,
      child: Stack(
        children: [
          Positioned(
            top: 80,
            child: Container(
              height: SizeConfig.blockSizeVertical*100,
              width: SizeConfig.blockSizeHorizontal*100,
              child: searchResultsFuture == null ?
              Icon(MdiIcons.accountSearch, size: SizeConfig.blockSizeHorizontal*50,) : buildSearchResults(),
            ) ,
          ),

          Container(
            decoration: BoxDecoration(
              color: isDark ? Color.fromRGBO(41, 41, 41, 1) : Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.01,
                    blurRadius: 20,
                    offset: Offset(0, -2))
              ],
            ),
            width: SizeConfig.blockSizeHorizontal * 100,
            height: 120,
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical * 6,
              left: SizeConfig.blockSizeHorizontal * 6,
              right: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey.withOpacity(0.1),
                hintColor: Colors.transparent,
              ),
              child: TextFormField(
                onFieldSubmitted: handleSearch,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black.withAlpha(500)
                ),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  hintText: "Search User",
                  hintStyle: TextStyle(
                      color:
                      isDark ? Colors.white : Colors.black.withAlpha(500)),
                  filled: true,
                  fillColor: isDark ? Colors.black : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  suffixIcon: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey : Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 0.01,
                              blurRadius: 20,
                              offset: Offset(0, -2))
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(MdiIcons.searchWeb,
                          color: Colors.black.withAlpha(500),),
                          onPressed: (){},
                      )),
                ),
              ),
            ),
          ),
          //Search Bar end
        ],
      ),
    );
  }
}
