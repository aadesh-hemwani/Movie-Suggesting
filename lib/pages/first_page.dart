import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moviesapp/FirebaseProvider/signInProvider.dart';
import 'package:moviesapp/home.dart';
import 'file:///C:/Flutter/projects/moviesapp/lib/pages/signup_page.dart';
import 'package:moviesapp/model/user_model.dart';
import 'package:moviesapp/pages/createUsername.dart';
import 'package:moviesapp/size_config/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userRef = Firestore.instance.collection("users");
final friendsRef = Firestore.instance.collection("friends");
final movieRef = Firestore.instance.collection("movies");
final sharedMoviesRef = Firestore.instance.collection("sharedMovies");
final timelineRef = Firestore.instance.collection("timeline");

final googleSignIn = GoogleSignIn();
User currentUser;

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  String errorMessage = "";
  final firebaseProvider = SignInProvider();
  SharedPreferences prefs;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final DateTime time = DateTime.now();
  bool emailValid = true;
  bool passwordValid = true;


  createUserInFireStore(BuildContext context, FirebaseUser fbUser) async{
    DocumentSnapshot doc = await userRef.document(fbUser.uid).get();

    if(!doc.exists){
      final username = await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context)=>UsernameCreate()
          )
      );

      userRef.document(fbUser.uid).setData({
        "id" : fbUser.uid,
        "username": username,
        "photoUrl": fbUser.photoUrl,
        "email": fbUser.email,
        "displayName": fbUser.displayName,
        "bio": "",
        "following": 0,
        "followers": 0,
        "timestamp": time
      });

      doc = await userRef.document(fbUser.uid).get();
    }

    currentUser = User.fromDocument(doc);
  }

  loginWithEmail()async{
    setState(() {
      EmailValidator.validate(email.text) ? emailValid = true :emailValid = false;
      password.text.trim().length < 8 ? passwordValid = false : passwordValid = true;
    });

    if(emailValid && passwordValid) {
      setState(() {
        errorMessage = "Signing you in....";
      });
      errorMessage = await firebaseProvider.emailSignIn(context, email.text, password.text);
      setState(() {});
    }
  }

  handelSignIn(BuildContext context) async{
    prefs = await SharedPreferences.getInstance();
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

    if(firebaseUser != null){
      createUserInFireStore(context, firebaseUser);

      DocumentSnapshot doc = await userRef.document(firebaseUser.uid).get();
      currentUser = User.fromDocument(doc);

      prefs.setString('id', firebaseUser.uid);
      prefs.setString('username', currentUser.username);
      prefs.setString('email', currentUser.email);
      prefs.setString('photoUrl', currentUser.photoUrl);
      prefs.setString('displayName', currentUser.displayName);
      prefs.setString('bio', currentUser.bio);


      prefs.setBool('isSignedIn', true);

      Navigator.pushReplacement(context,
          CupertinoPageRoute(
            builder: (context)=>Home(profileId: firebaseUser.uid),
          )
      );
    }
  }

  alreadySignedIn(BuildContext context)async{
    prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isSignedIn');
    String uid = prefs.getString('id');

    if(loggedIn){
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (_)=> Home(profileId: uid),
          )
      );
    }
  }

  void initState(){
    super.initState();
    alreadySignedIn(context);
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
                      child:Image(
                        image: AssetImage("images/Citynight.png"),
                        fit: BoxFit.fill,
                      )
                  ),
                  Positioned(
                    top: SizeConfig.blockSizeVertical*10,
                    child: Container(
                      child: Text(
                        "Welcome to",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.blockSizeVertical*2.4
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: SizeConfig.blockSizeVertical*12.5,
                    child: Container(
                      child: Text(
                        "Movies Hub".toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: SizeConfig.blockSizeVertical*6
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: SizeConfig.blockSizeVertical*22,
                    child: Container(
                        width: SizeConfig.blockSizeHorizontal*100,
                        child: Center(child: Text(errorMessage, style: TextStyle(fontSize: SizeConfig.blockSizeVertical*3, color: Colors.white),))
                    ),
                  )
                ],
              ),

              Positioned(
                top: SizeConfig.blockSizeVertical*35,
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12), topRight: Radius.circular(12)
                      )
                  ),
                  child: Column(
                    children: [
                      //Hey Text Start
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            )
                        ),
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*6),
                        width: SizeConfig.blockSizeHorizontal*100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                "Hey!",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: SizeConfig.blockSizeVertical*4.5
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "Fill in the details below to login",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: SizeConfig.blockSizeVertical*2
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Hey Text End


                      //TextField start
                      Container(
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal*6,
                            right: SizeConfig.blockSizeHorizontal*6,
                            top: SizeConfig.blockSizeVertical*1
                        ),
                        width: SizeConfig.blockSizeHorizontal*100,
                        child: Column(
                          children: [
                            Container(
                              child: TextField(
                                controller: email,
                                enableSuggestions: true,
                                cursorColor: Color.fromRGBO(43, 53, 125, 1),
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                    errorText: emailValid ? null : "Invalid Email",
                                    alignLabelWithHint: true,
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*3.5),
                                      child: Text(
                                        "Email :",
                                        style:
                                        TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig.blockSizeVertical*1.8,
                                            fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Color.fromRGBO(220, 220, 241, 1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    )
                                ),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical*2,),
                            Container(
                              child: TextField(
                                controller: password,
                                obscureText: true,
                                enableSuggestions: true,
                                cursorColor: Color.fromRGBO(43, 53, 125, 1),
                                keyboardType: TextInputType.visiblePassword,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                    errorText: passwordValid ? null : "Passowrd must be atleast 8 characters long",
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*3.5),
                                      child: Text(
                                        "Password :",
                                        style:
                                        TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig.blockSizeVertical*1.8,
                                            fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Color.fromRGBO(220, 220, 241, 1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    )
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //TextField End



                      //login button start
                      Container(
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*6),
                        width: SizeConfig.blockSizeHorizontal*100,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Container(
                                    child: Text(
                                      "forgot password?",
                                      style: TextStyle(
                                          fontSize: SizeConfig.blockSizeVertical*2
                                      ),
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
                                  onPressed: (){loginWithEmail();},
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)
                                  ),
                                  child: Text("Login", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeVertical*2),),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical*2,
                            ),
                            Divider(
                              color: Colors.grey,
                              height: 1,
                              indent: 50,
                              endIndent: 50,
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical*2,
                            ),
                            Container(
                                constraints: BoxConstraints(
                                    maxHeight: SizeConfig.blockSizeVertical*5
                                ),
                                child: GoogleSignInButton(
                                  onPressed: (){
                                    handelSignIn(context);
                                  },
                                  darkMode: Theme.of(context).scaffoldBackgroundColor == Color.fromRGBO(1, 1, 1, 1),
                                  textStyle: TextStyle(
                                      fontSize: SizeConfig.blockSizeVertical*1.8
                                  ),
                                  borderRadius: 5,
                                )
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical*1.5,),
                          ],
                        ),
                      ),
                      //Login button end
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                child: Container(
                  width: SizeConfig.blockSizeHorizontal*100,
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.blockSizeVertical*1.8
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_)=> SignUpPage()
                                  )
                              );
                            },
                            child: Text(
                              "Signup Now",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor,
                                  fontSize: SizeConfig.blockSizeVertical*1.8
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),


              //person profile image start
              Positioned(
                top: SizeConfig.blockSizeVertical*29,
                right: SizeConfig.blockSizeHorizontal*5,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: Image(
                        image: AssetImage("images/profile.png"),
                        width: SizeConfig.blockSizeHorizontal*22,
                      ),
                    ),
                  ),
                ),
              ),
              //person profile image end
            ],
          ),
        ),
      ),
    );
  }
}
