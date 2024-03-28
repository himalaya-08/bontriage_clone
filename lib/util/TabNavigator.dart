import 'package:flutter/material.dart';
import 'package:mobile/animations/SlideFromBottomPageRoute.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/view/CalendarScreen.dart';
import 'package:mobile/view/CalendarTriggersScreen.dart';
import 'package:mobile/view/CompareCompassScreen.dart';
import 'package:mobile/view/CompassScreen.dart';
import 'package:mobile/view/DiscoverScreen.dart';
import 'package:mobile/view/MeScreen.dart';
import 'package:mobile/view/MoreAgeScreen.dart';
import 'package:mobile/view/MoreEmailScreen.dart';
import 'package:mobile/view/MoreFaqScreen.dart';
import 'package:mobile/view/MoreGenderScreen.dart';
import 'package:mobile/view/MoreGeneralProfileSettingsScreen.dart';
import 'package:mobile/view/MoreGenerateReportScreen.dart';
import 'package:mobile/view/MoreHeadacheTypeScreen.dart';
import 'package:mobile/view/MoreHeadachesScreen.dart';
import 'package:mobile/view/MoreLocationServicesScreen.dart';
import 'package:mobile/view/MoreMedicationScreen.dart';
import 'package:mobile/view/MoreMyProfileScreen.dart';
import 'package:mobile/view/MoreNameScreen.dart';
import 'package:mobile/view/MoreNotificationScreen.dart';
import 'package:mobile/view/MoreScreen.dart';
import 'package:mobile/view/MoreSettingScreen.dart';
import 'package:mobile/view/MoreSexScreen.dart';
import 'package:mobile/view/MoreSupportScreen.dart';
import 'package:mobile/view/MoreTriggersScreen.dart';
import 'package:mobile/view/more_voice_selection_screen.dart';
import 'package:mobile/view/PDFScreen.dart';
import 'package:mobile/view/RecordScreen.dart';
import 'package:mobile/view/TrendsScreen.dart';
import 'package:mobile/view/more_health_description_screen.dart';
import 'package:mobile/view/more_health_screen.dart';
import 'package:provider/provider.dart';
import '../models/PDFScreenArgumentModel.dart';
import '../view/MoreMenstruationScreen.dart';

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String root;
  final Future<dynamic> Function(String,dynamic) openActionSheetCallback;
  final Function(Stream, Function) showApiLoaderCallback;
  final Function(GlobalKey, GlobalKey) getButtonsGlobalKeyCallback;

  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;

  final Function(Questions questions, Function(int) selectedAnswerCallback) openTriggerMedicationActionSheetCallback;
  final Function(
      List<String> listData, String initialData,  int initialIndex, bool month, Function(String ,int) selectedAgeCallback, bool disableFurtherOptions) openBirthDateBottomSheet;
  final Future<DateTime> Function (MonthYearCupertinoDatePickerMode, Function, DateTime) openDatePickerCallback;
  final Stream pushNotificationStream;

  TabNavigator({required this.navigatorKey, required this.root, required this.openActionSheetCallback, required this.navigateToOtherScreenCallback, required this.openTriggerMedicationActionSheetCallback, required this.showApiLoaderCallback, required this.getButtonsGlobalKeyCallback, required this.openDatePickerCallback, required this.pushNotificationStream, required this.openBirthDateBottomSheet});


  Future<dynamic> _push(BuildContext context, String routeName, dynamic argument) async {
    var routeBuilders = _routeBuilders(context, argument);

    debugPrint('RouteName???$routeName');

    return await Navigator.push(
        context,
        routeName == TabNavigatorRoutes.pdfScreenRoute ? SlideFromBottomPageRoute(
          widget: routeBuilders[routeName]!(context),
        ) : PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              routeBuilders[routeName]!(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeIn;

            var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 350),
          settings: RouteSettings(name: routeName),
        ));
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, dynamic arguments) {
    if (arguments is PDFScreenArgumentModel)
      arguments.onPush = _push;

    return {
      TabNavigatorRoutes.root: (context) {
        return Container();
      },
      TabNavigatorRoutes.meRoot: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => OnBoardAssessIncompleteInfo(),
          ),
          ChangeNotifierProvider(
            create: (context) => CurrentUserHeadacheInfo(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserNameInfo(),
          ),
        ],
        child: MeScreen(
          navigateToOtherScreenCallback: navigateToOtherScreenCallback,
          showApiLoaderCallback: showApiLoaderCallback,
          getButtonsGlobalKeyCallback: getButtonsGlobalKeyCallback,
          pushNotificationStream: pushNotificationStream,
        ),

      ),
      TabNavigatorRoutes.pdfScreenRoute: (context) => PDFScreen(
        pdfScreenArgumentModel: arguments,
      ),
      TabNavigatorRoutes.recordsRoot: (context) =>
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => CalendarInfo(),
              ),
              ChangeNotifierProvider(
                create: (context) => CalendarTriggerInfo(),
              ),
              ChangeNotifierProvider(
                create: (context) => CompassInfo(),
              ),
              ChangeNotifierProvider(
                create: (context) => CompareCompassInfo(),
              ),
              ChangeNotifierProvider(
                create: (context) => TrendsInfo(),
              ),
            ],
            child: RecordScreen(
              onPush: (context, routeName) {
                _push(context, routeName, arguments);
              },
              navigateToOtherScreenCallback: navigateToOtherScreenCallback,
              showApiLoaderCallback: showApiLoaderCallback,
              openActionSheetCallback: openActionSheetCallback,
              openDatePickerCallback: openDatePickerCallback,
            ),
          ),
      TabNavigatorRoutes.discoverRoot: (context) =>
          DiscoverScreen(onPush: (context, routeName) {
            _push(context, routeName, arguments);
          }),
      TabNavigatorRoutes.moreRoot: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MoreSettingNotificationInfo(),
          ),
        ],
        child: MoreScreen(
          onPush: _push,
          openActionSheetCallback: openActionSheetCallback,
          showApiLoaderCallback: showApiLoaderCallback,
          navigateToOtherScreenCallback: navigateToOtherScreenCallback,
        ),
      ),
      TabNavigatorRoutes.moreSettingRoute: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MoreSettingNotificationInfo(),
          ),
          ChangeNotifierProvider(
            create: (_) => MoreSettingLocationInfo(),
          ),
        ],
        child: MoreSettingScreen(
          onPush: _push,
          showApiLoaderCallback: showApiLoaderCallback,
          navigateToOtherScreenCallback: navigateToOtherScreenCallback,
        ),
      ),
      TabNavigatorRoutes.moreMyProfileScreenRoute: (context) => ChangeNotifierProvider(
        create: (_) => MoreTriggerMedicationInfo(),
        child: MoreMyProfileScreen(
          onPush: _push,
          showApiLoaderCallback: showApiLoaderCallback,
        ),
      ),
      TabNavigatorRoutes.moreHeadacheTypesScreenRoute: (context) => MoreHeadacheTypeScreen(
        onPush: _push,
        showApiLoaderCallback: showApiLoaderCallback,
        navigateToOtherScreenCallback: navigateToOtherScreenCallback,
      ),
      TabNavigatorRoutes.moreGenerateReportRoute: (context) =>
          MoreGenerateReportScreen(
            onPush: _push,
            openActionSheetCallback: openActionSheetCallback,
            navigateToOtherScreenCallback: navigateToOtherScreenCallback,
          ),
      TabNavigatorRoutes.moreSupportRoute: (context) => MoreSupportScreen(
        onPush: _push,
        navigateToOtherScreenCallback: navigateToOtherScreenCallback,
      ),
      TabNavigatorRoutes.moreFaqScreenRoute: (context) => MoreFaqScreen(),
      TabNavigatorRoutes.moreNotificationScreenRoute: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MoreNotificationSwitchInfo(),
          ),
          ChangeNotifierProvider(
            create: (_) => MoreNotificationInfo(),
          ),
        ],
        child: MoreNotificationScreen(
          openActionSheetCallback: openActionSheetCallback,
        ),
      ),
      TabNavigatorRoutes.moreHeadachesScreenRoute: (context) => MoreHeadachesScreen(
        openActionSheetCallback: openActionSheetCallback,
        moreHeadacheScreenArgumentModel: arguments,
        showApiLoaderCallback: showApiLoaderCallback,
        navigateToOtherScreenCallback: navigateToOtherScreenCallback,
        onPush: _push,
      ),
      TabNavigatorRoutes.moreLocationServicesScreenRoute: (context) => ChangeNotifierProvider(
        create: (context) => MoreLocationServiceInfo(),
        child: MoreLocationServicesScreen(
          showApiLoaderCallback: showApiLoaderCallback,
          openActionSheetCallback: openActionSheetCallback,
          moreLocationServicesArgumentModel: arguments,
        ),
      ),

      TabNavigatorRoutes.moreGeneralProfileSettingsRoute: (context) => MoreGeneralProfileSettingsScreen(
        moreGeneralProfileSettingsArgumentModel: arguments,
        openActionSheetCallback: openActionSheetCallback,
        onPush: _push,
        showApiLoaderCallback: showApiLoaderCallback,
      ),
      TabNavigatorRoutes.moreVoiceSelectionScreenRoute: (context) => ChangeNotifierProvider(
        create: (_) => MoreVoiceSelectionScreenInfo(),
        child: MoreVoiceSelectionScreen(openSelectVoiceActionSheetCallback: openActionSheetCallback,),
      ),
      TabNavigatorRoutes.moreNameScreenRoute: (context) => MoreNameScreen(
        selectedAnswerList: arguments,
        openActionSheetCallback: openActionSheetCallback,
      ),
      TabNavigatorRoutes.moreAgeScreenRoute: (context) => ChangeNotifierProvider(
        create: (context) => MoreAgeInfo(),
        child: MoreAgeScreen(
            selectedAnswerList: arguments,
            openActionSheetCallback: openActionSheetCallback,
            openBirthDateBottomSheet: openBirthDateBottomSheet
        ),
      ),
      TabNavigatorRoutes.moreGenderScreenRoute: (context) => ChangeNotifierProvider(
        create: (_) => MoreGenderInfo(),
        child: MoreGenderScreen(
          selectedAnswerList: arguments,
          openActionSheetCallback: openActionSheetCallback,
        ),
      ),
      TabNavigatorRoutes.moreMenstruationScreenRoute: (context) => ChangeNotifierProvider(
        create: (_) => MoreInfo(),
        child: MoreMenstruationScreen(
          selectedAnswerList: arguments,
          openActionSheetCallback: openActionSheetCallback,
        ),
      ),
      TabNavigatorRoutes.moreSexScreenRoute: (context) => ChangeNotifierProvider(
        create: (_) => MoreSexInfo(),
        child: MoreSexScreen(
          selectedAnswerList: arguments,
          openActionSheetCallback: openActionSheetCallback,
        ),
      ),
      TabNavigatorRoutes.moreTriggersScreenRoute: (context) => MoreTriggersScreen(
        openTriggerMedicationActionSheetCallback: openTriggerMedicationActionSheetCallback,
        openActionSheetCallback: openActionSheetCallback,
        moreTriggersArgumentModel: arguments,
        showApiLoaderCallback: showApiLoaderCallback,
      ),
      TabNavigatorRoutes.moreMedicationsScreenRoute: (context) => MoreMedicationScreen(
        openTriggerMedicationActionSheetCallback: openTriggerMedicationActionSheetCallback,
        moreMedicationArgumentModel: arguments,
        showApiLoaderCallback: showApiLoaderCallback,
        openActionSheetCallback: openActionSheetCallback,
      ),
      TabNavigatorRoutes.moreEmailScreenRoute: (context) => MoreEmailScreen(
        email: arguments,
        openActionSheetCallback: openActionSheetCallback,
        showApiLoaderCallback: showApiLoaderCallback,
        navigateToOtherScreenCallback: navigateToOtherScreenCallback,
      ),
      TabNavigatorRoutes.moreHealthScreenRoute: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MoreHealthDataInfo(),
          ),
        ],
        child: MoreHealthScreen(
          healthDataTypeList: arguments,
          navigateToOtherScreenCallback: navigateToOtherScreenCallback,
          onPush: _push,
        ),
      ),
      TabNavigatorRoutes.moreHealthDescriptionScreenRoute: (context) => MoreHealthDescriptionScreen(moreHealthDescriptionArgumentModel: arguments,)
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context, null);

    debugPrint('in build func of tab navigator');

    return Navigator(
      key: navigatorKey,
      initialRoute: root,
      onGenerateRoute: (routeSettings) {
        debugPrint('Route name ${routeSettings.name}');
        return MaterialPageRoute(
          builder: (context) {
            debugPrint('in material page route');
            return routeBuilders[routeSettings.name]!(context);
          },
          settings: RouteSettings(name: routeSettings.name),
        );
      },
    );
  }
}