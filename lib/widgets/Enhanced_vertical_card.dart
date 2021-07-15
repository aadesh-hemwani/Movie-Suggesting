import 'package:flutter/material.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/size_config/size_config.dart';

Container EnhancedVeritcalCard({BuildContext context, Widget child, bool enableGradient }){
  return Container(
    width: SizeConfig.blockSizeHorizontal * 90,
    height: SizeConfig.blockSizeVertical * 11,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),

        gradient: enableGradient? LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Theme
              .of(context)
              .accentColor, Theme
              .of(context)
              .accentColor
              .withGreen(230)
          ],
        ): null,

        color: !enableGradient ? isDark ? Color.fromRGBO(61, 61, 61, 1) : Colors.white : null,
        boxShadow:
        [
          enableGradient ?  BoxShadow(
              color: Colors.greenAccent.withBlue(220).withOpacity(
                  0.2),
              spreadRadius: 3,
              blurRadius: 15,
              offset: Offset(0, 10)
          ):
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.01,
              blurRadius: 20,
              offset: Offset(0, 10)
          )
        ]
    ),
    child: Center(
        child: child
    )
  );
}