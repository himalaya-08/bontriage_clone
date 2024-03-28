import '../models/ResponseModel.dart';
import '../networking/AppException.dart';
import '../networking/NetworkService.dart';
import '../networking/RequestMethod.dart';

class MoreHeadacheTypeRepository {
  Future<dynamic> callFetchAllHeadacheTypes(String url, RequestMethod requestMethod) async {
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return headacheTypeFromJson(response);
      }
    } catch (e) {
      return null;
    }
  }
}