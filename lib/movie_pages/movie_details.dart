import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moviesapp/pages/friends_list_page.dart';
import 'package:moviesapp/size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moviesapp/home.dart';


class MovieDetails extends StatefulWidget {
  final String description, backdrop, poster, title, releaseDate, id;
  final double  vote;
  final int index;
  final Map movies;

  MovieDetails({
      this.description,
      this.backdrop,
      this.poster,
      this.title,
      this.releaseDate,
      this.vote,
      this.id,
      this.movies,
      this.index,
      });

  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {

  Map<int, String> monthsInYear = {
    01: "Jan", 02: "Feb", 03: "Mar", 04: "April",
    05: "May", 06: "June",07: "July",08: "Aug",
    09: "Sep", 10: "Oct", 11: "Nov", 12: "Dec",
  };

  final baseUrl = "https://image.tmdb.org/t/p/w500";
  final apiKey = "3926dff0d2826b265d5396981f90bd1c";
  DateTime time = DateTime.now();

  Future<dynamic> getMovieCast() async {
    String link = "http://api.themoviedb.org/3/movie/" + widget.id + "/credits?api_key=" + apiKey;
    var response = await http.get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var cast = data["cast"] as List;
      return cast;
    }
  }

  Future<String> getVideoKey() async {
    String link = "http://api.themoviedb.org/3/movie/" + widget.id + "/videos?api_key=" + apiKey;
    var response = await http.get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var list = data["results"] as List;
      var key = list[0]["key"];
      return key;
    }
    return null;
  }

  handleShare(){
    Navigator.push(context,
      CupertinoPageRoute(
        builder: (_)=> FriendsList(
          userId: currentUID,
          isShareScreen: true,
          movieId: widget.id,
          title: widget.title,
          posterUrl: widget.poster,
        ),
      )
    );
  }

  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String year = widget.releaseDate.split("-")[0];
    String day = widget.releaseDate.toString().split("-")[2];
    String month = widget.releaseDate.toString().split("-")[1];

    SizeConfig().init(context);
    return Scaffold(
        body: Stack(
      alignment: Alignment.topCenter,
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          height: SizeConfig.blockSizeVertical * 100,
          child: widget.poster == null
              ? Container(
                  width: double.infinity,
                  height: 500,
                  color: Theme.of(context).accentColor,
                )
              : CachedNetworkImage(
                  imageUrl: baseUrl + widget.poster,
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
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6)),
                ),
              ),
            )),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: SizeConfig.blockSizeVertical * 6,
              ),
              Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(SizeConfig.blockSizeVertical * 1)),
                    child: Hero(
                      transitionOnUserGestures: true,
                      tag: "moviePoster${widget.index}",
                      child: Container(
                        height: SizeConfig.blockSizeVertical * 60,
                        child: widget.poster == null
                            ? Container(
                                width: SizeConfig.blockSizeHorizontal * 80,
                                height: SizeConfig.blockSizeVertical * 50,
                                color: Colors.white,
                              )
                            : CachedNetworkImage(
                                imageUrl: baseUrl + widget.poster,
                                height: SizeConfig.blockSizeVertical * 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: getVideoKey(),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: GestureDetector(
                                onTap: () async {
                                  if (await canLaunch(
                                      "https://m.youtube.com/watch?v=" + snap.data)) {
                                    await launch(
                                        "https://m.youtube.com/watch?v=" + snap.data);
                                  }
                                },
                                child: Icon(
                                  MdiIcons.youtube,
                                  color: Colors.red,
                                  size: SizeConfig.blockSizeVertical * 5,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Hero(
                    tag: "movieTitle${widget.index}",
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal*70,
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 4,
                          right: SizeConfig.blockSizeHorizontal * 4),
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 4,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: IconButton(
                      tooltip: "Share with",
                      icon: Icon(
                        MdiIcons.share,
                        color: isDark ? Colors.white:Colors.black,
                        size: SizeConfig.blockSizeVertical*4,
                      ),
                      onPressed:() =>  handleShare(),
                    ),
                  ),
                ],
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 4,
                      ),
                      child: Hero(
                        tag: "movieRating${widget.index}",
                        child: StarRating(
                          color: isDark ? Colors.amber : Colors.black,
                          starCount: 5,
                          rating: widget.vote.toDouble()/2,
                          size: 25.0,
                          borderColor:isDark ? Colors.white : Colors.black,
                        ),
                      )
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal*3,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 4,
                          right: SizeConfig.blockSizeHorizontal * 4),
                      child: Hero(
                        tag: "year${widget.index}",
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            day + " " + monthsInYear[int.parse(month)] + ", "+ year,
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical*2,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 4),
              Container(
                padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal * 4,
                    right: SizeConfig.blockSizeHorizontal * 4),
                child: Text(
                  widget.description,
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical * 2,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 4),
              FutureBuilder(
                future: getMovieCast(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 4,
                              right: SizeConfig.blockSizeHorizontal * 4),
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Cast ",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeVertical * 4),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: SizeConfig.blockSizeVertical * 35,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, i) {
                                return Padding(
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeVertical * 2),
                                    child: Container(
                                      width: SizeConfig.blockSizeHorizontal * 40,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(SizeConfig
                                                            .blockSizeVertical *
                                                        0.5)),
                                                child: snapshot.data[i]
                                                            ["profile_path"] ==
                                                        null
                                                    ? Image(
                                                        image: NetworkImage(
                                                            "https://www.searchpng.com/wp-content/uploads/2019/02/Men-Profile-Image-715x657.png"),
                                                        height: SizeConfig
                                                                .blockSizeVertical *
                                                            20,
                                                      )
                                                    : Image(
                                                        image: NetworkImage(baseUrl +
                                                            snapshot.data[i]
                                                                ["profile_path"]),
                                                        height: SizeConfig
                                                                .blockSizeVertical *
                                                            20,
                                                      )),
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical * 1,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left:
                                                    SizeConfig.blockSizeHorizontal *
                                                        1,
                                                right:
                                                    SizeConfig.blockSizeHorizontal *
                                                        1),
                                            child: Text(
                                              snapshot.data[i]["name"],
                                              style: TextStyle(
                                                  fontSize:
                                                      SizeConfig.blockSizeVertical *
                                                          1.8,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left:
                                                    SizeConfig.blockSizeHorizontal *
                                                        1,
                                                right:
                                                    SizeConfig.blockSizeHorizontal *
                                                        1),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "( " +
                                                  snapshot.data[i]["character"] +
                                                  " )",
                                              style: TextStyle(
                                                  fontSize:
                                                      SizeConfig.blockSizeVertical *
                                                          1.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              }),
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
//              SimilarMovies(
//                movieId: widget.id,
//              )
            ],
          ),
        )
      ],
    )
    );
  }
}
