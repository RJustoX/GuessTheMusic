abstract class HttpClient {
  Future<Map<String, dynamic>>? request({required String url, String method = 'post', Map? body});
}
