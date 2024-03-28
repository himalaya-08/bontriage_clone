import 'package:flutter/cupertino.dart';

import '../util/constant.dart';

class UserNameInfo with ChangeNotifier {
  String _userName = Constant.blankString;

  String getUserName() => _userName;

  updateUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }
}