import 'CalendarInfoDataModel.dart';

class CurrentUserHeadacheModel {
  String? userId;
  String? selectedDate;
  String? selectedEndDate;
  bool? isOnGoing;
  bool? isFromRecordScreen;
  int? headacheId;
  bool?
      isFromServer; //this attribute is to identify whether this headache date came from server or not.
  List<MobileEventDetails1>? mobileEventDetails;

  CurrentUserHeadacheModel(
      {this.userId,
      this.selectedDate,
      this.selectedEndDate,
      this.isOnGoing = false,
      this.isFromRecordScreen = false,
      this.headacheId,
      this.isFromServer = false,
      this.mobileEventDetails});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'userId': userId,
      'selectedDate': selectedDate,
      'selectedEndDate': selectedEndDate,
      'isOnGoing': isOnGoing,
      'isFromRecordScreen': isFromRecordScreen,
      'headacheId': headacheId,
      'isFromServer': isFromServer,
      'mobileEventDetails': mobileEventDetails != null
          ? List<dynamic>.from(mobileEventDetails!.map((x) => x.toJson()))
          : null,
    };
    return map;
  }

  CurrentUserHeadacheModel.fromJson(Map<String, dynamic> map) {
    userId = map['userId'];
    selectedDate = map['selectedDate'];
    selectedEndDate = map['selectedEndDate'];
    isOnGoing = map['isOnGoing'];
    isFromRecordScreen = map['isFromRecordScreen'];
    headacheId = map['headacheId'];
    isFromServer = map['isFromServer'];
    mobileEventDetails = map["mobileEventDetails"] != null
        ? List<MobileEventDetails1>.from(map["mobileEventDetails"]
            .map((x) => MobileEventDetails1.fromJson(x)))
        : null;
  }
}
