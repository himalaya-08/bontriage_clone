
class MedicationDataModel {
  String? medicationText;
  String? dosageValue;
  String? formulation;
  double? numberOfDosage;
  String? medicationTime;
  DateTime? startDateTime;
  DateTime? endDateTime;
  bool isPreventive;
  bool isChecked;

  MedicationDataModel({
    this.medicationText,
    this.dosageValue,
    this.numberOfDosage,
    this.medicationTime,
    this.formulation,
    this.startDateTime,
    this.endDateTime,
    this.isPreventive = true,
    this.isChecked = false,
  });
}
