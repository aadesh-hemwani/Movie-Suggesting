import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/movie_pages/movie_details.dart';
import 'package:moviesapp/pages/first_page.dart';
import 'package:moviesapp/size_config/size_config.dart';

class SharedMovies extends StatefulWidget {
  @override
  _SharedMoviesState createState() => _SharedMoviesState();
}

class _SharedMoviesState extends State<SharedMovies> {
  Map<int, String> monthsInYear = {
    01: "Jan", 02: "Feb", 03: "Mar", 04: "April",
    05: "May", 06: "June",07: "July",08: "Aug",
    09: "Sep", 10: "Oct", 11: "Nov", 12: "Dec",
  };

  String backdrop = "https://www.freevector.com/uploads/vector/preview/30348/Minimal_Dynamic_Background.jpg";
  var apiKey = "3926dff0d2826b265d5396981f90bd1c";
  var baseUrl = "https://image.tmdb.org/t/p/w500";
  bool now = false;
  Future<dynamic> getUpcomingMovies() async {
    String link =
        "http://api.themoviedb.org/3/movie/upcoming?api_key=3926dff0d2826b265d5396981f90bd1c&language=en-US&page=1";
    var response = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var movies = data["results"] as List;
      return movies;
    }
  }


  Future<dynamic> getMovieCast(String id) async {
    String link = "http://api.themoviedb.org/3/movie/" + id + "/credits?api_key=" + apiKey;
    var response = await http.get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var cast = data["cast"] as List;
      return cast;
    }
  }

  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        body: Stack(
          alignment: Alignment.topCenter,
          overflow: Overflow.visible,
          children: <Widget>[
            Container(
              height: SizeConfig.blockSizeVertical * 100,
              child: CachedNetworkImage(
                imageUrl:
                backdrop,
                height: SizeConfig.blockSizeVertical * 100,
                fit: BoxFit.cover,
              ),
            ),
            Container(
                height: SizeConfig.blockSizeVertical * 100,
                width: SizeConfig.blockSizeHorizontal * 100,
                child: ClipRRect(
                  child: new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: new Container(
                      decoration: new BoxDecoration(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.2)),
                    ),
                  ),
                )),
            Container(
              height: SizeConfig.blockSizeVertical * 100,
              width: SizeConfig.blockSizeHorizontal * 100,
              child: FutureBuilder(
                  future: sharedMoviesRef.document(currentUID).collection("sharedMovies").getDocuments(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Container(child: Center(child: CircularProgressIndicator()));
                    }
                    return Swiper(
                        viewportFraction: 0.76,
                        scale: 0.75,
                        onIndexChanged: (index){
                          setState(() {
                            backdrop = baseUrl + snap.data.documents[index]["posterUrl"];
                          });
                        },
                        itemCount: snap.data.documents.length,
                        itemBuilder: (BuildContext context, int i) {

                          var movie = snap.data.documents[i];
                          return Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [

                                Positioned(
                                  top: SizeConfig.blockSizeVertical*33 ,
                                  child: Container(
                                    width: SizeConfig.blockSizeHorizontal*76,
                                    height: SizeConfig.blockSizeVertical*60 ,
                                    decoration: BoxDecoration(
                                        color: isDark ? Color.fromRGBO(41, 41, 41, 1) :Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              spreadRadius: 0.01,
                                              blurRadius: 20,
                                              offset: Offset(0, 10)
                                          )
                                        ]
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top:SizeConfig.blockSizeVertical*15,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(0.4),
                                              spreadRadius: 0.01,
                                              blurRadius: 20,
                                              offset: Offset(0, 10)
                                          )
                                        ]
                                    ),
                                    child: movie["posterUrl"] != null ?
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Hero(
                                        tag: "moviePoster$i",
                                        child: CachedNetworkImage(
                                          imageUrl: baseUrl + movie["posterUrl"],
                                          height: SizeConfig.blockSizeVertical * 40,
                                        ),
                                      ),
                                    ) :
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.blueAccent,
                                      ),
                                      width: SizeConfig.blockSizeHorizontal*52,
                                      height: SizeConfig.blockSizeVertical * 40,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top:SizeConfig.blockSizeVertical*58,
                                  child: Column(
                                    children: [
                                      Hero(
                                        tag: "movieTitle$i",
                                        child: Container(
                                          width: SizeConfig.blockSizeHorizontal*60,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Text(movie["title"],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: SizeConfig.blockSizeVertical*4,
                                                fontWeight: FontWeight.bold,
                                              ),),
                                          ),
                                        ),
                                      ),
                                      Hero(
                                        tag: "movieRating$i",
                                        child: Container(
                                          width: SizeConfig.blockSizeHorizontal*100,
                                          child: StarRating(
                                            size: 25.0,
                                            color: Colors.amber,
                                            borderColor: isDark ? Colors.white :Colors.black45,
                                            starCount: 5,
                                            //rating: rating/2,
                                          ),
                                        ),
                                      ),
                                      Hero(
                                        tag: "year$i",
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: SizeConfig.blockSizeHorizontal*100,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Text(
                                              "",//day + " " + monthsInYear[int.parse(month)] + ", "+ year,
                                              style: TextStyle(
                                                fontSize: SizeConfig.blockSizeVertical*2,

                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: SizeConfig.blockSizeVertical*2,),
                                      FutureBuilder(
                                        future: getMovieCast(movie["movieId"].toString()),
                                        builder: (context, snapshot){
                                          if(!snapshot.hasData){
                                            return Container();
                                          }
                                          return Row(
                                            children: [
                                              Container(
                                                width: SizeConfig.blockSizeHorizontal*67,
                                                height: 90,
                                                child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: snapshot.data.length,
                                                    itemBuilder: (context, index){
                                                      if (snapshot.data[index]["profile_path"] != null) {
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: CircleAvatar(
                                                            backgroundImage: NetworkImage(baseUrl+snapshot.data[index]["profile_path"],),
                                                            radius: 35,

                                                          ),
                                                        );
                                                      } else {
                                                        return Container();
                                                      }
                                                    }
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }),
            ),
          ],
        ));
  }
}
