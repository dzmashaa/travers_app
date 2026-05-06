import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/models/user_role.dart';
import 'package:travers_app/providers/auth_provider.dart';
import 'package:travers_app/providers/comp_filter_provider.dart';
import 'package:travers_app/providers/role_provider.dart';
import 'package:travers_app/screens/add_competition.dart';
import 'package:travers_app/screens/competition_details.dart';
import 'package:travers_app/screens/home.dart';
import 'package:travers_app/utils/dialog_helpers.dart';
import 'package:travers_app/utils/snackbar_utils.dart';
import 'package:travers_app/widgets/competition_card.dart';

class CompetitionsScreen extends ConsumerStatefulWidget {
  const CompetitionsScreen({super.key});
  @override
  ConsumerState<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends ConsumerState<CompetitionsScreen> {
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
              onPressed: () async {
                final shouldLogout = await DialogHelpers.showConfirmDialog(
                  context,
                  title: 'Вихід з акаунта',
                  content: 'Ви впевнені, що хочете вийти?',
                  confirmText: 'Вийти',
                );

                if (shouldLogout == true) {
                  try {
                    await ref.read(roleProvider.notifier).clearRole();
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      SnackbarUtils.show(context, e.toString(), isError: true);
                    }
                  }
                }
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterBar(),
            const SizedBox(height: 12),
            _CompetitionsList(),
          ],
        ),
      ),
      floatingActionButton: (isHeadJudge)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 4),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCompetitionScreen(),
                    ),
                  );
                },
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFilter = ref.watch(competitionFilterProvider);
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CompetitionFilter.values.length,
        itemBuilder: (context, index) {
          final filter = CompetitionFilter.values[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  ref.read(competitionFilterProvider.notifier).state = filter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  filter.displayName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompetitionsList extends ConsumerWidget {
  const _CompetitionsList();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filteredAsyncValue = ref.watch(filteredCompetitionsProvider);
    ;

    return Expanded(
      child: filteredAsyncValue.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (error, stackTrace) =>
            _buildCenteredText('Помилка завантаження даних', theme),
        data: (filteredList) {
          if (filteredList.isEmpty) {
            return _buildCenteredText('Змагань не знайдено', theme);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final competition = filteredList[index];
              return CompetitionCard(
                competition: competition,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompetitionDetailsScreen(
                        competitionId: competition.id,
                        initialCompetition: competition,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCenteredText(String text, ThemeData theme) {
    return Center(
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }
}
