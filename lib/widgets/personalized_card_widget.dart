import 'package:flutter/material.dart';
import 'package:moviesapp/home.dart';
import 'package:moviesapp/size_config/size_config.dart';

Container EnhancedCard({String text, IconData icon}){
  return Container(
    width: SizeConfig.blockSizeHorizontal * 42,
    height: 210,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: isDark
            ? Color.fromRGBO(61, 61, 61, 1)
            : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              spreadRadius: 0.01,
              blurRadius: 10,
              offset: Offset(0, 10)
          )
        ]
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 22,
          child: Text(
            text,
            style: TextStyle(
                fontSize: SizeConfig.blockSizeVertical * 2,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
            top: 22,
            left: 23,
            child: Icon(icon,
              size: SizeConfig.blockSizeHorizontal * 8,)
        ),
      ],
    ),
  );
}