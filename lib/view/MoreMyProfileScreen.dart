import 'package:flutter/material.dart';
import 'package:mobile/blocs/MoreMyProfileBloc.dart';
import 'package:mobile/models/MoreGeneralProfileSettingsArgumentModel.dart';
import 'package:mobile/models/MoreMedicationArgumentModel.dart';
import 'package:mobile/models/MoreTriggerArgumentModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/MoreSection.dart';
import 'package:provider/provider.dart';

class MoreMyProfileScreen extends StatefulWidget {
  final Future<dynamic> Function(BuildContext, String, dynamic) onPush;
  final Function(String)? openActionSheetCallback;
  final Function(Stream, Function) showApiLoaderCallback;

  const MoreMyProfileScreen({Key? key, required this.onPush, this.openActionSheetCallback, required this.showApiLoaderCallback})
      : super(key: key);

  @override
  _MoreMyProfileScreenState createState() => _MoreMyProfileScreenState();
}

class _MoreMyProfileScreenState extends State<MoreMyProfileScreen> {
  MoreMyProfileBloc _moreMyProfileBloc = MoreMyProfileBloc();


  @override
  void initState() {
    super.initState();
    _moreMyProfileBloc = MoreMyProfileBloc();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _moreMyProfileBloc.initNetworkStreamController();
      widget.showApiLoaderCallback(_moreMyProfileBloc.networkStream, () {
        _moreMyProfileBloc.enterSomeDummyData();
        _moreMyProfileBloc.fetchMyProfileData(context);
      });
      _moreMyProfileBloc.fetchMyProfileData(context);
    });
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
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
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
                                fontFamily: Constant.jostRegular),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  StreamBuilder<dynamic>(
                    stream: _moreMyProfileBloc.myProfileStream,
                    builder: (context, snapshot) {
                      if(snapshot.hasData && snapshot.data is ResponseModel && snapshot.data != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Constant.moreBackgroundColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MoreSection(
                                    currentTag: Constant.generalProfileSettings,
                                    text: Constant.generalProfileSettings,
                                    moreStatus: '',
                                    isShowDivider: false,
                                    navigateToOtherScreenCallback: _navigateToOtherScreen,
                                    selectedAnswerList: _moreMyProfileBloc.profileSelectedAnswerList,
                                  ),
                                ],
                              ),
                            ),
                            _getHeadacheTypeWidget(snapshot.data.headacheList),
                            SizedBox(height: 30,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: CustomTextWidget(
                                text: Constant.myMedicationsAndTriggers,
                                style: TextStyle(
                                    color: Constant.addCustomNotificationTextColor,
                                    fontSize: 16,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Constant.moreBackgroundColor,
                              ),
                              child: Consumer<MoreTriggerMedicationInfo>(
                                builder: (context, data, child) {
                                  return _getTriggerMedicationWidget(snapshot.data);
                                },
                              ),
                            ),
                            SizedBox(height: 20,),
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOtherScreen(String routeName, dynamic arguments) async {
    if (routeName == TabNavigatorRoutes.moreGeneralProfileSettingsRoute) {
      if (arguments is List<SelectedAnswers>) {
        arguments = MoreGeneralProfileSettingsArgumentModel(
            selectedAnswerList: arguments,
            profileId: _moreMyProfileBloc.profileId,
            responseModel: _moreMyProfileBloc.getResponseModel
        );
      }
    }
    var result = await
    widget.onPush(context, routeName, arguments);
    if(result != null) {
      if(result is bool && result) {
        //if(_moreMyProfileBloc.profileSelectedAnswerList.length >= 4) {
        _moreMyProfileBloc.initNetworkStreamController();
        widget.showApiLoaderCallback(_moreMyProfileBloc.networkStream, () {
          _moreMyProfileBloc.enterSomeDummyData();
          _moreMyProfileBloc.editMyProfileServiceCall(context);
        });
        _moreMyProfileBloc.editMyProfileServiceCall(context);
        //}
      } else if (result is String && result == 'Event Deleted') {
        _moreMyProfileBloc.initNetworkStreamController();
        widget.showApiLoaderCallback(_moreMyProfileBloc.networkStream, () {
          _moreMyProfileBloc.enterSomeDummyData();
          _moreMyProfileBloc.fetchMyProfileData(context);
        });
        _moreMyProfileBloc.fetchMyProfileData(context);
      } else if(routeName == TabNavigatorRoutes.moreTriggersScreenRoute ||
          routeName == TabNavigatorRoutes.moreMedicationsScreenRoute) {
        var moreTriggerMedicationInfo = Provider.of<MoreTriggerMedicationInfo>(context, listen: false);
        moreTriggerMedicationInfo.updateMoreTriggerMedicationInfo();
      } else if (result is MoreGeneralProfileSettingsArgumentModel) {
        _moreMyProfileBloc.profileId = result.profileId;
      }
    }
    else{
/*      _moreMyProfileBloc.initNetworkStreamController();
      widget.showApiLoaderCallback(_moreMyProfileBloc.networkStream, () {
        _moreMyProfileBloc.enterSomeDummyData();
        _moreMyProfileBloc.fetchMyProfileData(context);
      });
      _moreMyProfileBloc.fetchMyProfileData(context);*/
    }
  }

  @override
  void dispose() {
    _moreMyProfileBloc.dispose();
    super.dispose();
  }

  Widget _getHeadacheTypeWidget(List<HeadacheTypeData> headacheList) {
    List<Widget> headacheTypeWidgetList = [];

    headacheList.asMap().forEach((index, value) {
      headacheTypeWidgetList.add(
        MoreSection(
          currentTag: Constant.headacheType,
          text: (value.isMigraine!) ? '${value.text} (Migraine)' : '${value.text} (Headache)',
          moreStatus: '',
          isShowDivider: index != headacheList.length - 1,
          navigateToOtherScreenCallback: _navigateToOtherScreen,
          headacheTypeData: value,
          isFromMyProfile: true,
        ),
      );
    });

    return headacheList.length == 0 ? Container() : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CustomTextWidget(
            text: Constant.headacheTypes,
            style: TextStyle(
                color: Constant.addCustomNotificationTextColor,
                fontSize: 16,
                fontFamily: Constant.jostMedium
            ),
          ),
        ),
        SizedBox(height: 10,),
        Container(
          padding:
          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Constant.moreBackgroundColor,
          ),
          child: Column(
            children: headacheTypeWidgetList,
          ),
        ),
      ],
    );
  }

  Widget _getTriggerMedicationWidget(ResponseModel responseModel) {
    List<Values> triggerValues = responseModel.triggerValues!;
    triggerValues.forEach((element) {
      element.isSelected = false;
    });
    List<Values> medicationValues = responseModel.medicationValues!;
    medicationValues.forEach((element) {
      element.isSelected = false;
    });
    List<SelectedAnswers> selectedAnswerList = [];
    if(responseModel.triggerMedicationValues!.length > 0)
      _moreMyProfileBloc.setSelectedAnswerList(selectedAnswerList, responseModel.triggerMedicationValues![0]);
    else
      _moreMyProfileBloc.setSelectedAnswerList(selectedAnswerList, null);
    return Column(
      children: [
        MoreSection(
          currentTag: Constant.myMedications,
          text: Constant.myMedications,
          moreStatus: '',
          isShowDivider: true,
          navigateToOtherScreenCallback: _navigateToOtherScreen,
          moreMedicationArgumentModel: MoreMedicationArgumentModel(
            eventId: responseModel.triggerMedicationValues!.length > 0 ? responseModel.triggerMedicationValues![0].id.toString() : null,
            medicationValues: medicationValues,
            responseModel: responseModel,
            selectedAnswerList: selectedAnswerList,
          ),
        ),
        MoreSection(
          currentTag: Constant.myTriggers,
          text: Constant.myTriggers,
          moreStatus: '',
          isShowDivider: false,
          navigateToOtherScreenCallback: _navigateToOtherScreen,
          moreTriggersArgumentModel: MoreTriggersArgumentModel(
              eventId: responseModel.triggerMedicationValues!.length > 0 ? responseModel.triggerMedicationValues![0].id.toString() : null,
              triggerValues: triggerValues,
              responseModel: responseModel,
              selectedAnswerList: selectedAnswerList
          ),
        ),
      ],
    );
  }
}

class MoreTriggerMedicationInfo with ChangeNotifier {
  updateMoreTriggerMedicationInfo() {
    notifyListeners();
  }
}