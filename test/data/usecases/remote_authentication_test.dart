import 'package:faker/faker.dart';
import 'package:guess_the_music/domain/usecases/authentication.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({required this.httpClient, required this.url});

  Future<void> auth(AuthenticationParams params) async {
    await httpClient.request(url: url, method: 'post', body: params.toJson());
  }
}

abstract class HttpClient {
  Future<void>? request({
    required String url,
    String method = 'post',
    Map? body,
  });
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication? sut;
  String? url;
  HttpClientSpy? httpClient;
  AuthenticationParams? params;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient!, url: url!);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  });

  test('Should call HttpClient with correct URL', () async {
    await sut!.auth(params!);

    verify(httpClient!.request(url: url!, body: params!.toJson()));
  });

  test('Should call HttpClient with correct method', () async {
    await sut!.auth(params!);

    verify(httpClient!.request(url: url!, method: 'post', body: params!.toJson()));
  });

  test('Should call HttpClient with correct body params', () async {
    await sut!.auth(params!);

    verify(httpClient!.request(
      url: url!,
      method: 'post',
      body: {
        'email': params?.email,
        'password': params?.password,
      },
    ));
  });
}
