import 'dart:io';
import 'package:collection/collection.dart';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/blocs/LogStudyMedicationBloc.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';

class LogStudyMedicationDialog extends StatefulWidget {
  final Function(Stream, Function) showApiLoaderCallback;
  final DateTime dateTime;
  final bool isYesterdayLog;

  const LogStudyMedicationDialog(
      {Key? key,
      required this.showApiLoaderCallback,
        required this.dateTime,
      this.isYesterdayLog = false})
      : super(key: key);

  @override
  _LogStudyMedicationDialogState createState() =>
      _LogStudyMedicationDialogState();
}

class _LogStudyMedicationDialogState extends State<LogStudyMedicationDialog> {
  LogStudyMedicationBloc _bloc = LogStudyMedicationBloc();

  SignUpOnBoardSelectedAnswersModel _signUpOnBoardSelectedAnswersModel = SignUpOnBoardSelectedAnswersModel();

  bool _isButtonClicked = false;

  @override
  void initState() {
    super.initState();

    _bloc = LogStudyMedicationBloc();
    _signUpOnBoardSelectedAnswersModel = SignUpOnBoardSelectedAnswersModel();
    _signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    _signUpOnBoardSelectedAnswersModel.selectedAnswers
        !.add(SelectedAnswers(questionTag: Constant.amDoseTag, answer: '0'));
    _signUpOnBoardSelectedAnswersModel.selectedAnswers
        !.add(SelectedAnswers(questionTag: Constant.pmDoseTag, answer: '0'));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var logStudyMedicationProvider =
          Provider.of<LogStudyMedicationInfo>(context, listen: false);
      widget.showApiLoaderCallback(_bloc.fetchDataStream, () {
        _bloc.enterSomeDummyData();
        _bloc.fetchLogStudyMedicationData(_signUpOnBoardSelectedAnswersModel,
            logStudyMedicationProvider, widget.dateTime, context);
      });

      _bloc.fetchLogStudyMedicationData(_signUpOnBoardSelectedAnswersModel,
          logStudyMedicationProvider, widget.dateTime, context);
    });

    _listenToSendStream();

    debugPrint('widget.isYesterdayLog????${widget.isYesterdayLog}');
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Constant.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding:  EdgeInsets.symmetric(
                  vertical: 20, horizontal: Platform.isAndroid ?10:20),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      CustomTextWidget(
                        text: 'Log Study Medication',
                        style: TextStyle(
                            fontSize: 16,
                            color: Constant.chatBubbleGreen,
                            fontFamily: Constant.jostMedium),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image(
                          image: AssetImage(Constant.closeIcon),
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextWidget(
                    text: !widget.isYesterdayLog
                        ? 'Did you take your study medication today?'
                        : 'Did you take your study medication yesterday?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Platform.isAndroid ? 13 : 14,
                      color: Constant.locationServiceGreen,
                      fontFamily: Constant.jostRegular,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Consumer<LogStudyMedicationInfo>(
                    builder: (context, data, child) {
                      return Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _getLogStudyMedicationWidget(
                                  data.getLogStudyMedicationList()[0]),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: _getLogStudyMedicationWidget(
                                  data.getLogStudyMedicationList()[1]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Consumer<LogStudyMedicationErrorInfo>(
                    builder: (context, data, child) {
                      return Visibility(
                        visible: data.isShowAlert(),
                        child: Container(
                          margin: EdgeInsets.only(left: 20, right: 10, top: 10),
                          child: Row(
                            children: [
                              Image(
                                image: AssetImage(Constant.warningPink),
                                width: 17,
                                height: 17,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              CustomTextWidget(
                                text: data.getErrorMessage(),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Constant.pinkTriggerColor,
                                    fontFamily: Constant.jostRegular),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BouncingWidget(
                        onPressed: () {
                          if (!_isButtonClicked) {
                            _isButtonClicked = true;
                            var errorInfo =
                            Provider.of<LogStudyMedicationErrorInfo>(context,
                                listen: false);

                            errorInfo.updateLoginErrorInfo(
                                false, Constant.blankString);

                            widget.showApiLoaderCallback(_bloc.sendDataStream,
                                    () {
                                  _bloc.enterSomeDummyData();
                                  _bloc.sendLogStudyMedicationData(
                                      _signUpOnBoardSelectedAnswersModel,
                                      widget.dateTime,
                                      context);
                                });

                            _bloc.sendLogStudyMedicationData(
                                _signUpOnBoardSelectedAnswersModel,
                                widget.dateTime, context);
                          }
                        },
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Constant.chatBubbleGreen,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: CustomTextWidget(
                              text: Constant.save,
                              style: TextStyle(
                                  color: Constant.bubbleChatTextView,
                                  fontSize: 15,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getLogStudyMedicationWidget(LogStudyMedicationList element) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 30,
          child: Theme(
              data: ThemeData(
                  unselectedWidgetColor: Constant.editTextBoarderColor),
              child: Checkbox(
                value: element.isSelected,
                checkColor: Constant.bubbleChatTextView,
                activeColor: Constant.chatBubbleGreen,
                focusColor: Constant.chatBubbleGreen,
                splashRadius: 20,
                autofocus: true,
                onChanged: (bool? value) async {
                  DateTime currentDateTime = DateTime.now();

                  DateTime threePMDateTime = DateTime(
                      currentDateTime.year,
                      currentDateTime.month,
                      currentDateTime.day,
                      15,
                      0,
                      0,
                      0,
                      0);

                  if (element.value == 'PM') {
                    if (widget.dateTime != null) {
                      if (Utils.getDateTimeOf12AM(widget.dateTime)
                          .isAtSameMomentAs(
                              Utils.getDateTimeOf12AM(currentDateTime))) {
                        if (currentDateTime.isBefore(threePMDateTime)) {
                          if (!element.isSelected) {
                            var result = await Utils.showConfirmationDialog(
                                context,
                                'It isn\'t the evening yet - do you really want to log your evening dose now?',
                                'Alert!',
                                Constant.continueText,
                                Constant.cancel);
                            if (result != null && result is String) {
                              if (result == Constant.no)
                                _clickEventHandle(element);
                            }
                          } else
                            _clickEventHandle(element);
                        } else {
                          _clickEventHandle(element);
                        }
                      } else {
                        _clickEventHandle(element);
                      }
                    } /*else {
                      if (currentDateTime.isBefore(threePMDateTime)) {
                        if (!element.isSelected) {
                          var result = await Utils.showConfirmationDialog(
                              context,
                              'Do you really want to log your Evening dose before evening.?',
                              'Alert!',
                              Constant.continueText,
                              Constant.cancel);
                          if (result != null && result is String) {
                            if (result == Constant.no)
                              _clickEventHandle(element);
                          }
                        } else
                          _clickEventHandle(element);
                      } else {
                        _clickEventHandle(element);
                      }
                    }*/
                  } else {
                    _clickEventHandle(element);
                  }
                  /*setState(() {
                    debugPrint('set State11');
                    element.isSelected = value;
                    _addMultiValuesToSelectedAnswer(headacheMigraineQuestion);
                  });*/
                },
              )),
        ),
        Expanded(
          child: Wrap(
            children: [
              Center(
                child: CustomTextWidget(
                  text:
                      element.value == 'AM' ? 'Morning Dose ' : 'Evening Dose ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      height: 1.3,
                      fontFamily: Constant.jostRegular,
                      fontSize: Platform.isAndroid ? 14 : 16,
                      color: Constant.chatBubbleGreen),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _listenToSendStream() {
    _bloc.sendDataStream.listen((eventData) {
      if (eventData != null && eventData is String) {
        if (eventData == Constant.success) {
          Future.delayed(Duration(milliseconds: 350), () {
            Navigator.pop(context);
          });
        }
      }
    });
  }

  void _clickEventHandle(LogStudyMedicationList element) {
    var logStudyMedicationProvider =
        Provider.of<LogStudyMedicationInfo>(context, listen: false);
    element.isSelected = !element.isSelected;

    SelectedAnswers? doseSelectedAnswer =
        _signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull(
            (element1) =>
                element1.questionTag ==
                (element.value == 'AM'
                    ? Constant.amDoseTag
                    : Constant.pmDoseTag));

    if (doseSelectedAnswer != null)
      doseSelectedAnswer.answer = element.isSelected ? '1' : '0';

    logStudyMedicationProvider.updateLogStudyMedicationInfo();
  }


}

class LogStudyMedicationList {
  String value;
  bool isSelected;

  LogStudyMedicationList({required this.value, this.isSelected = false});
}

class LogStudyMedicationInfo with ChangeNotifier {
  List<LogStudyMedicationList> _logStudyMedicationList = [];

  List<LogStudyMedicationList> getLogStudyMedicationList() =>
      _logStudyMedicationList;

  LogStudyMedicationInfo() {
    _logStudyMedicationList = [
      LogStudyMedicationList(value: 'AM'),
      LogStudyMedicationList(value: 'PM'),
    ];
  }

  updateLogStudyMedicationInfo() {
    notifyListeners();
  }
}

class LogStudyMedicationErrorInfo with ChangeNotifier {
  bool _isShowAlert = false;
  String _errorMessage = Constant.blankString;

  bool isShowAlert() => _isShowAlert;

  String getErrorMessage() => _errorMessage;

  updateLoginErrorInfo(bool isShowAlert, String errorMessage) {
    _isShowAlert = isShowAlert;
    _errorMessage = errorMessage;

    notifyListeners();
  }
}
