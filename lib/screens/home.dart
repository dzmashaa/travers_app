import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/models/user_role.dart';
import 'package:travers_app/providers/role_provider.dart';
import 'package:travers_app/screens/auth.dart';
import 'package:travers_app/screens/competitions.dart';
import 'package:travers_app/services/auth_service.dart';
import 'package:travers_app/utils/snackbar_utils.dart';
import 'package:travers_app/widgets/role_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'TS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TraverScore',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                'Цифрове суддівство змагань',
                style: TextStyle(color: Colors.black45, fontSize: 16),
              ),
              const SizedBox(height: 60),
              RoleCard(
                icon: Icons.shield_outlined,
                title: 'Головний суддя',
                description: 'Організація змагань',
                iconBgColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AuthScreen(wantsHeadJudgeRole: true),
                    ),
                  );
                },
              ),
              RoleCard(
                title: 'Суддя на етапі',
                description: 'Хронометраж та облік штрафів',
                icon: Icons.timer_outlined,
                iconBgColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AuthScreen(wantsHeadJudgeRole: false),
                    ),
                  );
                },
              ),
              RoleCard(
                title: 'Учасник',
                description: 'Перегляд результатів змагань',
                icon: Icons.leaderboard_outlined,
                iconBgColor: const Color(0xFFE0F2F1),
                iconColor: Colors.teal.shade700,
                onTap: () async {
                  try {
                    await AuthService().signInAnonymously();
                    if (!context.mounted) return;
                    await ref
                        .read(roleProvider.notifier)
                        .setRole(UserRole.participant);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompetitionsScreen(),
                      ),
                    );
                  } catch (e) {
                    SnackbarUtils.show(context, 'Помилка входу: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
