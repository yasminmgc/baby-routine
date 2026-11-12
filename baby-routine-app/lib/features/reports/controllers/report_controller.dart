import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/selected_baby_provider.dart';
import '../models/report_data.dart';
import '../repositories/report_repository.dart';
import '../repositories/report_repository_impl.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(dioClientProvider));
});

final reportControllerProvider =
    AsyncNotifierProvider<ReportController, void>(ReportController.new);

class ReportController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  ReportRepository get _repository => ref.read(reportRepositoryProvider);

  String get _babyId {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw Exception('Nenhum bebê selecionado');
    }
    return baby.id;
  }

  Future<List<SleepReportItem>> getSleepReport({
    String? startDate,
    String? endDate,
  }) async {
    return _repository.getSleepReport(
      _babyId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<FeedingReportItem>> getFeedingReport({
    String? startDate,
    String? endDate,
  }) async {
    return _repository.getFeedingReport(
      _babyId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<DiapersReportItem>> getDiapersReport({
    String? startDate,
    String? endDate,
  }) async {
    return _repository.getDiapersReport(
      _babyId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<GrowthReportItem>> getGrowthReport({
    String? startDate,
    String? endDate,
  }) async {
    return _repository.getGrowthReport(
      _babyId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<MedicationReportItem>> getMedicationReport({
    String? startDate,
    String? endDate,
  }) async {
    return _repository.getMedicationReport(
      _babyId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
