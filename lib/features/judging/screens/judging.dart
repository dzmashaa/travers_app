import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/utils/error_mapper.dart';
import 'package:travers_app/core/utils/network_helper.dart' show NetworkHelper;
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/core/widgets/comp_list.dart';
import 'package:travers_app/features/competitions/widgets/filter_bar.dart';
import 'package:travers_app/features/judging/controllers/judjing_controller.dart';
import 'package:travers_app/features/judging/providers/judge_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/features/judging/screens/judge_assignment.dart';

class JudgingScreen extends ConsumerWidget {
  const JudgingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.listen(judgingControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        SnackbarUtils.show(
          context,
          ErrorMapper.getHumanReadableMessage(next.error!),
          isError: true,
        );
      }
    });
    final isLoading = ref.watch(judgingControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Суддівство',
          style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FilterBar(),
          const SizedBox(height: 12),
          CompetitionsList(
            competitionsAsync: ref.watch(filteredJudgeCompetitionsProvider),
            emptyMessage:
                'Ви ще не є суддею жодного змагання\n (або за обраним фільтром змагань немає)',
            onCompetitionTap: (competition) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      JudgeAssignmentsScreen(competition: competition),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: isLoading
            ? null
            : () async {
                final hasConnection = await NetworkHelper.hasInternet();
                if (!context.mounted) return;
                if (!hasConnection) {
                  SnackbarUtils.show(
                    context,
                    'Для приєднання до змагання необхідне підключення до Інтернету.',
                    isError: true,
                  );
                  return;
                }
                final code = await DialogHelpers.showAccessCodeDialog(
                  context,
                  title: 'Приєднатися до змагання',
                  message:
                      'Введіть унікальний код змагання, щоб отримати права судді.',
                  cancelText: 'Скасувати',
                  confirmText: 'Приєднатися',
                );

                if (code != null && context.mounted) {
                  final success = await ref
                      .read(judgingControllerProvider.notifier)
                      .joinCompetition(code);
                  if (success && context.mounted) {
                    SnackbarUtils.show(
                      context,
                      'Ви успішно приєдналися до змагання!',
                      isError: false,
                    );
                  }
                }
              },
        backgroundColor: theme.primaryColor,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
