import 'package:taskmail/features/daily_brief/data/datasources/daily_brief_remote_datasource.dart';
import 'package:taskmail/features/daily_brief/domain/entities/daily_brief.dart';
import 'package:taskmail/features/daily_brief/domain/repositories/daily_brief_repository.dart';

class DailyBriefRepositoryImpl implements DailyBriefRepository {
  DailyBriefRepositoryImpl(this._remote);

  final DailyBriefRemoteDataSource _remote;

  @override
  Future<DailyBrief> getDailyBrief() async {
    final model = await _remote.getDailyBrief();
    return model.toEntity();
  }
}
