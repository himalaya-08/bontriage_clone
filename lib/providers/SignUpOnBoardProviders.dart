import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/LocalNotificationModel.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserAddHeadacheLogModel.dart';
import 'package:mobile/models/LogDayQuestionnaire.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/QuestionsModel.dart';

class SignUpOnBoardProviders {
  static const String TABLE_USER_PROGRESS = "user_progress";
  static const String USER_ID = "userId";
  static const String STEP = "step";
  static const String QUESTION_TAG = "questionTag";
  static const String TABLE_QUESTIONNAIRES = "questionnaire";
  static const String EVENT_TYPE = "event_type";
  static const String QUESTIONNAIRES = "questionnaires";
  static const String SELECTED_ANSWERS = "selectedAnswers";
  static const String USER_SCREEN_POSITION = "userScreenPosition";
  static const String backQuestionIndexList = "backQuestionIndexList";
  static const String TABLE_USER_PROFILE_INFO = "userProfileInfo";
  static const String TABLE_USER_CURRENT_HEADACHE = 'userCurrentHeadache';
  static const String TABLE_TUTORIAL = 'tutorialTable';
  static const String TABLE_LOG_HEADACHE_MEDICATION = 'tableLogHeadacheMedication';
  static const String NOTIFICATION_JSON = 'notificationJson';
  static const String TABLE_RECENT_MEDICATION = 'tableRecentMedication';
  static const String NUMBER_OF_TIMES_LOGGED = 'numberOfTimesLogged';
  static const String MEDICATION_NAME = 'medicationName';

  static const String TABLE_ADD_HEADACHE = "addHeadache";
  static const String HEADACHE_TYPE = "headacheType";
  static const String HEADACHE_START_DATE = "headacheStartDate";
  static const String HEADACHE_START_TIME = "headacheStartTime";
  static const String HEADACHE_END_DATE = "headacheEndDate";
  static const String HEADACHE_END_TIME = "headacheEndTime";
  static const String HEADACHE_INTENSITY = "headacheIntensity";
  static const String HEADACHE_DISABILITY = "headacheDisability";
  static const String HEADACHE_NOTE = "headacheNote";
  static const String HEADACHE_ONGOING = "headacheOnGoing";
  static const String USER_PROFILE_INFO_MODEL = "userProfileInfoModel";
  static const String USER_CURRENT_HEADACHE_JSON = "userCurrentHeadacheJson";
  static const String TUTORIAL_ID = "tutorialId";

  static const String USER_NOTIFICATION = "userNotification";

  //For Log Day Screen
  static const String TABLE_LOG_DAY = "tableLogDay";
  static const String TABLE_LOG_HEADACHE_MIGRAINE = 'tableLogHeadacheMigraine';

  static const String DOSAGE_TYPE = 'dosageType';
  static const String DOSAGE = 'dosage';
  static const String NUMBER_OF_DOSAGE = 'numberOfDosage';
  static const String MIGRAINE_LIST = 'migraineList';
  static const String UNITS = 'units';

  SignUpOnBoardProviders._();

  static final SignUpOnBoardProviders db = SignUpOnBoardProviders._();

  Database? _database;

  /// Database getter method used to get the database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await createDatabase();
    return _database!;
  }

  Future<Database> createDatabase() async {
    String dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, 'bonTriageDB.db');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    int version = packageInfo.packageName == "com.bontriage.mobile" ? 3 : 1;

    if (await databaseExists(dbPath)) {
      debugPrint("DB_VERSION1=$version");
      return await openDatabase(dbPath, version: version, onCreate: (Database database, int version) async {
        await _onCreate(database: database, version: version);
      }, onUpgrade: (db, oldVersion, newVersion) async {
        await _onUpgrade(db: db, oldVersion: oldVersion, newVersion: newVersion);
      });
    }

    return await openDatabase(dbPath, version: version,
        onCreate: (Database database, int version) async {
      await _onCreate(database: database, version: version);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      await _onUpgrade(db: db, oldVersion: oldVersion, newVersion: newVersion);
    });
  }

  static Future<void> _onCreate({required Database database, required int version}) async {
    Batch batch = database.batch();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    debugPrint("DB_VERSION=$version");

    if (packageInfo.packageName == "com.bontriage.mobile") {
      batch.execute("CREATE TABLE $TABLE_USER_PROGRESS ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$STEP TEXT,"
          "$QUESTION_TAG TEXT,"
          "$USER_SCREEN_POSITION integer,"
          "$backQuestionIndexList TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_USER_PROFILE_INFO ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$USER_PROFILE_INFO_MODEL TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_QUESTIONNAIRES ("
          "$EVENT_TYPE TEXT PRIMARY KEY,"
          "$QUESTION_TAG TEXT,"
          "$QUESTIONNAIRES TEXT,"
          "$SELECTED_ANSWERS TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_ADD_HEADACHE ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$SELECTED_ANSWERS TEXT"
          ")");

      batch.execute("CREATE TABLE $TABLE_LOG_DAY ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$SELECTED_ANSWERS TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_USER_CURRENT_HEADACHE ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$USER_CURRENT_HEADACHE_JSON TEXT"
          ")");

      batch.execute("CREATE TABLE $TABLE_TUTORIAL ("
          "$TUTORIAL_ID INT(10),"
          "$USER_ID TEXT"   ")");

      batch.execute("CREATE TABLE $USER_NOTIFICATION ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$NOTIFICATION_JSON TEXT"
          ")");

      batch.execute("CREATE TABLE $TABLE_RECENT_MEDICATION ("
          "$MEDICATION_NAME TEXT,"
          "$NUMBER_OF_TIMES_LOGGED int"
          ")");

      batch.execute("CREATE TABLE $TABLE_LOG_HEADACHE_MEDICATION ("
          "$MEDICATION_NAME TEXT"
          ")");
    } else {
      batch.execute("CREATE TABLE $TABLE_USER_PROGRESS ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$STEP TEXT,"
          "$QUESTION_TAG TEXT,"
          "$USER_SCREEN_POSITION integer,"
          "$backQuestionIndexList TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_USER_PROFILE_INFO ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$USER_PROFILE_INFO_MODEL TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_QUESTIONNAIRES ("
          "$EVENT_TYPE TEXT PRIMARY KEY,"
          "$QUESTION_TAG TEXT,"
          "$QUESTIONNAIRES TEXT,"
          "$SELECTED_ANSWERS TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_ADD_HEADACHE ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$SELECTED_ANSWERS TEXT"
          ")");

      batch.execute('DROP TABLE IF EXISTS $TABLE_LOG_DAY');
      batch.execute("CREATE TABLE $TABLE_LOG_DAY ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$SELECTED_ANSWERS TEXT"
          ")");

      batch.execute("CREATE TABLE $TABLE_USER_CURRENT_HEADACHE ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$USER_CURRENT_HEADACHE_JSON TEXT"
          ")");

      batch.execute("CREATE TABLE $TABLE_TUTORIAL ("
          "$TUTORIAL_ID INT(10),"
          "$USER_ID TEXT"   ")");

      batch.execute("CREATE TABLE $USER_NOTIFICATION ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$NOTIFICATION_JSON TEXT"
          ")");

      batch.execute("CREATE TABLE $TABLE_LOG_HEADACHE_MEDICATION ("
          "$USER_ID TEXT,"
          "$MEDICATION_NAME TEXT,"
          "$DOSAGE_TYPE TEXT,"
          "$DOSAGE TEXT,"
          "$UNITS TEXT,"
          "$NUMBER_OF_DOSAGE TEXT"
          ")");
      batch.execute("CREATE TABLE $TABLE_LOG_HEADACHE_MIGRAINE ("
          "$USER_ID TEXT PRIMARY KEY,"
          "$MIGRAINE_LIST TEXT"
          ")");

      batch.execute("CREATE TABLE $TABLE_RECENT_MEDICATION ("
          "$MEDICATION_NAME TEXT,"
          "$NUMBER_OF_TIMES_LOGGED int"
          ")");
    }
    await batch.commit();
  }

  static Future<void> _onUpgrade({required Database db, required int oldVersion, required int newVersion}) async {
    Batch batch = db.batch();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    debugPrint("OLD_DB_VERSION=$oldVersion, NEW_DB_VERSION=$newVersion");

    if (packageInfo.packageName == "com.bontriage.mobile") {
      if (oldVersion == 1) {
        batch.execute('DROP TABLE IF EXISTS $TABLE_LOG_HEADACHE_MEDICATION');
        batch.execute("CREATE TABLE $TABLE_LOG_HEADACHE_MEDICATION ("
            "$USER_ID TEXT,"
            "$MEDICATION_NAME TEXT,"
            "$DOSAGE_TYPE TEXT,"
            "$DOSAGE TEXT,"
            "$UNITS TEXT,"
            "$NUMBER_OF_DOSAGE TEXT"
            ")");

        batch.execute('DROP TABLE IF EXISTS $TABLE_RECENT_MEDICATION');
        batch.execute("CREATE TABLE $TABLE_RECENT_MEDICATION ("
            "$MEDICATION_NAME TEXT,"
            "$NUMBER_OF_TIMES_LOGGED int"
            ")");
        batch.execute('DROP TABLE IF EXISTS $TABLE_LOG_DAY');
        batch.execute("CREATE TABLE $TABLE_LOG_DAY ("
            "$USER_ID TEXT PRIMARY KEY,"
            "$SELECTED_ANSWERS TEXT"
            ")");
      } else if (oldVersion == 2) {
        batch.execute('DROP TABLE IF EXISTS $TABLE_LOG_HEADACHE_MEDICATION');
        batch.execute("CREATE TABLE $TABLE_LOG_HEADACHE_MEDICATION ("
            "$USER_ID TEXT,"
            "$MEDICATION_NAME TEXT,"
            "$DOSAGE_TYPE TEXT,"
            "$DOSAGE TEXT,"
            "$UNITS TEXT,"
            "$NUMBER_OF_DOSAGE TEXT"
            ")");

        batch.execute('DROP TABLE IF EXISTS $TABLE_RECENT_MEDICATION');
        batch.execute("CREATE TABLE $TABLE_RECENT_MEDICATION ("
            "$MEDICATION_NAME TEXT,"
            "$NUMBER_OF_TIMES_LOGGED int"
            ")");

        batch.execute('DROP TABLE IF EXISTS $TABLE_LOG_DAY');
        batch.execute("CREATE TABLE $TABLE_LOG_DAY ("
            "$USER_ID TEXT PRIMARY KEY,"
            "$SELECTED_ANSWERS TEXT"
            ")");
      }
    }
    await batch.commit();
  }

  Future<void> insertUserNotifications(List<LocalNotificationModel> localNotificationListData) async {
    debugPrint('insertUserNotifications1');
    final db = await database;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    List<dynamic> userInfoListData = await db.rawQuery('SELECT * FROM $USER_NOTIFICATION where $USER_ID = ${userProfileInfoData.userId}');

    if (userInfoListData.length == 0){
   // var notificationListData = await SignUpOnBoardProviders.db.getAllLocalNotificationsData();
   // if(notificationListData == null || notificationListData.length == 0){
      Map<String, dynamic> localNotificationMap = {USER_ID:userProfileInfoData.userId, NOTIFICATION_JSON:jsonEncode(localNotificationListData)};
      await db.insert(USER_NOTIFICATION, localNotificationMap);
    }else{
      await updateUserNotifications(localNotificationListData);
    }
  }

  Future<void> updateUserNotifications(List<LocalNotificationModel> localNotificationListData) async {
    final db = await database;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    Map<String,dynamic> localNotificationMap = {USER_ID:userProfileInfoData.userId, NOTIFICATION_JSON:jsonEncode(localNotificationListData)};
    await db.update(
      USER_NOTIFICATION,
      localNotificationMap,
      where: "$USER_ID = ?",
      whereArgs: [userProfileInfoData.userId],
    );
  }

  Future<List<LocalNotificationModel>?> getAllLocalNotificationsData() async {
    final db = await database;
    List<LocalNotificationModel>? localNotificationListData;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    List<dynamic> userInfoListData = await db.rawQuery('SELECT * FROM $USER_NOTIFICATION where $USER_ID = ${userProfileInfoData.userId}');
    if (userInfoListData.length != 0)
     localNotificationListData =  List<LocalNotificationModel>.from(jsonDecode(userInfoListData[0][NOTIFICATION_JSON]).map((x) => LocalNotificationModel.fromJson(x)));
    return localNotificationListData;
  }

  Future<UserProgressDataModel> insertUserProgress(
      UserProgressDataModel userProgressDataModel) async {
    final db = await database;
    await db.insert(TABLE_USER_PROGRESS, userProgressDataModel.toMap());
    return userProgressDataModel;
  }

  ///This method is used to insert tutorial data
  ///@param: tutorial id: 1 for me screen tutorial
  Future<void> insertTutorialData(int tutorialId) async{
    final db = await database;
    var userProfileInfoData = await getLoggedInUserAllInformation();
    Map<String, dynamic> map = {
      TUTORIAL_ID: tutorialId,
      USER_ID: userProfileInfoData.userId
    };
    db.insert(TABLE_TUTORIAL, map);
  }

  ///This method is used to check if user has already seen a tutorial
  ///[tutorialId] 1 for me screen tutorial
  Future<bool> isUserHasAlreadySeenTutorial(int tutorialId) async {
    final db = await database;
    var userProfileInfoData = await getLoggedInUserAllInformation();
    List<dynamic> tutorialListData = await db.rawQuery('SELECT * FROM $TABLE_TUTORIAL WHERE $TUTORIAL_ID = $tutorialId AND $USER_ID = ${userProfileInfoData.userId}');
    return tutorialListData.length != 0;
  }

  ///This method is used to delete entry of a specific tutorial
  ///[tutorialId] 1 for me screen tutorial
  Future<void> deleteUserTutorial(int tutorialId) async {
    final db = await database;
    var userProfileInfoData = await getLoggedInUserAllInformation();

    await db.delete(
      TABLE_TUTORIAL,
      where: "$TUTORIAL_ID = ? AND $USER_ID = ?",
      whereArgs: [tutorialId, userProfileInfoData.userId],
    );
  }

  void updateUserProgress(UserProgressDataModel userProgressDataModel) async {
    final db = await database;
    await db.update(
      TABLE_USER_PROGRESS,
      userProgressDataModel.toMap(),
      where: "$USER_ID = ?",
      whereArgs: [userProgressDataModel.userId],
    );
  }

  Future<UserProfileInfoModel> insertUserProfileInfo(
      UserProfileInfoModel userProfileInfoModel) async {
    final db = await database;
    Map<String, dynamic> userProfileInfoMap = {
      USER_ID: userProfileInfoModel.userId,
      USER_PROFILE_INFO_MODEL: jsonEncode(userProfileInfoModel)
    };
    await db.insert(TABLE_USER_PROFILE_INFO, userProfileInfoMap);
    return userProfileInfoModel;
  }

//updates the user data in the database corresponding to the user profileO model provided
  Future<void> updateUserProfileInfo(UserProfileInfoModel userProfileInfoModel) async {
    final db = await database;
    Map<String, String> map = {
      USER_ID: userProfileInfoModel.userId!,
      USER_PROFILE_INFO_MODEL: jsonEncode(userProfileInfoModel)
    };
    await db.update(
      TABLE_USER_PROFILE_INFO,
      map,
      where: "$USER_ID = ?",
      whereArgs: [userProfileInfoModel.userId],
    );
  }

  //checks whether the user is already logged in
  Future<bool> isUserAlreadyLoggedIn() async {
    final db = await database;
    List<dynamic> userInfoListData =
        await db.rawQuery('SELECT * FROM $TABLE_USER_PROFILE_INFO');
    return userInfoListData.length != 0;
  }


  Future<UserProfileInfoModel> getLoggedInUserAllInformation() async {
    final db = await database;
    UserProfileInfoModel userProfileInfoModel = UserProfileInfoModel();
    List<dynamic> userInfoListData = await db.rawQuery('SELECT * FROM $TABLE_USER_PROFILE_INFO');
    if (userInfoListData.length != 0)
      userProfileInfoModel = UserProfileInfoModel.fromJson(jsonDecode(userInfoListData[0][USER_PROFILE_INFO_MODEL]));
    return userProfileInfoModel;
  }

  Future<void> updateUserProfileInfoModel(UserProfileInfoModel userProfileInfoModel) async {
    Map<String, dynamic> map = {
      USER_ID: userProfileInfoModel.userId,
      USER_PROFILE_INFO_MODEL: jsonEncode(userProfileInfoModel)
    };
    final db = await database;
    await db.update(
      TABLE_USER_PROFILE_INFO,
      map,
      where: "$USER_ID = ?",
      whereArgs: [userProfileInfoModel.userId],
    );
  }

  Future<int?> checkUserProgressDataAvailable(String tableName) async {
    final db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    return count;
  }

  Future<UserProgressDataModel?> getUserProgress() async {
    final db = await database;
    UserProgressDataModel? userProgress;
    var userProgressDetail = await db.query(TABLE_USER_PROGRESS,
        columns: [USER_ID, STEP, QUESTION_TAG, USER_SCREEN_POSITION, backQuestionIndexList]);
    userProgressDetail.forEach((userProgressDetail) {
      userProgress = UserProgressDataModel.fromMap(userProgressDetail);
    });
    return userProgress;
  }

  Future<LocalQuestionnaire> insertQuestionnaire(
      LocalQuestionnaire questionnaire) async {
    final db = await database;
    await db.insert(TABLE_QUESTIONNAIRES, questionnaire.toMap());
    return questionnaire;
  }

  Future<List<LocalQuestionnaire>> getQuestionnaire(String eventType) async {
    final db = await database;
    List<LocalQuestionnaire> localQuestionnaire = <LocalQuestionnaire>[];
    try {
      var localQuestionnaireData = await db.rawQuery(
          "SELECT * FROM $TABLE_QUESTIONNAIRES WHERE $EVENT_TYPE = $eventType");

      localQuestionnaireData.forEach((currentQuestionnaire) {
        LocalQuestionnaire questionnaire =
            LocalQuestionnaire.fromJson(currentQuestionnaire);
        localQuestionnaire.add(questionnaire);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    var localQuestionnaireData = await db.query(TABLE_QUESTIONNAIRES,
        columns: [EVENT_TYPE, QUESTIONNAIRES, SELECTED_ANSWERS]);

    return localQuestionnaire;
  }

  void insertSelectedAnswers(String answer, String eventType) async {
    final db = await database;
    await db.rawInsert(
        'INSERT INTO $TABLE_QUESTIONNAIRES($SELECTED_ANSWERS) VALUES($answer) WHERE $EVENT_TYPE = $eventType');
  }

  Future<List<SelectedAnswers>?> getAllSelectedAnswers(String eventType) async {
    final db = await database;
    List<dynamic> selectedAnswerMapData = await db.rawQuery(
        'SELECT * FROM $TABLE_QUESTIONNAIRES WHERE $EVENT_TYPE = $eventType');
    if(selectedAnswerMapData.length == 0){
      return null;
    }else{
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel =
      SignUpOnBoardSelectedAnswersModel.fromJson(
          jsonDecode(selectedAnswerMapData[0].row[3]));
      return signUpOnBoardSelectedAnswersModel.selectedAnswers;
    }
  }

  void updateSelectedAnswers(
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel,
      String eventType) async {
    Map<String, dynamic> map = {
      SELECTED_ANSWERS: jsonEncode(signUpOnBoardSelectedAnswersModel)
    };
    final db = await database;
    await db.update(
      TABLE_QUESTIONNAIRES,
      map,
      where: "$EVENT_TYPE = ?",
      whereArgs: [eventType],
    );
  }

  Future<bool> isDatabaseExist() async {
    var localDir = await getDatabasesPath();
    var dbPath = join(localDir, "bonTriageDB.db");
    return await databaseExists(dbPath);
  }

  Future<UserAddHeadacheLogModel> insertAddHeadacheDetails(
      UserAddHeadacheLogModel userAddHeadacheLogModel) async {
    final db = await database;
    await db.insert(TABLE_ADD_HEADACHE, userAddHeadacheLogModel.toMap());
    return userAddHeadacheLogModel;
  }

  void updateAddHeadacheDetails(
      UserAddHeadacheLogModel userAddHeadacheLogModel) async {
    final db = await database;
    await db.update(
      TABLE_ADD_HEADACHE,
      userAddHeadacheLogModel.toMap(),
      where: "$USER_ID = ?",
      whereArgs: [userAddHeadacheLogModel.userId],
    );
  }

  Future<List<Map>?> getUserHeadacheData(String userId) async {
    final db = await database;
    List<Map>? logDayQuestionnaire;
    try {
      logDayQuestionnaire = await db.rawQuery(
          "SELECT * FROM $TABLE_ADD_HEADACHE WHERE $USER_ID = $userId");
    } catch (e) {
      debugPrint(e.toString());
    }
    debugPrint(logDayQuestionnaire.toString());
    return logDayQuestionnaire;
  }

  void updateLogDayData(String selectedAnswers, String userId) async {
    final db = await database;
    await db.update(
      TABLE_LOG_DAY,
      {SELECTED_ANSWERS: selectedAnswers},
      where: "$USER_ID = ?",
      whereArgs: [userId],
    );
    debugPrint("Log updated");
  }

  Future<List<Map>?> getLogDayData(String userId) async {
    final db = await database;
    List<Map>? logDayQuestionnaire;
    try {
      logDayQuestionnaire = await db
          .rawQuery("SELECT * FROM $TABLE_LOG_DAY WHERE $USER_ID = $userId");
    } catch (e) {
      debugPrint(e.toString());
    }
    debugPrint(logDayQuestionnaire.toString());
    return logDayQuestionnaire;
  }

  Future<LogDayQuestionnaire> insertLogDayData(
      LogDayQuestionnaire logDayQuestionnaire) async {
    final db = await database;
    await db.insert(TABLE_LOG_DAY, logDayQuestionnaire.toMap());
    return logDayQuestionnaire;
  }

  Future<void> deleteAllUserLogDayData() async {
    final db = await database;
    await db.delete(TABLE_LOG_DAY);
  }

  Future<void> deleteAllNotificationFromDatabase() async {
    final db = await database;
    await db.delete(USER_NOTIFICATION);
  }

  Future<void> deleteAllTableData() async {
    final db = await database;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    await db.delete(TABLE_QUESTIONNAIRES);
    await db.delete(TABLE_USER_PROGRESS);
    await db.delete(TABLE_USER_PROFILE_INFO);
    await db.delete(TABLE_LOG_DAY);
    await db.delete(TABLE_ADD_HEADACHE);
    await db.delete(TABLE_USER_CURRENT_HEADACHE);
    await db.delete(USER_NOTIFICATION);
    await db.delete(TABLE_LOG_HEADACHE_MEDICATION);
    await db.delete(TABLE_RECENT_MEDICATION);


    if (packageInfo.packageName != 'com.bontriage.mobile') {
      await db.delete(TABLE_LOG_HEADACHE_MIGRAINE);
    }
  }

  Future<void> deleteOnBoardQuestionnaireProgress(String eventType) async {
    final db = await database;
    await db.delete(
      TABLE_QUESTIONNAIRES,
      where: "$EVENT_TYPE = ?",
      whereArgs: [eventType],
    );
    debugPrint('deleteOnBoardQuestionnaireProgress');
  }

  Future<void> deleteTableQuestionnaires() async {
    final db = await database;
    await db.delete(TABLE_QUESTIONNAIRES);
  }

  Future<void> deleteTableUserProgress() async {
    final db = await database;
    await db.delete(TABLE_USER_PROGRESS);
  }

  Future<void> insertUserCurrentHeadacheData(CurrentUserHeadacheModel currentUserHeadacheModel) async{
    final db = await database;
    await deleteUserCurrentHeadacheData();

    List<Map> currentHeadacheData = [];
    try {
      currentHeadacheData = await db.rawQuery(
          "SELECT * FROM $TABLE_USER_CURRENT_HEADACHE WHERE $USER_ID = ${currentUserHeadacheModel.userId}");
    } catch (e) {
      debugPrint(e.toString());
    }

    Map<String, String?> map = {
      USER_ID: currentUserHeadacheModel.userId,
      USER_CURRENT_HEADACHE_JSON: jsonEncode(currentUserHeadacheModel.toJson())
    };

    if(currentHeadacheData.length == 0)
      await db.insert(TABLE_USER_CURRENT_HEADACHE, map);
  }

  Future<void> updateUserCurrentHeadacheData(CurrentUserHeadacheModel currentUserHeadacheModel) async {
    final db = await database;

    Map<String, String?> map = {
      USER_ID: currentUserHeadacheModel.userId,
      USER_CURRENT_HEADACHE_JSON: jsonEncode(currentUserHeadacheModel.toJson())
    };

    await db.update(
      TABLE_USER_CURRENT_HEADACHE,
      map,
      where: "$USER_ID = ?",
      whereArgs: [currentUserHeadacheModel.userId],
    );
  }

  Future<CurrentUserHeadacheModel?> getUserCurrentHeadacheData(String userId) async {
    final db = await database;
    CurrentUserHeadacheModel? currentUserHeadacheModel ;

    List<Map> userCurrentHeadacheDataMap = await db.rawQuery("SELECT * FROM $TABLE_USER_CURRENT_HEADACHE WHERE $USER_ID = $userId");

    if(userCurrentHeadacheDataMap.length != 0)
      currentUserHeadacheModel = CurrentUserHeadacheModel.fromJson(jsonDecode(userCurrentHeadacheDataMap[0][USER_CURRENT_HEADACHE_JSON]));

    return currentUserHeadacheModel;
  }

  Future<void> deleteUserCurrentHeadacheData() async{
    final db = await database;
    await db.delete(TABLE_USER_CURRENT_HEADACHE);
  }

  Future<void> insertMedicationList(List<Values> medicationValuesList) async {
    final db = await database;

    List<Map> recentMedicationMapList = await db.rawQuery("SELECT * FROM $TABLE_RECENT_MEDICATION");

    debugPrint('Done 1');

    for(int i = 0; i < medicationValuesList.length; i++) {
      Values medicationValue = medicationValuesList[i];
      Map? recentMedicationMap = recentMedicationMapList.firstWhereOrNull((element) => element[MEDICATION_NAME] == medicationValue.text);

      if(recentMedicationMap == null) {
        Map<String, dynamic> map = {
          MEDICATION_NAME: medicationValue.text,
          NUMBER_OF_TIMES_LOGGED: 0,
        };

        await db.insert(TABLE_RECENT_MEDICATION, map);
      }
    }

    debugPrint('Done 2');
  }

  Future<void> updateMedicationLoggedTimes(Map<String, dynamic> logDayMap) async {
    final db = await database;

    List<Map<String, dynamic>> recentMedicationMapList = await db.rawQuery("SELECT * FROM $TABLE_RECENT_MEDICATION");

    if (recentMedicationMapList.isNotEmpty) {

      var medicationMapList = logDayMap['medication'];

      if(medicationMapList is List<dynamic>) {
        if(medicationMapList.isNotEmpty) {
          for (int i = 0; i < medicationMapList.length; i++) {
            Map<String, dynamic> medicationObjectMap = medicationMapList[i];

            List<dynamic> mobileEventDetailsList = medicationObjectMap['mobile_event_details'];

            if (mobileEventDetailsList.isNotEmpty) {
              Map<String, dynamic> medicationMap = mobileEventDetailsList.firstWhere((element) => element['question_tag'] == Constant.logDayMedicationTag, orElse: () => null);

              if (medicationMap != null) {
                String medicationValue = medicationMap['value'][0];

                Map<String, dynamic>? recentMedicationMap = recentMedicationMapList.firstWhereOrNull((element) =>
                element[MEDICATION_NAME] ==
                    medicationValue);

                if(recentMedicationMap != null) {
                  recentMedicationMap = Map<String, dynamic>.from(recentMedicationMap);

                  recentMedicationMap[NUMBER_OF_TIMES_LOGGED] += 1;

                  await db.update(
                    TABLE_RECENT_MEDICATION,
                    recentMedicationMap,
                    where: "$MEDICATION_NAME = ?",
                    whereArgs: [recentMedicationMap[MEDICATION_NAME]],
                  );
                } else {
                  Map<String, dynamic> map = {
                    MEDICATION_NAME: medicationValue,
                    NUMBER_OF_TIMES_LOGGED: 1,
                  };

                  await db.insert(TABLE_RECENT_MEDICATION, map);
                }
              }
            }
          }
        }
      }
    }
  }

  Future<List<Map>> getRecentMedicationLogged() async {
    final db = await database;

    List<Map<String, dynamic>> recentMedicationMap = await db.rawQuery("SELECT * FROM $TABLE_RECENT_MEDICATION ORDER BY $NUMBER_OF_TIMES_LOGGED DESC LIMIT 4");

    recentMedicationMap = List<Map<String, dynamic>>.generate(recentMedicationMap.length, (index) => recentMedicationMap[index]);

    if(recentMedicationMap.isEmpty)
      return recentMedicationMap;
    else {
      if(recentMedicationMap.first[NUMBER_OF_TIMES_LOGGED] == 0)
        return [];
      else {
        recentMedicationMap.removeWhere((element) => element[NUMBER_OF_TIMES_LOGGED] == 0);
        return recentMedicationMap;
      }
    }
  }

  Future<List<Map>> getLogHeadacheMedication() async {
    final db = await database;

    List<Map> logHeadacheMedicationMap = await db.rawQuery("SELECT * FROM $TABLE_LOG_HEADACHE_MEDICATION LIMIT 4");

    return logHeadacheMedicationMap;
  }

  Future<void> insertOrUpdateLogHeadacheMedication(Map<String, dynamic> logDayMap) async {
    final db = await database;

    var medicationMapList = logDayMap['medication'];

    if(medicationMapList is List<dynamic>) {
      if(medicationMapList.isNotEmpty) {
        await db.delete(TABLE_LOG_HEADACHE_MEDICATION);

        for (int i = 0; i < medicationMapList.length; i++) {
          Map<String, dynamic> medicationObjectMap = medicationMapList[i];

          List<dynamic> mobileEventDetailsList = medicationObjectMap['mobile_event_details'];

          if (mobileEventDetailsList.isNotEmpty) {
            Map<String, dynamic> medicationMap = mobileEventDetailsList.firstWhere((element) => element['question_tag'] == Constant.logDayMedicationTag, orElse: () => null);

            if (medicationMap != null) {
              String medicationValue = medicationMap['value'][0];

              List<Map> logMedicationMap = await db.rawQuery("SELECT * FROM $TABLE_LOG_HEADACHE_MEDICATION WHERE $MEDICATION_NAME = ?", [medicationValue]);

              Map<String, String> map = {
                MEDICATION_NAME: medicationValue,
              };

              if(logMedicationMap.isEmpty)
                await db.insert(TABLE_LOG_HEADACHE_MEDICATION, map);
              else
                await db.update(
                  TABLE_LOG_HEADACHE_MEDICATION,
                  map,
                  where: "$MEDICATION_NAME = ?",
                  whereArgs: [medicationValue],
                );
            }
          }
        }
      }
    }
  }

  Future<void> tonixInsertOrUpdateLogHeadacheMedication(List<List<SelectedAnswers>> medicationSelectedAnswerList) async {
    final db = await database;

    var userProfileInfoModel = await getLoggedInUserAllInformation();

    //List<Map> logHeadacheMedicationMap = await db.rawQuery("SELECT * FROM $TABLE_LOG_HEADACHE_MEDICATION WHERE $USER_ID = ${userProfileInfoModel.userId}");

    /*Map<String, String> map = {
      USER_ID: userProfileInfoModel.userId,
      MEDICATION_LIST: jsonEncode(medicationValues)
    };*/

    await db.delete(TABLE_LOG_HEADACHE_MEDICATION);

    for (int i = 0; i < medicationSelectedAnswerList.length; i++) {
      var medicationSelectedAnswers = medicationSelectedAnswerList[i];

      SelectedAnswers? medicationSelectedAnswer = medicationSelectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.logDayMedicationTag);
      SelectedAnswers? dosageTypeSelectedAnswer = medicationSelectedAnswers.firstWhereOrNull((element) => element.questionTag!.contains('.type'));
      SelectedAnswers? dosageSelectedAnswer = medicationSelectedAnswers.firstWhereOrNull((element) => element.questionTag!.contains('.dosage'));
      SelectedAnswers? numberOfDosageSelectedAnswer = medicationSelectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.numberOfDosageTag);
      SelectedAnswers? unitSelectedAnswer = medicationSelectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.unitTag);

      if(medicationSelectedAnswer != null && dosageTypeSelectedAnswer != null && dosageSelectedAnswer != null && numberOfDosageSelectedAnswer != null && unitSelectedAnswer != null) {
        List<Map> logMedicationMap = await db.rawQuery("SELECT * FROM $TABLE_LOG_HEADACHE_MEDICATION WHERE $USER_ID = ? AND $MEDICATION_NAME = ?", [userProfileInfoModel.userId, medicationSelectedAnswer.answer]);

        Map<String, String> map = {
          USER_ID: userProfileInfoModel.userId!,
          MEDICATION_NAME: medicationSelectedAnswer.answer!,
          DOSAGE_TYPE: dosageTypeSelectedAnswer.answer!,
          DOSAGE: dosageSelectedAnswer.answer!,
          UNITS: unitSelectedAnswer.answer!,
          NUMBER_OF_DOSAGE: numberOfDosageSelectedAnswer.answer!
        };

        if(logMedicationMap.isEmpty)
          await db.insert(TABLE_LOG_HEADACHE_MEDICATION, map);
        else
          await db.update(
            TABLE_LOG_HEADACHE_MEDICATION,
            map,
            where: "$USER_ID = ? AND $MEDICATION_NAME = ?",
            whereArgs: [userProfileInfoModel.userId, medicationSelectedAnswer.answer],
          );
      }
    }
  }

  Future<void> tonixUpdateMedicationLoggedTimes(List<List<SelectedAnswers>> medicationSelectedAnswerList) async {
    final db = await database;

    List<Map<String, dynamic>> recentMedicationMapList = await db.rawQuery("SELECT * FROM $TABLE_RECENT_MEDICATION");

    if(recentMedicationMapList.isNotEmpty) {
      for (int i = 0; i < medicationSelectedAnswerList.length; i++) {
        var medicationSelectedAnswers = medicationSelectedAnswerList[i];

        SelectedAnswers? medicationSelectedAnswer = medicationSelectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.logDayMedicationTag);

        if(medicationSelectedAnswer != null) {
          Map<String, dynamic> recentMedicationMap = recentMedicationMapList.firstWhere((
              element) =>
          element[MEDICATION_NAME] ==
              medicationSelectedAnswer.answer);

          if (recentMedicationMap != null) {

            recentMedicationMap = Map<String, dynamic>.from(recentMedicationMap);

            recentMedicationMap[NUMBER_OF_TIMES_LOGGED] += 1;

            await db.update(
              TABLE_RECENT_MEDICATION,
              recentMedicationMap,
              where: "$MEDICATION_NAME = ?",
              whereArgs: [recentMedicationMap[MEDICATION_NAME]],
            );
          }
        }
      }
    }
  }

  Future<void> insertOrUpdateCurrentHeadacheData(CurrentUserHeadacheModel currentUserHeadacheModel) async {
    final db = await database;

    var userProfileInfoModel = await getLoggedInUserAllInformation();

    List<Map> currentHeadacheData = [];
    try {
      currentHeadacheData = await db.rawQuery("SELECT * FROM $TABLE_USER_CURRENT_HEADACHE WHERE $USER_ID = ${userProfileInfoModel.userId}");
    } catch (e) {
      debugPrint(e.toString());
    }

    Map<String, String> map = {
      USER_ID: userProfileInfoModel.userId!,
      USER_CURRENT_HEADACHE_JSON: jsonEncode(currentUserHeadacheModel.toJson())
    };

    if(currentHeadacheData.length == 0) {
      await deleteUserCurrentHeadacheData();
      await db.insert(TABLE_USER_CURRENT_HEADACHE, map);
    }
    else {
      Map<String, String> map = {
        USER_ID: userProfileInfoModel.userId!,
        USER_CURRENT_HEADACHE_JSON: jsonEncode(currentUserHeadacheModel.toJson())
      };

      await db.update(
        TABLE_USER_CURRENT_HEADACHE,
        map,
        where: "$USER_ID = ?",
        whereArgs: [userProfileInfoModel.userId],
      );
    }
  }

  Future<void> insertOrUpdateLogHeadacheMigraine(List<String> migraineValues) async {
    final db = await database;

    var userProfileInfoModel = await getLoggedInUserAllInformation();

    List<Map> logHeadacheMigraineMap = await db.rawQuery("SELECT * FROM $TABLE_LOG_HEADACHE_MIGRAINE WHERE $USER_ID = ${userProfileInfoModel.userId}");

    Map<String, String> map = {
      USER_ID: userProfileInfoModel.userId!,
      MIGRAINE_LIST: jsonEncode(migraineValues)
    };

    if(logHeadacheMigraineMap.isEmpty)
      db.insert(TABLE_LOG_HEADACHE_MIGRAINE, map);
    else
      db.update(
        TABLE_LOG_HEADACHE_MIGRAINE,
        map,
        where: "$USER_ID = ?",
        whereArgs: [userProfileInfoModel.userId],
      );
  }

  Future<List<String>> getLogHeadacheMigraine() async {
    final db = await database;

    var userProfileInfoModel = await getLoggedInUserAllInformation();

    List<Map> logHeadacheMigraineMap = await db.rawQuery("SELECT * FROM $TABLE_LOG_HEADACHE_MIGRAINE WHERE $USER_ID = ${userProfileInfoModel.userId}");

    if(logHeadacheMigraineMap.length != 0) {
      var migraineList = List<String>.from(jsonDecode(logHeadacheMigraineMap[0][MIGRAINE_LIST]));
      return migraineList;
    }

    return [];
  }
}
