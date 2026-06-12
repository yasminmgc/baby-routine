import '../../../core/network/dio_client.dart';
import '../models/checklist_item.dart';
import 'checklist_repository.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final DioClient _dioClient;

  ChecklistRepositoryImpl(this._dioClient);

  @override
  Future<ChecklistResponse> fetch(String babyId, {String? date}) async {
    final params = <String, dynamic>{};
    if (date != null) {
      params['date'] = date;
    }
    final response = await _dioClient.get(
      '/babies/$babyId/checklist',
      params: params.isNotEmpty ? params : null,
    );
    return ChecklistResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
