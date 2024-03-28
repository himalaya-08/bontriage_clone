import 'package:flutter/material.dart';
import 'package:mobile/main.dart';
import 'package:mobile/util/constant.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'AppConfig.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var configuredApp = AppConfig(
    appTitle: Constant.migraineMentorBuildFlavor,
    buildFlavor: Constant.migraineMentorBuildFlavor,
    appFlavour: Constant.migraineMentorBuildFlavor, //packageInfo.packageName,
    child: MyApp(),
  );
  await mainCommon(configuredApp);
  runApp(configuredApp);
}
