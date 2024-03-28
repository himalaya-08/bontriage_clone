import 'package:mobile/models/ClinicalImpressionModel.dart';
import 'package:mobile/models/UserGenerateReportDataModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';

class SignUpSecondStepCompassRepository {
  Future<dynamic> serviceCall(String url, RequestMethod requestMethod) async {
    var album;
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return album;
    }
  }

  Future<dynamic> callServiceForViewReport(String url, RequestMethod requestMethod) async {
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return userGenerateReportDataModelFromJson(response);
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> callServiceForClinicalImpression(String url, RequestMethod requestMethod) async {
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return clinicalImpressionModelFromJson(response);
      }
    } catch (e) {
      return null;
    }
  }
}