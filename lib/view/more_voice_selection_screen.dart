import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class MoreVoiceSelectionScreen extends StatefulWidget {
  final Future<dynamic> Function(String, dynamic)
  openSelectVoiceActionSheetCallback;

  const MoreVoiceSelectionScreen(
      {Key? key, required this.openSelectVoiceActionSheetCallback})
      : super(key: key);

  @override
  State<MoreVoiceSelectionScreen> createState() =>
      _MoreVoiceSelectionScreenState();
}

class _MoreVoiceSelectionScreenState extends State<MoreVoiceSelectionScreen> {
  late FlutterTts _flutterTts;
  late SharedPreferences _sharedPreferences;
  late List<MoreVoiceSelectionScreenModel> _moreVoiceSelectionScreenModelList;

  late String _prevSelectedAccentName;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _moreVoiceSelectionScreenModelList = [];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getAllAccents();
    });
  }

  Future<void> _getLastSelectedAccent() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _prevSelectedAccentName =
        _sharedPreferences.getString(Constant.ttsAccentKey) ?? (Platform.isAndroid ? 'en-us-x-sfg-local' : 'en-US%@Samantha');

    if (_prevSelectedAccentName == 'en-US')
      _prevSelectedAccentName = 'en-US%@Samantha';
  }

  Future<void> _getAllAccents() async {
    await _getLastSelectedAccent();
    var voices = await _flutterTts.getVoices;
    if (voices != null) {
      List<Map<String, String>?> _allVoices =
      voices.map<Map<String, String>?>((voice) {
        Map<String, String> voiceMap = Map<String, String>.from(voice as Map);
        return voiceMap;
      }).toList();
      for (int i = 0; i < _allVoices.length; i++) {
        if (_allVoices[i]!['locale']?.substring(0, 2) == 'en') {
          if (Platform.isAndroid) {
            if (_allVoices[i]!['name'] == _prevSelectedAccentName) {
              _moreVoiceSelectionScreenModelList.insert(
                  0,
                  MoreVoiceSelectionScreenModel(
                      englishAccent: _allVoices[i],
                      isPaused: true,
                      isSelected: true));
            } else {
              _moreVoiceSelectionScreenModelList.add(
                  MoreVoiceSelectionScreenModel(
                      englishAccent: _allVoices[i],
                      isPaused: true,
                      isSelected: false));
            }
          } else {
            List<String> list = _prevSelectedAccentName.split('%@');
            if (list.length == 2) {
              String locale = list[0];
              String name = list[1];

              if (_allVoices[i]!['name'] == name && _allVoices[i]!['locale'] == locale) {
                _moreVoiceSelectionScreenModelList.insert(
                    0,
                    MoreVoiceSelectionScreenModel(
                        englishAccent: _allVoices[i],
                        isPaused: true,
                        isSelected: true));
              } else {
                _moreVoiceSelectionScreenModelList.add(
                    MoreVoiceSelectionScreenModel(
                        englishAccent: _allVoices[i],
                        isPaused: true,
                        isSelected: false));
              }
            } else {
              _moreVoiceSelectionScreenModelList.add(
                  MoreVoiceSelectionScreenModel(
                      englishAccent: _allVoices[i],
                      isPaused: true,
                      isSelected: false));
            }
          }
        }
      }
      _getLastSelectedAccent();
      Provider.of<MoreVoiceSelectionScreenInfo>(context, listen: false).updateAllVoiceList();
      //setState(() {});
    }
  }

  void _pausedButtonListHandler(int index) {
    if (_moreVoiceSelectionScreenModelList[index].isPaused) {
      for (int i = 0; i < _moreVoiceSelectionScreenModelList.length; i++) {
        _moreVoiceSelectionScreenModelList[i].isPaused = true;
      }
      _moreVoiceSelectionScreenModelList[index].isPaused = false;
    } else {
      _moreVoiceSelectionScreenModelList[index].isPaused = true;
    }
  }

  Future<void> _ttsPlayHandler(int index) async {
    await _flutterTts.stop();
    await _flutterTts
        .setVoice(_moreVoiceSelectionScreenModelList[index].englishAccent!);
    await _flutterTts.speak(Constant.ttsDemoText);
    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS: setCompletionHandler1 index=$index");
      setState(() {
        _moreVoiceSelectionScreenModelList[index].isPaused = true;
      });
    });
    _flutterTts.setProgressHandler((text, start, end, word) {
      debugPrint("TTS: setContinueHandler1 index=$index");
      setState(() {
        _moreVoiceSelectionScreenModelList[index].isPaused = false;
      });
    });
    /*_flutterTts.setCancelHandler(() {
      debugPrint("TTS: setCancelHandler1 index=$index");
      setState(() {
        _moreVoiceSelectionScreenModelList[index].isPaused = false;
      });
    });*/
    _flutterTts.setErrorHandler((message) {
      debugPrint("TTS: setErrorHandler1 index=$index");
      _flutterTts.stop();
    });
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: Constant.backgroundBoxDecoration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RawScrollbar(
              thickness: 2,
              thumbColor: Constant.locationServiceGreen,
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _flutterTts.stop();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constant.moreBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(Constant.leftArrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: 'Settings',
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostRegular),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Consumer<MoreVoiceSelectionScreenInfo>(
                      builder: (context, data, child){
                        return Container(
                          height: _moreVoiceSelectionScreenModelList.length * 65,
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _scrollController,
                            itemCount: _moreVoiceSelectionScreenModelList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(
                                  top: index == 0 ? 9:0,
                                  bottom: index == _moreVoiceSelectionScreenModelList.length-1 ? 9:0,
                                  left: 15,
                                  right: 23,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: (index == 0
                                        ? Radius.circular(20)
                                        : Radius.circular(0)),
                                    topRight: (index == 0
                                        ? Radius.circular(20)
                                        : Radius.circular(0)),
                                    bottomLeft: (index ==
                                        _moreVoiceSelectionScreenModelList
                                            .length -
                                            1
                                        ? Radius.circular(20)
                                        : Radius.circular(0)),
                                    bottomRight: (index ==
                                        _moreVoiceSelectionScreenModelList
                                            .length -
                                            1
                                        ? Radius.circular(20)
                                        : Radius.circular(0)),
                                  ),
                                  color: Constant.moreBackgroundColor,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () =>
                                                _openSelectVoiceActionSheet(index),
                                            child: CustomTextWidget(
                                              overflow: TextOverflow.ellipsis,
                                              text: (Platform.isIOS)
                                                  ? '${Constant.englishAccentMap[_moreVoiceSelectionScreenModelList[index].englishAccent?['locale'] ?? 'en-US'] ?? '${_moreVoiceSelectionScreenModelList[index].englishAccent?['locale']}'} (${_moreVoiceSelectionScreenModelList[index].englishAccent?['name']})'
                                                  : '${Constant.englishAccentMap[_moreVoiceSelectionScreenModelList[index].englishAccent?['locale'] ?? 'en-US'] ?? '${_moreVoiceSelectionScreenModelList[index].englishAccent?['locale']}'}',
                                              style: TextStyle(
                                                  color:
                                                  Constant.locationServiceGreen,
                                                  fontSize: 16,
                                                  fontFamily: Constant.jostRegular),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.multitrack_audio_rounded,
                                                  color:
                                                  (_moreVoiceSelectionScreenModelList[
                                                  index]
                                                      .isPaused)
                                                      ? Constant
                                                      .notificationTextColor
                                                      : Constant.chatBubbleGreen,
                                                  size: 30,
                                                ),
                                                /*(_isPausedButtonList[index])
                                                ? Icons.play_arrow_rounded
                                                : Icons.pause_rounded, color: Constant
                                              .notificationTextColor , size: 30,),*/
                                                onPressed: () async {
                                                  setState(() {
                                                    _pausedButtonListHandler(index);
                                                  });
                                                  if (_moreVoiceSelectionScreenModelList[
                                                  index]
                                                      .isPaused) {
                                                    await _flutterTts.stop();
                                                  } else {
                                                    _ttsPlayHandler(index);
                                                  }
                                                },
                                              ),
                                              GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: (){
                                                  setState(() {
                                                    _pausedButtonListHandler(index);
                                                  });
                                                  if (!_moreVoiceSelectionScreenModelList[index].isSelected) {
                                                    if (Platform.isAndroid) {
                                                      _sharedPreferences.setString(
                                                          Constant.ttsAccentKey,
                                                          _moreVoiceSelectionScreenModelList[
                                                          index]
                                                              .englishAccent?[
                                                          'name'] ??
                                                              _prevSelectedAccentName);
                                                      Utils.sendAnalyticsEvent('default_accent_selected', {
                                                        'platform': Constant.android,
                                                        'accentLocale': _moreVoiceSelectionScreenModelList[index].englishAccent?['locale'] ?? _prevSelectedAccentName,
                                                        'accentName': _moreVoiceSelectionScreenModelList[index].englishAccent?['locale'] ?? 'en-US'
                                                      }, context);
                                                    } else {
                                                      _sharedPreferences.setString(Constant.ttsAccentKey,
                                                          '${_moreVoiceSelectionScreenModelList[
                                                          index]
                                                              .englishAccent?[
                                                          'locale']}%@${_moreVoiceSelectionScreenModelList[
                                                          index]
                                                              .englishAccent?[
                                                          'name']}');
                                                    }
                                                    Utils.sendAnalyticsEvent('default_accent_selected', {
                                                      'platform': Constant.ios,
                                                      'accentLocale': _moreVoiceSelectionScreenModelList[index].englishAccent?['locale'] ?? _prevSelectedAccentName,
                                                      'accentName': _moreVoiceSelectionScreenModelList[index].englishAccent?['locale'] ?? 'en-US'
                                                    }, context);
                                                    setState(() {
                                                      for (int i = 0; i < _moreVoiceSelectionScreenModelList.length; i++)
                                                        _moreVoiceSelectionScreenModelList[i].isSelected = false;
                                                      _moreVoiceSelectionScreenModelList[
                                                      index]
                                                          .isSelected = true;
                                                    });
                                                    _ttsPlayHandler(index);
                                                  } else {
                                                    _sharedPreferences.setString(
                                                        Constant.ttsAccentKey,
                                                        _prevSelectedAccentName);
                                                    setState(() {
                                                      _moreVoiceSelectionScreenModelList[
                                                      index]
                                                          .isSelected = false;
                                                      _moreVoiceSelectionScreenModelList[
                                                      index]
                                                          .isPaused = true;
                                                    });
                                                    _flutterTts.stop();
                                                  }
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(60),
                                                    border: Border.all(width: 2, color: (_moreVoiceSelectionScreenModelList[index].isSelected)
                                                        ? Constant.chatBubbleGreen : Constant.notificationTextColor,),
                                                  ),
                                                  child: (_moreVoiceSelectionScreenModelList[index].isSelected) ? Center(
                                                    child: Container(
                                                      height: 10,
                                                      width: 10,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(40),
                                                        border: Border.all(width: 2, color: Constant.chatBubbleGreen,),
                                                        color: Constant.chatBubbleGreen,
                                                      ),
                                                    ),
                                                  ) : const SizedBox(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    (index !=
                                        _moreVoiceSelectionScreenModelList
                                            .length -
                                            1)
                                        ? Divider(
                                      color: Constant.locationServiceGreen,
                                      thickness: 1,
                                    )
                                        : SizedBox(),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSelectVoiceActionSheet(int index) async {
    var result = await widget.openSelectVoiceActionSheetCallback(
        Constant.selectTtsAccentActionSheet, null);
    if (result == Constant.play) {
      setState(() {
        _pausedButtonListHandler(index);
      });
      _ttsPlayHandler(index);
    }
  }
}

class MoreVoiceSelectionScreenModel {
  Map<String, String>? englishAccent;
  bool isPaused;
  bool isSelected;

  MoreVoiceSelectionScreenModel(
      {required this.englishAccent,
        required this.isPaused,
        required this.isSelected});
}

class MoreVoiceSelectionScreenInfo with ChangeNotifier{
  updateAllVoiceList() => Future.delayed(const Duration(milliseconds: 150)).then((value) => notifyListeners());
}