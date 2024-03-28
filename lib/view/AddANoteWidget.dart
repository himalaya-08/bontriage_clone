import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import 'AddNoteBottomSheet.dart';

class AddANoteWidget extends StatefulWidget {
  final List<SelectedAnswers> selectedAnswerList;
  final String noteTag;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AddANoteWidget(
      {Key? key, required this.selectedAnswerList, required this.scaffoldKey, required this.noteTag})
      : super(key: key);

  @override
  _AddANoteWidgetState createState() => _AddANoteWidgetState();
}

class _AddANoteWidgetState extends State<AddANoteWidget> {
  String? text;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _showAddNoteBottomSheet();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: _getNoteWidget(),
        ),
      ),
    );
  }

  Widget _getNoteWidget() {
    SelectedAnswers? headacheNoteSelectedAnswer = widget.selectedAnswerList
        .firstWhereOrNull((element) => element.questionTag == widget.noteTag);
    if (headacheNoteSelectedAnswer == null) {
      return CustomTextWidget(
        text: Constant.addANote,
        style: TextStyle(
          fontSize: 16,
          color: Constant.addCustomNotificationTextColor,
          fontFamily: Constant.jostRegular,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      if (headacheNoteSelectedAnswer.answer!.trim().isNotEmpty) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              color: Constant.addCustomNotificationTextColor,
              size: 16,
            ),
            SizedBox(
              width: 5,
            ),
            CustomTextWidget(
              text: Constant.viewEditNote,
              style: TextStyle(
                fontSize: 16,
                color: Constant.addCustomNotificationTextColor,
                fontFamily: Constant.jostRegular,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      } else {
        return CustomTextWidget(
          text: Constant.addANote,
          style: TextStyle(
            fontSize: 16,
            color: Constant.addCustomNotificationTextColor,
            fontFamily: Constant.jostRegular,
            fontWeight: FontWeight.w500,
          ),
        );
      }
    }
  }

  void _showAddNoteBottomSheet() {
    FocusScope.of(context).requestFocus(FocusNode());
    text = '';
    SelectedAnswers? noteSelectedAnswer = widget.selectedAnswerList.firstWhereOrNull(
        (element) => element.questionTag == widget.noteTag);
    if (noteSelectedAnswer != null) {
      text = noteSelectedAnswer.answer ?? '';
    }
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height/3.5,
            child: AddNoteBottomSheet(
                  text: text ?? '',
                  addNoteCallback: (note) {
                    if (note != null) {
                      if (note is String) {
                        note = note.trim();
                        SelectedAnswers? noteSelectedAnswer =
                            widget.selectedAnswerList.firstWhereOrNull(
                                (element) => element.questionTag == widget.noteTag);
                        if (noteSelectedAnswer == null)
                          widget.selectedAnswerList.add(SelectedAnswers(
                              questionTag: widget.noteTag, answer: note));
                        else
                          noteSelectedAnswer.answer = note;

                        setState(() {});
                      }
                    }
                  },
                ),
          ),
        ));
  }
}
