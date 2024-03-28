import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/PhotoHero.dart';
import 'package:mobile/util/constant.dart';

class SignUpOnBoardSplash extends StatefulWidget {
  @override
  _SignUpOnBoardSplashState createState() => _SignUpOnBoardSplashState();
}

class _SignUpOnBoardSplashState extends State<SignUpOnBoardSplash> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 2000), () {
        Navigator.of(context).pushReplacementNamed(Constant.signUpOnBoardBubbleTextViewRouter);
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: Center(
          child: PhotoHero(
            photo: Constant.userAvatar,
            width: 130.0,
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return true;
  }
}
