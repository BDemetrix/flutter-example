import 'package:flutter_example/domain/entities/group/group.dart';
import 'package:flutter/material.dart';

/// Виджет элемента группы в списке контактов.
/// Зона ответственности: отображение названия и иконки группы.
class GroupItem extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const GroupItem({super.key, required this.group, required this.onTap});

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
        leading: _buildAvatar(context),
        title: Text(
          group.name,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Group',
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

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.grey,
      child: Icon(Icons.group, color: Colors.white),
    );
  }
}
