import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moviesapp/pages/main_chats_page.dart';
import 'file:///C:/Flutter/projects/moviesapp/lib/pages/feeds_page.dart';
import 'package:moviesapp/pages/movieSearch_page.dart';
import 'package:moviesapp/pages/profilePage.dart';
import 'package:moviesapp/pages/searchPage.dart';
import 'package:moviesapp/size_config/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isDark;
String currentUID,username, displayName, email, photoUrl, bio;
int following, followers;

class Home extends StatefulWidget {
  final String profileId;

  Home({this.profileId});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController _pageController;
  int _currentIndex = 0;
  SharedPreferences saved;

  onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  loadUserDetails()async{
    saved = await SharedPreferences.getInstance();
    setState(() {
      currentUID = saved.getString("id");
      username = saved.getString('username');
      displayName = saved.getString('displayName');
      email = saved.getString('email');
      photoUrl = saved.getString('photoUrl');
      bio = saved.getString('bio');
      followers = saved.getInt('followers');
      following = saved.getInt('following');
    });
  }


  void initState() {
    super.initState();
    _pageController = PageController();
    loadUserDetails();
  }

  void dispose(){
    super.dispose();
    _pageController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).scaffoldBackgroundColor == Color.fromRGBO(1, 1, 1, 1);
    SizeConfig().init(context);
    return Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index){
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                Container(
                  width: SizeConfig.blockSizeHorizontal*100,
                  height: SizeConfig.blockSizeVertical*100,
                  child: ChatsList(),
                ),
                Container(
                  width: SizeConfig.blockSizeHorizontal*100,
                  height: SizeConfig.blockSizeVertical*100,
                  child: MovieSearchPage(),
                ),
                Container(
                  width: SizeConfig.blockSizeHorizontal*100,
                  height: SizeConfig.blockSizeVertical*100,
                  child: SearchPage(),
                ),

                Container(
                  width: SizeConfig.blockSizeHorizontal*100,
                  height: SizeConfig.blockSizeVertical*100,
                  child: Container(),
                ),
                Container(
                  width: SizeConfig.blockSizeHorizontal*100,
                  height: SizeConfig.blockSizeVertical*100,
                  child: Profile(profileId: currentUID, photoUrl: photoUrl, username: username, displayName: displayName),
                )
              ],
            ),
            Positioned(
              left: 0, bottom: 0, right: 0,
              child: bottomNavigationBar(isDark),
            ),
          ],
        )
    );
  }

  Widget bottomNavigationBar(bool isDark) {
    return CurvedNavigationBar(
      index: _currentIndex,
      onTap: onTabTapped,
      backgroundColor: Colors.transparent,
      items: <Widget>[
          Icon(MdiIcons.movieOutline, size: 35,),
          Icon(MdiIcons.movieSearch, size: 35,),
          Icon(MdiIcons.accountSearch, size: 35,),
          Icon(MdiIcons.heart, size: 35,),
          Icon(MdiIcons.face, size: 35,),
      ],
      color: isDark ? Color.fromRGBO(41, 41, 41, 1) :  Color.fromRGBO(211, 211, 211, 1),
      height: 60,
      buttonBackgroundColor: isDark ? Color.fromRGBO(41, 41, 41, 1) :  Color.fromRGBO(221, 221, 221, 1),
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 500),
    );
  }
}