import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';

class MedicationDeleteDialog extends StatefulWidget {
  const MedicationDeleteDialog({Key? key}) : super(key: key);

  @override
  State<MedicationDeleteDialog> createState() => _MedicationDeleteDialogState();
}

class _MedicationDeleteDialogState extends State<MedicationDeleteDialog> {
  late List<Values> _firstValueList;
  late List<Values> _secondValueList;

  String? _firstSelectedAnswer;
  String? _secondSelectedAnswer;

  late ScrollController _scrollController;
  late TextEditingController _textEditingController;

  double _sideEffectsTextBoxHeight = 100;

  List<String> _selectedAnswersList = [];

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _textEditingController = TextEditingController();

    _firstValueList = [
      Values(isSelected: false, text: Constant.yes),
      Values(isSelected: false, text: Constant.no)
    ];
    _secondValueList = List.generate(
        Constant.logDayMedicationDeleteOptionList.length,
        (index) => Values(
            isSelected: false,
            text: Constant.logDayMedicationDeleteOptionList[index]));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Scaffold(
        backgroundColor: Constant.transparentColor,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            color: Constant.backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 15),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.pop(context),
                      child: Image(
                        image: AssetImage(Constant.closeIcon),
                        width: 22,
                        //height: 22,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15, bottom: 15, left: 15, right: 15),
                  child: Consumer<SelectedAnswersInfo>(
                      builder: (context, data, child) {
                    return Column(
                      children: [
                        _questionnaireBuilder(
                            Constant.logDayMedicationDeleteQuestionList[0],
                            _firstValueList,
                            data),
                        const SizedBox(
                          height: 20,
                        ),
                        (data.getFirstSelectedAnswer() == Constant.yes)
                            ? _questionnaireBuilder(
                                Constant.logDayMedicationDeleteQuestionList[1],
                                _secondValueList,
                                data)
                            : const SizedBox(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            child: BouncingWidget(
                              onPressed: () {
                                if (_firstSelectedAnswer != null) {
                                  MedicationDeleteModel medicationDeleteModel =
                                      MedicationDeleteModel();

                                  medicationDeleteModel.isStopped =
                                      _firstSelectedAnswer == Constant.yes;
                                  medicationDeleteModel.reason =
                                      _secondSelectedAnswer;
                                  medicationDeleteModel.comments =
                                      _textEditingController.text;
                                  Navigator.pop(
                                          context, medicationDeleteModel);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Constant.chatBubbleGreen,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: Constant.done,
                                    style: TextStyle(
                                        color: Constant.bubbleChatTextView,
                                        fontSize: 15,
                                        fontFamily: Constant.jostMedium),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration(int index, List<Values> valuesList) {
    if (!valuesList[index].isSelected) {
      return BoxDecoration(
        border: Border.all(
            width: 1, color: Constant.chatBubbleGreen.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      );
    } else {
      return BoxDecoration(
          border: Border.all(width: 1, color: Constant.locationServiceGreen),
          borderRadius: BorderRadius.circular(4),
          color: Constant.locationServiceGreen);
    }
  }

  Color _getOptionTextColor(int index, List<Values> valuesList) {
    if (valuesList[index].isSelected) {
      return Constant.bubbleChatTextView;
    } else {
      return Constant.locationServiceGreen;
    }
  }

  //runs when any option is selected
  void _onOptionSelected(int index, List<Values> valuesList) {
    valuesList.asMap().forEach((key, value) {
      valuesList[key].isSelected = index == key;
    });
    if (valuesList[index].isSelected) {
      if (valuesList[index].text == Constant.yes ||
          valuesList[index].text == Constant.no) {
        _firstSelectedAnswer = valuesList[index].text;
        Provider.of<SelectedAnswersInfo>(context, listen: false)
            .updateFirstSelectedAnswersInfo(
                valuesList[index].text ?? Constant.blankString);
        if (valuesList[index].text == Constant.yes &&
            _scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 400))
              .then((value) => _scrollController.jumpTo(180));
        }
      } else if (Constant.logDayMedicationDeleteOptionList
          .contains(valuesList[index].text)) {
        _secondSelectedAnswer = valuesList[index].text;
        Provider.of<SelectedAnswersInfo>(context, listen: false)
            .updateSecondSelectedAnswersInfo(
                valuesList[index].text ?? Constant.blankString);
      }
      Provider.of<SelectedAnswersInfo>(context, listen: false).updateState();
    } else {
      Provider.of<SelectedAnswersInfo>(context, listen: false).updateState();
    }
  }

  //builds a single questionnaire
  Widget _questionnaireBuilder(
      String question, List<Values> optionsList, SelectedAnswersInfo data) {
    List<Widget> optionsWidgetList = [];
    for (int index = 0; index < optionsList.length; index++) {
      optionsWidgetList.add(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _onOptionSelected(index, optionsList),
            child: Container(
              decoration: _getBoxDecoration(index, optionsList),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: CustomTextWidget(
                  text: optionsList[index].text!,
                  style: TextStyle(
                      fontSize: 14,
                      color: _getOptionTextColor(index, optionsList),
                      fontFamily: Constant.jostRegular,
                      height: 1.2),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          (data.getSecondSelectedAnswer() ==
                      Constant.logDayMedicationDeleteOptionList[1] &&
                  optionsList[index].text ==
                      Constant.logDayMedicationDeleteOptionList[1])
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _sideEffectsTextBoxHeight,
                  child: TextFormField(
                    minLines: 4,
                    maxLines: null,
                    cursorColor: Constant.chatBubbleGreen,
                    style: TextStyle(
                      color: Constant.chatBubbleGreen.withOpacity(0.4),
                      fontFamily: Constant.jostRegular,
                    ),
                    keyboardType: TextInputType.name,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Tap to type',
                      hintStyle: TextStyle(
                        color: Constant.chatBubbleGreen.withOpacity(0.5),
                        fontFamily: Constant.jostRegular,
                      ),
                      fillColor: Constant.oliveGreen,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ))
              : const SizedBox(),
          (data.getSecondSelectedAnswer() ==
                      Constant.logDayMedicationDeleteOptionList[1] &&
                  optionsList[index].text ==
                      Constant.logDayMedicationDeleteOptionList[1])
              ? const SizedBox(
                  height: 10,
                )
              : const SizedBox()
        ],
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CustomTextWidget(
            text: question,
            style: TextStyle(
                color: Constant.locationServiceGreen,
                fontSize: 14,
                fontFamily: Constant.jostMedium),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ...optionsWidgetList,
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

//provider for selectedAnswers in the questionnaire
class SelectedAnswersInfo with ChangeNotifier {
  String? _firstQuestionCurrentSelectedAnswer;
  String? _secondQuestionCurrentSelectedAnswer;

  String? getFirstSelectedAnswer() => _firstQuestionCurrentSelectedAnswer;

  String? getSecondSelectedAnswer() => _secondQuestionCurrentSelectedAnswer;

  updateFirstSelectedAnswersInfo(String selectedAnswer) {
    _firstQuestionCurrentSelectedAnswer = selectedAnswer;
    notifyListeners();
  }

  updateSecondSelectedAnswersInfo(String selectedAnswer) {
    _secondQuestionCurrentSelectedAnswer = selectedAnswer;
    notifyListeners();
  }

  updateState() {
    //_currentSelectedAnswer = null;
    notifyListeners();
  }
}

class MedicationDeleteModel {
  bool? isStopped;
  String? reason;
  String? comments;

  MedicationDeleteModel({this.isStopped, this.reason, this.comments});
}
