import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import '../util/constant.dart';

class DeviceListActionSheet extends StatefulWidget {
  final Questions deviceQuestion;
  final SelectedAnswers? selectedAnswer;

  const DeviceListActionSheet({Key? key, required this.deviceQuestion, this.selectedAnswer}) : super(key: key);

  @override
  State<DeviceListActionSheet> createState() => _DeviceListActionSheetState();
}

class _DeviceListActionSheetState extends State<DeviceListActionSheet> {

  TextEditingController _textEditingController = TextEditingController();
  List<Values> _valuesList = [];

  @override
  void initState() {
    super.initState();

    widget.deviceQuestion.values?.forEach((deviceElement) {
      _valuesList.add(Values(
        valueNumber: deviceElement.valueNumber,
        text: deviceElement.text,
        isValid: true,
        isSelected: deviceElement.isSelected,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Constant.backgroundTransparentColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, right: 15),
                      child: CustomTextWidget(
                        text: Constant.close,
                        style: TextStyle(
                          fontFamily: Constant.jostMedium,
                          color: Constant.locationServiceGreen,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 35,
                  child: CustomTextFormFieldWidget(
                    controller: _textEditingController,
                    style: TextStyle(
                      color: Constant.locationServiceGreen,
                      fontSize: 15,
                      fontFamily: Constant.jostMedium,
                    ),
                    cursorColor: Constant.locationServiceGreen,
                    decoration: InputDecoration(
                      hintText: Constant.searchType,
                      hintStyle: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontSize: 13,
                        fontFamily: Constant.jostMedium,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(color: Constant.locationServiceGreen),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(color: Constant.locationServiceGreen),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    ),
                    onChanged: (searchText) {
                      setState(() {

                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    itemCount: _valuesList.length,
                    itemBuilder: (context, index) {
                      String searchText = _textEditingController.text.trim();
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            Values value = _valuesList[index];
                            bool isSelected = value.isSelected;

                            if (isSelected) {
                              value.isSelected = false;
                            } else {
                              value.isSelected = true;
                            }
                          });
                        },
                        child: Visibility(
                          visible: (searchText.isNotEmpty) ? _valuesList[index].text?.toLowerCase().contains(searchText.toLowerCase()) ?? false : true,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            color: _valuesList[index].isSelected ? Constant.locationServiceGreen : Colors.transparent,
                            child: CustomTextWidget(
                              text: _valuesList[index].text ?? '',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: _valuesList[index].isSelected
                                      ? Constant.bubbleChatTextView
                                      : Constant.locationServiceGreen,
                                  fontFamily: Constant.jostMedium,
                                  height: 1.2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
