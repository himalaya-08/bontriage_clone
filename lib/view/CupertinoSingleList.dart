import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class CupertinoSingleList extends StatefulWidget {
  final List<String> listData;
  final String initialData;
  final int initialIndex;
  final Function(String, int) onItemSelected;
  final bool disableFurtherOptions;

  CupertinoSingleList(
      {Key? key,
      required this.listData,
      required this.initialData,
      required this.onItemSelected,
      required this.initialIndex,
      this.disableFurtherOptions = false})
      : super(key: key);

  @override
  State<CupertinoSingleList> createState() => _CupertinoSingleListState();
}

class _CupertinoSingleListState extends State<CupertinoSingleList> {
  String? _data;
  String? _selectedData;

  int? _selectedIndex = 0;

  List<Widget> _itemWidgetList = [];
  FixedExtentScrollController _fixedExtentScrollController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    _fixedExtentScrollController = FixedExtentScrollController();

    _data = widget.initialData;
    _selectedData = _data;

    _selectedIndex = widget.initialIndex;

    _itemWidgetList = List<Widget>.generate(
        widget.listData.length,
        (int index) => Center(
          child: Text(
                widget.listData[index],
            style: TextStyle(color: (widget.disableFurtherOptions) ? (index > DateTime.now().month-1) ? Constant.locationServiceGreen.withOpacity(0.6) : Constant.locationServiceGreen : Constant.locationServiceGreen),
              ),
        ),
        growable: true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fixedExtentScrollController.jumpToItem(widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      height: mediaQueryData.size.height * 0.5,
      child: Stack(
        fit: StackFit.expand,
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
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Constant.backgroundTransparentColor),
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bottomSheetTopButtons(
                          () => Navigator.of(context).pop(), Constant.cancel),
                  _bottomSheetTopButtons(() {
                    widget.onItemSelected(_selectedData ?? '', _selectedIndex!);
                    Navigator.pop(context);
                  }, Constant.done)
                ],
              ),
              Expanded(
                child: Container(
                  child: MediaQuery(
                    data: mediaQueryData.copyWith(
                      textScaleFactor: mediaQueryData.textScaleFactor.clamp(Constant.minTextScaleFactor, Constant.maxTextScaleFactor),
                    ),
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                              fontSize: 18,
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                      child: CupertinoPicker(
                        scrollController: _fixedExtentScrollController,
                        itemExtent: 40,
                        children: _itemWidgetList,
                        onSelectedItemChanged: (index) {
                          if(widget.disableFurtherOptions){
                            if(index <= DateTime.now().month-1){
                              _selectedIndex = index;
                              _selectedData = widget.listData[index];
                            }
                            else{
                              Future.delayed(const Duration(milliseconds: 700)).then((value) => _fixedExtentScrollController.jumpToItem(DateTime.now().month-1));
                            }
                          }
                          else{
                            _selectedIndex = index;
                            _selectedData = widget.listData[index];
                          }
                        },
                        //selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: CupertinoColors.tertiarySystemFill, capStartEdge: false, capEndEdge: true),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  //widget that returns the top button in the cupertino bottom sheet
  Widget _bottomSheetTopButtons(void Function() onTap, String buttonText) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, right: 15, left: 15,),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: CustomTextWidget(
            text: buttonText,
            style: TextStyle(
                fontSize: 14,
                fontFamily: Constant.jostMedium,
                fontWeight: FontWeight.w500,
                color: Constant.locationServiceGreen),
          ),
        ),
      ),
    );
  }
}
