import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_example/domain/entities/profile.dart';

/// Виджет карточки профиля.
/// Зона ответственности: отображение аватара и данных профиля, обработка нажатий.
class ProfileCard extends StatelessWidget {
  final Profile? profile;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(),
          const SizedBox(height: 16),
          if (profile != null)
            Flexible(
              child: Text(
                profile!.username,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 4),
          if (profile != null)
            Flexible(
              child: Text(
                profile!.description,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // TODO в будущем надо добавить обработку ошибок
  Widget _buildAvatar() {
    final size = 160.0;

    if (profile == null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.add, size: size * 0.5, color: Colors.grey[600]),
      );
    } else if (profile?.imageUri != null) {
      final imagePath = profile!.imageUri!;
      return CircleAvatar(
        radius: size / 2,
        child: ClipOval(
          child: Image.file(
            File(imagePath),
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.transparent,
        child: Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]),
      );
    }
  }
}
