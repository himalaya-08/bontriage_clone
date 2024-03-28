class RequestHeader{
  Map<String,String> createRequestHeaders() {
    var map = Map<String,String>();
        map = {"Accept": "application/json; charset=UTF-8", "Authorization": "Basic dXNlcm5hbWU6cGFzc3dvcmQ="};
    return map;
  }

  Map<String,String> createRequestHeadersForSanareAPI() {
    var map = Map<String,String>();
    map = {"Accept": "application/json", "Authorization": "Basic dXNlcm5hbWU6cGFzc3dvcmQ=", "Content-Type": "application/json"};
    return map;
  }
}