
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';

class SocialSigninRepository{

  final String _apiKey = 'dJUl7lnX1UiBD01019rGfqnKc';
  final String _apiSecret = 'N7QrpklaD4cEZnQ4KTNAun0tm4S4S1O6Ip2R7X3EuTT26S3Svw';
  final String _redirectUrl = 'twittersdk://';

  ///Method that handles the user signup via Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    debugPrint('google access token????${googleAuth?.accessToken}');
    debugPrint('google idToken????${googleAuth?.idToken}');

    return googleUser;
  }

  ///Method that handles the user signup via Facebook
  Future<dynamic> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken?.token ?? '');

    final userData = await FacebookAuth.instance.getUserData();
    return userData['email'];
  }


  ///Method that handles the user signup via X
  Future<String?> signInWithX() async {
    // Create a TwitterLogin instance
    final twitterLogin = new TwitterLogin(
        apiKey: _apiKey,
        apiSecretKey: _apiSecret,
        redirectURI: _redirectUrl
    );

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );
    debugPrint('twitter access token????${authResult.authToken}');
    debugPrint('twitter secret????${authResult.authTokenSecret}');

    // Once signed in, return the UserCredential
     await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
     debugPrint('Twitter logged in');

    return (authResult.status == TwitterLoginStatus.loggedIn) ? authResult.user?.email : null;
  }

}