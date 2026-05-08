import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/utils/exeptions.dart';
import 'package:travers_app/features/auth/auth_provider.dart';

final judgingControllerProvider =
    AsyncNotifierProvider.autoDispose<JudgingController, void>(() {
      return JudgingController();
    });

class JudgingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> joinCompetition(String code) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(competitionRepositoryProvider);
      final uid = ref.read(currentUserUidProvider);

      if (uid == null) throw Exception('Користувач не авторизований');

      final competition = await repo.getCompetitionByInviteCode(code);
      if (competition == null) {
        throw AppException(
          'Змагання з таким кодом не знайдено. Перевірте правильність вводу.',
        );
      }

      if (competition.judgeIds.contains(uid)) {
        throw AppException('Ви вже приєднані до цього змагання.');
      }
      await repo.addCompetitionJudge(competition.id, uid);
    });

    return !state.hasError;
  }
}
