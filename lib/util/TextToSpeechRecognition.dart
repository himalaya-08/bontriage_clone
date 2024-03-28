import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'constant.dart';

class TextToSpeechRecognition {
  static final FlutterTts flutterTts = FlutterTts();

  static Future<void> speechToText(String chatText) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      String ttsAccentName = sharedPreferences.getString(
          Constant.ttsAccentKey) ?? 'en-us-x-sfg-local';
      String ttsAccentLocale = ttsAccentName.substring(0, 3) +
          ttsAccentName.substring(3, 5).toUpperCase();
      await flutterTts.setVoice(
          {'name': ttsAccentName, 'locale': ttsAccentLocale});
    } else {
      String accentSelected = sharedPreferences.getString(
          Constant.ttsAccentKey) ?? 'en-US%@Samantha';

      if (accentSelected == 'en-US')
        accentSelected = 'en-US%@Samantha';

      List<String> list = accentSelected.split('%@');
      if (list.length == 2) {
        String locale = list[0];
        String name = list[1];

        await flutterTts.setVoice({'name': name, 'locale': locale});
      }
    }

    await flutterTts.setSpeechRate(0.5);

    if (Platform.isAndroid) {
      // Android-specific code
      await flutterTts.setPitch(1.0);
    } else if (Platform.isIOS) {
      // iOS-specific code
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSharedInstance(true);

      await flutterTts
          .setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      ]);
    }

    bool? isVolume = sharedPreferences.getBool(Constant.chatBubbleVolumeState);
    chatText = chatText.replaceAll('headache', 'head ache');
    chatText = chatText.replaceAll('Headache', 'Head ache');

    debugPrint('TTS?????$chatText');
    if (isVolume == null || isVolume) {
      Future.delayed(Duration(milliseconds: 50), () {
        startSpeech(chatText);
      });
    } else {
        await flutterTts.stop();
    }
  }

  static void startSpeech(String chatText) async{
    await flutterTts.speak(chatText);
  }

  static void stopSpeech() async{
    await flutterTts.stop();
  }
}
