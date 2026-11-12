import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import 'storage_provider.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});
