import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _dateFromJson(String? value) =>
      value == null ? null : DateTime.parse(value);

  static String? _dateToJson(DateTime? date) => date?.toIso8601String();

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, name, email, createdAt);
}

@JsonSerializable()
class LoginResponse {
  final String token;
  final User user;

  const LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  String toString() => 'LoginResponse(token: $token, user: $user)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponse &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          user == other.user;

  @override
  int get hashCode => Object.hash(token, user);
}

@JsonSerializable()
class RegisterResponse {
  final String id;
  final String name;
  final String email;
  final String token;

  const RegisterResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);

  @override
  String toString() =>
      'RegisterResponse(id: $id, name: $name, email: $email, token: $token)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          token == other.token;

  @override
  int get hashCode => Object.hash(id, name, email, token);
}
