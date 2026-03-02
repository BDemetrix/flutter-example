// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

/// Сущность профиля пользователя.
/// Зона ответственности: хранение данных профиля (имя, пароль, сервер, аватар).
class Profile extends Equatable {
  final String userId;
  final int imageResId; // Для чего это поле?
  final String username;
  final String description;
  final String password;
  final String? imageUri;
  final String serverUri;

  const Profile({
    required this.userId,
    required this.imageResId,
    required this.username,
    required this.description,
    required this.password,
    this.imageUri,
    required this.serverUri,
  });

  @override
  List<Object?> get props => [
    userId,
    imageResId,
    username,
    description,
    password,
    imageUri,
    serverUri,
  ];

  Profile copyWith({
    String? userId,
    int? imageResId,
    String? username,
    String? description,
    String? password,
    String? imageUri,
    String? serverUri,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      imageResId: imageResId ?? this.imageResId,
      username: username ?? this.username,
      description: description ?? this.description,
      password: password ?? this.password,
      imageUri: imageUri ?? this.imageUri,
      serverUri: serverUri ?? this.serverUri,
    );
  }
}
