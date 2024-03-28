import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/blocs/MoreHeadacheTypeBloc.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/EmojiFilteringTextInputFormatter.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CustomTextFormFieldWidget.dart';
import 'CustomTextWidget.dart';

class SignUpNameScreen extends StatefulWidget {
  final String? tag;
  final String? helpText;
  final Function(String, String)? selectedAnswerCallBack;
  final List<SelectedAnswers>? selectedAnswerListData;
  final String? errorString;

  const SignUpNameScreen(
      {Key? key,
      this.tag,
      this.helpText,
      this.selectedAnswerListData,
      this.selectedAnswerCallBack,
         this.errorString})
      : super(key: key);

  @override
  _SignUpNameScreenState createState() => _SignUpNameScreenState();
}

class _SignUpNameScreenState extends State<SignUpNameScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  TextEditingController textEditingController = TextEditingController();
  SelectedAnswers? selectedAnswers;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();

    if (widget.selectedAnswerListData != null) {
      selectedAnswers = widget.selectedAnswerListData
          !.firstWhereOrNull((model) => model.questionTag == widget.tag);
      if (selectedAnswers != null) {
        textEditingController.text = selectedAnswers!.answer!;
      }
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animationController!.forward();

    textEditingController.addListener(_printLatestValue);
  }

  @override
  void didUpdateWidget(SignUpNameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_animationController!.isAnimating) {
      _animationController!.reset();
      _animationController!.forward();
    }
  }

  _printLatestValue() {
    print("Second text field: ${textEditingController.text}");
  }

  @override
  void dispose() {
    widget.selectedAnswerCallBack!(widget.tag!, textEditingController.text);
    _animationController!.dispose();
    textEditingController.dispose();

    super.dispose();
  }

  MoreHeadacheTypeBloc _bloc = MoreHeadacheTypeBloc();

  Future<void> updateHeadacheDataChecker() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isUpdateHeadacheDataMoreScreen =
    sharedPreferences.getBool(Constant.updateMoreHeadacheData) ?? false;
    bool isUpdateHeadacheDataTrendsScreen =
    sharedPreferences.getBool(Constant.updateMoreHeadacheData) ?? false;
    bool isUpdateHeadacheDataCompareCopassScreen =
    sharedPreferences.getBool(Constant.updateMoreHeadacheData) ?? false;
    bool isUpdateHeadacheDataOvertimeCopassScreen =
    sharedPreferences.getBool(Constant.updateMoreHeadacheData) ?? false;
      if (isUpdateHeadacheDataMoreScreen || isUpdateHeadacheDataTrendsScreen || isUpdateHeadacheDataCompareCopassScreen || isUpdateHeadacheDataOvertimeCopassScreen) {
        _bloc.initNetworkStreamController();
        /*widget.showApiLoaderCallback(_bloc.networkStream, () {
          _bloc.enterDummyDataToNetworkStream();
          _bloc.getAllHeadacheTypeService(context);
        });*/
        _bloc.getAllHeadacheTypeService(context);
       // await sharedPreferences.setBool(Constant.updateMoreHeadacheData, false);
      }
    }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController!,
      child: Container(
        padding: EdgeInsets.fromLTRB(Constant.chatBubbleHorizontalPadding, 0,
            Constant.chatBubbleHorizontalPadding, 50),
        child: Center(
          child: Consumer<SignupOnboardErrorInfo>(
            builder: (context, data, child){
              return Column(
                children: [
                  const SizedBox(height: 120,),
                  CustomTextFormFieldWidget(
                    maxLength: 40,
                    inputFormatters: [EmojiFilteringTextInputFormatter()],
                    textCapitalization: TextCapitalization.sentences,
                    /*onEditingComplete: () {
                      widget.selectedAnswerCallBack!(
                          widget.tag!, textEditingController.text);
                    },*/
                    onFieldSubmitted: (String value) {
                      widget.selectedAnswerCallBack!(widget.tag!, value);
                      FocusScope.of(context).requestFocus(FocusNode());
                      _bloc.getAllHeadacheTypeService(context);
                    },
                    controller: textEditingController,
                    onChanged: (String value) {
                      widget.selectedAnswerCallBack!(widget.tag!, value);
                      //print(value);
                    },
                    style: TextStyle(
                        color: Constant.chatBubbleGreen,
                        fontSize: 15,
                        fontFamily: Constant.jostMedium),
                    cursorColor: Constant.chatBubbleGreen,
                    decoration: InputDecoration(
                      hintText: 'Tap to Type',
                      hintStyle: TextStyle(
                          color: Color.fromARGB(50, 175, 215, 148),
                          fontSize: 15,
                          fontFamily: Constant.jostMedium),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Constant.chatBubbleGreen)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Constant.chatBubbleGreen)),
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      counterText: '',
                    ),
                  ),

                  (data.getErrorString == Constant.blankString)
                      ? const SizedBox()
                      : Align(
                    alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.only(right: 10, top: 10),
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
                                  Expanded(
                                    child: CustomTextWidget(
                                      text: data.getErrorString,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Constant.pinkTriggerColor,
                                          fontFamily: Constant.jostRegular),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //const SizedBox(height: 200),
                          ],
                        ),
                      ),
                ],
              );
            },
          ),

        ),
      ),
    );
  }
}
