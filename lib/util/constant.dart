import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

class Constant {
  static const String splashRouter = 'splash';
  static const String homeRouter = 'home';
  static const String signUpRouter = 'signUP';
  static const String signUpOnBoardSplashRouter = 'signUpOnBoardSplash';
  static const String signUpOnBoardStartAssessmentRouter =
      'signUpOnBoardStartAssessment';
  static const String signUpFirstStepHeadacheResultRouter =
      'signUpFirstStepHeadacheResult';

  static const String signUpOnBoardPersonalizedHeadacheResultRouter =
      'signUpOnBoardPersonalizedHeadacheResult';
  static const String signUpNameScreenRouter = 'signUpNameScreen';
  static const String signUpAgeScreenRouter = 'signUpAgeScreen';
  static const String signUpLocationServiceRouter = 'signUpLocationService';
  static const String signUpOnBoardProfileQuestionRouter =
      'signUpOnBoardHeadacheQuestion';
  static const String addNewHeadacheIntroScreen = 'addNewHeadacheIntroScreen';
  static const String headacheQuestionnaireDisclaimerScreenRouter =
      'headacheQuestionnaireDisclaimerScreen';

  static const String partTwoOnBoardScreenRouter = 'partTwoOnBoardScreenRouter';
  static const String partThreeOnBoardScreenRouter =
      'partThreeOnBoardScreenRouter';

  static const String loginScreenRouter = 'loginScreenRouter';
  static const String onBoardingScreenSignUpRouter =
      'onBoardingScreenSignUpRouter';
  static const String signUpSecondStepHeadacheResultRouter =
      'signUpSecondStepHeadacheResult';
  static const String signUpOnBoardSecondStepPersonalizedHeadacheResultRouter =
      'signUpOnBoardSecondStepPersonalizedHeadacheResult';
  static const String signUpScreenRouter = 'signUpScreenRouter';

  static const String welcomeScreenRouter = 'WelcomeScreen';
  static const String welcomeStartAssessmentScreenRouter =
      'welcomeStartAssessmentScreenRouter';
  static const String onBoardHeadacheInfoScreenRouter =
      'onBoardHeadacheInfoScreenRouter';

  static const String partOneOnBoardScreenTwoRouter = 'partOneOnBoardScreenTwo';
  static const String onBoardCreateAccountScreenRouter =
      'onBoardCreateAccountScreen';
  static const String prePartTwoOnBoardScreenRouter = 'prePartTwoOnBoardScreen';
  static const String onBoardHeadacheNameScreenRouter =
      'onBoardHeadacheNameScreen';
  static const String partTwoOnBoardMoveOnScreenRouter =
      'partTwoOnBoardMoveOnScreen';
  static const String prePartThreeOnBoardScreenRouter =
      'prePartThreeOnBoardScreen';
  static const String signUpOnBoardBubbleTextViewRouter =
      'signUpOnBoardBubbleTextView';
  static const String postPartThreeOnBoardRouter = 'postPartThreeOnBoardRouter';
  static const String postNotificationOnBoardRouter =
      'postNotificationOnBoardRouter';
  static const String notificationScreenRouter = 'NotificationScreenRouter';
  static const String headacheStartedScreenRouter =
      'HeadacheStartedScreenRouter';
  static const String currentHeadacheProgressScreenRouter =
      'CurrentHeadacheProgressScreenRouter';
  static const String addHeadacheOnGoingScreenRouter =
      'addHeadacheOnGoingScreenRouter';
  static const String logDayScreenRouter = 'logDayScreenRouter';
  static const String addHeadacheSuccessScreenRouter =
      'addHeadacheSuccessScreenRouter';
  static const String logDaySuccessScreenRouter = 'logDaySuccessScreenRouter';
  static const String profileCompleteScreenRouter =
      'profileCompleteScreenRouter';
  static const String notificationTimerRouter = 'notificationTimerRouter';
  static const String calendarTriggersScreenRouter =
      'calendarTriggersScreenRouter';
  static const String calendarSeverityScreenRouter =
      'calendarSeverityScreenRouter';
  static const String logDayNoHeadacheScreenRouter =
      'logDayNoHeadacheScreenRouter';
  static const String calenderScreenRouter = 'calenderScreenRouter';

  static const String onBoardExitScreenRouter = 'onBoardExitScreenRouter';
  static const String onCalendarHeadacheLogDayDetailsScreenRouter =
      'onCalendarHeadacheLogDayDetailsScreenRouter';

  static const String compassScreenRouter = 'compassScreenRouter';
  static const String webViewScreenRouter = 'webViewScreenRouter';
  static const String otpValidationScreenRouter = 'otpValidationScreenRouter';
  static const String changePasswordScreenRouter = 'changePasswordScreenRouter';
  static const String tonixAddHeadacheScreen = 'tonixAddHeadacheScreen';
  static const String postClinicalImpressionScreenRouter =
      "postClinicalImpressionScreenRouter";

  //strings
  static const String welcomeToAurora = "Welcome to Aurora";
  static const String welcomeToMigraineMentor = 'Welcome to\nMigraineMentor';
  static const String developedByATeam =
      'Developed by a team of board-certified migraine and headache specialists, computer scientists, engineers, mathematicians, and designers. MigraineMentor is an important part of an advanced headache diagnosis and treatment system. By downloading this tool, you have already taken the first step towards better managing your headaches.';
  static const String trackRightData = 'Track the right data';
  static const String mostHeadacheTracking =
      'Unlike most headache tracking apps, MigraineMentor utilizes big data — weather changes, pollen counts, sleep quality, exercise, and self-logged triggers — to build your personalized headache risk profile (HRP).';
  static const String conquerYourHeadaches = 'Conquer your headaches';
  static const String withRegularUse =
      'With regular use, MigraineMentor creates a predictive model that can alert you when you are at risk for headaches and can even suggest steps to avoid them. You can also set reminders to take your daily medicine or send an update to your doctor to let them know how you are doing.';
  static const String next = 'Next';
  static const String getGoing = 'Get Going!';
  static const String firstBasics = 'First, a few basics...';
  static const String whatShouldICallYou = 'What should I call you?';
  static const String howOld = 'How old are you?';
  static const String likeToEnableLocationServices =
      'Would you like to enable Location Services?';
  static const String back = 'Back';
  static const String nameHint = 'Tap to type your name';
  static const String emailHint = 'Tap to type your name';
  static const String enableLocationServices = 'Enable Location Services';
  static const String enableLocationRecommended =
      'Enabling location services is highly recommended since it allows us to analyze environmental factors that may affect your headaches.';
  static const String welcomeMigraineMentorTextView =
      '\nUnlike other migraine trackers, fitness, relaxation and trigger based apps, MigraineMentor is like having a headache expert in your pocket.';

  static const String welcomeMigraineMentorBubbleTextView =
      'Welcome to MigraineMentor! Unlike other migraine trackers, fitness, relaxation and trigger based apps, MigraineMentor is like having a headache expert in your pocket.';
  static const String answeringTheNextBubbleTextView =
      'MigraineMentor can help you and your doctor manage your headaches better through an informed diagnosis, aided by your time and effort. Together, we can help you achieve your treatment, lifestyle, and headache prevention goals.';

  static const String migraineMentorHelpTextView =
      'can help you and your doctor manage your headaches better through an informed diagnosis, aided by your time and effort. Together, we can help you achieve your treatment, lifestyle, and headache prevention goals.';
  static const String compassDiagramTextView =
      'Surprised\'? This is your Compass Diagram, and the number in the middle is your current Headache Score. The lower the number, the better.';

  static const String welcomePersonalizedHeadacheFirstTextView =
      'Welcome to your personalized Headache Compass! The number you see in the middle is your current Headache Score (the lower the number, the better).';

  static const String welcomePersonalizedHeadacheSecondStepFirstTextView =
      'Based on what you entered, it looks like your Red Wine Headache could potentially be considered by doctors to be a Cluster Headache. We\'ll learn more about this as you log your headache and daily habits in the app.';

  static const String welcomePersonalizedHeadacheSecondTextView =
      'Throughout your journey with MigraineMentor, you will work on shrinking the size and changing the shape of your compass to lower your Headache Score.';

  static const String welcomePersonalizedHeadacheThirdTextView =
      'Your Compass is generated based on intensity, duration, disability, frequency - the four main parameters that headache specialists evaluate when diagnosing migraines and headache.';

  static const String welcomePersonalizedHeadacheFourthTextView =
      'As you get better at managing your headache, you will learn to use the compass to see the impact of exposure to possible triggers or starting new medications.';

  static const String welcomePersonalizedHeadacheFifthTextView =
      'To learn more about the characteristics of your headache, tap any of the Compass dimensions displayed below.';

  static const String startAssessment = 'Start Assessment';
  static const String letsStarted = 'Let\'s get started!';
  static const String personalizedHeadacheCompass =
      'Generating your personalized Headache Compass...';

  static const String howManyDays =
      'Over the last three months, how many days per month, on average, have you been absolutely headache free?';
  static const String howManyHours =
      'Over the last three months, how many hours, on average, does a typical headache last if you don\'t treat it?';
  static const String onScaleOf =
      'On a scale of 1 to 10, 1 being no pain, how bad is the pain of your typical headache, if you don\'t treat it?';
  static const String howDisabled =
      'Overall, from 0-4, how disabled are you by your headaches, 0 being no disability and 4 being completely disabled?';
  static const String yearsOld = 'years old';
  static const String days = 'days';
  static const String hours = 'hours';
  static const String noneAtAll = 'NONE AT\nALL';
  static const String blankString = '';
  static const String siteCode = 'Site Code';
  static const String siteName = 'Site Name';
  static const String confirmPassword = 'Confirm Password';
  static const String addYesterdayLogText = 'Add/Edit Yesterday\'s Log';
  static const String viewYesterdayLogText = 'View/Edit Yesterday\'s Log';
  static const String addEditLogYourDay = 'Add/Edit Log Your Day';
  static const String addEditLogStudyMedication =
      'Add/Edit Log Study Medication';
  static const String amDoseTag = 'am_dose';
  static const String pmDoseTag = 'pm_dose';
  static const String numberOfDosageTag = 'number_of_dosage';
  static String atWhatAge = 'At what age did you first experience headaches?';
  static String selectOne = 'Select one';
  static String selectAllThatApply = 'Select all that apply';
  static const String firstLoggedScore = 'First logged Score';
  static String yes = 'Yes';
  static String no = 'No';
  static String regular = 'regular';
  static String irregular = 'irregular';
  static String isStopped = 'stopped >2 years';
  static String times = 'times';
  static String lessThanFiveMinutes = 'Less than 5 minutes';
  static String fiveToTenMinutes = '5 to 10 minutes';
  static String tenToThirtyMinutes = '10 to 30 minutes';
  static String moreThanThirtyMinutes = 'More than 30 minutes';
  static String fewSecAtATime = 'Only a few seconds at a time';
  static String fewSecUpTo20Min = 'A few seconds up to a 20 minutes';
  static String moreThan20Min =
      'More than 20 minutes, but always less than 3 hours';
  static String moreThan3To4Hours = 'More than 3-4 hours';
  static String alwaysOneSide = 'Always on one side';
  static String usuallyOnOneSide =
      'Usually on one side, but sometimes on the other';
  static String usuallyOnBothSide = 'Usually on both sides';
  static String headacheChanged =
      'Have your headaches changed significantly in the last year?';
  static String howManyTimes =
      'How many times have you had this headache in the past?';
  static String didYourHeadacheStart =
      'Did your headaches start following a major event (i.e. trauma, stress, illness, school, start of menses)?';
  static String isYourHeadache =
      'Is your headache present much of the day, more than 15 days per month?';
  static String separateHeadachesPerDay =
      'Do you get 2 or more separate headaches per day?';
  static String headachesFrequentForDays =
      'Are your headaches frequent for days to weeks, then disappear for weeks to months, then become frequent again?';
  static String headachesOccurSeveralDays =
      'Do your headaches occur several days or more per week for many months or years without a break for at least 4 weeks per year?';
  static String headachesBuild =
      'How quickly do your headaches build to maximum severity?';
  static String headacheLast =
      'If untreated, how long does your typical headache last?';
  static String experienceYourHeadache =
      'Where do you experience your headache?';
  static String isYourHeadacheWorse =
      'Is your headache worse with changes in position?';
  static String headacheStartDuring =
      'Does your headache start during or after exertion or straining?';
  static String beforeContinuing =
      'Before continuing, please create a secure account with us so that we can track your progress.';
  static String compareHeadacheErrorMessage = 'Please select two different headache types.';
  static String createAccount = 'Create an Account';
  static String nextWeAreGoing =
      'Next, we are going to find out what kind of headaches you have. If you have more than one type of headache, let’s focus on the one that’s most bothersome to you.';
  static String answeringTheNext =
      'Answering the next set of questions will give us a good idea of your headache type. Stick with us. It will be worth it!';
  static String continueText = 'Continue';
  static String moveOnForNow = 'Move On For Now';
  static String experienceTypesOfHeadaches =
      'If you experience other types of headaches, you can complete a similar assessment for them either now or later in the app.';
  static String almostReadyToHelp =
      'We’re almost ready to help you start getting your headaches under better control. To really understand your headaches, we need to know what you have already learned about what has helped — and what has not worked or has worsened — your headaches.';
  static String quickAndEasySection =
      'For some people, this is a quick and easy section; for others, it can take some serious thinking back, but you will find it worth the effort as we move forward. There are only five more questions.';
  static String setUpNotifications = 'Set Up Notifications';
  static String qualityOfOurMentorShip =
      'Here is where we can start helping you. The quality of our mentorship is dependent on how much accurate information you provide. It usually takes less than two minutes to log your daily behaviors and potential triggers; doing so everyday yields the best results.';
  static String easyToLoseTrack =
      'We know it can be easy to lose track of this, and we found it works best if you let us send you a daily reminder — we recommend the late afternoon or evening. Can we set that up for you?';
  static String addAnotherHeadache = 'Add Another Headache';
  static String saveAndFinishLater = 'Save & Finish Later';
  static String finish = 'Finish';
  static String notNow = 'Not Now';
  static String migraineMentor = 'MigraineMentor';
  static String personalizedUnderstanding =
      'Get a personalized understanding of your migraines and headaches through tools developed by leading board-certified migraine and headache specialists.';
  static const String startYourAssessment = 'Start Your Assessment';
  static const String continueYourAssessment = 'Continue Your Assessment';
  static String or = 'or ';
  static String signIn = 'Sign In';
  static String toAn = ' to an';
  static String existingAccount = 'existing account';
  static const String email = 'Email';
  static String password = 'Password';
  static const String subjectId = 'Subject ID';
  static const String yearBirth = 'Year of Birth';
  static const String forgotPassword = 'Forgot Password?';
  static const String logStudyMedicationEvent = 'study_medication';
  static String continueSurvey = 'Continue Survey';
  static String continueAssessment = 'Continue Assessment';
  static String exitAndLoseProgress = 'Exit & Lose Progress';
  static String untilYouCompleteInitialAssessment =
      'Until you complete the initial assessment and create your account, you will not be able to use MigraineMentor. Please continue through the first step, it shouldn\'t take more than a minute or two.';
  static String untilYouComplete =
      'Until you complete the assessment, your personalized headache profile will be incomplete. Without a complete profile, MigraineMentor can’t create a predictive model, and won’t be able to alert you when you are at risk for headaches or suggest steps to avoid them.';
  static String letsBeginBySeeing =
      'Let’s begin by seeing what your most problematic headache looks like using a Headache Compass diagram. Just answer a few questions and you will be able to visualize your headache from the eyes of a headache specialist.';
  static String searchYourType = 'Search or type your own';
  static String suspectTriggerYourHeadache =
      'Which of the following do you suspect trigger your headaches?';
  static String followingMedications =
      'Which of the following medications have you tried to stop a headache once it has started?';
  static String followingDevices =
      'Which of the following devices have you tried to improve your headache?';
  static String followingLifeStyle =
      'Which of the following lifestyle interventions have you tried to help manage your headache?';
  static String searchType = 'Search or type your own';
  static String signUp = 'Sign Up';
  static String cancel = 'Cancel';

  static String openHealthApp = 'Open Health App';
  static String openGoogleFit = 'Open Google Fit';
  static const done = 'Done';
  static String register = 'Register';
  static String login = 'Login';
  static String secureMigraineMentorAccount =
      'Please enter your email address and password to create an account.';
  static const String healthKitDialogContent =
      'We cannot find the data logged in HealthKit. If you haven\'t allowed permission to access this data, please grant permission.';
  static String termsAndCondition =
      'I agree to the Terms & Conditions and Privacy\nPolicy';
  static String emailFromMigraineMentor =
      'I\'d like to receive emails from MigraineMentor\nregarding my progress and app updates';
  static String accurateClinicalImpression =
      'This is not a diagnosis, but it is an accurate clinical impression, based on your answer, of how your headache best matches up to known headache types. If you haven\'t already done so, you should see a qualified medical professional for a firm diagnosis.';
  static String moreDetailedHistory =
      'You can also provide a much more detailed history, have an opportunity to explain your headaches in greater detail, and get a more complete to take to your doctor report at BonTriage.com.';
  static String viewDetailedReport = 'View detailed report';
  static String tapToType = 'Tap to type';
  static String greatWeAreDone =
      'Great we’re done with that part! For your future reference of this headache in the app, what would you like to call this type of headache?';
  static String withWhatGender = 'With what gender do you identify?';
  static String whatBiologicalSex =
      'What biological sex were you assigned at birth (note: answering this question helps to provide diagnostic information about your headaches)? ';

  static String greatFromHere =
      'Great! From here on it is easy. Every day, you can log in to answer a few questions and report headaches as they arise. We need data from headache days as well as non-headache days – that’s how our deep learning system predicts how to improve your headaches.';
  static String finallyNotification =
      'Finally, the next two screens will give you a brief introduction to some of the buttons you can use to log your headaches and behaviors.';

  static String woman = 'Woman';
  static String man = 'Man';
  static String genderNonConforming = 'Gender non-conforming';
  static String nonBinary = 'Non-binary';
  static String preferNotToAnswer = 'Prefer not to answer';
  static String interSex = 'Intersex';
  static String compass = 'Compass';
  static String intensity = 'Intensity';
  static String frequency = 'Frequency';
  static String disability = 'Disability';
  static String duration = 'Duration';
  static String compassTextView =
      'This graph is your Compass\n\nThe shape of it is determined by your headache’s specific characteristics. Each person\'s compass shape is unique -- yours will change as you manage your headaches with Migraine Mentor.\n\nTap on each point of the Compass to learn about a specific dimension of your headaches.';
  static String doubleTapAnItem =
      'Double tap an item to keep it pre-selected for the next time you come back to enter a log.';
  static String sleep = 'Sleep';
  static String howFeelWakingUp = 'How did you feel waking up this morning?';
  static String energizedRefreshed = 'Energized\n& refreshed';
  static String couldHaveBeenBetter = 'Could have\nbeen better';
  static String headacheLogStarted = 'Headache log started.';
  static String feelFreeToComeBack =
      ' Feel free to come back when you’re feeling better.';
  static String viewCurrentLog = 'View Current Log';
  static String addDetails = 'Add Details';
  static String addEditDetails = 'Add/Edit Details';
  static String yourCurrentHeadache = 'Your current headache:';
  static String started = 'STARTED';
  static String endHeadache = 'End Headache';
  static const String headacheType = 'Headache Type';
  static String whatKindOfHeadache = 'What kind of headache is it?';
  static String time = 'Time';
  static String whenHeadacheStart = 'When did your headache start?';
  static String start = 'START';
  static const String notifications = 'Push Notifications';
  static const String changePassword = 'Change Password';
  static const String selectTextToSpeechAccent = 'Select text-to-speech accent';
  static const String dailyLog = 'Daily Log';
  static const String medication = 'Medication';
  static const String exercise = 'Exercise';
  static const String amStudyMedicationNotification =
      'Study Medication (Morning)';
  static const String pmStudyMedicationNotification =
      'Study Medication (Evening)';
  static const String medicationNotificationTitle = 'Medication';
  static const String exerciseNotificationTitle = 'Exercise';
  static const String dailyNotificationType = 'Daily';
  static String addCustomNotification = '+  Add Custom Notification';
  static String save = 'Save';
  static const String QuestionNumberType = 'number';
  static const String QuestionTextType = 'text';
  static const String QuestionSingleType = 'single';
  static const String QuestionMultiType = 'multi';
  static const String QuestionLocationType = 'location';
  static const String QuestionInfoType = 'info';
  static const String HeadacheTypeTag = 'headacheType';
  static const String logDayMedicationTag = 'medication';
  static const String logDayNoteTag = 'logday.note';
  static const String administeredTag = 'administered';
  static const String triggersTag = 'triggers1';
  static const String profileFirstNameTag = 'profile.firstname';
  static const String profileAgeTag = 'profile.age';
  static const String profileSexTag = 'profile.sex';
  static const String profileGenderTag = 'profile.gender';
  static const String profileMenstruationTag = 'profile.menstruation';
  static const String profileEmailTag = 'profile.emailAddress';
  static const String headacheFreeTag = 'headache.free';
  static const String headacheTypicalTag = 'headache.typical';
  static const String headacheDisabledTag = 'headache.disabled';
  static const String headacheTypicalBadPainTag = 'headache.typicalbadpain';
  static const String headacheNumberTag = 'headache.number';
  static const String profileLocationTag = 'profile.location';
  static const String headacheMedicationsTag = 'headache.medications';
  static const String headacheTriggerTag = 'headache.trigger';
  static String end = 'END';
  static String tapHereToEnd = 'Headache in progress. Tap here to end.';
  static String onAScaleOf1To10 =
      'On a scale of 1 - 10, how painful is this headache?';
  static String min = 'MIN';
  static String max = 'MAX';
  static String one = '1';
  static String ten = '10';
  static String mild = 'MILD';
  static String veryPainful = 'VERY\nPAINFUL';
  static String onAScaleOf1To10Disability =
      'On a scale of 1- 10, how much disability are you experienciing as result of this headache?';
  static String noneAtALL = 'NONE AT\nALL';
  static String totalDisability = 'TOTAL\nDISABILITY';
  static const String addANote = '+ Add a note';
  static String addAPreventiveMedication = '+ Add a preventive medication';
  static String addAnAcuteCareMedication = '+ Add an acute care medication';
  static String at = 'at';
  static const String tapHereIfInProgress =
      'Tap here if this headache is still ongoing.';
  static String reset = 'Reset';
  static String submit = 'Submit';
  static String userHeadacheName = "userHeadacheName";
  static String tutorialsState = 'tutorialsState';
  static String chatBubbleVolumeState = 'chatBubbleVolumeState';
  static String userAlreadyLoggedIn = 'userAlreadyLoggedIn';
  static String currentIndexOfTabBar = 'currentIndexOfTabBar';
  static String currentIndexOfCalenderTabBar = 'currentIndexOfCalenderTabBar';
  static String tabNavigatorState = '0';
  static const String recordTabNavigatorState = 'recordTabNavigatorState';
  static const String isSeeMoreClicked = 'isSeeMoreClicked';
  static const String isViewTrendsClicked = 'isViewTrendsClicked';
  static const String zeroEventStep = "0";
  static const String firstEventStep = "1";
  static const String firstCompassEventStep = "1.1";
  static const String secondEventStep = "2";
  static const String secondCompassEventStep = "2.1";
  static const String thirdEventStep = '3';
  static const String headacheInfoEventStep = '1.2';
  static const String createAccountEventStep = '1.3';
  static const String signUpEventStep = '1.4';
  static const String prePartTwoEventStep = '1.5';
  static const String onBoardMoveOnForNowEventStep = '2.2';
  static const String prePartThreeEventStep = '2.3';
  static const String postPartThreeEventStep = '3.1';
  static const String notificationEventStep = '3.2';
  static const String postNotificationEventStep = '3.3';
  static const String userID = "4214";
  static const String trueString = 'true';
  static const String falseString = 'false';
  static const String noExercise = 'No exercise';
  static const String noRestorativeSleep = 'No restorative sleep';
  static const String irregularMeals = 'Irregular meals';

  static String plusText = "+";
  static String clinicalImpressionEventType = "clinical_impression";
  static String welcomeOnBoardStepTwoEventType = "clinical_impression_short2";

  static const platform = const MethodChannel('method_channel');

  static const String severityTag = "severity";
  static const String onSetTag = "onset";
  static const String disabilityTag = "disability";
  static const String onGoingTag = "ongoing";
  static const String endTimeTag = "endtime";
  static const String headacheTypeTag = "headacheType";
  static const String singleTypeTag = "single";
  static const String numberTypeTag = "number";
  static const String dateTimeTypeTag = "datetime";
  static const String headacheNoteTag = "headache.note";
  static const String behaviourPreSleepTag = 'behavior.presleep';
  static const String behaviourSleepTag = 'behavior.sleep';
  static const String behaviourPreExerciseTag = 'behavior.preexercise';
  static const String behaviourPreMealTag = 'behavior.premeal';
  static const String HeadacheNotification = 'Log Headache';
  static const String dailyLogNotification = 'Log Day';
  static const String onGoingHeadacheNotification = 'OnGoing Headache';
  static const String pushNotificationTitle = 'title';
  static const String dailyLogNotificationTitle = 'Daily Log';
  static const String healthDescription = 'healthDescription';

  static String whenYouAreLoggingYourDay =
      'When you’re logging your day, you can double tap any items you experience frequently to keep them pre-selected for every time you come back. For example, if you drink coffee every morning, you could double tap “Caffeine.”';
  static String doubleTappedItems =
      'Double tapped items — indicated by a green border — are pre-selected for you every time you enter a log. Deselecting an item on any given day toggles pre-select off, and you can always toggle it back on by double tapping again later.';
  static String tryDoubleTappingMe = 'Try double tapping me!';
  static String gotIt = 'Got it!';
  static String logDayEvenFaster = 'Log your day even faster with Double Tap!';
  static String viewTrends = 'View Trends';
  static String logDay = 'Log Day';
  static String logYourDayToAssess =
      ' Log your day to assess potential triggers.';
  static const String headacheRecorded = 'Headache recorded!';
  static String dayLogged = ' Day Logged!';

  static String loggedDaysInARow =
      'You’ve logged the day! Keep logging to increase accuracy and uncover more trends.';
  static String profileCompleteThatNow = 'That\'s it for now! Thanks for using';

  static String tonixProfileCompleteTextView =
      'Personalize your push notifications (from the ';

  static String profileCompleteCommentsSignedInfo =
      'We welcome (and actually read) all feedback you may have to improve this experience and help other headache-sufferers. Please send comments to info@bontriage.com. Here’s to good headache control.\n\nSigned,\nRobert Cowan (MD), Alan Rapoport\n(MD) and the team at BonTriage';

  static String profileCompleteTextView =
      'That\'s it for now! Thanks for using Migraine Mentor! We welcome (and actually read) all feedback you may have to improve this experience and help other headache-sufferers. Please send comments to info@bontriage.com. Here’s to good headache control.\n\nSigned,\nRobert Cowan (MD), Alan Rapoport\n(MD) and the team at BonTriage';

  static String tonixTextSpeechProfileCompleteTextView =
      'Thank you for registering for Tonix eDiary app!. Personalize your push notifications (from the Settings menu) to best suit your daily schedule.';

  static String addNewHeadacheIntroScreenTextView =
      'To customize the app for you, we need a short clinical assessment. It will take approximately 10 minutes to complete. For each question, please consider a single headache type you currently have, or have had in the past. You can enter as many headache types as you wish by recording a new headache in the app. You may review or edit your responses by using the "back" and "next" buttons at the bottom of each screen or update your answers from My Profile > My Headache Types section of the app. Try to keep your assessment answers up-to-date by reviewing your headache types periodically. When you are ready to begin, please press the button below.';

  static String headacheQuestionnaireDisclaimerTextView =
      'The questionnaire you are about to complete is intended as a tool to help your physician or other qualified health professional make a diagnosis and create a treatment plan for you. Only a physician can make a diagnosis after taking a history and doing a medical and neurological examination and appropriate testing. The answers you give to the questions will be used to generate a clinical impression that should be taken to your physician or other qualified health professional for further evaluation, physical examination and any appropriate testing.';

  static String thankYouProfile = ' Thank you!\nYour profile is complete.';
  static String daily = ' Daily';
  static String weekDays = ' weekDays';
  static String off = ' off';
  static String skip = ' Skip';
  static String delete = ' Delete';
  static String calendar = ' Calendar';
  static String trends = ' Trends';
  static String triggers = ' Triggers';
  static String sortedCalenderTextView =
      'Sorted from your most to least logged, view the trends of your personalized triggers.';
  static String calculatedSeverityCalendarTextView =
      ' Calculated from your Headache Score, see the most severe headache on a particular day';

  static String logDayNoHeadacheTextView =
      'We noticed you didn’t log a headache today. Can you confirm what happened?';

  static String deleteLog = ' Delete Log';
  static String discardChanges = ' Discard Changes';
  static const String settings = ' Settings';
  static String allowed = 'Allowed';
  static const String myInfo = 'My Info';
  static const String myProfile = 'My Profile';
  static const String locationServices = 'Location Services';
  static const String voiceSelection = 'Voice Selection';

  static const String android = 'Android';
  static const String ios = 'iOS';

  static String appleWatch = 'Apple Watch';
  static String notSetUp = 'Not set up';
  static const String appleHealth = 'Apple Health';
  static const String googleFit = 'Google Fit';
  static String connected = 'Connected';
  static String darkTheme = 'Dark Theme';
  static String duringMigraine = 'During Migraine';
  static String firstDayOfTheWeek = 'First day of the week';
  static String sunday = 'Sunday';
  static String timeFormat = 'Time format';
  static String twelveHourAMPM = '12 hour AM/PM';
  static const String generateReport = 'Generate Report';
  static const String support = 'Support';
  static const String inviteFriends = 'Invite Friends';
  static const String shareText =
      'Hey!\nI came across MigraineMentor App a few days back. It’s an amazing app for you to get your migraines and other headaches under better control. I love it! It learns to identify what prevents your headaches and which triggers set them off. You must really try it!\n\nHere is the link: https://migrainementor.page.link/qbvQ';
  static const String dateRange = 'Selected Month';
  static String dataToInclude = 'Data to include';
  static String all = 'All';
  static const String last2Weeks = 'Last 2 weeks';
  static String fileType = 'File type';
  static String pdf = 'PDF';
  static const String faq = 'FAQs';
  static const String contactTheMigraineMentorTeam =
      'Contact the Migraine Mentor team';
  static String medicalHelp = 'Medical Help';
  static String call911 = 'Call 911';
  static String callADoctor = 'Call a doctor (urgent care)';
  static String findALocalDoctor = 'Find a local doctor (non-urgent)';
  static String openYourProviderApp = 'Open your provider’s app';
  static String lindaJonesPdf = 'Linda_Jones_4_29_20.pdf';
  static String saveAndExit = 'Save & Exit';
  static const play = 'Play';
  static String text = 'Text';
  static String print = 'Print';
  static const String name = 'Name';
  static const String menstruation = 'My menstruation is…';
  static String lindaJones = 'Linda Jones';
  static const String age = 'Age';
  static const String viewReport = 'View Report';
  static String twentyTwo = '22';
  static const String gender = 'Gender';
  static String female = 'Female';
  static String male = 'Male';
  static const String sex = 'Sex';
  static String homeLocation = 'Home Location';
  static String stanfordCA = 'Stanford, CA';
  static String reCompleteInitialAssessment = 'Re-complete Initial Assessment';
  static String questionOne = 'Question 1';
  static String anInsightfulAndWellWorded =
      'An insightful and well-worded answer to question 1 and all related concerns.';
  static String theSecondQuestion = 'The second question?';
  static String hereIsASimple = 'Here is a simple answer to your question!';
  static String whatIfMyQuestion = 'What if my question is more compilicated?';
  static String aMoreComplicated =
      'A more complicated question deserves a well-thought out and complicated answer that may take several lines to explain in full detail.';
  static String threeDots = '...';
  static String logOut = 'Logout';
  static String logoutConfirmation = 'Logout confirmation!';
  static const String headacheTypes = 'My Headache Types';
  static const String myMedicationsAndTriggers = 'My Medications and Triggers';
  static const String myTriggers = 'Triggers';
  static const String myMedications = 'Medications';
  static String reCompleteDiagnosticAssessment =
      'Re-complete diagnostic assessment';
  static String deleteHeadacheType = 'Delete Headache Type';
  static String basedOnWhatYouEntered =
      'Based on what you entered, it looks like your [My Headache Type] could potentially be considered by doctors to be a [Clinical Type]. This is not a diagnosis, but it is an accurate clinical impression, based on your answers, of how your headache best matches up to known headache types. If you haven’t already done so, you should see a qualified medical professional for a firm diagnosis';
  static String weKnowItCanBeEasy =
      'We know it can be easy to lose track of daily logging, and we found it works best if you let us send you a daily reminder — we recommend the late afternoon or evening.';
  static String enablingLocationServices =
      'Enabling Location Services is highly recommended since it allows us to analyze environmental factors that may affect your headaches.';
  static String tapToTypeYourName = 'Tap to type your name';
  static const String tapToTypeYourEmail = 'Tap to type your email';
  static String slideToEnterYourAge = 'Slide to enter your age.';
  static String selectToEnterYourAge = 'Select to enter your age.';
  static String selectTheGender = 'Select the gender with which you identify.';
  static String isMenstruating = 'Regarding your menstruation, it is...';
  static String toProvideDiagnosticInfo =
      'To provide diagnostic information about your headaches, please select the biological sex you were assigned at birth.';
  static String whichOfTheFollowingDoYouSuspect =
      'Which of the following do you suspect trigger your headache? Select any that apply. Type to search or add a trigger that’s not on our list.';
  static String whichOfTheFollowingMedication =
      'Which of the following medications do you take for your headache? Select any that apply. Type to search or add a medication that’s not on our list.';
  static const String me = 'ME';
  static const String myDay = 'MY DAY';
  static String records = 'RECORDS';
  static String discover = 'DISCOVER';
  static String more = 'More';
  static String moreCap = 'MORE';
  static String signUpAlertMessage =
      'Use 8 or more characters and at least 1 uppercase, 1 lowercase, and 1 number.';
  static String passwordNotMatchMessage =
      'Passwords do not match. Please try again.';
  static String signUpCheckboxAlertMessage =
      'You must agree to the Terms & Conditions in order to complete the registration process.';
  static String agreeAndContinue = 'Agree and continue';

  static String signUpEmilFieldAlertMessage =
      'Please enter a valid email address';
  static const String loginAlertMessage =
      'Please enter a valid email address and password.';
  static const String tonixLoginAlertMessage =
      'Please enter a valid subject ID and password.';
  static const String userNotFound = 'User Not Found';
  static const String duplicateEmailAlertMessage =
      'This email has already been registered, Please try to enter a different email!';
  static String messageTextKey = 'message_text';
  static String loading = 'Loading...';
  static const String success = 'Success';
  static const String somethingWentWrong = 'Something went Wrong!';
  static String onBoardingAssessmentIncomplete =
      'Please complete the initial assessment - ';
  static String clickHereToFinish = 'click here to continue';
  static String isProfileInCompleteStatus = 'isProfileInCompleteStatus';
  static String tapToRetry = 'Tap to Retry';
  static String none = 'none';
  static String logHeadacheError =
      'Headache duration cannot be more than 3 days.';
  static String viewEditNote = 'View/Edit Note';
  static String multipleTriggers = 'Selecting multiple triggers at a time';
  static String selectUpTo3Triggers =
      'You can only select up to 3 triggers at a time. In order to look at different triggers, please unselect one or more of the active triggers before selecting new ones.';
  static String logDayDoubleTapDialog = 'logDayDoubleTapDialog';
  static String noneOfTheAbove = 'None of the above';
  static String cancelAssessment = 'Cancel Assessment';
  static const String migraineDaysVsHeadacheDaysDialogText =
      'In this Intensity view of your calendar, you can see a distinction between Headache days and Migraine days. When you complete an assessment for a new headache type, we classify it internally as either a Headache or a Migraine. In most cases throughout the app, your migraines are included generally as a headache, but you can view the distinction between the two in this Intensity view, depending on which headache types you select when logging.';
  static const String migraineDaysVsHeadacheDaysDialogTriggerText =
      'In this Triggers view of your calendar, you can see a distinction between Headache days and Migraine days. When you complete an assessment for a new headache type, we classify it internally as either a Headache or a Migraine. In most cases throughout the app, your migraines are included generally as a headache, but you can view the distinction between the two in this Triggers view, depending on which headache types you select when logging.';
  static String migraineDaysVsHeadacheDays = 'Migraine days vs Headache days';
  static String headacheLogInProgress = 'Headache log currently in progress.';
  static String dotDosage = '.dosage';
  static const String migraineMentorBuildFlavor = 'MigraineMentor';

  static const String migraineMentorPackageName = 'com.bontriage.mobile';
  static const String migraineMentorDebugBuildPackage = 'com.bontriage.mobile.debug';

  static const String tonixBuildFlavor = 'Tonix';
  static const String poweredBy = 'Powered by';
  static const String bonTriageMigraineMentor = ' BonTriage Migraine Mentor';

  static const String noHeadacheData = 'NoHeadacheData';
  static const String compassHeadacheTypeActionSheet =
      'compassHeadacheTypeActionSheet';

  static const String dailyLogNotificationDetail =
      "You haven't logged your day for today. Would you like to log your day now?";
  static const String morningMedicationNotificationDetail =
      "Hey there! It's time to take your morning medication dose.";
  static const String eveningMedicationNotificationDetail =
      "Hey there! It's time to take your evening medication dose.";

  static String selectAtLeastOneOptionLogDayError =
      'Please select at least one option to log your day';

  static const String singleHeadache = 'Single headache:';
  static const String summaryOfAllHeadacheTypes =
      'Summary of all my headache types';
  static const String selectTheSavedHeadacheType =
      'Select the headache type that you would like to view:';
  static const String editGraphView = 'Edit Graph View';
  static const String viewSingleHeadache = 'View Single Headache';
  static const String compareHeadache = 'Compare Headache';
  static const String otherFactors = 'Other Factors:';
  static const String loggedBehaviors = 'Logged Behaviors';
  static const String loggedPotentialTriggers = 'Logged Potential Triggers';
  static const String medications = 'Medications';
  static const String noneRadioButtonText = 'None';
  static const String minText = 'min_text';
  static const String maxText = 'max_text';
  static const String minLabel = 'min_label';
  static const String maxLabel = 'max_label';
  static const String minLabel1 = 'minlabel';
  static const String maxLabel1 = 'maxlabel';

  static const String currentMedications = 'Current Medications';
  static const String medicationHistory = 'Medication History';

  static const String label = 'label';
  static const String updateMeScreenData = 'updateMeScreenData';
  static const String loggedHeadacheName = 'loggedHeadacheName';
  static const String deletedHeadacheName = 'deletedHeadacheName';
  static const String updateCalendarTriggerData = 'updateCalendarTriggerData';
  static const String updateCalendarIntensityData =
      'updateCalendarIntensityData';
  static const String updateOverTimeCompassData = 'updateOverTimeCompassData';
  static const String updateCompareCompassData = 'updateCompareCompassData';
  static const String updateMoreHeadacheData = 'updateMoreHeadacheData';
  static const String userHeadacheNameString = 'userHeadacheName';
  static const String updateCompassHeadacheList = 'updateCompassHeadacheList';
  static const String isNotificationInitiallyAdded =
      'isNotificationInitiallyAdded';
  static const String updateTrendsData = 'updateTrendsData';
  static const String ttsAccentKey = 'ttsAccent';
  static const String last4Weeks = 'Last 4 weeks';
  static const String last2Months = 'Last 2 months';
  static const String last3Months = 'Last 3 months';
  static const String close = 'Close';
  static const String acute = 'Acute Care';
  static const String preventive = 'Preventive';
  static const String beyondDateErrorMessage =
      'Future records can not be displayed.';
  static const String exerciseNotification =
      "Here's your daily reminder to exercise!";
  static const String medicationNotification =
      "Hey there! It's time to take your medication dose.";
  static const String logDayNotification =
      "You haven't logged your day for today. Would you like to log your day now?";
  static const String LogDayNotification = 'Log Day';
  static const String coordinatorName = 'Coordinator Name';
  static const String contactInfo = 'Contact Phone Number';
  static const String contactEmail = 'Contact Email';
  static const String noHeadacheValue = 'No Headache';
  static const String unitTag = 'unit';
  static const String isRescueMedicationTakenTag = 'isRescueMedicationTaken';
  static const String timeZoneTag = 'time_zone';
  static const String timeZoneOffsetTag = 'time_zone_offset';
  static const String headacheMigraineTag = 'headache.migraine';
  static const String migraineProbableMigraine = 'Migraine/Probable Migraine';
  static const String noHeadacheMedication =
      "In spite of having no headache, did you take any of the following medication(s) today?";
  static const String feedback = 'Feedback';
  static const String noneDisability = 'None';
  static const String mildDisability = 'Mild';
  static const String moderateDisability = 'Moderate';
  static const String severeDisability = 'Severe';
  static const String bedriddenDisability = 'Bedridden';
  static const String noneDisabilityDesc = 'normal activity.';
  static const String mildDisabilityDesc =
      'interferes with, but does not prevent daily activities.';
  static const String moderateDisabilityDesc =
      'makes daily activities very difficult.';
  static const String severeDisabilityDesc =
      'makes daily activities nearly impossible.';
  static const String bedriddenDisabilityDesc =
      'unable to perform daily activities.';
  static const String morningTime = 'Morning';
  static const String afternoonTime = 'Afternoon';
  static const String eveningTime = 'Evening';
  static const String bedTime = 'Bedtime';
  static const String doNotStopMedications =
      'Do not stop taking your medications abruptly without consulting your doctor or headache-specialist first.';
  static const String defaultClinicalImpression =
      "The presence of specific red flags means that further evaluation is warranted.";
  static const String defaultClinicalImpressionReplacement =
      'Due to the presence of specific red flags, further evaluation by your provider or headache specialist is warranted.';
  static const String thisIsNotDiagnosis =
      'This is not a diagnosis, but a clinical impression of how your headache matches up to known headache types.';
  static const String ifYouHaventAlreadyDone =
      'If you haven\'t already done so, you should see a qualified medical professional for a firm diagnosis.';
  static const String medicalHistoryClinicalImpression =
      'The information provided in the medical history does not match any of the recognized diagnostic criteria developed by the International Classification of Headache Disorders. Often this is the result of conflicting information in the history and can be sorted out by your physician with additional history, physical examination, and testing.';

  //tutorial text
  static const String tonixMeScreenTutorial1 =
      'When you\'re on the My Day screen of the app, you\'ll be able to log your study medication by pressing Log Study Medication and log your day by clicking Log Your Day/End Headache.';
  static const String meScreenTutorial1 =
      'When you\'re on the Me screen of the app, you’ll be able to log your day by pressing the Log Day button and log your headache by clicking the Add Headache/End Headache button.';
  static const String meScreenTutorial2 =
      'Last thing before we go — Whenever you want, you can click on Records to track information like how your Compass and Headache Score have evolved over time, the potential impact of changes in medication or lifestyle, and more! This is all based on the suggestions we have made and the steps you and your provider have taken.';
  static const String trendsTutorialText1 =
      'For days you have completed your daily log, these dots represent the data you inputted.';
  static const String trendsTutorialText2 =
      'A filled circle (•) indicates if a certain behavior, potential trigger, or medication was present on a given day.';
  static const String trendsTutorialText3 =
      'An outlined circle () means you did not experience that item on a given day.';
  static const String trendsTutorialText4 =
      'For instance, you can see that on arrow, this person got 20+ minutes of exercise, but did not have regular meals, and did not get good sleep.';
  static const String trendsTutorialText5 =
      'You can use this information to track how certain behaviors, triggers, or medications may affect different characteristics of your headaches!';

  static const String faqQuestion1 = 'What is the Migraine Compass Score?';
  static const String faqQuestion2 =
      'What does it mean if a patient\'s Migraine Compass score is decreasing?';
  static const String faqQuestion3 =
      'What is the difference between Log Day and Add Headache?';
  static const String faqQuestion4 =
      'Why do I need to log every day on the app?';
  static const String faqQuestion5 =
      'Is the headache name in the app the same as the actual medical diagnosis?';

  static const String faqAnswer1 =
      'A person\'s Migraine Compass Score is generated based on\ni. Intensity\nii. Disability\niii. Duration\niv. Frequency\n\nThese parameters are used by headache specialists to evaluate and diagnose headaches and migraines.';
  static const String faqAnswer2 =
      'When a patient’s intensity, disability, duration or frequency of headaches are decreasing, it contributes to a lower compass score. This means the patient\'s overall quality of health is improving with the overall decrease in the migraine compass score.';
  static const String faqAnswer3 =
      'Log Day refers to the user entering their overall activities in a day such as meals, exercise and sleep. Whereas "Add Headache" requires the user to add details about the headache such as the intensity, duration etc.';
  static const String faqAnswer4 =
      'Using Migraine Mentor daily will allow the app to better track your overall health.';
  static const String faqAnswer5 =
      'No. The headache name is user defined (e.g. a "Red wine headache" to indicate the headache that started after drinking red wine).';
  static const String replayTutorial = "Replay Tutorial";
  static const String goToBontriageAssessment = "Go to BonTriage Assessment";
  static const String termsAndConditions = "Terms & Conditions";
  static const String keepHeadacheAndExit = "Keep Headache & Exit";
  static const String ttsDemoText = 'This is a demo for text to speech';
  static const String discardHeadache = "Discard Headache";
  static const String generalProfileSettings = "General Profile Settings";
  static const String menstruatingTriggerOption = "Menstruating";
  static const String heartRate = 'Heart Rate (HR)';
  static const String bloodOxygen = 'Blood Oxygen';
  static const String bloodPressure = 'Blood Pressure';
  static const String bodyTemperature = 'Body Temperature';
  static const String electrodermalActivity = 'Electrodermal activity';
  static const String restingHeartRate = 'Resting HR';
  static const String walkingHeartRate = 'Walking HR';
  static const String heartRateVariability = 'Heart rate variability';
  static const String exerciseTime = 'Exercise time';
  static const String moveMinutes = 'Move Minutes';
  static const String isHealthAuthorized = 'isHealthAuthorized';
  static const String androidHealthConsentMessage =
      'MigraineMentor fetches and displays heart rate, blood oxygen, blood pressure, and body temperature data from Google Fit without storing or sharing your health information.';
  static const String iosHealthConsentMessage =
      'MigraineMentor fetches and displays heart rate, blood oxygen, blood pressure, and more, from the Health App without storing or sharing your health information. The app also records headache intensity levels in the Health app as headache mild, moderate, and severe.';
  static const String healthApp = 'Health App';

  //Action Sheet Identifier
  static const String medicalHelpActionSheet = 'medicalHelpActionSheet';
  static const String generateReportActionSheet = 'generateReportActionSheet';
  static const String deleteHeadacheTypeActionSheet =
      'deleteHeadacheTypeActionSheet';
  static const String saveAndExitActionSheet = 'saveAndExitActionSheet';
  static const String selectTtsAccentActionSheet = 'selectTtsAccentActionSheet';
  static const String editGraphViewBottomSheet = 'editGraphViewBottomSheet';
  static const String dateRangeActionSheet = 'dateRangeActionSheet';

  static const String isFromMoreScreen = 'isFromMoreScreen';
  static const String isFromCompareCompassScreen = 'isFromCompareCompassScreen';
  static const String isFromOvertimeCompassScreen =
      'isFromOvertimeCompassScreen';
  static const String isFromTrendsScreen = 'isFromTrendsScreen';

  static final int highBarColorIntensity = 2;
  static final int lowBarColorIntensity = 0;
  static final int mediumBarIntensity = 1;

  //Dimensions
  static final double screenHorizontalPadding = 25;
  static final double chatBubbleHorizontalPadding = 30;
  static const double chatBubbleMaxHeight = 85;
  static const double chatBubbleCompassResultMaxHeight = 80;

  //decorations
  static BoxDecoration backgroundBoxDecoration = BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: <Color>[
        Color(0xff0E232F),
        Color(0xff0E4C47),
      ]));

  //colors
  static const Color backgroundColor = Color(0xff0E232F);
  static const Color chatBubbleGreen = Color(0xffAFD794);
  static const Color migraineColor60Alpha = Color(0xCC66A2D8);
  static const Color chatBubbleGreenBlue = Color.fromARGB(15, 175, 215, 148);
  static const Color locationServiceGreen = Color(0xffCAD7BF);
  static const Color bubbleChatTextView = Color(0xff0E1712);
  static const Color chatBubbleGreenTransparent = Color(0x26AFD794);
  static const Color chatBubbleGreen60Alpha = Color(0x99AFD794);
  static const Color selectTextColor = Color.fromARGB(50, 175, 215, 148);
  static const Color transparentColor = Colors.transparent;
  static const Color backgroundTransparentColor = Color(0xff0E4C47);
  static const Color oliveGreen = Color(0xff263E3E);
  static const Color editTextBoarderColor = Color(0xffAFD794);
  static const Color headacheCompassColor = Color(0xffB8FFFF);
  static const Color unselectedTextColor = Color(0x80AFD794);
  static const Color splashColor = Color(0xffD7EBC9);
  static const Color splashTextColor = Color(0xff0E232F);
  static const Color splashMigraineMentorTextColor = Color(0xff30af72);
  static const Color doubleTapTextColor = Color(0xff1DAA6D);
  static const Color sliderTrackColor = Color(0xff434351);
  static const Color notificationTextColor = Color(0x80AFD794);
  static const Color addCustomNotificationTextColor = Color(0xff1DAA6D);
  static const Color pinkTriggerColor = Color(0xffF479D9);
  static const Color mildTriggerColor = Color(0xff55AE88);
  static const Color moderateTriggerColor = Color(0xfff69946);
  static const Color severeTriggerColor = Color(0xffEB5757);
  static const Color migraineColor = Color(0xff66A2D8);
  static const Color lightDurationColor = Color(0xA6B8E1FF);
  static const Color otherHeadacheColor = Color(0xff177D5A);
  static const Color deleteLogRedColor = Color(0xffFF2D55);
  static const Color cancelBlueColor = Color(0xff007AFF);
  static const Color moreBackgroundColor = Color(0xCC0E232F);
  static const Color whiteColorAlpha85 = Color(0xD9FFFFFF);
  static const Color greyColor = Color(0xff8C8C8C);
  static const Color actionSheetDividerColor = Color(0xffCDCED2);
  static const Color selectedNotificationColor = Color(0xff145C56);
  static const Color currentDateColor = Color(0xff68906e);
  static const Color calendarRedTriggerColor = Color(0xffD85B00);
  static const Color calendarPurpleTriggersColor = Color(0XFF7E00CB);
  static const Color calendarBlueTriggersColor = Color(0XFF00A8CD);
  static const Color compassMyHeadacheTextColor = Color(0XFF0E4C47);
  static const Color compareCompassHeadacheValueColor = Color(0xff7E00CB);
  static const Color compareCompassMonthSelectedColor = Color(0xffB8FFFF);
  static const Color compareCompassChartValueColor = Color(0x597E00CB);
  static const Color compareCompassChartFirstLoggedValueColor =
      Color(0xff7E00CB);
  static const Color barTutorialsTapColor = Color.fromARGB(255, 202, 215, 191);
  static const Color triggerOutlineColor = Color(0xff25504c);
  static const Color menstruatingTriggerColor = Color(0xffc00000);
  static const Color triggerOneColor = Color(0xffD59066);
  static const Color triggerTwoColor = Color(0xffA17125);
  static const Color triggerThreeColor = Color(0xff7F82AF);
  static const Color triggerFourColor = Color(0xffACBED3);
  static const Color triggerFiveColor = Color(0xff9DC7B7);
  static const Color triggerSixColor = Color(0xff50897a);
  static const Color triggerSevenColor = Color(0xff8FAADC);
  static const Color triggerEightColor = Color(0xffca96a2);
  static const Color headacheDayColor = Color(0xffAFD693);
  static const Color headacheFreeDayColor = Color(0x33d9d9d9);
  static const Color scrollBarColorGrey = Color(0xffd9d9d9);

  static const double minTextScaleFactor = 0.8;
  static const double maxTextScaleFactor = 1.2;

  //images
  static const String googleFitIcon = 'images/google_fit_icon.png';
  static const String googleIcon = 'images/google_icon.png';
  static const String xIcon = 'images/x_icon.png';
  static const String appleHealthIcon = 'images/apple_health_icon.png';
  static String userAvatar = 'images/user_avatar.png';
  static String closeIcon = 'images/close_icon.png';
  static String volumeOn = 'images/volume_on.png';
  static String volumeOff = 'images/volume_off.png';
  static String brain = 'images/brain.png';
  static String chart = 'images/chart.png';
  static String ellipse = 'images/ellipse.png';
  static String notifsGreenWhite = 'images/notifs_green_white.png';
  static String showPassword = 'images/show_password.png';
  static String hidePassword = 'images/hide_password.png';
  static String downArrow = 'images/down_arrow.png';
  static String splashCompass = 'images/splash_compass.png';
  static String compassGreen = 'images/compass_green.png';
  static String brainShadow = 'images/brain_shadow.png';
  static String chartShadow = 'images/chart_shadow.png';
  static String notifsGreenShadow = 'images/notifs_green_shadow.png';
  static String rightArrow = 'images/right_arrow.png';
  static String logoShadow = 'images/logo_shadow.png';
  static String backArrow = 'images/back_arrow.png';
  static String nextArrow = 'images/next_arrow.png';
  static String migraineIcon = 'images/migraine_icon.png';
  static String mealIcon = 'images/meal_icon.png';
  static const String exerciseIcon = 'images/exercise.png';
  static String pillIcon = 'images/pill_icon.png';
  static String alcoholIcon = 'images/alcohol_icon.png';
  static String sleepIcon = 'images/sleep_icon.png';
  static String waterDropIcon = 'images/water_drop_icon.png';
  static String weatherIcon = 'images/weather_icon.png';
  static String warningPink = 'images/warning_pink.png';
  static String addCircleIcon = 'images/add_circle_icon.png';
  static String calenderBackArrow = 'images/calender_back_arrow.png';
  static String calenderNextArrow = 'images/calender_next_arrow.png';
  static String tutorialArrowUp = 'images/tutorial_arrow_up.png';
  static String tutorialArrowDown = 'images/tutorial_arrow_down.png';
  static String tutorialArrowDown2 = 'images/tutorial_arrow_down_2.png';

  static String leftArrow = 'images/left_arrow.png';
  static String downArrow2 = 'images/down_arrow_2.png';
  static String notificationDownArrow = 'images/notification_down_arrow.png';
  static String meUnselected = 'images/me_unselected.png';
  static String meSelected = 'images/me_selected.png';
  static String recordsUnselected = 'images/records_unselected.png';
  static String recordsSelected = 'images/records_selected.png';
  static String discoverUnselected = 'images/discover_unselected.png';
  static String discoverSelected = 'images/discover_selected.png';
  static String moreUnselected = 'images/more_unselected.png';
  static String moreSelected = 'images/more_selected.png';
  static String errorGreen = 'images/error_green.png';
  static const String closeIcon2 = 'images/close_icon_2.png';
  static const String graph = 'images/graph.png';
  static const String trendsTutorialArrowUp =
      'images/trends_tutorial_arrow_up.png';

  static const googleSocialSource = 'go';
  static const facebookSocialSource = 'fb';
  static const twitterSocialSource = 'tw';

  static String barGraph = 'images/union.png';
  static String lineGraph = 'images/vector.png';
  static String upperArrow = 'images/upperArrow.png';
  static String barQuestionMark = 'images/bar_question_mark.png';
  static const String tonixSplash = 'images/tonix_logo.png';
  static const String medicationCloseIcon = 'images/medication_close_icon.png';

  static const String bloodPressureIcon = 'images/blood_pressure_icon.png';
  static const String clockIcon = 'images/clock_icon.png';
  static const String electrodermalActivityIcon =
      'images/electrodermal_activity_icon.png';
  static const String heartIcon = 'images/heart_icon.png';
  static const String heartRateVariabilityIcon =
      'images/heart_rate_variability_icon.png';
  static const String oxygenIcon = 'images/oxygen_icon.png';
  static const String thermometerIcon = 'images/thermometer_icon.png';
  static const String walkingIcon = 'images/walking_icon.png';

  //fontFamily
  static String futuraMaxiLight = "FuturaMaxiLight";
  static String jostBold = "JostBold";
  static String jostMedium = "JostMedium";
  static String jostRegular = "JostRegular";

  //event types
  static const String clinicalImpressionShort3 = 'clinical_impression_short3';
  static const String clinicalImpressionShort0 = 'clinical_impression_short0';
  static const String clinicalImpressionShort1 = 'clinical_impression_short1';
  static const String clinicalImpression = 'clinical_impression';
  static const String profileEventType = 'profile';
  static const String behaviorsEventType = 'behaviors';
  static const String medicationEventType = 'medication';
  static const String triggersEventType = 'triggers';
  static const String noteEventType = 'note';

  //urls
  static const String termsAndConditionUrl =
      'https://www.bontriage.com/terms-of-service.html';
  static const String privacyPolicyUrl =
      'https://www.bontriage.com/privacy.html';
  static const String deepDiveUrl =
      'https://assessment.bontriage.com/questionnaire/disclaimer';

  static const String prodServerUrl = 'https://migrainementor.bontriage.com/mobileapi/v0/';

  static const String notAllowed = 'Not Allowed';

  static const String chooseDifferentHeadacheType =
      'Choose a different headache name.';
  static const String locationSwitchState = 'locationSwitchState';
  static const String homeScreen = 'HomeScreen';
  static const String headacheLogStartedScreen = 'HeadacheLogStartedScreen';
  static const String currentHeadacheProgressScreen =
      'CurrentHeadacheProgressScreen';
  static const String addHeadacheScreen = 'AddHeadacheScreen';
  static const String addHeadacheSuccessScreen = 'AddHeadacheSuccessScreen';
  static const String logDayScreen = 'LogDayScreen';
  static const String logDaySuccessScreen = 'LogDaySuccessScreen';
  static const String meScreen = 'MeScreen';
  static const String calendarScreen = 'CalendarScreen';
  static const String compassScreen = 'CompassScreen';
  static const String trendsScreen = 'TrendsScreen';
  static const String welcomeStartAssessmentScreen =
      'WelcomeStartAssessmentScreen';
  static const String moreScreen = 'MoreScreen';
  static const String moreSettingScreen = 'MoreSettingScreen';
  static const String moreMyProfileScreen = 'MoreMyProfileScreen';
  static const String moreGenerateReportScreen = 'MoreGenerateReportScreen';
  static const String moreSupportScreen = 'MoreSupportScreen';
  static const String moreFaqScreen = 'MoreFaqScreen';
  static const String moreNotificationScreen = 'MoreNotificationScreen';
  static const String moreHeadachesScreen = 'MoreHeadachesScreen';
  static const String moreLocationServicesScreen = 'MoreLocationServicesScreen';
  static const String moreNameScreen = 'MoreNameScreen';
  static const String moreAgeScreen = 'MoreAgeScreen';
  static const String moreGenderScreen = 'MoreGenderScreen';
  static const String moreSexScreen = 'MoreSexScreen';
  static const String moreTriggersScreen = 'MoreTriggersScreen';
  static const String moreMedicationScreen = 'MoreMedicationScreen';
  static const String moreEmailScreen = 'MoreEmailScreen';
  static const String partOneOnBoardAssessmentScreen =
      'PartOneOnBoardAssessmentScreen';
  static const String partTwoOnBoardAssessmentScreen =
      'PartTwoOnBoardAssessmentScreen';
  static const String partThreeOnBoardAssessmentScreen =
      'PartThreeOnBoardAssessmentScreen';
  static const Map<int, String> monthMapper = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December'
  };

  static const Map<String, String> englishAccentMap = {
    'en': 'English',
    'en-US': 'English (United States)',
    'en-GB': 'English (United Kingdom)',
    'en-CA': 'English (Canada)',
    'en-AU': 'English (Australia)',
    'en-IN': 'English (India)',
    'en-NG': 'English (Nigeria)',
    'en-IE': 'English (Ireland)',
    'en-ZA': 'English (South Africa)',
    'en-BZ': 'English (Belize)',
    'en-JM': 'English (Jamaica)',
    'en-TT': 'English (Trinidad)',
  };

  static const Map<String, String> questionTagMap = {
    "headache.sided": "headache1.sided",
    "nameClinicalImpression": "nameClinicalImpression",
    "headache.restlessness": "headache1.restlessness",
    "drowsiness": "drowsiness",
    "headache.exp2During": "headache1.exp2During",
    "comeOnWithin": "comeOnWithin",
    "experienceAfterHeadache": "experienceAfterHeadache",
    "headache.severityBeforeTreating": "headache1.severityBeforeTreating",
    "headache.cluster": "headache1.cluster",
    "headache.aveDaysPerMonth": "headache1.aveDaysPerMonth",
    "headache.haveAuraBoolean": "headache1.haveAuraBoolean",
    "headache.chronic": "headache1.chronic",
    "headache.exp1During": "headache1.exp1During",
    "headache.averageDurationWithoutTreatment":
        "headache1.averageDurationWithoutTreatment",
    "headache.haveAura": "headache1.haveAura",
    "paralysis": "paralysis",
    "recentChanges": "recentChanges",
    "headache.auraGap": "headache1.auraGap",
    "agitated": "agitated",
    "headache.number": "headache1.number",
    "fever": "fever",
    "headache.location": "headache1.location",
    "headache.eventAssociatedWithFirstHeadache":
        "headache1.eventAssociatedWithFirstHeadache",
    "headache.awakens": "headache1.awakens",
    "headache.auraPrecedesHeadache": "headache1.auraPrecedesHeadache",
    "headache.sameLocation": "headache1.sameLocation",
    "howDisabledAfter": "howDisabledAfter",
    "headache.durationOnAwakening": "headache1.durationOnAwakening",
    "headache.trauma": "headache1.trauma",
    "headacheAge": "headache",
    "locationChange": "locationChange",
    "startedRecently": "startedRecently",
    "headache.lessThanThreeHours": "headache1.lessThanThreeHours",
    "headache.worstPain": "headache1.worstPain",
    "headache.sameSide": "headache1.sameSide",
    "headache.aveEpisodesPerDay": "headache1.aveEpisodesPerDay",
  };

  static const List<String> logDayMedicationDeleteQuestionList = [
    'Did you stop taking this medication dose?',
    'Why did you stop taking this medication dose?'
  ];

  static const List<String> logDayMedicationDeleteOptionList = [
    "It wasn't working",
    'I had side effects',
    'My doctor changed my medications',
    'My doctor told me to stop taking this medication'
  ];

  static const List<String> formulationTypesList = [
    'Lozenge',
    'Injection solution',
    'Tablet',
    'Extended-release tablet',
    'Oral suspension',
    'Suppository',
    'Capsule',
    'Oral solution',
    'Extended-release capsule',
    'Oral powder',
    'Nasal spray',
    'Orally disintegrating tablet',
    'Delayed-release capsule',
    'Oral syrup',
    'Delayed-release tablet',
    'Chewable tablet',
    'Enteric-coated, extended-release tablet',
    'Sublingual',
    'Buccal tablet',
    'Nasal powder',
    'Orally dissolving film'
  ];

  static const Map<String, String> healthDataUnitMap = {
    heartRate: "bpm",
    restingHeartRate: "bpm",
    walkingHeartRate: "bpm",
    bloodOxygen: "%",
    bloodPressure: "mmHg",
    bodyTemperature: "\u00b0F",
    electrodermalActivity: "\u00b5S",
    heartRateVariability: "ms",
    exerciseTime: "min",
    moveMinutes: "min"
  };
  static const String averageValue = '7 Days average:';

  static const Map<String, String> healthDataNormalText = {
    heartRate: "Normal 60-100 beats/min",
    restingHeartRate: "Normal 60-100 beats/min",
    walkingHeartRate: "Normal 100-120 beats/min",
    bloodOxygen: "Normal 95% or higher",
    bloodPressure: "Normal 90/60-120/80 mmHg",
    bodyTemperature: "Normal 37\u00b0F",
    electrodermalActivity: "Normal 1-20\u00b5S",
    heartRateVariability: "Normal 20-200 ms",
    exerciseTime: "Normal 20-60 min daily",
  };

  static const Map<String, HealthDataType> vitalsTitleMap = {
    exerciseTime: HealthDataType.EXERCISE_TIME,
    bloodOxygen: HealthDataType.BLOOD_OXYGEN,
    bloodPressure: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    bodyTemperature: HealthDataType.BODY_TEMPERATURE,
    electrodermalActivity: HealthDataType.ELECTRODERMAL_ACTIVITY,
    heartRate: HealthDataType.HEART_RATE,
    restingHeartRate: HealthDataType.RESTING_HEART_RATE,
    walkingHeartRate: HealthDataType.WALKING_HEART_RATE,
    heartRateVariability: HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    moveMinutes: HealthDataType.MOVE_MINUTES,
  };

  //Medication list routers
  static const medicationListScreenRouter = 'medicationListScreenRouter';
  static const medicationFormulationScreenRouter =
      'medicationFormulationScreenRouter';
  static const medicationDosageScreenRouter = 'medicationDosageScreenRouter';
  static const medicationTimeScreenRouter = 'medicationTimeScreenRouter';
  static const medicationStartDateScreenRouter =
      'medicationStartDateScreenRouter';
  static const numberOfDosageScreenRouter = 'numberOfDosageScreenRouter';

  //MigraineMentor Firebase Events
  //static const String signUpEvent = 'sign_up';
  static const String logDayEvent = 'day_logged';
  static const String headacheLogEvent = 'headache_logged';
  static const String healthComponentClicked = 'health_component_clicked';
  static const String pushNotificationClicked = 'push_notification_clicked';
  static const String part3AssessmentCompleted = 'part_3_assessment_completed';
  static const String part2AssessmentCompleted = 'part_2_assessment_completed';
  static const String part1AssessmentCompleted = 'part_1_assessment_completed';
  static const String reCompleteAssessmentCompleted = 'reComplete_assessment_completed';
  static const String assessmentPartiallyCompleted = 'assessment_partially_completed';
  static const String headacheTypeClicked = 'headacheType_clicked';

  //Tonix Firebase Events
  static const String tonixLogStudyMedicationEvent = 'tonix_log_study_medication';
  static const String tonixHeadacheLoggedEvent = 'tonix_headache_logged';
}
