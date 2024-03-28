class CompassTutorialModel {
  DateTime? currentDateTime = DateTime.now();
   int? previousMonthIntensity;
   int currentMonthIntensity;
   int? previousMonthDisability;
   int currentMonthDisability;
   int? previousMonthFrequency;
   int? currentMonthFrequency;
   int? previousMonthDuration;
   int currentMonthDuration;
   bool isFromOnBoard;

  CompassTutorialModel({
    this.currentDateTime,
    this.previousMonthIntensity,
    this.currentMonthIntensity = 0,
    this.previousMonthDisability,
    this.currentMonthDisability = 0,
    this.previousMonthFrequency,
    this.currentMonthFrequency = 0,
    this.previousMonthDuration,
    this.currentMonthDuration = 0,
    this.isFromOnBoard = false,
  });
}
