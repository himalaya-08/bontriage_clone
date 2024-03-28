import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/SignUpHeadacheAnswerListModel.dart';
import 'package:mobile/models/UserLogHeadacheDataCalendarModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:provider/provider.dart';

import 'CalendarTriggersScreen.dart';
import 'CustomTextWidget.dart';

class DateWidget extends StatelessWidget {
  final DateTime weekDateData;
  final int calendarType;
  final int calendarDateViewType;
  final List<SignUpHeadacheAnswerListModel> triggersListData;
  final List<SignUpHeadacheAnswerListModel> userMonthTriggersListData;
  final SelectedDayHeadacheIntensity? selectedDayHeadacheIntensity;
  final Future<dynamic> Function(String, dynamic)? navigateToOtherScreenCallback;

  const DateWidget(
      {Key? key, required this.weekDateData,
        required this.calendarType,
        required this.calendarDateViewType,
        required this.triggersListData,
        required this.userMonthTriggersListData,
        required this.selectedDayHeadacheIntensity,
        required this.navigateToOtherScreenCallback}) : super(key: key);

  final double dotSize = 9;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: _getWidget(context),
      ),
    );
  }

  Widget _getWidget(BuildContext context) {
    return (calendarType == 1) ?
        Consumer<CalendarTriggerInfo>(
          builder: (context, data, child) {
            return _getDateStack(context);
          },
        ) :
        _getDateStack(context);
  }

  Widget _getDateStack(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 100),
          height: (calendarType == 1 && checkVisibilityForDateTriggers(0)) ? 33.5 : 28,
          width: (calendarType == 1 && checkVisibilityForDateTriggers(0)) ? 32.5 : 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            border: Border.all(color: (calendarType == 1 && checkVisibilityForDateTriggers(0)) ? Constant.menstruatingTriggerColor : Colors.transparent, width: 3),
          ),
          child: const SizedBox(height: 28, width: 28,),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if(navigateToOtherScreenCallback != null) {
              Duration duration = DateTime.tryParse(Utils.getDateTimeInUtcFormat(weekDateData, true, context))!.difference(DateTime.tryParse(Utils.getDateTimeInUtcFormat(DateTime.now(), true, context))!);
              debugPrint('WeekData????${DateTime.tryParse(Utils.getDateTimeInUtcFormat(weekDateData, true, context))}');
              debugPrint('NowDateTime????${DateTime.tryParse(Utils.getDateTimeInUtcFormat(DateTime.now(), true, context))}');
              debugPrint('Duration???${duration.inSeconds}');
              if (duration.inSeconds <= 0)
                navigateToOtherScreenCallback!(
                    Constant.onCalendarHeadacheLogDayDetailsScreenRouter,
                    weekDateData);
              else {
                //Utils.showValidationErrorDialog(context, 'Invalid date selected.', 'Alert!');
                Utils.showSnackBar(context, 'Future dates cannot be selected.');
              }
            }
          },
          child: Container(
            height: 28,
            width: 28,
            decoration: setDateViewWidget(calendarDateViewType, context),
            padding: EdgeInsets.all(2),
            margin: EdgeInsets.only(top: 3, left: 2),
            child: Center(
              child: CustomTextWidget(
                text: weekDateData.day.toString(),
                style: setTextViewStyle(calendarDateViewType, context),
              ),
            ),
          ),
        ),
        //setMenstruatingTriggerView(calendarType, triggersListData.length),
        setTriggersViewOne(calendarType, triggersListData.length),
        setTriggersViewTwo(calendarType, triggersListData.length),
        setTriggersViewThree(calendarType, triggersListData.length),
        setTriggersViewFour(calendarType, triggersListData.length),
        setTriggersViewFive(calendarType, triggersListData.length),
        setTriggersViewSix(calendarType, triggersListData.length),
        setTriggersViewSeven(calendarType, triggersListData.length),
        setTriggersViewEight(calendarType, triggersListData.length),
        /*setTriggersViewOne(calendarType, triggersListData.length),
        setTriggersViewTwo(calendarType, triggersListData.length),
        setTriggersViewThree(calendarType, triggersListData.length),*/
        /*setTriggersViewFour(calendarType, triggersListData.length),
        setTriggersViewFive(calendarType, triggersListData.length),
        setTriggersViewSix(calendarType, triggersListData.length),
        setTriggersViewSeven(calendarType, triggersListData.length),
        setTriggersViewEight(calendarType, triggersListData.length),*/
        Visibility(
          visible: calendarType == 0 ? false : calendarType == 2,
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(right: 3),
                width: 16,
                height: 8,
                decoration: BoxDecoration(
                  color: setIntensityTriggerColor(),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  bool isCurrentDate() {
    DateTime now = new DateTime.now();
    return weekDateData.month == now.month &&
        weekDateData.year == now.year &&
        now.day.toString() == weekDateData.day.toString();
  }

  BoxDecoration setDateViewWidget(int calendarDateViewType, BuildContext context) {
    var appConfig = AppConfig.of(context);

    debugPrint('cvt= $calendarDateViewType');

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      if (calendarDateViewType == 0) {
        return BoxDecoration(
            color: ((selectedDayHeadacheIntensity != null ) ? selectedDayHeadacheIntensity?.isMigraine ?? false : false)
                ? Constant.migraineColor
                : Constant.headacheDayColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: ((selectedDayHeadacheIntensity != null ) ? selectedDayHeadacheIntensity?.isMigraine ?? false : false)
                  ? (isCurrentDate() ? Colors.white : Constant.migraineColor)
                  : isCurrentDate()
                  ? Colors.white
                  : Constant.headacheDayColor,
              width: 2,
            ));
      } else if (calendarDateViewType == 1) {
        return BoxDecoration(
            color: Constant.headacheFreeDayColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentDate() ? Colors.white : Colors.transparent,
              width: 2,
            ));
      } else {
        return BoxDecoration(
          color: isCurrentDate() ? Constant.currentDateColor : Colors.transparent,
          shape: BoxShape.circle,
        );
      }
    } else {
      debugPrint(
          'calendarDateViewType?????$calendarDateViewType????DateTime???$weekDateData');
      if (calendarDateViewType == 0) {
        return BoxDecoration(
            color: isCurrentDate() ?
            Constant.currentDateColor :
            Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentDate() ? Constant.currentDateColor
                  : Colors.transparent,
              width: 2,
            ));
      } else if (calendarDateViewType == 1) {
        return BoxDecoration(
            color: isCurrentDate()
                ? Constant.currentDateColor
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentDate()
                  ? Constant.currentDateColor
                  : Colors.transparent,
              width: 2,
            ));
      } else {
        return BoxDecoration(
          color: isCurrentDate() ? Constant.currentDateColor : Colors.transparent,
          shape: BoxShape.circle,
        );
      }
    }
  }

  TextStyle setTextViewStyle(int calendarDateViewType, BuildContext context) {
    var appConfig = AppConfig.of(context);
    double fontSize = 15;

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      if (calendarDateViewType == 0) {
        return TextStyle(
            fontSize: fontSize,
            color: isCurrentDate() ? Colors.white : Colors.black,
            fontFamily: Constant.jostRegular);
      } else if (calendarDateViewType == 1) {
        return TextStyle(
            fontSize: fontSize,
            color: isCurrentDate() ? Colors.white : Constant
                .locationServiceGreen,
            fontFamily: Constant.jostRegular);
      } else {
        return TextStyle(
            fontSize: fontSize,
            color: isCurrentDate() ? Colors.white : Constant
                .locationServiceGreen,
            fontFamily: Constant.jostRegular);
      }
    } else {
      if (calendarDateViewType == 0) {
        return TextStyle(
            fontSize: fontSize,
            color: ((selectedDayHeadacheIntensity != null)
                ? selectedDayHeadacheIntensity?.isMigraine ?? false
                : false)
                ? Colors.white
                : Colors.white,
            fontFamily: Constant.jostRegular);
      } else if (calendarDateViewType == 1) {
        return TextStyle(
            fontSize: fontSize,
            color: isCurrentDate() ? Colors.white : Constant.locationServiceGreen,
            fontFamily: Constant.jostRegular);
      } else {
        return TextStyle(
            fontSize: fontSize,
            color: ((selectedDayHeadacheIntensity != null)
                ? selectedDayHeadacheIntensity?.isMigraine ?? false
                : false)
                ? Colors.white
                : /*(DateTime.now().day.toString() == weekDateData.day.toString()) ? Colors.white :*/ Colors.red,
            //color: isCurrentDate() ? Colors.white : Constant.locationServiceGreen,
            fontFamily: Constant.jostRegular);
      }
    }
  }

  Visibility setMenstruatingTriggerView(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(0),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(right: 2),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.menstruatingTriggerColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewOne(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(1),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(left: 13, bottom: 1.5),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerOneColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewTwo(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(2),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(bottom: 7, right: 1),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerTwoColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewThree(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(3),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(bottom: 2),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerThreeColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewFour(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(4),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 1.5, top: 5),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerFourColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewFive(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(5),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 7, top: 1),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerFiveColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewSix(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(6),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(right: 3),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerSixColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewSeven(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(7),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(left: 4, top: 1.5),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerSevenColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewEight(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      //if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(8),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(bottom: 11.5),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.triggerOutlineColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.triggerEightColor),
              ),
            ),
          ),
        );
      /*} else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }*/
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

// 0- Red
  // 1-Purple
  //2 - Blue
  /*Visibility setTriggersViewOne(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(0),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(left: 9),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffD85B00)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewTwo(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(1),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(left: 18, bottom: 2),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0XFF7E00CB)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewThree(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(2),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(left: 22, bottom: 10),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0Xff00A8CD)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewFour(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(0),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 3, top: 6),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffD85B00)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewFive(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(1),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 9),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0XFF7E00CB)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewSix(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(1),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(left: 7),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0Xff00A8CD)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewSeven(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(0),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(top: 6),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffD85B00)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Visibility setTriggersViewEight(int calendarType, int triggersCount) {
    if (calendarType == 1) {
      if (triggersCount == 1 || triggersCount == 2 || triggersCount >= 3) {
        return Visibility(
          visible: checkVisibilityForDateTriggers(1),
          child: Container(
            width: 35,
            height: 35,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(bottom: 9),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Constant.bubbleChatTextView, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0XFF7E00CB)),
              ),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: false,
          child: Container(),
        );
      }
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }*/

  bool checkVisibilityForDateTriggers(int colorValue) {
    bool isVisible = false;
    switch (colorValue) {
      case 0:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
              (triggersElement) =>
                  triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                    Constant.menstruatingTriggerColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 1:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
              (triggersElement) =>
                  triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                    Constant.triggerOneColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 2:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
              (triggersElement) =>
                  triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                    Constant.triggerTwoColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 3:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
                  (triggersElement) =>
              triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                Constant.triggerThreeColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 4:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
                  (triggersElement) =>
              triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                Constant.triggerFourColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 5:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
                  (triggersElement) =>
              triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                Constant.triggerFiveColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 6:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
                  (triggersElement) =>
              triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                Constant.triggerSixColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 7:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
                  (triggersElement) =>
              triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                Constant.triggerSevenColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
      case 8:
        triggersListData.forEach((element) {
          var filteredTriggersData = userMonthTriggersListData.firstWhereOrNull(
                  (triggersElement) =>
              triggersElement.answerData == element.answerData);
          if (filteredTriggersData != null &&
              filteredTriggersData.color != null) {
            if (filteredTriggersData.color ==
                Constant.triggerEightColor &&
                filteredTriggersData.isSelected!) {
              isVisible = true;
            }
          }
        });
        break;
    }
    return isVisible && (calendarType == 0 ? false : calendarType == 1);
  }

  /// Mild - from 1 to 3
  /// Moderate - from 4 to 7
  /// Severe - from 8 to 10
  Color setIntensityTriggerColor() {
    if (selectedDayHeadacheIntensity != null &&
        selectedDayHeadacheIntensity?.intensityValue != null) {
      int intensityValue =
          int.parse(selectedDayHeadacheIntensity?.intensityValue ?? '0');
      if (intensityValue >= 1 && intensityValue <= 3) {
        return Constant.mildTriggerColor;
      } else if (intensityValue >= 4 && intensityValue <= 7) {
        return Constant.moderateTriggerColor;
      } else if (intensityValue >= 8 && intensityValue <= 10) {
        return Constant.severeTriggerColor;
      } else
        return Colors.transparent;
    } else {
      return Colors.transparent;
    }
  }
}
