import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moviesapp/size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class NewMovieDetails extends StatefulWidget {
  final String description, backdrop, poster, title, releaseDate, id;
  final double  vote;
  final int index;

  NewMovieDetails({
    this.description,
    this.backdrop,
    this.poster,
    this.title,
    this.releaseDate,
    this.vote,
    this.id,
    this.index,
  });


  @override
  _NewMovieDetailsState createState() => _NewMovieDetailsState();
}

class _NewMovieDetailsState extends State<NewMovieDetails> {
  final baseUrl = "https://image.tmdb.org/t/p/w500";
  final apiKey = "3926dff0d2826b265d5396981f90bd1c";
  String firstDesp;
  String secondDesp;
  bool flag = true;


  @override
  void initState() {
    if(widget.description.length > 150){
      firstDesp = widget.description.substring(0, 150);
      secondDesp = widget.description.substring(150, widget.description.length);
    }
    else{
      firstDesp = widget.description;
      secondDesp = "";
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          overflow: Overflow.visible,
          children: [
            ClipPath(
              clipper: ClippingClass(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  widget.backdrop != null ?
                  CachedNetworkImage(
                    imageUrl: baseUrl+widget.backdrop,
                    fit: BoxFit.fitHeight,
                  ) :
                  Container(),
                  getTrailerLink(),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*20),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  spreadRadius: 0.01,
                                  blurRadius: 10,
                                  offset: Offset(0, 10)
                              )
                            ]
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Hero(
                            transitionOnUserGestures: true,
                            tag: "moviePoster${widget.index}",
                            child: CachedNetworkImage(
                              imageUrl: baseUrl+widget.poster,
                              height: SizeConfig.blockSizeVertical*25,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: SizeConfig.blockSizeHorizontal*4,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: SizeConfig.blockSizeHorizontal*50,
                            child: Text(
                                widget.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28
                                ),
                            ),
                          ),

                          Container(
                            child: Row(
                              children: [
                                Text(
                                    widget.vote.toString(),
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 25
                                    ),
                                ),
                                SizedBox(width: SizeConfig.blockSizeHorizontal*4,),
                                StarRating(
                                  starCount: 5,
                                  size: 30,
                                  color: Colors.redAccent,
                                  borderColor: Colors.grey,
                                  rating: widget.vote/2,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical*4,),
                  Text(
                    "Story line",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25
                    ),
                  ),
                  Container(
                    width: SizeConfig.blockSizeHorizontal*90,
                    child: showDescription()
                  ),

                  SizedBox(height: SizeConfig.blockSizeVertical*4,),
                  showImages(),
                  SizedBox(height: SizeConfig.blockSizeVertical*4,),
                  showCast(),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDescription(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          flag ? (firstDesp + "...") : (firstDesp + secondDesp),
          style: TextStyle(
            fontSize: 18
          ),
        ),
        InkWell(
          onTap: (){
            setState(() {
              flag = !flag;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  flag ? "more" : "less",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
              ),
              SizedBox(width: 5,),
              Icon(flag ? MdiIcons.arrowDownCircle : MdiIcons.arrowUpCircle)
            ],
          ),
        )
      ],
    );
  }


  getImages()async{
    String link = "http://api.themoviedb.org/3/movie/" + widget.id + "/images?api_key=" + apiKey;
    var response = await http.get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    }
  }

  showImages(){
    return FutureBuilder(
      future: getImages(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Text("");
        }
        return
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Stills",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 25
              ),
            ),
            Container(
              height: SizeConfig.blockSizeVertical*15,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data["backdrops"].length,
                  itemBuilder: (context, i){
                    var image = snapshot.data["backdrops"][i];
                    if (image["file_path"] != null) {
                      return Container(
                        margin: EdgeInsets.only(right: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                          imageUrl: baseUrl+image["file_path"],
                    ),
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
    );
  }


  Future<dynamic> getMovieCast() async {
    String link = "http://api.themoviedb.org/3/movie/" + widget.id + "/credits?api_key=" + apiKey;
    var response = await http.get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var cast = data["cast"] as List;
      return cast;
    }
  }

  showCast(){
    return FutureBuilder(
      future: getMovieCast(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Actors",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical*1,),
              Container(
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 20,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, i) {
                      return Container(
                        width: SizeConfig.blockSizeHorizontal*30,
                        child: Column(
                          children: <Widget>[
                            snapshot.data[i]["profile_path"] == null ?
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider("https://www.searchpng.com/wp-content/uploads/2019/02/Men-Profile-Image-715x657.png"),
                              radius: 45,
                              backgroundColor: Colors.transparent,
                            ) :
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(baseUrl + snapshot.data[i]["profile_path"]),
                              radius: 45,
                              backgroundColor: Theme.of(context).accentColor,
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical*1,),
                            Container(
                              width: SizeConfig.blockSizeHorizontal*22,
                              child: Text(
                                snapshot.data[i]["name"],
                                style: TextStyle(
                                    fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          );
        }
        return Container();
      },
    );
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


  getTrailerLink(){
    return FutureBuilder(
      future: getVideoKey(),
      builder: (context, snap) {
        if (snap.hasData) {
          return RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            color: Colors.white,
            child: Icon(
              MdiIcons.play,
              color: Colors.red,
              size: 40
            ),
              onPressed: () async {
                if (await canLaunch(
                    "https://m.youtube.com/watch?v=" + snap.data)) {
                  await launch(
                      "https://m.youtube.com/watch?v=" + snap.data);
                }
              },
          );
        }
        return Text("");
      },
    );
  }
}



class ClippingClass extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height-40);
    path.quadraticBezierTo(size.width/4, size.height, size.width/2, size.height);
    path.quadraticBezierTo(size.width - (size.width/4), size.height, size.width, size.height-40);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }

}