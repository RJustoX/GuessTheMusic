abstract class HttpClient {
  Future<Map<dynamic, dynamic>> request({required String url, String method = 'post', Map? body});
}
