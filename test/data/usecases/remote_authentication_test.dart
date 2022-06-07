import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:guess_the_music/data/http/_http.dart';
import 'package:guess_the_music/data/usecases/_usecases.dart';

import 'package:guess_the_music/domain/helpers/_helpers.dart';
import 'package:guess_the_music/domain/usecases/authentication.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication? sut;
  String? url;
  HttpClientSpy? httpClient;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient!, url: url!);
  });

  test('Should call HttpClient with correct URL, method and params', () async {
    final params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );

    await sut!.auth(params);

    verify(httpClient!.request(
      url: url!,
      body: {
        'email': params.email,
        'password': params.password,
      },
    ));
  });

  test('Should throw an unexpected exception if httpClient returns 400', () async {
    when(httpClient!
            .request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
        .thenThrow(HttpError.badRequest);

    final params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
    final future = sut!.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
