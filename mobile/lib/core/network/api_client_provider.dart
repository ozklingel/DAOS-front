import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/core/network/dio_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
