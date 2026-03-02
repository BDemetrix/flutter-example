import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter/material.dart';

/// Виджет элемента абонента в списке контактов.
/// Зона ответственности: отображение аватара, имени, логина и статуса онлайн абонента.
class AbonentItem extends StatelessWidget {
  final Abonent contact;
  final VoidCallback onTap;

  const AbonentItem({super.key, required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: _buildAvatarWithStatus(context),
        title: Text(
          contact.name,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          contact.login,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildAvatarWithStatus(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: contact.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).cardColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
