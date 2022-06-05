abstract class HttpClient {
  Future<void>? request({
    required String url,
    String method = 'post',
    Map? body,
  });
}
