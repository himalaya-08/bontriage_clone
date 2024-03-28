import 'CalendarInfoDataModel.dart';
import 'SignUpHeadacheAnswerListModel.dart';

class UserLogHeadacheDataCalendarModel {
  List<SelectedHeadacheLogDate> addHeadacheListData = [];
  List<SelectedHeadacheLogDate> addTriggersListData = [];
  List<SelectedHeadacheLogDate> addLogDayListData = [];
  List<SelectedHeadacheLogDate> behavioursListData = [];
  List<SelectedHeadacheLogDate> medicationsListData = [];
  List<SelectedDayHeadacheIntensity> addHeadacheIntensityListData = [];
  List<SelectedHeadacheLogDate> studyMedicationList = [];
  String userId = "";
}

class SelectedHeadacheLogDate {
  String? formattedDate;
  String? selectedDay;
  List<Headache>? headacheListData;
  List<SignUpHeadacheAnswerListModel>? userTriggersListData = [];
}

class SelectedDayHeadacheIntensity {
  String? questionTag;
  String? intensityValue;
  String? selectedDay;
  String? headacheStartDate;
  bool isMigraine  = false;
}
