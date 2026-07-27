import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daos/core/constants/api_constants.dart';
import 'package:daos/core/constants/storage_keys.dart';
import 'package:daos/core/network/api_client.dart';
import 'package:daos/features/sms/data/sms_device_reader.dart';
import 'package:daos/features/sms/data/sms_ingest_models.dart';
import 'package:daos/features/sms/data/sms_remote_datasource.dart';

/// Isolate-safe background sync (no Riverpod / UI deps).
Future<SmsIngestResult?> syncSmsFromBackground() async {
  final prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool(StorageKeys.smsSyncEnabled) ?? false)) {
    return null;
  }

  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final access = await storage.read(key: StorageKeys.accessToken);
  if (access == null || access.isEmpty) return null;

  final reader = SmsDeviceReader();
  if (!await reader.hasPermission()) return null;
  final messages = await reader.readToday();
  final fresh = await filterUnsyncedSms(prefs, messages);
  if (fresh.isEmpty) return null;

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Authorization': 'Bearer $access',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  final remote = SmsRemoteDataSource(ApiClient(dio));

  var processed = 0;
  var createdCount = 0;
  final created = <SmsIngestCreatedItem>[];
  const batchSize = 40;
  for (var i = 0; i < fresh.length; i += batchSize) {
    final end = (i + batchSize < fresh.length) ? i + batchSize : fresh.length;
    final chunk = fresh.sublist(i, end);
    final result = await remote.ingest(chunk);
    processed += result.processed;
    createdCount += result.createdCount;
    created.addAll(result.created);
    await markSyncedSms(prefs, chunk.map((m) => m.messageId));
  }

  await prefs.setString(
    StorageKeys.smsLastSyncAt,
    DateTime.now().toUtc().toIso8601String(),
  );
  return SmsIngestResult(
    processed: processed,
    createdCount: createdCount,
    created: created,
  );
}

Future<List<SmsDeviceMessage>> filterUnsyncedSms(
  SharedPreferences prefs,
  List<SmsDeviceMessage> messages,
) async {
  final raw = prefs.getString(StorageKeys.smsSyncedIds);
  final known = <String>{};
  if (raw != null && raw.isNotEmpty) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      known.addAll(list.map((e) => e.toString()));
    } catch (_) {}
  }
  return messages.where((m) => !known.contains(m.messageId)).toList();
}

Future<void> markSyncedSms(
  SharedPreferences prefs,
  Iterable<String> ids,
) async {
  final raw = prefs.getString(StorageKeys.smsSyncedIds);
  final known = <String>[];
  if (raw != null && raw.isNotEmpty) {
    try {
      known.addAll((jsonDecode(raw) as List<dynamic>).map((e) => e.toString()));
    } catch (_) {}
  }
  for (final id in ids) {
    if (!known.contains(id)) known.add(id);
  }
  final trimmed = known.length > 400 ? known.sublist(known.length - 400) : known;
  await prefs.setString(StorageKeys.smsSyncedIds, jsonEncode(trimmed));
}
