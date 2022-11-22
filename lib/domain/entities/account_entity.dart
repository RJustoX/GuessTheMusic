class AccountEntity {
  final String token;

  AccountEntity(this.token);

  factory AccountEntity.fromJson(Map<dynamic, dynamic> json) => AccountEntity(json['accessToken']);
}
