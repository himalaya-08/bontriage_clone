import 'dart:convert';

DeleteHeadacheResponseModel deleteHeadacheResponseModelFromJson(String str) => DeleteHeadacheResponseModel.fromJson(json.decode(str));

String deleteHeadacheResponseModelToJson(DeleteHeadacheResponseModel data) => json.encode(data.toJson());

class DeleteHeadacheResponseModel {
  DeleteHeadacheResponseModel({
    required this.messageType,
    required this.messageText,
  });

  String messageType;
  String messageText;

  factory DeleteHeadacheResponseModel.fromJson(Map<String, dynamic> json) => DeleteHeadacheResponseModel(
    messageType: json["message_type"],
    messageText: json["message_text"],
  );

  Map<String, dynamic> toJson() => {
    "message_type": messageType,
    "message_text": messageText,
  };
}