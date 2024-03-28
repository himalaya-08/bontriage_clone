import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:mobile/main.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/health_privacy_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/health_grid_item_model.dart';
import '../util/constant.dart';
import 'CustomTextWidget.dart';
import 'package:collection/collection.dart';

import 'more_health_description_screen.dart';

class MoreHealthScreen extends StatefulWidget {
  final List<HealthDataType> healthDataTypeList;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final Future<dynamic> Function(BuildContext, String, dynamic) onPush;

  const MoreHealthScreen(
      {Key? key,
      required this.navigateToOtherScreenCallback,
      required this.healthDataTypeList,
      required this.onPush})
      : super(key: key);

  @override
  State<MoreHealthScreen> createState() => _MoreHealthScreenState();
}

class _MoreHealthScreenState extends State<MoreHealthScreen> {
  List<HealthGridItemModel> _healthGridItemModelList = [];
  ScrollController _scrollController = ScrollController();

  TextStyle _textStyle = TextStyle(
    color: Constant.locationServiceGreen,
    fontSize: 13,
    fontFamily: Constant.jostRegular,
  );

  @override
  void initState() {
    super.initState();

    _prepareHealthGridItemModelList();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkHealthAuthorization();
    });
  }

  ///fetches the user health data of the health types given
  Future<void> _fetchHealthData(
      List<HealthDataType> types, MoreHealthDataInfo data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime endTime = DateTime(2024, 2, 3);
    debugPrint("endtime??????${endTime.toIso8601String()}");
    //DateTime endTime = DateTime.now();
    DateTime startTime = endTime.subtract(const Duration(days: 7));
    startTime = DateTime(startTime.year, startTime.month, startTime.day);

    List<HealthDataAccess> permissions = [];

    types.forEach((element) {
      if (element == HealthDataType.HEADACHE_MILD ||
          element == HealthDataType.HEADACHE_MODERATE ||
          element == HealthDataType.HEADACHE_SEVERE)
        permissions.add(HealthDataAccess.WRITE);
      else
        permissions.add(HealthDataAccess.READ);
    });

    bool requested = await healthFactory.requestAuthorization(types,
        permissions: permissions);

    List<HealthDataPoint> dataPoints = [];

    if (requested) {
      MoreHealthDataInfo moreHealthDataInfo =
          Provider.of<MoreHealthDataInfo>(context, listen: false);
      moreHealthDataInfo.updateAuthorization(true);

      prefs.setBool(
          Constant.isHealthAuthorized, moreHealthDataInfo.isAuthorized);

      try {
        dataPoints = await healthFactory.getHealthDataFromTypes(
            startTime, endTime, types);
      } catch (error) {
        debugPrint('Caught exception in getting data: $error');
      }

      dataPoints = HealthFactory.removeDuplicates(dataPoints);

      List<HealthDataPoint> newPointsList = [];

      for (int i = 0; i < dataPoints.length; i++) {
        List<HealthDataPoint> tempDataPointsList = [];
        tempDataPointsList.add(dataPoints[i]);

        for (int j = i + 1; j < dataPoints.length; j++) {
          if (dataPoints[j].dateFrom.isAtSameMomentAs(dataPoints[i].dateFrom)) {
            tempDataPointsList.add(dataPoints[j]);
          } else {
            i = j - 1;
            break;
          }
        }

        newPointsList.addAll(tempDataPointsList.reversed.toList());
      }

      dataPoints = newPointsList;

      List<HealthDataPoint> bloodOxygenPoints = dataPoints
          .where((element) => element.type == HealthDataType.BLOOD_OXYGEN)
          .toList();
      List<HealthDataPoint> systolicBloodPressureDataPoints = dataPoints
          .where((element) =>
              element.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC)
          .toList();
      List<HealthDataPoint> diastolicBloodPressureDataPoints = dataPoints
          .where((element) =>
              element.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC)
          .toList();
      List<HealthDataPoint> bodyTemperaturePoints = dataPoints
          .where((element) => element.type == HealthDataType.BODY_TEMPERATURE)
          .toList();
      List<HealthDataPoint> electrodermalActivityPoints = dataPoints
          .where((element) =>
              element.type == HealthDataType.ELECTRODERMAL_ACTIVITY)
          .toList();
      List<HealthDataPoint> heartRatePoints = dataPoints
          .where((element) => element.type == HealthDataType.HEART_RATE)
          .toList();
      List<HealthDataPoint> restingHeartRatePoints = dataPoints
          .where((element) => element.type == HealthDataType.RESTING_HEART_RATE)
          .toList();
      List<HealthDataPoint> walkingHeartRatePoints = dataPoints
          .where((element) => element.type == HealthDataType.WALKING_HEART_RATE)
          .toList();
      List<HealthDataPoint> heartRateVariabilityPoints = dataPoints
          .where((element) =>
              element.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN)
          .toList();
      List<HealthDataPoint> exerciseTimePoints = dataPoints
          .where((element) => element.type == HealthDataType.EXERCISE_TIME)
          .toList();
      List<HealthDataPoint> moveMinutesPoints = dataPoints
          .where((element) => element.type == HealthDataType.MOVE_MINUTES)
          .toList();

      HealthDataPoint? bloodOxygenPoint =
          _getMostRecentHealthDataPoint(bloodOxygenPoints);
      HealthGridItemModel? bloodOxygenGridItem = _healthGridItemModelList
          .firstWhereOrNull((element) => element.title == Constant.bloodOxygen);
      if (bloodOxygenGridItem != null) {
        String bloodOxygenStringValue = '--';
        double? bloodOxygenValue =
            double.tryParse(bloodOxygenPoint?.value.toString() ?? '');

        if (bloodOxygenValue != null) {
          if (Platform.isIOS) {
            bloodOxygenValue = bloodOxygenValue * 100;

            bloodOxygenStringValue = bloodOxygenValue.toInt().toString();
          } else {
            bloodOxygenStringValue = bloodOxygenValue.toInt().toString();
          }
        }
        bloodOxygenGridItem.value = bloodOxygenStringValue;

        bloodOxygenGridItem.averageValue =
            '${Constant.averageValue} ${_getAverageValue(bloodOxygenPoints)?.toInt() ?? '--'}${Constant.healthDataUnitMap[Constant.bloodOxygen]}';
        bloodOxygenGridItem.dateFrom = bloodOxygenPoint?.dateFrom;
      }

      //todo: check for the latest
      HealthDataPoint? systolicBloodPressureDataPoint =
          _getMostRecentHealthDataPoint(systolicBloodPressureDataPoints);
      HealthDataPoint? diastolicBloodPressureDataPoint =
          _getMostRecentHealthDataPoint(diastolicBloodPressureDataPoints);
      HealthGridItemModel? bloodPressureGridItem =
          _healthGridItemModelList.firstWhereOrNull(
              (element) => element.title == Constant.bloodPressure);
      if (bloodPressureGridItem != null) {
        if (systolicBloodPressureDataPoint != null &&
            diastolicBloodPressureDataPoint != null) {
          bloodPressureGridItem.value =
              '${double.tryParse(systolicBloodPressureDataPoint.value.toString())?.toInt().toString()}/${double.tryParse(diastolicBloodPressureDataPoint.value.toString())?.toInt().toString()}';

          bloodPressureGridItem.averageValue =
              '${Constant.averageValue} ${_getAverageValue(systolicBloodPressureDataPoints)?.toInt() ?? '--'}/${_getAverageValue(diastolicBloodPressureDataPoints)?.toInt() ?? '--'} ${Constant.healthDataUnitMap[Constant.bloodPressure]}';

          bloodPressureGridItem.dateFrom =
              diastolicBloodPressureDataPoint.dateFrom;
        } else {
          bloodPressureGridItem.value = '--/--';
          bloodPressureGridItem.averageValue =
              '${Constant.averageValue} --/-- ${Constant.healthDataUnitMap[Constant.bloodPressure]}';
        }
      }

      HealthDataPoint? bodyTemperaturePoint =
          _getMostRecentHealthDataPoint(bodyTemperaturePoints);
      HealthGridItemModel? bodyTemperatureGridItem =
          _healthGridItemModelList.firstWhereOrNull(
              (element) => element.title == Constant.bodyTemperature);
      if (bodyTemperatureGridItem != null) {
        double? celsius =
            double.tryParse(bodyTemperaturePoint?.value.toString() ?? '');
        if (celsius != null) {
          double fahrenheit = (celsius * 9 / 5) + 32;

          int fractionDigits = Utils.countFractionDigits(fahrenheit);

          bodyTemperatureGridItem.value = fractionDigits > 2
              ? fahrenheit.toStringAsFixed(2)
              : fahrenheit.toString();

          fahrenheit =
              ((_getAverageValue(bodyTemperaturePoints) ?? 0) * 9 / 5) + 32;
          fractionDigits = Utils.countFractionDigits(fahrenheit);

          String averageValue = fractionDigits > 2
              ? fahrenheit.toStringAsFixed(2)
              : fahrenheit.toString();
          bodyTemperatureGridItem.averageValue =
              '${Constant.averageValue} $averageValue${Constant.healthDataUnitMap[Constant.bodyTemperature]}';

          bodyTemperatureGridItem.dateFrom = bodyTemperaturePoint?.dateFrom;
        }
      }

      HealthDataPoint? electrodermalActivityPoint =
          _getMostRecentHealthDataPoint(electrodermalActivityPoints);
      HealthGridItemModel? electrodermalGridItem =
          _healthGridItemModelList.firstWhereOrNull(
              (element) => element.title == Constant.electrodermalActivity);
      if (electrodermalGridItem != null) {
        String electrodermalActivityStringValue = '--';
        double? electrodermalActivityValue =
            double.tryParse(electrodermalActivityPoint?.value.toString() ?? '');

        if (electrodermalActivityValue != null) {
          if (Platform.isIOS) {
            electrodermalActivityValue = electrodermalActivityValue * 1e6;

            int fractionDigits = Utils.countFractionDigits(electrodermalActivityValue);

            electrodermalActivityStringValue =
                fractionDigits > 2 ? electrodermalActivityValue.toStringAsFixed(2) : electrodermalActivityValue.toString();
          } else {
            electrodermalActivityStringValue =
                electrodermalActivityValue.toInt().toString();
          }
        }
        electrodermalGridItem.value = electrodermalActivityStringValue;

        String averageValue = '--';
        double? value = _getAverageValue(electrodermalActivityPoints);

        if (value != null) {
          int fractionDigits = Utils.countFractionDigits(value);

          averageValue =
              fractionDigits > 2 ? value.toStringAsFixed(2) : value.toString();
        }
        electrodermalGridItem.averageValue =
            '${Constant.averageValue} $averageValue${Constant.healthDataUnitMap[Constant.electrodermalActivity]}';

        electrodermalGridItem.dateFrom = electrodermalActivityPoint?.dateFrom;
      }

      HealthDataPoint? heartRatePoint =
          _getMostRecentHealthDataPoint(heartRatePoints);
      HealthGridItemModel? heartRateGridItem = _healthGridItemModelList
          .firstWhereOrNull((element) => element.title == Constant.heartRate);
      if (heartRateGridItem != null) {
        heartRateGridItem.value =
            double.tryParse(heartRatePoint?.value.toString() ?? '')
                    ?.toInt()
                    .toString() ??
                '--';
        heartRateGridItem.averageValue =
            '${Constant.averageValue} ${_getAverageValue(heartRatePoints)?.toInt() ?? '--'} ${Constant.healthDataUnitMap[Constant.heartRate]}';

        heartRateGridItem.dateFrom = heartRatePoint?.dateFrom;
      }

      HealthDataPoint? restingHeartRatePoint =
          _getMostRecentHealthDataPoint(restingHeartRatePoints);
      HealthGridItemModel? restingHeartRateGridItem =
          _healthGridItemModelList.firstWhereOrNull(
              (element) => element.title == Constant.restingHeartRate);
      if (restingHeartRateGridItem != null) {
        restingHeartRateGridItem.value =
            double.tryParse(restingHeartRatePoint?.value.toString() ?? '')
                    ?.toInt()
                    .toString() ??
                '--';
        restingHeartRateGridItem.averageValue =
            '${Constant.averageValue} ${_getAverageValue(restingHeartRatePoints)?.toInt() ?? '--'} ${Constant.healthDataUnitMap[Constant.restingHeartRate]}';

        restingHeartRateGridItem.dateFrom = restingHeartRatePoint?.dateFrom;
      }

      HealthDataPoint? walkingHeartRatePoint =
          _getMostRecentHealthDataPoint(walkingHeartRatePoints);
      HealthGridItemModel? walkingHeartRateGridItem =
          _healthGridItemModelList.firstWhereOrNull(
              (element) => element.title == Constant.walkingHeartRate);
      if (walkingHeartRateGridItem != null) {
        walkingHeartRateGridItem.value =
            double.tryParse(walkingHeartRatePoint?.value.toString() ?? '')
                    ?.toInt()
                    .toString() ??
                '--';
        walkingHeartRateGridItem.averageValue =
            '${Constant.averageValue} ${_getAverageValue(walkingHeartRatePoints)?.toInt() ?? '--'} ${Constant.healthDataUnitMap[Constant.walkingHeartRate]}';

        walkingHeartRateGridItem.dateFrom = walkingHeartRatePoint?.dateFrom;
      }

      HealthDataPoint? heartRateVariabilityPoint =
          _getMostRecentHealthDataPoint(heartRateVariabilityPoints);
      HealthGridItemModel? heartRateVariabilityGridItem =
          _healthGridItemModelList.firstWhereOrNull(
              (element) => element.title == Constant.heartRateVariability);
      if (heartRateVariabilityGridItem != null) {
        heartRateVariabilityGridItem.value =
            double.tryParse(heartRateVariabilityPoint?.value.toString() ?? '')
                    ?.toInt()
                    .toString() ??
                '--';
        heartRateVariabilityGridItem.averageValue =
            '${Constant.averageValue} ${_getAverageValue(heartRateVariabilityPoints)?.toInt() ?? '--'} ${Constant.healthDataUnitMap[Constant.heartRateVariability]}';
        heartRateVariabilityGridItem.dateFrom =
            heartRateVariabilityPoint?.dateFrom;
      }

      List<MoreHealthDescriptionModel> moreHealthDescriptionModelList = [];

      List<double> totalMinList = [];

      for (int i = 0; i < exerciseTimePoints.length; i++) {
        double totalMin = 1;

        for (int j = i + 1; j < exerciseTimePoints.length; j++) {
          if (exerciseTimePoints[j].dateFrom.isAtSameMomentAs(
              exerciseTimePoints[j - 1]
                  .dateFrom
                  .subtract(Duration(minutes: 1)))) {
            totalMin++;
          } else {
            i = j - 1;
            break;
          }
        }

        totalMinList.add(totalMin);
        if (totalMin > 10) {
          moreHealthDescriptionModelList.add(MoreHealthDescriptionModel(
              vitalValue: totalMin.toInt().toString(),
              vitalTime: exerciseTimePoints[i].dateFrom,
              vitalUnit: ''));
        }
      }

      double avgTime = 0;

      for (double a in totalMinList) {
        avgTime = avgTime + a;
      }

      avgTime = avgTime / /*totalMinList.length*/7;
      HealthGridItemModel? exerciseTimeGridItem =
          _healthGridItemModelList.firstWhereOrNull(
              (element) => element.title == Constant.exerciseTime);
      if (exerciseTimeGridItem != null) {
        exerciseTimeGridItem.value = moreHealthDescriptionModelList.isNotEmpty
            ? moreHealthDescriptionModelList.first.vitalValue
            : '--';
        exerciseTimeGridItem.averageValue =
            '${Constant.averageValue} ${totalMinList.isNotEmpty ? avgTime.toInt() : '--'} ${Constant.healthDataUnitMap[Constant.exerciseTime]}';
        exerciseTimeGridItem.dateFrom =
            moreHealthDescriptionModelList.isNotEmpty
                ? moreHealthDescriptionModelList.first.vitalTime
                : null;
      }

      HealthDataPoint? moveMinutesPoint =
          _getMostRecentHealthDataPoint(moveMinutesPoints);
      HealthGridItemModel? moveMinutesGridItem = _healthGridItemModelList
          .firstWhereOrNull((element) => element.title == Constant.moveMinutes);
      if (moveMinutesGridItem != null) {
        moveMinutesGridItem.value =
            double.tryParse(moveMinutesPoint?.value.toString() ?? '')
                    ?.toInt()
                    .toString() ??
                '--';
        moveMinutesGridItem.averageValue =
            '${Constant.averageValue} ${_getAverageValue(moveMinutesPoints)?.toInt() ?? '--'} ${Constant.healthDataUnitMap[Constant.moveMinutes]}';
        moveMinutesGridItem.dateFrom = moveMinutesPoint?.dateFrom;
      }
    }
    data.setHealthDataPointsList(dataPoints);
  }

  ///gets the average value of the health data list given
  double? _getAverageValue(List<HealthDataPoint> healthDataPoints) {
    if (healthDataPoints.isNotEmpty) {
      double totalValue = 0;
      for (HealthDataPoint healthDataPoint in healthDataPoints) {
        if (Platform.isIOS) {
          if (healthDataPoint.type == HealthDataType.BLOOD_OXYGEN) {
            totalValue += double.parse(healthDataPoint.value.toString()) * 100;
          } else if (healthDataPoint.type ==
              HealthDataType.ELECTRODERMAL_ACTIVITY) {
            totalValue += double.parse(healthDataPoint.value.toString()) * 1e6;
          } else
            totalValue += double.parse(healthDataPoint.value.toString());
        } else
          totalValue += double.parse(healthDataPoint.value.toString());
      }

      HealthDataPoint healthDataPoint = healthDataPoints[0];

      debugPrint("EXERCISE_TIME?????${healthDataPoint.type.toString()}");
      if (healthDataPoint.type == HealthDataType.EXERCISE_TIME)
        debugPrint("EXERCISE_TIME?????$totalValue");

      return (healthDataPoint.type == HealthDataType.EXERCISE_TIME) ? totalValue / 7 : totalValue / healthDataPoints.length;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constant.backgroundBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: SafeArea(
            child: Consumer<MoreHealthDataInfo>(
              builder: (context, data, child) {
                return ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constant.moreBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(Constant.leftArrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: Constant.more,
                              style: TextStyle(
                                color: Constant.locationServiceGreen,
                                fontSize: 16,
                                fontFamily: Constant.jostRegular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: Platform.isAndroid || !data.isAuthorized,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constant.moreBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Image(
                              width: Platform.isAndroid ? 16 : 20,
                              height: Platform.isAndroid ? 16 : 20,
                              image: AssetImage(Platform.isAndroid
                                  ? Constant.googleFitIcon
                                  : Constant.appleHealthIcon),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: Platform.isIOS
                                  ? Constant.healthApp
                                  : Constant.googleFit,
                              style: TextStyle(
                                color: Constant.locationServiceGreen,
                                fontSize: 16,
                                fontFamily: Constant.jostRegular,
                              ),
                            ),
                            Expanded(child: Container()),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                if (!data.isAuthorized) {
                                  _fetchHealthData(
                                      widget.healthDataTypeList, data);
                                } else {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  await healthFactory.revokePermissions();
                                  await prefs.setBool(
                                      Constant.isHealthAuthorized, false);
                                  data.updateAuthorization(false);
                                }
                              },
                              child: CustomTextWidget(
                                text: data.isAuthorized
                                    ? 'Disconnect'
                                    : 'Connect',
                                style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostRegular,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 20, left: 15, right: 15),
                      child: CustomRichTextWidget(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: Platform.isIOS
                                  ? Constant.iosHealthConsentMessage
                                  : Constant.androidHealthConsentMessage,
                              style: _textStyle,
                            ),
                            TextSpan(
                                text: ' For more information ',
                                style: _textStyle),
                            TextSpan(
                              text: "click here",
                              style: _textStyle.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: Constant.locationServiceGreen,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                if (Platform.isAndroid) {
                                  showDialog<void>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.all(0),
                                          backgroundColor: Colors.transparent,
                                          content: HealthPrivacyDialog(),
                                        );
                                      });
                                } else {
                                  Uri uri = Uri.parse(Constant.privacyPolicyUrl);
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                                },
                            ),
                            TextSpan(text: '.', style: _textStyle),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: data.isAuthorized,
                      child: RawScrollbar(
                        thickness: 1.5,
                        radius: Radius.circular(2),
                        thumbColor: Constant.locationServiceGreen,
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: GridView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 175,
                            ),
                            itemCount: _healthGridItemModelList.length,
                            itemBuilder: (context, index) {
                              HealthGridItemModel model =
                                  _healthGridItemModelList[index];
                              List<MoreHealthDescriptionModel>
                                  healthDescriptionDataList =
                                  _getHealthDescriptionDataList(
                                      data.getHealthDataPointsList,
                                      Constant.vitalsTitleMap[model.title]!);
                              MoreHealthDescriptionArgumentModel argumentModel =
                                  MoreHealthDescriptionArgumentModel(
                                      title: model.title,
                                      moreHealthDescriptionModelList:
                                          healthDescriptionDataList);
                              return GestureDetector(
                                onTap: () async {
                                  if (model.value != '--' &&
                                      model.value != '--/--') {
                                    if (data.getIsFetchedHealthData) {
                                      Utils.sendAnalyticsEvent(Constant.healthComponentClicked, {
                                        'componentName': argumentModel.title,
                                      }, context);
                                      widget.onPush(
                                          context,
                                          TabNavigatorRoutes
                                              .moreHealthDescriptionScreenRoute,
                                          argumentModel);
                                    }
                                  } else {
                                    if (Platform.isIOS) {
                                      var result =
                                          await Utils.showConfirmationDialog(
                                              context,
                                              Constant.healthKitDialogContent,
                                              model.title,
                                              Platform.isAndroid
                                                  ? Constant.openGoogleFit
                                                  : Constant.openHealthApp,
                                              Constant.cancel);
                                      if (result == Constant.no) {
                                        Utils.customLaunch(
                                            Uri(scheme: 'x-apple-health'));
                                      }
                                    }
                                  }
                                },
                                child: Card(
                                  color: Color(0xff00292F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 18,
                                              child: model.icon,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: CustomTextWidget(
                                                text: model.title,
                                                style: TextStyle(
                                                  color: Constant
                                                      .locationServiceGreen,
                                                  fontSize: 16,
                                                  fontFamily:
                                                      Constant.jostRegular,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          textBaseline: TextBaseline.alphabetic,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 100,
                                              ),
                                              child: CustomTextWidget(
                                                text: model.value,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Constant
                                                      .locationServiceGreen,
                                                  fontSize: (model.title !=
                                                          Constant
                                                              .bloodPressure)
                                                      ? 28
                                                      : 22,
                                                  fontFamily:
                                                      Constant.jostMedium,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            CustomTextWidget(
                                              text: model.unit,
                                              style: TextStyle(
                                                color: Constant
                                                    .locationServiceGreen,
                                                fontSize: 14,
                                                fontFamily:
                                                    Constant.jostRegular,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: CustomTextWidget(
                                              text: model.averageValue,
                                              style: TextStyle(
                                                color: Constant
                                                    .locationServiceGreen
                                                    .withOpacity(0.6),
                                                fontSize: 11,
                                                fontFamily:
                                                    Constant.jostRegular,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ///fetches the data list for the health description screen
  List<MoreHealthDescriptionModel> _getHealthDescriptionDataList(
      List<HealthDataPoint> dataPoints, HealthDataType type) {
    List<MoreHealthDescriptionModel> moreHealthDescriptionModelList = [];
    if (type == HealthDataType.EXERCISE_TIME) {
      List<HealthDataPoint> typeDataPoints =
          dataPoints.where((element) => element.type == type).toList();

      String title = Constant.vitalsTitleMap.keys.firstWhere(
          (vitalTitle) => Constant.vitalsTitleMap[vitalTitle] == type,
          orElse: () => '--');

      for (int i = 0; i < typeDataPoints.length; i++) {
        double totalMin = 1;

        for (int j = i + 1; j < typeDataPoints.length; j++) {
          if (typeDataPoints[j].dateFrom.isAtSameMomentAs(
              typeDataPoints[j - 1].dateFrom.subtract(Duration(minutes: 1)))) {
            totalMin++;
          } else {
            i = j - 1;
            break;
          }
        }

        //if (totalMin > 10) {
          moreHealthDescriptionModelList.add(MoreHealthDescriptionModel(
              vitalValue: totalMin.toString(),
              vitalTime: typeDataPoints[i].dateFrom,
              vitalUnit: Constant.healthDataUnitMap[title] ?? ''));
        //}
      }
    } else if (type != HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
      List<HealthDataPoint> typeDataPoints =
          dataPoints.where((element) => element.type == type).toList();

      String title = Constant.vitalsTitleMap.keys.firstWhere(
          (vitalTitle) => Constant.vitalsTitleMap[vitalTitle] == type,
          orElse: () => '--');

      for (int i = 0; i < typeDataPoints.length; i++) {
        moreHealthDescriptionModelList.add(MoreHealthDescriptionModel(
            vitalValue:
                double.tryParse(typeDataPoints[i].value.toString())!.toString(),
            vitalTime: typeDataPoints[i].dateFrom,
            vitalUnit: Constant.healthDataUnitMap[title] ?? ''));
      }
    } else {
      List<HealthDataPoint> systolicBloodPressureDataPoints = dataPoints
          .where((element) =>
              element.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC)
          .toList();
      List<HealthDataPoint> diastolicBloodPressureDataPoints = dataPoints
          .where((element) =>
              element.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC)
          .toList();

      String title = Constant.vitalsTitleMap.keys.firstWhere(
          (vitalTitle) => Constant.vitalsTitleMap[vitalTitle] == type,
          orElse: () => '--');

      for (int i = 0; i < diastolicBloodPressureDataPoints.length; i++) {
        moreHealthDescriptionModelList.add(MoreHealthDescriptionModel(
            vitalValue:
                '${double.tryParse(systolicBloodPressureDataPoints[i].value.toString())!.toString()}/${double.tryParse(diastolicBloodPressureDataPoints[i].value.toString())!.toString()}',
            vitalTime: systolicBloodPressureDataPoints[i].dateFrom,
            vitalUnit: Constant.healthDataUnitMap[title] ?? ''));
      }
    }
    return (Platform.isAndroid) ? moreHealthDescriptionModelList.reversed.toList() : moreHealthDescriptionModelList.toList();
  }

  void _prepareHealthGridItemModelList() {
    debugPrint('Length??????${widget.healthDataTypeList.length}');
    widget.healthDataTypeList.forEach((healthDataTypeElement) {
      switch (healthDataTypeElement) {
        case HealthDataType.BLOOD_OXYGEN:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.bloodOxygen);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.oxygenIcon),
                  title: Constant.bloodOxygen,
                  unit: Constant.healthDataUnitMap[Constant.bloodOxygen] ?? '',
                  averageValue:
                      '${Constant.averageValue} --${Constant.healthDataUnitMap[Constant.bloodOxygen]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.bloodPressure);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.bloodPressureIcon),
                  title: Constant.bloodPressure,
                  unit:
                      Constant.healthDataUnitMap[Constant.bloodPressure] ?? '',
                  averageValue:
                      '${Constant.averageValue} --/-- ${Constant.healthDataUnitMap[Constant.bloodPressure]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.BODY_TEMPERATURE:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.bodyTemperature);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.thermometerIcon),
                  title: Constant.bodyTemperature,
                  unit: Constant.healthDataUnitMap[Constant.bodyTemperature] ??
                      '',
                  averageValue:
                      '${Constant.averageValue} --${Constant.healthDataUnitMap[Constant.bodyTemperature]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.HEART_RATE:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.heartRate);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.heartIcon),
                  title: Constant.heartRate,
                  unit: Constant.healthDataUnitMap[Constant.heartRate] ?? '',
                  averageValue:
                      '${Constant.averageValue} -- ${Constant.healthDataUnitMap[Constant.heartRate]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.heartRateVariability);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.heartRateVariabilityIcon),
                  title: Constant.heartRateVariability,
                  unit: Constant
                          .healthDataUnitMap[Constant.heartRateVariability] ??
                      '',
                  averageValue:
                      '${Constant.averageValue} -- ${Constant.healthDataUnitMap[Constant.heartRateVariability]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.RESTING_HEART_RATE:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.restingHeartRate);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.heartIcon),
                  title: Constant.restingHeartRate,
                  unit: Constant.healthDataUnitMap[Constant.restingHeartRate] ??
                      '',
                  averageValue:
                      '${Constant.averageValue} -- ${Constant.healthDataUnitMap[Constant.restingHeartRate]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.WALKING_HEART_RATE:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.walkingHeartRate);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.walkingIcon),
                  title: Constant.walkingHeartRate,
                  unit: Constant.healthDataUnitMap[Constant.walkingHeartRate] ??
                      '',
                  averageValue:
                      '${Constant.averageValue} -- ${Constant.healthDataUnitMap[Constant.walkingHeartRate]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.EXERCISE_TIME:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.exerciseTime);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.clockIcon),
                  title: Constant.exerciseTime,
                  unit: Constant.healthDataUnitMap[Constant.exerciseTime] ?? '',
                  averageValue:
                      '${Constant.averageValue} -- ${Constant.healthDataUnitMap[Constant.exerciseTime]}',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.MOVE_MINUTES:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.moveMinutes);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.clockIcon),
                  title: Constant.moveMinutes,
                  unit: Constant.healthDataUnitMap[Constant.moveMinutes] ?? '',
                  averageValue: '${Constant.averageValue} --',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        case HealthDataType.ELECTRODERMAL_ACTIVITY:
          HealthGridItemModel? healthGridItemModel =
              _healthGridItemModelList.firstWhereOrNull(
                  (element) => element.title == Constant.electrodermalActivity);

          if (healthGridItemModel == null) {
            _healthGridItemModelList.add(
              HealthGridItemModel(
                  icon: Image.asset(Constant.electrodermalActivityIcon),
                  title: Constant.electrodermalActivity,
                  unit: Constant
                          .healthDataUnitMap[Constant.electrodermalActivity] ??
                      '',
                  averageValue: '${Constant.averageValue} --',
                  value: '--',
                  dateFrom: null),
            );
          }
          break;
        default:
          debugPrint('Do Nothing!');
      }
    });
  }

  HealthDataPoint? _getMostRecentHealthDataPoint(
      List<HealthDataPoint> healthDataPointList) {
    if (healthDataPointList.isNotEmpty) {
      HealthDataPoint dataPoint = healthDataPointList[0];

      healthDataPointList.forEach((healthDataPointElement) {
        if (healthDataPointElement.dateFrom.isAfter(dataPoint.dateFrom)) {
          dataPoint = healthDataPointElement;
        }
      });

      return dataPoint;
    }
    return null;
  }

  Future<void> _checkHealthAuthorization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthorized = prefs.getBool(Constant.isHealthAuthorized) ?? false;

    if (isAuthorized) {
      MoreHealthDataInfo data =
          Provider.of<MoreHealthDataInfo>(context, listen: false);
      data.updateAuthorization(true);
      _fetchHealthData(widget.healthDataTypeList, data);
    }
  }
}

class MoreHealthDataInfo with ChangeNotifier {
  bool _isFetchedHealthData = false;
  bool _isAuthorized = false;

  ///this contains the list of data points of all the required health data types
  List<HealthDataPoint> _healthDataPointsList = [];

  bool get getIsFetchedHealthData => _isFetchedHealthData;

  bool get isAuthorized => _isAuthorized;

  ///Tells the medication section type
  List<HealthDataPoint> get getHealthDataPointsList => _healthDataPointsList;

  String heartRateValue = '--';
  String restingHeartRateValue = '--';
  String walkingHeartRateValue = '--';
  String heartRateVariabilityValue = '--';
  String exerciseTimeValue = '--';
  String bloodPressureValue = '--';
  String edaValue = '--';
  String bloodOxygenValue = '--';
  String bodyTemperatureValue = '--';

  ///Sets the medication section type
  void setHealthDataPointsList(List<HealthDataPoint> healthDataPointsList) {
    _healthDataPointsList = healthDataPointsList;
    _isFetchedHealthData = true;
    notifyListeners();
  }

  void updateAuthorization(bool auth) {
    _isAuthorized = auth;
    notifyListeners();
  }
}
