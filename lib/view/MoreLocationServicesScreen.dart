import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/blocs/MoreLocationServicesBloc.dart';
import 'package:mobile/models/MoreLocationSevicesArgumentModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:provider/provider.dart';

import 'CustomTextWidget.dart';

class MoreLocationServicesScreen extends StatefulWidget {
  final Function(Stream, Function) showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final MoreLocationServicesArgumentModel moreLocationServicesArgumentModel;

  const MoreLocationServicesScreen({Key? key, required this.showApiLoaderCallback, required this.openActionSheetCallback, required this.moreLocationServicesArgumentModel}) : super(key: key);

  @override
  _MoreLocationServicesScreenState createState() =>
      _MoreLocationServicesScreenState();
}

class _MoreLocationServicesScreenState
    extends State<MoreLocationServicesScreen> with WidgetsBindingObserver {
  //bool _locationServicesSwitchState;

  Position? _position;

  late MoreLocationServicesBloc _bloc;

  @override
  void initState() {
    super.initState();

    //_locationServicesSwitchState = false;

    _bloc = MoreLocationServicesBloc();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      bool isLocationAllowed = await Utils.checkLocationPermission();

      widget.showApiLoaderCallback(
          _bloc.locationStream, () {
        _getLocationPosition();
      });
      _getLocationPosition();

      _bloc.profileId = widget.moreLocationServicesArgumentModel.profileId;
      _bloc.profileSelectedAnswerList = widget.moreLocationServicesArgumentModel.profileSelectedAnswerList;

      if(isLocationAllowed) {
        bool locationSwitchState = await Utils.getLocationSwitchState();

        if(locationSwitchState) {
          var moreLocationServicesProvider = Provider.of<MoreLocationServiceInfo>(context, listen: false);
          moreLocationServicesProvider.updateMoreLocationServicesInfo(true);
        }
      }
    });

    _listenToStream();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed)
      _bloc.locationSink.add(Constant.success);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _openSaveAndExitActionSheet();
        return false;
      },
      child: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        /*if(!_locationServicesSwitchState) {
                          Navigator.pop(context);
                        } else {
                          _openSaveAndExitActionSheet();
                        }*/
                        _openSaveAndExitActionSheet();
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
                              width: 20,
                              height: 20,
                              image: AssetImage(Constant.leftArrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: 'Settings',
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.moreBackgroundColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
                            child: CustomTextWidget(
                              text: Constant.locationServices,
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostMedium
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Consumer<MoreLocationServiceInfo>(
                              builder: (context, data, child) {
                                return CupertinoSwitch(
                                  value: data.getLocationServicesSwitchState(),
                                  onChanged: (bool state) {
                                    if (state) {
                                      _checkLocationPermission();
                                    } else {
                                      data.updateMoreLocationServicesInfo(state);
                                    }
                                  },
                                  activeColor: Constant.chatBubbleGreen.withOpacity(0.6),
                                  trackColor: Constant.chatBubbleGreen.withOpacity(0.2),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextWidget(
                        text: Constant.enablingLocationServices,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostMedium
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _getLocationPosition() async {
    Position? position = await Utils.determinePosition();
    debugPrint('Position????$position');
    _bloc.locationSink.add(Constant.success);
    _position = position;
  }

  Future<void> _checkLocationPermission() async {
    var moreLocationServiceInfo = Provider.of<MoreLocationServiceInfo>(context, listen: false);

    if(_position == null) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if(permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        //Navigator.pop(context);
        var result = await Utils.showConfirmationDialog(context, 'You haven\'t allowed Location permissions to MigraineMentor. If you want to access Location, please grant permission.','Permission Required!','Not now','Allow');
        if(result == 'Yes') {
          Geolocator.openAppSettings();
        }
      } else {
        moreLocationServiceInfo.updateMoreLocationServicesInfo(true);

        _position = await Utils.determinePosition();
        //Navigator.pop(context);
      }
    }

    if(_position != null) {
      moreLocationServiceInfo.updateMoreLocationServicesInfo(true);

      List<String> latLngList = [];
      latLngList.add(_position!.latitude.toString());
      latLngList.add(_position!.longitude.toString());
      //widget.selectedAnswerCallBack(widget.question.tag, jsonEncode(latLngList));
    }
  }

  Future<void> _openSaveAndExitActionSheet() async{
    var moreLocationServiceInfo = Provider.of<MoreLocationServiceInfo>(context, listen: false);

    if(_position == null) {
      Navigator.pop(context);
      return;
    }

    double lat = _position!.latitude;
    double lng = _position!.longitude;

    print('Lat???$lat????${_bloc.lat}');
    print('Lng???$lng????${_bloc.lng}');

    if(moreLocationServiceInfo.getLocationServicesSwitchState()) {
      var result = await widget.openActionSheetCallback(Constant.saveAndExitActionSheet, null);

      if(result != null && result is String) {
        if(result == Constant.saveAndExit) {
          await Utils.changeLocationSwitchState(moreLocationServiceInfo.getLocationServicesSwitchState());
          SelectedAnswers? locationSelectedAnswers = _bloc.profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileLocationTag);
          List<String> latLngValues = [_position!.latitude.toString(), _position!.longitude.toString()];

          if(locationSelectedAnswers == null) {
            _bloc.profileSelectedAnswerList.add(SelectedAnswers(questionTag: Constant.profileLocationTag, answer: jsonEncode(latLngValues)));
          } else {
            locationSelectedAnswers.answer = jsonEncode(latLngValues);
          }

          widget.showApiLoaderCallback(_bloc.stream, () {
            _bloc.enterDummyDataToStreamController();
            _bloc.editMyProfileData(context);
          });
          _bloc.editMyProfileData(context);
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      var result = await widget.openActionSheetCallback(Constant.saveAndExitActionSheet, null);

      if(result != null && result is String) {
        if (result == Constant.saveAndExit) {
          await Utils.changeLocationSwitchState(moreLocationServiceInfo.getLocationServicesSwitchState());

          _bloc.profileSelectedAnswerList.removeWhere((element) => element.questionTag == Constant.profileLocationTag);

          widget.showApiLoaderCallback(_bloc.stream, () {
            _bloc.enterDummyDataToStreamController();
            _bloc.editMyProfileData(context);
          });

          _bloc.editMyProfileData(context);
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  void _listenToStream() {
    _bloc.myProfileStream.listen((event) {
      if(event is String && event == Constant.success) {
        Navigator.pop(context);
      }
    });
  }
}

class MoreLocationServiceInfo with ChangeNotifier {
  bool _locationServicesSwitchState = false;

  bool getLocationServicesSwitchState() => _locationServicesSwitchState;

  updateMoreLocationServicesInfo(bool locationServicesSwitchState) {
    _locationServicesSwitchState = locationServicesSwitchState;
    notifyListeners();
  }
}
