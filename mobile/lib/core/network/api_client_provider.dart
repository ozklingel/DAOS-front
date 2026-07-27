import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/core/network/api_client.dart';
import 'package:daos/core/network/dio_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
