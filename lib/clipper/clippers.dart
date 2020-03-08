import 'package:flutter/material.dart';

class RigthEdgedClipper extends CustomClipper<Path>{

  @override
  Path getClip(Size size) {

    final path = new Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width-size.width*0.33, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;

  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper)=>false;
}

class BothEdgesClipper extends CustomClipper<Path>{


  @override
  Path getClip(Size size) {

    final path = new Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width-size.width*0.33, size.height);
    path.lineTo(0-size.width*0.33, size.height);
    path.close();
    return path;

  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper)=>false;
}

class LeftEdgeClipper extends CustomClipper<Path>{


  @override
  Path getClip(Size size) {

    final path = new Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0-size.width*0.33, size.height);
    path.close();
    return path;

  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper)=>false;
}

class RigthFillTriangleClipper extends CustomClipper<Path>{


  @override
  Path getClip(Size size) {

    final path = new Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width-size.width*0.33, size.height);
    path.close();

    return path;

  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper)=>false;
}
