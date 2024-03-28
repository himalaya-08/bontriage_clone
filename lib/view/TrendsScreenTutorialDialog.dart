import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/TrendsTutorialDotModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import 'TutorialChatBubble.dart';

class TrendsScreenTutorialDialog extends StatefulWidget {
  @override
  _TrendsScreenTutorialDialogState createState() => _TrendsScreenTutorialDialogState();
}

class _TrendsScreenTutorialDialogState extends State<TrendsScreenTutorialDialog> {

  List<List<InlineSpan>> _textSpanList = [];
  List<String> _chatBubbleTextList = [];
  int _currentIndex = 0;
  List<TrendsTutorialDotModel> _trendsTutorialDotModelList1 = [];
  List<TrendsTutorialDotModel> _trendsTutorialDotModelList2 = [];
  List<TrendsTutorialDotModel> _trendsTutorialDotModelList3 = [];
  GlobalKey _dotBoxGlobalKey = GlobalKey();
  GlobalKey _dotGlobalKey = GlobalKey();
  GlobalKey _graphBoxGlobalKey = GlobalKey();
  GlobalKey _arrowUpBoxGlobalKey = GlobalKey();
  Offset? _dotOffset;
  bool _shouldClip = false;

  TextStyle _textStyle = TextStyle(
    fontSize: 16,
    fontFamily: Constant.jostRegular,
    height: 1.3,
    color: Constant.chatBubbleGreen,
  );

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;

    _dotBoxGlobalKey = GlobalKey();
    _dotGlobalKey = GlobalKey();
    _graphBoxGlobalKey = GlobalKey();
    _arrowUpBoxGlobalKey = GlobalKey();

    _chatBubbleTextList = [
      Constant.trendsTutorialText1,
      Constant.trendsTutorialText2,
      Constant.trendsTutorialText3,
      Constant.trendsTutorialText4,
      Constant.trendsTutorialText5,
    ];

    _textSpanList = [
      [
        TextSpan(
          text: Constant.trendsTutorialText1,
          style: _textStyle,
        ),
      ],
      [
        TextSpan(
          text: 'A filled circle (',
          style: _textStyle,
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(Icons.circle, size: 8, color: Constant.locationServiceGreen,),
          ),
        ),
        TextSpan(
          text: ') indicates if a certain behavior, potential trigger, or medication was present on a given day.',
          style: _textStyle,
        ),
      ],
      [
        TextSpan(
          text: 'An outlined circle (',
          style: _textStyle,
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(Icons.brightness_1_outlined, size: 8, color: Constant.locationServiceGreen,),
          ),
        ),
        TextSpan(
          text: ') means you did not experience that item on a given day.',
          style: _textStyle,
        ),
      ],
      [
        TextSpan(
          text: Constant.trendsTutorialText4,
          style: _textStyle,
        ),
      ],
      [
        TextSpan(
          text: Constant.trendsTutorialText5,
          style: _textStyle,
        ),
      ],
    ];

    _initTrendsTutorialDotModel();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderBox dotRenderBox = _dotGlobalKey.currentContext!.findRenderObject() as RenderBox;
      _dotOffset = dotRenderBox.localToGlobal(Offset.zero);
      debugPrint('DotOffset???$_dotOffset');
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          _shouldClip = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_currentIndex != 0) {
          setState(() {
            _currentIndex--;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Container(
        color: Constant.backgroundColor,
        child: Stack(
          children: [
            SafeArea(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 140,),
                    Padding(
                      key: _graphBoxGlobalKey,
                      padding: const EdgeInsets.only(left: 25, right: 10),
                      child: Image(
                        key: _arrowUpBoxGlobalKey,
                        image: AssetImage(
                            Constant.graph,
                        ),
                      ),
                    ),
                    Column(
                      key: _dotBoxGlobalKey,
                      children: [
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomTextWidget(
                                    text: 'Exercise',
                                    style: TextStyle(
                                      color: Constant.locationServiceGreen,
                                      fontSize: 12,
                                      fontFamily: Constant.jostRegular
                                    ),
                                  ),
                                  SizedBox(height: 2,),
                                  CustomTextWidget(
                                    text: 'Reg. meals',
                                    style: TextStyle(
                                        color: Constant.locationServiceGreen,
                                        fontSize: 12,
                                        fontFamily: Constant.jostRegular
                                    ),
                                  ),
                                  SizedBox(height: 2,),
                                  CustomTextWidget(
                                    text: 'Good Sleep',
                                    style: TextStyle(
                                        color: Constant.locationServiceGreen,
                                        fontSize: 12,
                                        fontFamily: Constant.jostRegular
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 10),
                                    child: Row(
                                      children: _getDots(1),
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 10),
                                    child: Row(
                                      children: _getDots(2),
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 10),
                                    child: Row(
                                      children: _getDots(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Visibility(
                      visible: _currentIndex != 3,
                      child: SizedBox(
                        height: 30,
                      ),
                    ),
                    Visibility(
                      visible: _currentIndex == 3,
                      child: Padding(
                        padding: EdgeInsets.only(left: (_dotOffset == null) ? 0 : _dotOffset?.dx ?? 30 -  30),
                        child: Image(
                          image: AssetImage(
                            Constant.trendsTutorialArrowUp,
                          ),
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipPath(
              clipper: TrendsTutorialClipper(
                currentIndex: _currentIndex,
                dotBoxGlobalKey: _dotBoxGlobalKey,
                dotGlobalKey: _dotGlobalKey,
                graphBoxGlobalKey: _graphBoxGlobalKey,
                shouldClip: _shouldClip,
              ),
              child: Container(
                color: Constant.backgroundColor.withOpacity(0.9),
                child: Column(
                  children: [
                    TutorialChatBubble(
                      chatBubbleText: _chatBubbleTextList[_currentIndex],
                      textSpanList: _textSpanList[_currentIndex],
                      currentIndex: _currentIndex,
                      isFromTrends: true,
                      nextButtonFunction: () {
                        if(_currentIndex < _textSpanList.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      backButtonFunction: () {
                        if(_currentIndex != 0) {
                          setState(() {
                            _currentIndex--;
                          });
                        }
                      },
                      isShowBackNextButton: _currentIndex != (_chatBubbleTextList.length - 1),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: _currentIndex == (_chatBubbleTextList.length - 1),
                                child: BouncingWidget(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                                    decoration: BoxDecoration(
                                      color: Constant.chatBubbleGreen,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: CustomTextWidget(
                                        text: 'Got it!',
                                        style: TextStyle(
                                            color:
                                            Constant.bubbleChatTextView,
                                            fontSize: 15,
                                            fontFamily:
                                            Constant.jostMedium),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 30, top: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                    },
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
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _getDots(int type) {
    List<Widget> dotsList;

    switch(type) {
      case 1:
        dotsList = List.generate(31, (index) => Expanded(
          child: Container(
            height: 10,
            child: Center(
              child: Icon(
                _trendsTutorialDotModelList1[index].isSelected ? Icons.circle : Icons.brightness_1_outlined,
                size: 8,
                color: Constant.locationServiceGreen,
              ),
            ),
          ),
        ));
        break;
      case 2:
        dotsList = List.generate(31, (index) => Expanded(
          child: Container(
            height: 10,
            child: Center(
              child: Icon(
                _trendsTutorialDotModelList2[index].isSelected ? Icons.circle : Icons.brightness_1_outlined,
                size: 8,
                color: Constant.locationServiceGreen,
              ),
            ),
          ),
        ));
        break;
      default:
        dotsList = List.generate(31, (index) => Expanded(
          child: Container(
            height: 10,
            child: Center(
              child: Icon(
                _trendsTutorialDotModelList3[index].isSelected ? Icons.circle : Icons.brightness_1_outlined,
                size: 8,
                key: _trendsTutorialDotModelList3[index].isAddKey ? _dotGlobalKey : null,
                color: Constant.locationServiceGreen,
              ),
            ),
          ),
        ));
    }

    return dotsList;
  }

  void _initTrendsTutorialDotModel() {
    _trendsTutorialDotModelList1 = List.generate(31, (index) => TrendsTutorialDotModel());

    _trendsTutorialDotModelList1[5].isSelected = true;
    _trendsTutorialDotModelList1[9].isSelected = true;
    _trendsTutorialDotModelList1[10].isSelected = true;
    _trendsTutorialDotModelList1[11].isSelected = true;
    _trendsTutorialDotModelList1[12].isSelected = true;
    _trendsTutorialDotModelList1[13].isSelected = true;

    _trendsTutorialDotModelList2 = List.generate(31, (index) => TrendsTutorialDotModel());

    _trendsTutorialDotModelList2[5].isSelected = true;
    _trendsTutorialDotModelList2[8].isSelected = true;
    _trendsTutorialDotModelList2[9].isSelected = true;

    _trendsTutorialDotModelList3 = List.generate(31, (index) => TrendsTutorialDotModel());

    _trendsTutorialDotModelList3[5].isSelected = true;
    _trendsTutorialDotModelList3[9].isSelected = true;
    _trendsTutorialDotModelList3[13].isAddKey = true;
  }
}

class TrendsTutorialClipper extends CustomClipper<Path> {
  int? currentIndex;
  GlobalKey? dotBoxGlobalKey;
  GlobalKey? dotGlobalKey;
  GlobalKey? graphBoxGlobalKey;
  GlobalKey? arrowUpBoxGlobalKey;
  bool? shouldClip;

  TrendsTutorialClipper({this.shouldClip = false, this.currentIndex, this.dotBoxGlobalKey, this.dotGlobalKey, this.graphBoxGlobalKey, this.arrowUpBoxGlobalKey});

  @override
  Path getClip(Size size) {
    switch(currentIndex) {
      case 0:
      case 1:
      case 2:
        RenderBox dotsRenderBox = dotBoxGlobalKey!.currentContext!.findRenderObject() as RenderBox;
        Offset dotsOffset = dotsRenderBox.localToGlobal(Offset.zero);
        Size dotsSize = dotsRenderBox.size;
        return Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()..addRect(Rect.fromLTWH(0, dotsOffset.dy, shouldClip! ? dotsSize.width : 0, shouldClip! ? dotsSize.height : 0))
            ..close(),
        );
      case 3:
        RenderBox graphRenderBox = graphBoxGlobalKey!.currentContext!.findRenderObject() as RenderBox;
        Offset graphOffset = graphRenderBox.localToGlobal(Offset.zero);
        Size graphSize = graphRenderBox.size;

        RenderBox dotsRenderBox = dotBoxGlobalKey!.currentContext!.findRenderObject() as RenderBox;
        Size dotsSize = dotsRenderBox.size;

        return Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            ..addRect(Rect.fromLTWH(0, graphOffset.dy, size.width, graphSize.height + dotsSize.height + 30))
            ..close(),
        );
      case 4:
        RenderBox dotsRenderBox = dotBoxGlobalKey!.currentContext!.findRenderObject() as RenderBox;
        Offset dotsOffset = dotsRenderBox.localToGlobal(Offset.zero);
        Size dotsSize = dotsRenderBox.size;

        RenderBox graphRenderBox = graphBoxGlobalKey!.currentContext!.findRenderObject() as RenderBox;
        Offset graphOffset = graphRenderBox.localToGlobal(Offset.zero);
        Size graphSize = graphRenderBox.size;

        debugPrint('in 3??$graphOffset');
        //debugPrint(graphSize as String?);

        return Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            ..addRect(Rect.fromLTWH(0, dotsOffset.dy, shouldClip! ? dotsSize.width : 0, shouldClip! ? dotsSize.height : 0))
            ..addRect(Rect.fromLTWH(0, graphOffset.dy, shouldClip! ? graphSize.width : 0, shouldClip! ? graphSize.height : 0))
            ..close(),
        );
      default:
        return Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()..addRect(Rect.fromLTWH(0, 0, 0, 0))
            ..close(),
        );
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}
