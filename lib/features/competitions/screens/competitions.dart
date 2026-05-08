import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/user_role.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/core/providers/role_provider.dart';
import 'package:travers_app/features/competitions/screens/add_competition.dart';
import 'package:travers_app/features/auth/screens/home.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/competitions/widgets/comp_list.dart';
import 'package:travers_app/features/competitions/widgets/filter_bar.dart';

class CompetitionsScreen extends ConsumerStatefulWidget {
  const CompetitionsScreen({super.key});
  @override
  ConsumerState<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends ConsumerState<CompetitionsScreen> {
  Future<void> _handleLogout() async {
    final shouldLogout = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Вихід з акаунта',
      content: 'Ви впевнені, що хочете вийти?',
      confirmText: 'Вийти',
    );
    if (shouldLogout != true || !mounted) return;

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
      if (mounted) {
        SnackbarUtils.show(context, e.toString(), isError: true);
      }
    }
  }

  void _navigateToAddCompetition() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCompetitionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = ref.watch(roleProvider).value;
    final isHeadJudge = role == UserRole.headJudge;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Змагання',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          if (role == UserRole.participant)
            IconButton(
              icon: Icon(
                Icons.logout,
                color: theme.textTheme.displayMedium?.color,
              ),
              onPressed: _handleLogout,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterBar(),
            const SizedBox(height: 12),
            CompetitionsList(),
          ],
        ),
      ),
      floatingActionButton: (isHeadJudge)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 4),
              child: FloatingActionButton(
                onPressed: _navigateToAddCompetition,
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
    );
  }
}
