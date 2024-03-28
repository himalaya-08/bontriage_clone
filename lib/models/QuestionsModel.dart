import 'package:mobile/util/constant.dart';

class Questions {
  String? tag;
  int? id;
  String? questionType;
  String? precondition;
  String? next;
  String? text;
  String? helpText;
  List<Values>? values;
  int? min;
  int? max;
  String? updatedAt;
  String? exclusiveValue;
  int? phi;
  int? required;
  String? uiHints;
  String? currentValue;

  Questions(
      {this.tag,
      this.id,
      this.questionType,
      this.precondition,
      this.next,
      this.text,
      this.helpText,
      this.values,
      this.min,
      this.max,
      this.updatedAt,
      this.exclusiveValue,
      this.phi,
      this.required,
      this.uiHints,
      this.currentValue});

  Questions.fromJson(Map<String, dynamic> json) {
    tag = json['tag'];
    id = json['id'];
    questionType = json['question_type'];

    if(json['questionType'] != null)
      questionType = json['questionType'];

    precondition = json['precondition'];
    next = json['next'];
    text = json['text'];
    helpText = json['help_text'];
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        values!.add(new Values.fromJson(v));
      });
    }
    min = json['min'];
    max = json['max'];
    updatedAt = json['updated_at'];

    if(json['updatedAt'] != null)
      updatedAt = json['updatedAt'];

    exclusiveValue = json['exclusive_value'];

    if(json['exclusiveValue'] != null)
      exclusiveValue = json['exclusiveValue'];

    phi = json['phi'];
    required = json['required'];
    uiHints = json['ui_hints'];

    if(json['uiHints'] != null)
      uiHints = json['uiHints'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tag'] = this.tag;
    data['id'] = this.id;
    data['question_type'] = this.questionType;
    data['precondition'] = this.precondition;
    data['next'] = this.next;
    data['text'] = this.text;
    data['help_text'] = this.helpText;
    if (this.values != null) {
      data['values'] = this.values!.map((v) => v.toJson()).toList();
    }
    data['min'] = this.min;
    data['max'] = this.max;
    data['updated_at'] = this.updatedAt;
    data['exclusive_value'] = this.exclusiveValue;
    data['phi'] = this.phi;
    data['required'] = this.required;
    data['ui_hints'] = this.uiHints;
    return data;
  }
}

class Values {
  String? valueNumber;
  String? text;
  String? selectedText;
  bool isSelected = false;
  bool isDoubleTapped = false;
  bool isNewlyAdded = false;
  bool? isValid;
  bool? isMigraine;
  int? numberOfDosage;
  List<Values>? unitList;
  bool? isRecentMedication;
  int? medicationType = 3; //TODO: remove its value
  // [1: acute, 2: preventive, 3: both]

  Values({this.valueNumber, this.text, this.isSelected = false, this.isDoubleTapped = false, this.isNewlyAdded = false, this.isValid = true, this.numberOfDosage = 0, this.unitList, this.isRecentMedication = false, this.isMigraine = false, this.selectedText, this.medicationType});

  Values.fromJson(Map<String, dynamic> json) {
    valueNumber = json['value_number'];
    text = json['text'];
    isSelected = (json['isSelected'] == null) ? false : json['isSelected'];
    isValid = json['is_valid'];
    isDoubleTapped = json['isDoubleTapped'] ?? false;
    isMigraine = json['is_migraine'] ?? false;
    selectedText = json['selected_text'];

    unitList = [];
    if(json['unit'] != null) {

      List<String> unit = [];

      json['unit'].forEach((el) {
        unit.add(el);
      });

      if (unit == null)
        unit = [];

      List<Values> unitLists = [];

      unit.forEach((element) {
        unitLists.add(Values(text: element, isSelected: false));
      });

      unitList = unitLists;
    }

    /*unitList = [];*/
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value_number'] = this.valueNumber;
    data['text'] = this.text;
    data['isSelected'] = this.isSelected;
    data['is_valid'] = isValid;
    data['isDoubleTapped'] = isDoubleTapped;
    data['unit'] = unitList;
    data['is_migraine'] = isMigraine;
    data['selected_text'] = selectedText;
    return data;
  }
}
