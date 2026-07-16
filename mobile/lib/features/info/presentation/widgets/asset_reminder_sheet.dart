import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';
import 'package:taskmail/features/hub/presentation/providers/hub_providers.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/theme/app_colors.dart';

Future<void> showAssetReminderSheet(
  BuildContext context,
  WidgetRef ref,
  AssetReminderData reminder,
) async {
  final l = AppLocalizations.of(context);
  final titleController = TextEditingController(text: reminder.title);
  final dateController = TextEditingController(text: reminder.expiryDate);
  final notesController = TextEditingController(text: reminder.notes ?? '');

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.assetReminderDetails,
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ),
                AssetStatusBadge(status: reminder.status, l: l),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: l.assetTitleLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: l.assetExpiryLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.assetNotesLabel),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.apply),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (saved != true || !context.mounted) return;

  try {
    await ref.read(hubRemoteDataSourceProvider).updateAsset(
          id: reminder.id,
          title: titleController.text.trim(),
          expiryDate: dateController.text.trim(),
          notes: notesController.text.trim(),
        );
    ref.invalidate(infoHubProvider);
    ref.invalidate(calendarProvider(null));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.assetUpdated)),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.serverError)),
      );
    }
  }
}

class AssetStatusBadge extends StatelessWidget {
  const AssetStatusBadge({super.key, required this.status, required this.l});

  final String status;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'overdue' => (l.assetStatusOverdue, AppColors.critical),
      'urgent' => (l.assetStatusUrgent, AppColors.critical),
      'warning' => (l.assetStatusWarning, AppColors.warning),
      _ => (l.assetStatusOk, AppColors.success),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

String assetDaysLabel(AppLocalizations l, AssetReminderData reminder) {
  if (reminder.daysUntil < 0) {
    return l.assetDaysOverdue(reminder.daysUntil.abs());
  }
  if (reminder.daysUntil == 0) {
    return l.assetDaysToday;
  }
  return l.assetDaysUntil(reminder.daysUntil);
}
