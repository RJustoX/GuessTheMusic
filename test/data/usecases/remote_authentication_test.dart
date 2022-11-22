import 'package:faker/faker.dart';
import 'package:guess_the_music/data/http/_http.dart';
import 'package:guess_the_music/data/usecases/_usecases.dart';
import 'package:guess_the_music/domain/entities/_entities.dart';
import 'package:guess_the_music/domain/helpers/_helpers.dart';
import 'package:guess_the_music/domain/usecases/authentication.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

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
    when(() => httpClient.request(
            url: any(named: 'url'), method: any(named: 'method'), body: any(named: 'body')))
        .thenAnswer((_) async => {'accessToken': faker.guid.guid(), 'name': faker.person.name()});

    await sut.auth(params);

    verify(() => httpClient.request(
          url: url,
          body: {
            'email': params.email,
            'password': params.password,
          },
        ));
  });

  test('Should throw an unexpected exception if httpClient returns 400', () async {
    when(() => httpClient.request(
        url: any(named: 'url'),
        method: any(named: 'method'),
        body: any(named: 'body'))).thenThrow(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw invalidCredentialsError if httpClient returns 401', () async {
    when(() => httpClient.request(
        url: any(named: 'url'),
        method: any(named: 'method'),
        body: any(named: 'body'))).thenThrow(HttpError.unauthorized);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should throw an unexpected exception if httpClient returns 404', () async {
    when(() => httpClient.request(
        url: any(named: 'url'),
        method: any(named: 'method'),
        body: any(named: 'body'))).thenThrow(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw an unexpected exception if httpClient returns 500', () async {
    when(() => httpClient.request(
        url: any(named: 'url'),
        method: any(named: 'method'),
        body: any(named: 'body'))).thenThrow(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should return an account if httpClient returns 200', () async {
    final String accessToken = faker.guid.guid();
    when(() => httpClient.request(
            url: any(named: 'url'), method: any(named: 'method'), body: any(named: 'body')))
        .thenAnswer((_) async => {'accessToken': accessToken, 'name': faker.person.name()});

    final AccountEntity account = await sut.auth(params);

    expect(account.token, accessToken);
  });

  test('Should throw unexpectedError if httpClient returns 200 with invalid data', () async {
    when(() => httpClient.request(
        url: any(named: 'url'),
        method: any(named: 'method'),
        body: any(named: 'body'))).thenAnswer((_) async => {'invalid_key': 'invalid_value'});

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
