import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moviesapp/FirebaseProvider/RegisterProvider.dart';
import 'package:moviesapp/size_config/size_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool tappedOnSignUp = false;
  String photoUrl = "";

  String errorMessage = "";
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();

  bool firstNamevalid = true;
  bool lastNamevalid = true;
  bool emailValid = true;
  bool passwordValid = true;
  bool usernameValid = true;

  final registrationProvider = RegisterUser();
  String imageId = Uuid().v4();

  File _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }


  compressImage() async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImage = File('$path/img_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 50));

    setState(() {
      _image = compressedImage;
    });
  }

  Future<String> uploadImage(imageFile) async{
    StorageUploadTask uploadTask = storageRef.child("profiles/profile_$imageId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String profileUrl = await storageSnap.ref.getDownloadURL();
    return profileUrl;
  }

  registerUser()async{
    final QuerySnapshot result = await Firestore.instance.collection("users").where("username", isEqualTo: username.text).getDocuments();
    List<DocumentSnapshot> documents = result.documents;

    if(documents.length == 0) {
      setState(() {
        usernameValid = true;
      });
    }
    else{
      setState(() {
        usernameValid = false;
      });
    }
    setState(() {
      firstName.text.trim().length < 3 ? firstNamevalid = false : firstNamevalid = true;
      lastName.text.trim().length < 3 ? lastNamevalid = false : lastNamevalid = true;
      EmailValidator.validate(email.text) ? emailValid = true : emailValid = false;
      password.text.trim().length < 8 ? passwordValid = false : passwordValid = true;
    });
    if(_image != null){
      await compressImage();
      photoUrl = await uploadImage(_image);
    }
    if(firstNamevalid && lastNamevalid && emailValid && passwordValid && usernameValid && photoUrl != ""){
      setState(() {
        tappedOnSignUp = true;
        errorMessage = "Creating account, hang on for a few seconds....";
      });
      errorMessage = await registrationProvider.createAccount(context, email.text, password.text, firstName.text+" "+lastName.text, username.text, photoUrl);
      setState(() {
        _image = null;
        tappedOnSignUp = false;
        imageId = Uuid().v4();
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
          child: Stack(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: SizeConfig.blockSizeHorizontal*100,
                        height: SizeConfig.blockSizeVertical*38,
                        child: _image == null ?  Image(
                          image: AssetImage("images/Citynight.png"),
                          fit: BoxFit.fill,
                        ) : Image.file(_image, fit: BoxFit.fitHeight,),
                    ),
                    if (_image == null)Positioned(
                      top: SizeConfig.blockSizeVertical*10,
                      child: Container(
                        child: Text(
                          "Hey there!",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.blockSizeVertical*2.4
                          ),
                        ),
                      ),
                    ),
                    if (_image == null)Positioned(
                      top: SizeConfig.blockSizeVertical*13,
                      child: Container(
                        child: Text(
                          "Create your account".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: SizeConfig.blockSizeVertical*3
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: SizeConfig.blockSizeVertical*25,
                      left: 30,
                      child: FloatingActionButton(
                        elevation: 1,
                        onPressed: getImage,
                        tooltip: 'Pick Image',
                        child: Icon(MdiIcons.cameraPlus, color: Colors.white,),
                      ),
                    ),
                    Positioned(
                      top: SizeConfig.blockSizeVertical*4,
                      child: Container(
                          alignment: Alignment.topLeft,
                          width: SizeConfig.blockSizeHorizontal*100,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                      ),
                    ),
                    Positioned(
                        top: SizeConfig.blockSizeVertical*20,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal*80,
                        child: Text(errorMessage==""? "" : errorMessage,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeVertical*3,
                            color: Colors.white, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ),

                  ],
                ) ,

               Positioned(
                 top: SizeConfig.blockSizeVertical*35,
                 child: Container(
                   height: SizeConfig.blockSizeVertical*65,
                     decoration: BoxDecoration(
                         color: Theme.of(context).scaffoldBackgroundColor,
                         borderRadius: BorderRadius.only(
                             topLeft: Radius.circular(12), topRight: Radius.circular(12)
                         )
                     ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Container(
                           width: SizeConfig.blockSizeHorizontal*100,
                           child: Form(
                            child: Column(
                              children: [
                                commonTF('First Name : ', false, TextInputType.text, firstName, firstNamevalid, "First Name too short"),
                                commonTF('Last Name : ', false, TextInputType.text, lastName, lastNamevalid, "Last Name too short"),
                                commonTF('Userame : ', false, TextInputType.text, username, usernameValid, "Username is already taken"),
                                commonTF('Email ID : ', false, TextInputType.emailAddress, email, emailValid, "Invalid Email"),
                                commonTF('Password : ', true, TextInputType.visiblePassword, password, passwordValid, "Password must be atleast 8 characters long"),
                              ],
                            ),
                        ),
                         ) ,

                        Container(
                          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*6),
                          width: SizeConfig.blockSizeHorizontal * 100,
                          child: RaisedButton(
                            elevation: 0,
                            padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeVertical*1.5,
                              bottom: SizeConfig.blockSizeVertical*1.5,
                              left: SizeConfig.blockSizeHorizontal*10,
                              right: SizeConfig.blockSizeHorizontal*10,
                            ),
                            color: tappedOnSignUp ? Colors.grey : Color.fromRGBO(253, 1, 86, 1),
                            onPressed: () {
                                if(!tappedOnSignUp){
                                  registerUser();
                                }
                              },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Text("Signup", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeVertical*2),),
                          ),
                        ),
                      ],
                    )
                  ),
               ),
              ]),
        ),
      ),
    );
  }


  Padding commonTF(String lblTxt, bool txtObscure, TextInputType typeOfKeyboard, TextEditingController controller, bool condition, String errorMsg) {
    return Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.blockSizeHorizontal*6,
          right: SizeConfig.blockSizeHorizontal*6,
          top: SizeConfig.blockSizeVertical*1
      ),
      child: Container(
        child: TextFormField(
          controller: controller,
          obscureText: txtObscure,
          enableSuggestions: true,
          cursorColor: Color.fromRGBO(43, 53, 125, 1),
          keyboardType: typeOfKeyboard,
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            errorText: condition ? null : errorMsg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
            ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*4),
                child: Text(
                  lblTxt,
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
              fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}


