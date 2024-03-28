class SignUpOnBoardAnswersRequestModel {
  String? calendarEntryAt;
  String? eventType;
  List<MobileEventDetails>? mobileEventDetails;
  String? updatedAt;
  int? userId;
  int? eventId;

  SignUpOnBoardAnswersRequestModel(
      {this.calendarEntryAt,
        this.eventType,
        this.mobileEventDetails,
        this.updatedAt,
        this.userId,
      this.eventId});

  SignUpOnBoardAnswersRequestModel.fromJson(Map<String, dynamic> json) {
    calendarEntryAt = json['calendar_entry_at'];
    eventType = json['event_type'];
    if (json['mobile_event_details'] != null) {
      mobileEventDetails = <MobileEventDetails>[];
      json['mobile_event_details'].forEach((v) {
        mobileEventDetails!.add(new MobileEventDetails.fromJson(v));
      });
    }
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    eventId = json['eventId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['calendar_entry_at'] = this.calendarEntryAt;
    data['event_type'] = this.eventType;
    if (this.mobileEventDetails != null) {
      data['mobile_event_details'] =
          this.mobileEventDetails!.map((v) => v.toJson()).toList();
    }
    data['updated_at'] = this.updatedAt;
    data['user_id'] = this.userId;
    if(this.eventId != null)
      data['event_id'] = this.eventId;
    return data;
  }
}

class MobileEventDetails {
  String? questionJson;
  String? questionTag;
  String? updatedAt;
  int? eventId;
  List<String>? value;

  MobileEventDetails(
      {this.questionJson, this.questionTag, this.updatedAt, this.value, this.eventId});

  MobileEventDetails.fromJson(Map<String, dynamic> json) {
    questionJson = json['question_json'];
    questionTag = json['question_tag'];
    updatedAt = json['updated_at'];
    value = json['value'].cast<String>();
    eventId = json['event_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question_json'] = this.questionJson;
    data['question_tag'] = this.questionTag;
    data['updated_at'] = this.updatedAt;
    data['value'] = this.value;
    if(this.eventId != null)
      data['event_id'] = this.eventId;
    return data;
  }
}