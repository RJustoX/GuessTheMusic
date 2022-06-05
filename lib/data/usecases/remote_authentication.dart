import 'package:guess_the_music/data/http/_http.dart';

import '../../domain/usecases/authentication.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({required this.httpClient, required this.url});

  Future<void> auth(AuthenticationParams params) async {
    await httpClient.request(url: url, method: 'post', body: params.toJson());
  }
}

class RemoteAuthenticationParams {
  final String email = '';
  final String password = '';

  RemoteAuthenticationParams({
    required String email,
    required String password,
  });

  Map toJson() => {'email': email, 'password': password};
}
