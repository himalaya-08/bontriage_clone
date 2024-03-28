import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class AddNoteBottomSheet extends StatefulWidget {
  final Function(String?) addNoteCallback;
  final String? text;

  const AddNoteBottomSheet({Key? key, required this.addNoteCallback, this.text}): super(key: key);

  @override
  _AddNoteBottomSheetState createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  widget.addNoteCallback(_textEditingController.text);
                  Navigator.pop(context, _textEditingController.text.trim());
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10, right: 10),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.chatBubbleGreen,
                  ),
                  child: CustomTextWidget(
                    text: Constant.save,
                    style: TextStyle(
                      fontSize: 14,
                      color: Constant.bubbleChatTextView,
                      fontFamily: Constant.jostRegular,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              padding: EdgeInsets.only(top: 10,bottom: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  color: Constant.backgroundTransparentColor
              ),
              child: Column(
                children: [
                  Container(
                    child: CustomTextFormFieldWidget(
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 400,
                      focusNode: _focusNode,
                      controller: _textEditingController,
                      maxLines: 5,
                      onFieldSubmitted: (value) {
                        widget.addNoteCallback(_textEditingController.text);
                        Navigator.pop(context, _textEditingController.text);
                      },
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: Constant.jostMedium,
                          color: Constant.unselectedTextColor),
                      cursorColor: Constant.unselectedTextColor,
                      textAlign: TextAlign.start,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(400, maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds),
                      ],
                      decoration: InputDecoration(
                        counterStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: Constant.jostRegular,
                          color: Constant.unselectedTextColor,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        hintText: 'Add a note...',
                        hintStyle: TextStyle(
                            fontSize: 15,
                            color: Constant.unselectedTextColor,
                            fontFamily: Constant.jostRegular),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          borderSide: BorderSide(
                              color: Colors.transparent, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          borderSide: BorderSide(
                              color: Colors.transparent, width: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
