import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/user_role.dart';
import 'package:travers_app/core/repositories/sync_repository.dart';
import 'package:travers_app/core/widgets/stat_card.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/core/providers/role_provider.dart';
import 'package:travers_app/features/auth/screens/home.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/profile/provider/profile_providers.dart';
import 'package:travers_app/features/profile/screens/penalty_guide.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _getRoleName(UserRole? role) {
    switch (role) {
      case UserRole.headJudge:
        return 'Головний суддя';
      case UserRole.judge:
        return 'Суддя';
      case UserRole.participant:
        return 'Учасник';
      default:
        return 'Гість';
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _handleLogout() async {
    final hasUnsyncedData = await ref
        .read(syncRepositoryProvider)
        .hasPendingWrites();

    if (!mounted) return;

    if (hasUnsyncedData) {
      final forceLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Критична загроза!'),
            ],
          ),
          content: const Text(
            'У вас є несинхронізовані результати виступів.\n\nЯкщо ви вийдете з профілю зараз, ці дані будуть НАЗАВЖДИ ВТРАЧЕНІ.\n\nБудь ласка, дочекайтеся стабільного підключення до мережі.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Залишитись (Рекомендовано)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Все одно вийти',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (forceLogout != true) return;
    } else {
      final shouldLogout = await DialogHelpers.showConfirmDialog(
        context,
        title: 'Вихід з акаунта',
        content: 'Ви впевнені, що хочете вийти?',
        confirmText: 'Вийти',
      );
      if (shouldLogout != true) return;
    }

    if (!mounted) return;
    try {
      await ref.read(roleProvider.notifier).clearRole();
      await ref.read(authServiceProvider).signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) SnackbarUtils.show(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final roleState = ref.watch(roleProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 46,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                child: Text(
                  _getInitials(user?.displayName ?? user?.email),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                user?.displayName ?? 'Користувач',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'Немає пошти',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              roleState.when(
                data: (role) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRoleName(role),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                loading: () => const CircularProgressIndicator(),
              ),
              const SizedBox(height: 32),
              statsAsync.when(
                data: (stats) {
                  final isHeadJudge = roleState.value == UserRole.headJudge;

                  return Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          number: isHeadJudge
                              ? '${stats['created']}'
                              : '${stats['judgedComps']}',
                          label: isHeadJudge ? 'Створено' : 'Змагань',
                          numberColor: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          number: isHeadJudge
                              ? '${stats['judgedComps']}'
                              : '${stats['judgedBlocks']}',
                          label: isHeadJudge ? 'Відсуджено' : 'Блоків',
                          numberColor: const Color(0xFFE4704B),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PenaltyGuideScreen(),
                          ),
                        );
                      },
                      leading: Icon(
                        Icons.menu_book_rounded,
                        color: Colors.grey.shade700,
                      ),
                      title: const Text(
                        'Довідник штрафів',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      onTap: _handleLogout,
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Вийти',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
