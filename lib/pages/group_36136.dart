import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class Group36136 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
    Transform(
      transform: Matrix4.identity()..setRotationZ(-1.5742066255),
      child: Container(
        child: SizedBox(
          width: 293,
          height: 25,
          child: SvgPicture.asset(
            'assets/vectors/arrow_262_x2.svg',
          ),
        ),
      ),
    );
  }
}