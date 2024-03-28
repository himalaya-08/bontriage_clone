class UserHeadacheLogDayDetailsModel {
  List<RecordWidgetData>? headacheLogDayListData;
  String? logDayNote;
  bool? isHeadacheLogged = false;
  bool? isDayLogged = false;

  UserHeadacheLogDayDetailsModel(
      {this.headacheLogDayListData, this.logDayNote,this.isDayLogged,this.isHeadacheLogged});
}

class RecordWidgetData {
  String? imagePath;
  List<HeadacheData>? headacheListData = [];
  LogDayData? logDayListData;

  RecordWidgetData(
      {this.headacheListData, this.imagePath, this.logDayListData});
}

class HeadacheData {
  String? headacheName;
  String? headacheInfo;
  String? headacheNote;
  bool isMigraine;
  int? headacheId;

  HeadacheData({this.headacheNote, this.headacheInfo, this.headacheName, this.headacheId, this.isMigraine = false});
}

class LogDayData {
  String? titleName;
  String? titleInfo;

  LogDayData({this.titleInfo, this.titleName});
}
