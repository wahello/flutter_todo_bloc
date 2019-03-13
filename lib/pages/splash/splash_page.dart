import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SvgPicture.asset(
          'assets/todo_list.svg',
          width: 200,
        ),
      ),
    );
  }
}
