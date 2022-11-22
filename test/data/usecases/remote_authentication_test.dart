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

  Map mockValidData() => {'accessToken': faker.guid.guid(), 'name': faker.person.name()};

  When mockRequest() => when(() => httpClient.request(
      url: any(named: 'url'), method: any(named: 'method'), body: any(named: 'body')));

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
    mockHttpData(mockValidData());
  });

  test('Should call HttpClient with correct URL, method and params', () async {
    await sut.auth(params);

    verify(() => httpClient.request(
          url: url,
          body: {'email': params.email, 'password': params.password},
        ));
  });

  test('Should throw an unexpected exception if httpClient returns 400', () async {
    mockHttpError(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw invalidCredentialsError if httpClient returns 401', () async {
    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should throw an unexpected exception if httpClient returns 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw an unexpected exception if httpClient returns 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should return an account if httpClient returns 200', () async {
    final Map validData = mockValidData();
    mockHttpData(validData);

    final AccountEntity account = await sut.auth(params);

    expect(account.token, validData['accessToken']);
  });

  test('Should throw unexpectedError if httpClient returns 200 with invalid data', () async {
    mockHttpData({'invalid_key': 'invalid_value'});

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
