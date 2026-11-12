import '../models/report_data.dart';

abstract class ReportRepository {
  Future<List<SleepReportItem>> getSleepReport(
    String babyId, {
    String? startDate,
    String? endDate,
  });

  Future<List<FeedingReportItem>> getFeedingReport(
    String babyId, {
    String? startDate,
    String? endDate,
  });

  Future<List<DiapersReportItem>> getDiapersReport(
    String babyId, {
    String? startDate,
    String? endDate,
  });

  Future<List<GrowthReportItem>> getGrowthReport(
    String babyId, {
    String? startDate,
    String? endDate,
  });

  Future<List<MedicationReportItem>> getMedicationReport(
    String babyId, {
    String? startDate,
    String? endDate,
  });
}
