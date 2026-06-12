import '../../../../core/network/dio_client.dart';
import '../models/report_data.dart';
import 'report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final DioClient _dioClient;

  ReportRepositoryImpl(this._dioClient);

  Map<String, dynamic> _buildParams(String? startDate, String? endDate) {
    final params = <String, dynamic>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    return params;
  }

  List<T> _parseList<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = responseData as List<dynamic>;
    return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SleepReportItem>> getSleepReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dioClient.get(
      '/babies/$babyId/reports/sleep',
      params: _buildParams(startDate, endDate),
    );
    return _parseList(response.data, SleepReportItem.fromJson);
  }

  @override
  Future<List<FeedingReportItem>> getFeedingReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dioClient.get(
      '/babies/$babyId/reports/feeding',
      params: _buildParams(startDate, endDate),
    );
    return _parseList(response.data, FeedingReportItem.fromJson);
  }

  @override
  Future<List<DiapersReportItem>> getDiapersReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dioClient.get(
      '/babies/$babyId/reports/diapers',
      params: _buildParams(startDate, endDate),
    );
    return _parseList(response.data, DiapersReportItem.fromJson);
  }

  @override
  Future<List<GrowthReportItem>> getGrowthReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dioClient.get(
      '/babies/$babyId/reports/growth',
      params: _buildParams(startDate, endDate),
    );
    return _parseList(response.data, GrowthReportItem.fromJson);
  }

  @override
  Future<List<MedicationReportItem>> getMedicationReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dioClient.get(
      '/babies/$babyId/reports/medication',
      params: _buildParams(startDate, endDate),
    );
    return _parseList(response.data, MedicationReportItem.fromJson);
  }
}
