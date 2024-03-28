class RecordsCompassAxesResultModel {
  List<Axes>? previousAxes;
  List<Axes>? currentAxes;
  List<Axes>? signUpAxes;
  String? calendarEntryAt;

  RecordsCompassAxesResultModel(
      {this.previousAxes,
      this.currentAxes,
      this.signUpAxes,
      this.calendarEntryAt});

  RecordsCompassAxesResultModel.fromJson(Map<String, dynamic> json) {
    if (json['previous_axes'] != null) {
      previousAxes = <Axes>[];
      json['previous_axes'].forEach((v) {
        previousAxes!.add(new Axes.fromJson(v));
      });
    }
    if (json['axes'] != null) {
      signUpAxes = <Axes>[];
      json['axes'].forEach((v) {
        signUpAxes!.add(new Axes.fromJson(v));
      });
    }
    if (json['current_axes'] != null) {
      currentAxes = <Axes>[];
      json['current_axes'].forEach((v) {
        currentAxes!.add(new Axes.fromJson(v));
      });
    }

    calendarEntryAt = json['calendarEntryAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['calendarEntryAt'] = this.calendarEntryAt;
    if (this.previousAxes != null) {
      data['previous_axes'] = this.previousAxes!.map((v) => v.toJson()).toList();
    }
    if (this.currentAxes != null) {
      data['current_axes'] = this.currentAxes!.map((v) => v.toJson()).toList();
    }
    if (this.signUpAxes != null) {
      data['axes'] = this.signUpAxes!.map((v) => v.toJson()).toList();
    }
    data["calendarEntryAt"] = calendarEntryAt;
    return data;
  }
}

class Axes {
  double? total;
  int? min;
  double? max;
  String? name;
  double? value;

  Axes({this.total, this.min, this.max, this.name, this.value});

  Axes.fromJson(Map<String, dynamic> json) {
    total = double.tryParse(json['total'].toString());
    min = json['min'];
    max = double.tryParse(json['max'].toString());
    name = json['name'];
    value = double.tryParse(json['value'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['min'] = this.min;
    data['max'] = this.max;
    data['name'] = this.name;
    data['value'] = this.value;
    return data;
  }
}
