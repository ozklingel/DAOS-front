import 'package:taskmail/features/daily_brief/domain/entities/daily_brief.dart';

abstract class DailyBriefRepository {
  Future<DailyBrief> getDailyBrief();
}
