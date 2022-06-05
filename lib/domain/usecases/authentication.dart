import 'package:guess_the_music/domain/entities/account_entity.dart';

abstract class Authentication {
  Future<AccountEntity> auth(AuthenticationParams params);
}

class AuthenticationParams {
  final String email = '';
  final String password = '';

  AuthenticationParams({
    required String email,
    required String password,
  });

  Map toJson() => {'email': email, 'password': password};
}
