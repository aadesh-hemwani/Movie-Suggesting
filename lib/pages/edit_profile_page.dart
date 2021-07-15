import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/size_config/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final editDisplayName = TextEditingController();
  final editBio = TextEditingController();
  bool displayNameValid = true;
  bool bioValid = true;
  SharedPreferences saved;

  void initState(){
    super.initState();
    editBio.text = bio;
    editDisplayName.text = displayName;
  }

  updateProfile()async{
    setState(() {
      editDisplayName.text.trim().length < 3 || editDisplayName.text.isEmpty ? displayNameValid = false : displayNameValid = true;
      editBio.text.trim().length > 100 ? bioValid = false : bioValid = true;
    });

    if(displayNameValid && bioValid){
      userRef.document(currentUID).updateData({"displayName":editDisplayName.text, "bio": editBio.text}).whenComplete(() => print("updated"));
      saved = await SharedPreferences.getInstance();

    }
    setState(() {
      saved.setString("displayName", editDisplayName.text);
      saved.setString("bio", editBio.text);

      displayName = editDisplayName.text;
      bio = editBio.text;
    });

    SnackBar snackbar = SnackBar(
      content: Text("Profile will be Updated in a few Minutes"),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(14), topLeft: Radius.circular(14))
      ),
      backgroundColor: Theme.of(context).accentColor,
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
            "Edit Profile",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0
            ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*6),
          width: SizeConfig.blockSizeHorizontal*100,
          height: SizeConfig.blockSizeVertical*89,
          child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Stack(
                      alignment: Alignment.center,
                      overflow: Overflow.visible,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child:  photoUrl == "" ?
                            Container(
                              width: SizeConfig.blockSizeHorizontal*40,
                              height: SizeConfig.blockSizeVertical*20,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [Theme
                                        .of(context)
                                        .accentColor, Colors.greenAccent.withBlue(220)],
                                  ),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(15))
                              ),
                            )
                           : CachedNetworkImage(
                            imageUrl: photoUrl,
                            fit: BoxFit.fitWidth,
                            height: SizeConfig.blockSizeVertical*20,
                          ),
                        ),
                        Positioned(
                          top: SizeConfig.blockSizeVertical*16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : Colors.black,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              enableFeedback: true,
                              icon: Icon(MdiIcons.cameraOutline,color: isDark ? Colors.black : Colors.white,),
                              onPressed: () {  },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w400
                      ),
                      suffixIcon: Icon(MdiIcons.lockOutline)
                    ),
                    enabled: false,
                    initialValue: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.blockSizeVertical*2.5
                    ),
                  ),
                  TextFormField(
                    controller: editDisplayName,
                    decoration: InputDecoration(
                      errorText: displayNameValid ? null : "Name is Too Short",
                      labelText: "Name",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w400
                      ),
                        suffixIcon: Icon(Icons.person)
                    ),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.blockSizeVertical*2.5
                    ),
                  ),
                  TextFormField(
                    controller: editBio,
                    decoration: InputDecoration(
                        errorText: bioValid ? null : "Bio is Too Long",
                      labelText: "Bio",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w400
                      ),
                        suffixIcon: Icon(MdiIcons.bookOpen)
                    ),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.blockSizeVertical*2.5
                    ),
                  ),
                  RaisedButton(
                    padding: EdgeInsets.only(
                      top: SizeConfig.blockSizeVertical*1.5,
                      bottom: SizeConfig.blockSizeVertical*1.5,
                      left: SizeConfig.blockSizeHorizontal*10,
                      right: SizeConfig.blockSizeHorizontal*10,
                    ),
                    child: Text("Update", style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: (){
                      updateProfile();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  )
                ],
              ),
          )
        ),
    );
  }
}
