import 'package:flutter/material.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/LogDayScreenArgumentModel.dart';
import 'package:mobile/models/UserHeadacheLogDayDetailsModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class RecordDayPage extends StatefulWidget {
  final bool hasData;
  final DateTime dateTime;
  final UserHeadacheLogDayDetailsModel userHeadacheLogDayDetailsModel;
  final Function(bool, bool, dynamic) openHeadacheLogDayScreenCallback;
  final int? onGoingHeadacheId;

  const RecordDayPage(
      {Key? key,
      this.hasData = false,
      required this.dateTime,
      required this.userHeadacheLogDayDetailsModel,
      required this.openHeadacheLogDayScreenCallback,
      this.onGoingHeadacheId})
      : super(key: key);

  @override
  _RecordDayPageState createState() => _RecordDayPageState();
}

class _RecordDayPageState extends State<RecordDayPage>
    with SingleTickerProviderStateMixin {
  GlobalKey _globalKey = GlobalKey();
  AnimationController? _animationController;

  UserHeadacheLogDayDetailsModel? userLogDayDetails;

  List<Widget> _getSections() {
    if (widget.hasData) {
      List<Widget> listWidget = [];
      if (userLogDayDetails!.headacheLogDayListData != null) {
        userLogDayDetails!.headacheLogDayListData!.forEach((element) {
          if (element.imagePath != Constant.migraineIcon) {
            listWidget.add(_getSectionWidget(
                element.imagePath!,
                element.logDayListData!.titleName!,
                element.logDayListData!.titleInfo!,
                "",
                ""));
          }
        });
      }
      listWidget.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.userHeadacheLogDayDetailsModel.logDayNote != null
                ? widget.userHeadacheLogDayDetailsModel.logDayNote!.isNotEmpty
                : false,
            child: SizedBox(
              height: 10,
            ),
          ),
          Visibility(
            visible: widget.userHeadacheLogDayDetailsModel.logDayNote != null
                ? widget.userHeadacheLogDayDetailsModel.logDayNote!.isNotEmpty
                : false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible:
                      widget.userHeadacheLogDayDetailsModel.logDayNote != null
                          ? widget.userHeadacheLogDayDetailsModel.logDayNote!
                              .isNotEmpty
                          : false,
                  child: CustomTextWidget(
                    text: 'Note:',
                    style: TextStyle(
                        color: Constant.chatBubbleGreen60Alpha,
                        fontFamily: Constant.jostRegular,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Visibility(
                    visible:
                        widget.userHeadacheLogDayDetailsModel.logDayNote != null
                            ? widget.userHeadacheLogDayDetailsModel.logDayNote!
                                .isNotEmpty
                            : false,
                    child: CustomTextWidget(
                      text: widget.userHeadacheLogDayDetailsModel.logDayNote ??
                          Constant.blankString,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                        color: Constant.addCustomNotificationTextColor,
                        fontFamily: Constant.jostRegular,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Visibility(
              visible: /*!userLogDayDetails.isDayLogged ?? true*/ true,
              child: TextButton.icon(
                /*padding: EdgeInsets.all(0),*/
                style: ButtonStyle(
                  padding: MaterialStateProperty.resolveWith(
                      (states) => EdgeInsets.all(0)),
                ),
                onPressed: () {
                  /*Navigator.pushNamed(
                      context, Constant.logDayScreenRouter,
                      arguments: widget.dateTime);*/
                  widget.openHeadacheLogDayScreenCallback(
                      false,
                      true,
                      LogDayScreenArgumentModel(
                          selectedDateTime: widget.dateTime,
                          isFromRecordScreen: true));
                },
                icon: Image.asset(
                  Constant.addCircleIcon,
                  width: 20,
                  height: 20,
                ),
                label: CustomTextWidget(
                  text: (widget.userHeadacheLogDayDetailsModel.isDayLogged == true) ? 'Edit Log Day' : 'Add Log Day',
                  style: TextStyle(
                      color: Constant.chatBubbleGreen,
                      fontFamily: Constant.jostRegular,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
                /*materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,*/
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Visibility(
              visible: /*!userLogDayDetails.isHeadacheLogged*/ true,
              child: TextButton.icon(
                /*padding: EdgeInsets.all(0),*/
                style: ButtonStyle(
                  padding: MaterialStateProperty.resolveWith(
                      (states) => EdgeInsets.all(0)),
                ),
                onPressed: () {
                  _openAddHeadacheScreen();
                },
                icon: Image.asset(
                  Constant.addCircleIcon,
                  width: 20,
                  height: 20,
                ),
                label: CustomTextWidget(
                  text: widget.onGoingHeadacheId == null
                      ? 'Add Headache'
                      : 'Edit On-Going Headache',
                  style: TextStyle(
                      color: Constant.chatBubbleGreen,
                      fontFamily: Constant.jostRegular,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
                /*materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,*/
              ),
            ),
          )
        ],
      ));
      return listWidget;
    } else {
      return [
        CustomTextWidget(
          text: 'Nothing Logged!',
          style: TextStyle(
              fontSize: 18,
              color: Constant.chatBubbleGreen,
              fontWeight: FontWeight.w500,
              fontFamily: Constant.jostRegular),
        ),
        SizedBox(
          height: 5,
        ),
        CustomTextWidget(
          text: 'Add info to better personalize your experience.',
          style: TextStyle(
              fontSize: 18,
              color: Constant.chatBubbleGreen60Alpha,
              fontWeight: FontWeight.w500,
              fontFamily: Constant.jostRegular),
        ),
        Divider(
          thickness: 0.5,
          color: Constant.chatBubbleGreen,
          height: 40,
        ),
        TextButton.icon(
          /*padding: EdgeInsets.all(0),*/
          style: ButtonStyle(
            padding: MaterialStateProperty.resolveWith(
                (states) => EdgeInsets.all(0)),
          ),
          onPressed: () {
            /*Navigator.pushNamed(context, Constant.logDayScreenRouter,
                arguments: widget.dateTime);*/
            widget.openHeadacheLogDayScreenCallback(
                false,
                false,
                LogDayScreenArgumentModel(
                    selectedDateTime: widget.dateTime,
                    isFromRecordScreen: true));
          },
          icon: Image.asset(
            Constant.addCircleIcon,
            width: 20,
            height: 20,
          ),
          label: CustomTextWidget(
            text: (widget.userHeadacheLogDayDetailsModel.isDayLogged == true) ? 'Edit Log Day' : 'Add Log Day',
            style: TextStyle(
                color: Constant.chatBubbleGreen,
                fontFamily: Constant.jostRegular,
                fontWeight: FontWeight.w500,
                fontSize: 18),
          ),
          /*materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,*/
        ),
        SizedBox(
          height: 10,
        ),
        TextButton.icon(
          /*padding: EdgeInsets.all(0),*/
          style: ButtonStyle(
            padding: MaterialStateProperty.resolveWith(
                (states) => EdgeInsets.all(0)),
          ),
          onPressed: () {
            _openAddHeadacheScreen();
          },
          icon: Image.asset(
            Constant.addCircleIcon,
            width: 20,
            height: 20,
          ),
          label: CustomTextWidget(
            text: 'Add Headache',
            style: TextStyle(
                color: Constant.chatBubbleGreen,
                fontFamily: Constant.jostRegular,
                fontWeight: FontWeight.w500,
                fontSize: 18),
          ),
          /*materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,*/
        ),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          _globalKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      print(size);
    });

    print(widget.dateTime);

    userLogDayDetails = widget.userHeadacheLogDayDetailsModel;

    _animationController = AnimationController(
        duration: Duration(milliseconds: 1000),
        reverseDuration: Duration(milliseconds: 1000),
        vsync: this);
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RecordDayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(widget.dateTime);

    if (!_animationController!.isAnimating) {
      _animationController!.reverse();
      _animationController!.forward();
    }

    print("IN DID UPDATE WIDGET???");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController!,
      child: Padding(
        key: _globalKey,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getSections(),
        ),
      ),
    );
  }

  Widget _getSectionWidget(String imagePath, String headerText, String subText,
      String noteText, String warningText) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(
              height: 20,
              width: 20,
              image: AssetImage(imagePath),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    text: headerText,
                    style: TextStyle(
                        color: Constant.chatBubbleGreen,
                        fontFamily: Constant.jostRegular,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  CustomTextWidget(
                    text: subText,
                    style: TextStyle(
                        color: Constant.chatBubbleGreen60Alpha,
                        fontFamily: Constant.jostRegular,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: noteText.isNotEmpty,
                    child: CustomTextWidget(
                      text: 'Note:\n$noteText',
                      maxLines: 3,
                      style: TextStyle(
                          color: Constant.chatBubbleGreen60Alpha,
                          fontFamily: Constant.jostRegular,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: warningText.isNotEmpty,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          width: 13,
                          height: 13,
                          image: AssetImage(Constant.warningPink),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Visibility(
                          visible: false,
                          child: CustomTextWidget(
                            text: warningText,
                            style: TextStyle(
                              color: Constant.pinkTriggerColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: Constant.jostRegular,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(
          thickness: 0.5,
          color: Constant.chatBubbleGreen,
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  void _openAddHeadacheScreen() async {
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    if (userProfileInfoData != null) {
      DateTime dateTime = DateTime(
          widget.dateTime.year,
          widget.dateTime.month,
          widget.dateTime.day,
          DateTime.now().hour,
          DateTime.now().minute,
          0,
          0);

      DateTime currentDateTime = DateTime.now();
      DateTime endDateTime = DateTime(
          currentDateTime.year,
          currentDateTime.month,
          currentDateTime.day,
          currentDateTime.hour,
          currentDateTime.minute,
          0,
          0,
          0);

      CurrentUserHeadacheModel currentUserHeadacheModel =
          CurrentUserHeadacheModel(
              userId: userProfileInfoData.userId,
              isOnGoing: false,
              selectedDate:
                  Utils.getDateTimeInUtcFormat(dateTime, true, context),
              isFromRecordScreen: true,
              selectedEndDate:
                  Utils.getDateTimeInUtcFormat(endDateTime, true, context),
              headacheId: widget.onGoingHeadacheId);

      widget.openHeadacheLogDayScreenCallback(
          true, false, currentUserHeadacheModel);
      /*Navigator.pushNamed(
          context, Constant.addHeadacheOnGoingScreenRouter,
          arguments: currentUserHeadacheModel);*/
    }
  }
}
