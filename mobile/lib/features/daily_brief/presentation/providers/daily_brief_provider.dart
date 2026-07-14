import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/features/daily_brief/domain/entities/daily_brief.dart';

final dailyBriefProvider =
    AsyncNotifierProvider<DailyBriefNotifier, DailyBrief>(() {
  return DailyBriefNotifier();
});

class DailyBriefNotifier extends AsyncNotifier<DailyBrief> {
  @override
  Future<DailyBrief> build() async {
    return ref.read(dailyBriefRepositoryProvider).getDailyBrief();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dailyBriefRepositoryProvider).getDailyBrief(),
    );
  }
}
