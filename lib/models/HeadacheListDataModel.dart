class HeadacheListDataModel {
  String? valueNumber;
  String? text;
  bool? isValid;
  bool? isSelected = false;

  HeadacheListDataModel(
      { this.valueNumber,
       this.text,
       this.isValid,
       this.isSelected});

  HeadacheListDataModel.fromJson(
      Map<String, dynamic> json) {
    valueNumber = json['value_number'];
    text = json['text'];
    isValid = json['is_valid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value_number'] = this.valueNumber;
    data['text'] = this.text;
    data['is_valid'] = this.isValid;
    return data;
  }
}
