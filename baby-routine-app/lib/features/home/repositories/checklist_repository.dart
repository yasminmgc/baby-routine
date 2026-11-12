import '../models/checklist_item.dart';

abstract class ChecklistRepository {
  Future<ChecklistResponse> fetch(String babyId, {String? date});
}
