import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/models/user_role.dart';
import 'package:travers_app/providers/role_provider.dart';

class CompetitionsScreen extends ConsumerWidget {
  const CompetitionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider).value;
    final isHeadJudge = role == UserRole.headJudge;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Змагання',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            if (role == UserRole.participant) Text('Привіт, учасник!'),
            if (role == UserRole.judge) Text('Привіт, суддя!'),
            if (isHeadJudge) Text('Привіт, головний суддя!'),
            Text(
              'Тут будуть всі змагання',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: (isHeadJudge)
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Додавання змагання
              },
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }
}
