
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/util/constant.dart';

class WebservicePost {
  static String qaServerUrl = "https://migrainementor.bontriage.com/mobileapi/v0/";
  //static String qaServerUrl = " https://migrainementor.bontriage.com/v0/";

  //static String qaServerUrl = "https://mobileapp.bontriage.com/mobileapi/v0/";
  //static String qaServerUrl = "http://34.222.200.187:8080/mobileapi/v0/";
  //static String qaServerUrl = "http://54.214.122.115:8080/mobileapi/v0/";
  static String productionServerUrl = "https://mobileapi3.bontriage.com:8181/mobileapi/v0/";

  /// MigraineMentor production url
  //static const String migraineMentorServerUrl = 'https://migrainementor.bontriage.com/mobileapi/v0/';

  /// MigraineMentor QA url
  //static const String migraineMentorServerUrl = 'https://mobileapp.bontriage.com/mobileapi/v0/';

  /// MigraineMentor Staging url
  static const String migraineMentorServerUrl = 'https://migrainementorstaging.bontriage.com/mobileapi/v0/';

  /// MigraineMentor Staging clone url
  //static const String migraineMentorServerUrl = 'https://migrainementorstagingclone.bontriage.com/mobileapi/v0/';


  /// Tonix production url
  //static const String tonixServerUrl = 'http://tonix.bontriage.com:8080/mobileapi/v0/';

  /// Tonix QA url
  static const String tonixServerUrl = 'https://mobileapp.bontriage.com/tonixqa/v0/';

  ///Sanare Prod
  //static const String sanareAPIUrl = 'http://api.bontriage.com:8080/SanareAPI/diagnostic';

  ///Sanare Staging & QA
  static const String sanareAPIUrl = 'http://api2.bontriage.com:8080/SanareAPI/diagnostic';

  /// This method is used to get server url on the basis of build flavor
  /// [context] is used to get the app config object
  static String getServerUrl(BuildContext context) {
    var appConfig = AppConfig.of(context);

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
      return migraineMentorServerUrl;
    else
      return tonixServerUrl;
  }
}
