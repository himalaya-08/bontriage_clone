import 'dart:convert';

ForgotPasswordModel forgotPasswordModelFromJson(String str) => ForgotPasswordModel.fromJson(json.decode(str));

String forgotPasswordModelToJson(ForgotPasswordModel data) => json.encode(data.toJson());

class ForgotPasswordModel {
  ForgotPasswordModel({
    this.messageType,
    this.messageText,
    this.status
  });

  String? messageType;
  String? messageText;
  int? status;

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordModel(
          messageType: json["message_type"],
          messageText: json["message_text"],
          status: json['status']
      );

  Map<String, dynamic> toJson() =>
      {
        "message_type": messageType,
        "message_text": messageText,
        'status': status,
      };
}