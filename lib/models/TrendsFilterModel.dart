class TrendsFilterModel {
 List<DateTime>? occurringDateList;
 String? dotName;
 int? numberOfOccurrence ;

 TrendsFilterModel({this.occurringDateList ,this.dotName,this.numberOfOccurrence});

}

class TrendsFilterListModel{
  List<TrendsFilterModel> behavioursListData = [];
 List<TrendsFilterModel> medicationListData = [];
 List<TrendsFilterModel> triggersListData = [];

}