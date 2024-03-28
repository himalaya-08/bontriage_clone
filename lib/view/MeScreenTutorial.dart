import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/TutorialChatBubble.dart';

class MeScreenTutorialDialog extends StatefulWidget {
  final GlobalKey logDayGlobalKey;
  final GlobalKey addHeadacheGlobalKey;
  final GlobalKey recordsGlobalKey;
  final bool isFromOnBoard;
  final AppConfig? appConfig;

  const MeScreenTutorialDialog({Key? key, required this.logDayGlobalKey, required this.addHeadacheGlobalKey, required this.recordsGlobalKey, this.isFromOnBoard = false, this.appConfig}) : super(key: key);

  @override
  _MeScreenTutorialDialogState createState() => _MeScreenTutorialDialogState();
}

class _MeScreenTutorialDialogState extends State<MeScreenTutorialDialog> with SingleTickerProviderStateMixin {

  bool? _shouldClip;
  Offset? _logDayOffset;
  RenderBox? _logDayRenderBox;
  RenderBox? _addHeadacheRenderBox;
  RenderBox? _recordsRenderBox;
  Offset? _recordsOffset;
  Offset? _addHeadacheOffset;
  List<List<TextSpan>>? _textSpanList;
  List<String>? _chatBubbleTextList;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _shouldClip = true;
    _logDayRenderBox = widget.logDayGlobalKey.currentContext!.findRenderObject() as RenderBox;
    _logDayOffset = _logDayRenderBox!.localToGlobal(Offset.zero);

    _addHeadacheRenderBox = widget.addHeadacheGlobalKey.currentContext!.findRenderObject() as RenderBox;
    _addHeadacheOffset = _addHeadacheRenderBox!.localToGlobal(Offset.zero);

    if(widget.appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      _recordsRenderBox = widget.recordsGlobalKey.currentContext!.findRenderObject() as RenderBox;
      _recordsOffset = _recordsRenderBox!.localToGlobal(Offset.zero);
    }

    if (widget.appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      _chatBubbleTextList = [
        Constant.meScreenTutorial1,
        Constant.meScreenTutorial2,
      ];

      _textSpanList = [
        [
          TextSpan(
            text: 'When you\'re on the Me screen of the app, you’ll be able to log your day by pressing the ',
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              height: 1.3,
              color: Constant.chatBubbleGreen,
            ),
          ),
          TextSpan(
            text: 'Log Day',
            style: TextStyle(
                fontSize: 16,
                fontFamily: Constant.jostMedium,
                height: 1.3,
                color: Constant.chatBubbleGreen,
                fontStyle: FontStyle.italic
            ),
          ),
          TextSpan(
            text: ' button and log your headaches by clicking the ',
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              height: 1.3,
              color: Constant.chatBubbleGreen,
            ),
          ),
          TextSpan(
            text: 'Add Headache/End Headache',
            style: TextStyle(
                fontSize: 16,
                fontFamily: Constant.jostMedium,
                height: 1.3,
                color: Constant.chatBubbleGreen,
                fontStyle: FontStyle.italic
            ),
          ),
          TextSpan(
            text: ' button.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              height: 1.3,
              color: Constant.chatBubbleGreen,
            ),
          ),
        ],
        [
          TextSpan(
            text: 'Last thing before we go — Whenever you want, you can click on ',
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              height: 1.3,
              color: Constant.chatBubbleGreen,
            ),
          ),
          TextSpan(
            text: 'Records',
            style: TextStyle(
                fontSize: 16,
                fontFamily: Constant.jostMedium,
                height: 1.3,
                color: Constant.chatBubbleGreen,
                fontStyle: FontStyle.italic
            ),
          ),
          TextSpan(
            text: ' to track information like how your Compass and Headache Score have evolved over time, the potential impact of changes in medication or lifestyle, and more! This is all based on the suggestions we have made and the steps you and your provider have taken.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              height: 1.3,
              color: Constant.chatBubbleGreen,
            ),
          ),
        ],
      ];
    } else {
      _chatBubbleTextList = [
        Constant.tonixMeScreenTutorial1,
      ];

      _textSpanList = [
        [
          TextSpan(
            text: 'When you\'re on the My Day screen of the app, you\'ll be able to log your study medication by pressing',
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              height: 1.3,
              color: Constant.chatBubbleGreen,
            ),
          ),
          TextSpan(
            text: ' Log Study Medication',
            style: TextStyle(
                fontSize: 16,
                fontFamily: Constant.jostMedium,
                height: 1.3,
                color: Constant.chatBubbleGreen,
                fontStyle: FontStyle.italic
            ),
          ),
          TextSpan(
            text: ' and log your day by clicking ',
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              height: 1.3,
              color: Constant.chatBubbleGreen,
            ),
          ),
          TextSpan(
            text: 'Log Your Day/End Headache.',
            style: TextStyle(
                fontSize: 16,
                fontFamily: Constant.jostMedium,
                height: 1.3,
                color: Constant.chatBubbleGreen,
                fontStyle: FontStyle.italic
            ),
          ),
        ],
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_currentIndex != 0) {
          setState(() {
            _currentIndex--;
            _shouldClip = true;
          });
        }
        return false;
      },
      child: Stack(
        children: [
          ClipPath(
            clipper: TutorialClipper(
              logDayBox: _logDayRenderBox!,
              addHeadacheBox: _addHeadacheRenderBox!,
              recordsBox: _recordsRenderBox!,
              currentIndex: _currentIndex,
              shouldClip: _shouldClip!,
              appConfig: widget.appConfig!
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Container(
                color: Constant.backgroundColor.withOpacity(0.9),
                child: Stack(
                  children: [
                    TutorialChatBubble(
                      chatBubbleText: _chatBubbleTextList![_currentIndex],
                      textSpanList: _textSpanList![_currentIndex],
                      chatTextListLength: _chatBubbleTextList!.length,
                      currentIndex: _currentIndex,
                      nextButtonFunction: () {
                        if(_currentIndex < _textSpanList!.length - 1) {
                          setState(() {
                            _currentIndex++;
                            _shouldClip = false;
                          });
                        } else {
                          _popOrNavigateToOtherScreen();
                        }
                      },
                      backButtonFunction: () {
                        if(_currentIndex != 0) {
                          setState(() {
                            _currentIndex--;
                            _shouldClip = true;
                          });
                        }
                      },
                    ),
                    Visibility(
                      visible: _shouldClip!,
                      child: Padding(
                        padding: EdgeInsets.only(top: (widget.appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) ? _logDayOffset!.dy + 40 : _addHeadacheOffset!.dy + 45, right: (widget.appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) ? _logDayOffset!.dx - 20 : _addHeadacheOffset!.dx - 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Image(
                                    image: AssetImage(Constant.tutorialArrowUp),
                                    width: 40,
                                    height: 40,
                                  ),
                                  Image(
                                    image: AssetImage(Constant.tutorialArrowDown),
                                    width: 40,
                                    height: 40,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.appConfig?.buildFlavor != Constant.migraineMentorBuildFlavor ? !_shouldClip! : false,
                      child: Container(
                        padding: EdgeInsets.only(left: (_recordsOffset != null) ? _recordsOffset!.dx - 35 : 0, top: (_recordsOffset != null) ? _recordsOffset!.dy - 50 : 0),
                        child: Image(
                          image: AssetImage(Constant.tutorialArrowDown2),
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30, top: 52),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 5, top: 5),
                            child: Image(
                              image: AssetImage(Constant.closeIcon),
                              width: 22,
                              height: 22,
                            ),
                          ),
                        ),
                        ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _popOrNavigateToOtherScreen() async {
    Navigator.pop(context);

    if(widget.isFromOnBoard)
      Navigator.pushNamed(context, Constant.profileCompleteScreenRouter);
  }
}

class TutorialClipper extends CustomClipper<Path> {
  final RenderBox? logDayBox;
  final RenderBox? addHeadacheBox;
  final RenderBox? recordsBox;
  final int? currentIndex;
  final bool? shouldClip;
  final AppConfig? appConfig;

  const TutorialClipper({this.logDayBox, this.addHeadacheBox, this.recordsBox, this.currentIndex, this.shouldClip, this.appConfig});

  @override
  Path getClip(Size size) {
    Offset logDayOffset = logDayBox!.localToGlobal(Offset.zero);
    Size logDaySize = logDayBox!.size;

    Offset addHeadacheOffset = addHeadacheBox!.localToGlobal(Offset.zero);
    Size addHeadacheSize = addHeadacheBox!.size;

    if(shouldClip!) {
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(logDayOffset.dx, logDayOffset.dy, logDaySize.width, logDaySize.height), Radius.circular(20)))..addRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(addHeadacheOffset.dx, addHeadacheOffset.dy, addHeadacheSize.width, addHeadacheSize.height), Radius.circular(20)))
          ..close(),
      );
    } else {
      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
        Offset recordsOffset = recordsBox!.localToGlobal(Offset.zero);
        return Path.combine(PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()..addOval(Rect.fromLTWH(
                recordsOffset.dx - 18, recordsOffset.dy - 10, 65, 65))
            ..close(),
        );
      }
    }
    return Path();
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
