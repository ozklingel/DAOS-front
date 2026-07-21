import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/features/dashboard/data/recording_bytes.dart';
import 'package:taskmail/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/theme/app_colors.dart';

Future<void> showVoiceTaskRecorder(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _VoiceTaskRecorderSheet(),
  );
}

class _VoiceTaskRecorderSheet extends ConsumerStatefulWidget {
  const _VoiceTaskRecorderSheet();

  @override
  ConsumerState<_VoiceTaskRecorderSheet> createState() => _VoiceTaskRecorderSheetState();
}

class _VoiceTaskRecorderSheetState extends ConsumerState<_VoiceTaskRecorderSheet> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  bool _busy = false;
  String? _error;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _error = null);
    if (_recording) {
      await _stopAndUpload();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    final l = AppLocalizations.of(context);
    try {
      final allowed = await _recorder.hasPermission();
      if (!allowed) {
        setState(() => _error = l.voiceMicDenied);
        return;
      }

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      final path = kIsWeb
          ? 'voice.wav'
          : p.join(
              (await getTemporaryDirectory()).path,
              'voice_${DateTime.now().millisecondsSinceEpoch}.wav',
            );

      await _recorder.start(config, path: path);
      setState(() {
        _recording = true;
        _elapsed = Duration.zero;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (e) {
      setState(() => _error = l.errorMessage(e));
    }
  }

  Future<void> _stopAndUpload() async {
    final l = AppLocalizations.of(context);
    _timer?.cancel();
    setState(() {
      _recording = false;
      _busy = true;
    });

    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) {
        throw StateError(l.voiceRecordFailed);
      }

      final bytes = await readRecordingBytes(path);
      if (bytes.isEmpty) {
        throw StateError(l.voiceRecordFailed);
      }

      final result = await ref.read(tasksRemoteDataSourceProvider).createFromVoice(
            audioBytes: bytes,
            audioFilename: 'voice.wav',
          );

      if (!mounted) return;
      Navigator.pop(context);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(dashboardProvider);

      final msg = result.created
          ? (result.transcript == null || result.transcript!.isEmpty
              ? l.voiceTaskCreated
              : '${l.voiceTaskCreated}: ${result.transcript}')
          : result.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      if (result.created) {
        context.go(RouteNames.tasks);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l.errorMessage(e);
      });
    }
  }

  String _formatElapsed() {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l.voiceTaskTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l.voiceRecordHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.darkTextSecondary, height: 1.35),
          ),
          const SizedBox(height: 24),
          Text(
            _formatElapsed(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),
          if (_busy)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(l.voiceProcessing, style: const TextStyle(color: AppColors.darkTextSecondary)),
              ],
            )
          else
            GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _recording ? AppColors.critical : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (_recording ? AppColors.critical : AppColors.primary)
                          .withValues(alpha: 0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(
                  _recording ? Icons.stop_rounded : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          if (!_busy) ...[
            const SizedBox(height: 14),
            Text(
              _recording ? l.voiceTapToStop : l.voiceTapToStart,
              style: const TextStyle(color: AppColors.darkTextSecondary),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.critical),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
