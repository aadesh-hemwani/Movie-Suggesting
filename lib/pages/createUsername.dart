import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviesapp/size_config/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameCreate extends StatefulWidget {
  final String uid;

  UsernameCreate({this.uid});

  @override
  _UsernameCreateState createState() => _UsernameCreateState();
}

class _UsernameCreateState extends State<UsernameCreate> {
  var username = TextEditingController();
  String errorMsg = "";
  SharedPreferences prefs;

  saveUsername()async {
    final QuerySnapshot result = await Firestore.instance.collection("users").where("username", isEqualTo: username.text).getDocuments();
    List<DocumentSnapshot> documents = result.documents;

    if(documents.length == 0){
      Navigator.pop(context, username.text);

      setState(() {
        errorMsg = "Done";
      });
    }
    else{
      setState(() {
        errorMsg = "Username already exists";
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig.blockSizeVertical*100,
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                errorMsg,
                style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical*3,
                    color: Colors.red
                ),
              ),
              Text(
                  "Create a Unique Username so your friends can find you",
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical*6,
                    fontWeight: FontWeight.w600
                  ),
              ),
              Theme(
                data: ThemeData(
                  primaryColor: Color.fromRGBO(240, 242, 255, 1),
                  hintColor: Color.fromRGBO(240, 242, 255, 1),
                ),
                child: Container(
                  constraints: BoxConstraints(maxHeight: SizeConfig.blockSizeVertical * 7),
                  child: TextFormField(
                    controller: username,
                    enableSuggestions: true,
                    cursorColor: Color.fromRGBO(43, 53, 125, 1),
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*4),
                        child: Text(
                          "Username",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeVertical*1.8,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(220, 220, 241, 1),
                    ),
                    style: TextStyle(
                        color: Colors.black,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.blockSizeVertical * 1.9),
                  ),
                ),
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                elevation: 0,
                padding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical*1.5,
                  bottom: SizeConfig.blockSizeVertical*1.5,
                  left: SizeConfig.blockSizeHorizontal*10,
                  right: SizeConfig.blockSizeHorizontal*10,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)
                ),
                child: Text("Proceed", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeVertical*2),),
                onPressed: (){
                  if(username.text == ""){
                    setState(() {
                      errorMsg = "username cannot be empty";
                    });
                  }
                  if(username.text != ""){
                    saveUsername();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
