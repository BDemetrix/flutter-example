import 'package:flutter_example/app/cubit/failure/failure_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Глобальный слушатель ошибок.
/// Зона ответственности: отображение SnackBar при получении ошибок из FailureCubit.
/// Используется внутри MaterialApp для централизованной обработки ошибок.
class FailureBlocListener extends StatelessWidget {
  final Widget child;
  const FailureBlocListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FailureCubit, FailureState>(
      listener: (context, state) {
        if (state is! FailureReceived) return;

        final cubit = context.read<FailureCubit>();
        final failure = state.failure;
        final snack = ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));

        snack.closed.then((_) {
          cubit.reset();
        });
      },
      child: child,
    );
  }
}
