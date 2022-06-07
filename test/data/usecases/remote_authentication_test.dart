import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:guess_the_music/data/http/_http.dart';
import 'package:guess_the_music/data/usecases/_usecases.dart';

import 'package:guess_the_music/domain/helpers/_helpers.dart';
import 'package:guess_the_music/domain/usecases/authentication.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late String url;
  late HttpClientSpy httpClient;
  late AuthenticationParams params;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  });

  test('Should call HttpClient with correct URL, method and params', () async {
    await sut.auth(params);

    verify(httpClient.request(
      url: url,
      body: {
        'email': params.email,
        'password': params.password,
      },
    ));
  });

  test('Should throw an unexpected exception if httpClient returns 400', () async {
    when(httpClient.request(
            url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
        .thenThrow(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw an unexpected exception if httpClient returns 404', () async {
    when(httpClient.request(
            url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
        .thenThrow(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
