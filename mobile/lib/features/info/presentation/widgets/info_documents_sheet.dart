import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';
import 'package:taskmail/features/hub/presentation/providers/hub_providers.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/widgets/hub_menu_card.dart';
import 'package:taskmail/theme/app_colors.dart';

Future<void> showInfoCategorySheet(
  BuildContext context,
  WidgetRef ref, {
  required InfoCategoryData category,
  required List<InfoDocumentData> documents,
}) {
  final l = AppLocalizations.of(context);
  final docs = documents.where((d) => d.category == category.id).toList();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(hubIconForKey(category.icon), color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category.title,
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              color: AppColors.darkTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  docs.isEmpty ? l.infoCategoryEmpty : l.infoDocumentsCount(docs.length),
                  style: const TextStyle(color: AppColors.darkTextSecondary),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: docs.isEmpty
                      ? Center(
                          child: Text(
                            l.infoCategoryEmptyHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.darkTextTertiary),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final doc = docs[index];
                            return _InfoDocumentTile(
                              document: doc,
                              onTap: () {
                                Navigator.pop(ctx);
                                showInfoDocumentDetail(context, ref, doc);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showInfoDocumentDetail(
  BuildContext context,
  WidgetRef ref,
  InfoDocumentData doc,
) {
  final l = AppLocalizations.of(context);
  final imageBytes = _decodeDataUrl(doc.imageDataUrl);

  return showModalBottomSheet<void>(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.title,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                doc.categoryTitle,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              if (imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                      maxWidth: double.infinity,
                    ),
                    child: InteractiveViewer(
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _MissingImage(l: l),
                      ),
                    ),
                  ),
                )
              else
                _MissingImage(l: l),
              if (doc.summary != null && doc.summary!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  doc.summary!,
                  style: const TextStyle(color: AppColors.darkTextSecondary, height: 1.4),
                ),
              ],
              if (doc.expiryDate != null && doc.expiryDate!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${l.infoDocumentDate}: ${doc.expiryDate}',
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (doc.extractedText != null && doc.extractedText!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l.infoDocumentExtracted,
                  style: const TextStyle(
                    color: AppColors.darkTextTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doc.extractedText!,
                  style: const TextStyle(color: AppColors.darkTextSecondary, height: 1.35),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmAndDelete(context, ctx, ref, doc, l),
                  icon: const Icon(Icons.delete_outline, color: AppColors.critical),
                  label: Text(
                    l.deleteDocument,
                    style: const TextStyle(color: AppColors.critical),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.critical),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.dismiss),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _confirmAndDelete(
  BuildContext pageContext,
  BuildContext sheetContext,
  WidgetRef ref,
  InfoDocumentData doc,
  AppLocalizations l,
) async {
  final confirmed = await showDialog<bool>(
    context: sheetContext,
    builder: (dialogCtx) => AlertDialog(
      title: Text(l.deleteDocument),
      content: Text(l.deleteDocumentConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: Text(l.dismiss),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.critical),
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: Text(l.deleteDocument),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    await ref.read(hubRemoteDataSourceProvider).deleteInfoDocument(doc.id);
    ref.invalidate(infoHubProvider);
    ref.invalidate(calendarProvider(null));
    if (sheetContext.mounted) Navigator.pop(sheetContext);
    if (pageContext.mounted) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(content: Text(l.documentDeleted)),
      );
    }
  } catch (_) {
    if (pageContext.mounted) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(content: Text(l.serverError)),
      );
    }
  }
}

Uint8List? _decodeDataUrl(String? dataUrl) {
  if (dataUrl == null || dataUrl.isEmpty) return null;
  try {
    final comma = dataUrl.indexOf(',');
    final b64 = comma >= 0 ? dataUrl.substring(comma + 1) : dataUrl;
    return base64Decode(b64);
  } catch (_) {
    return null;
  }
}

class _MissingImage extends StatelessWidget {
  const _MissingImage({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.darkGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkGlassBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_outlined, color: AppColors.darkTextTertiary),
          const SizedBox(height: 8),
          Text(
            l.infoDocumentNoImage,
            style: const TextStyle(color: AppColors.darkTextTertiary),
          ),
        ],
      ),
    );
  }
}

class _InfoDocumentTile extends StatelessWidget {
  const _InfoDocumentTile({required this.document, required this.onTap});

  final InfoDocumentData document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = _decodeDataUrl(document.imageDataUrl);

    return Material(
      color: AppColors.darkGlass,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: thumb != null
                      ? Image.memory(thumb, fit: BoxFit.cover)
                      : ColoredBox(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          child: Icon(
                            hubIconForKey(document.icon),
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    if (document.summary != null && document.summary!.isNotEmpty)
                      Text(
                        document.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    if (document.expiryDate != null)
                      Text(
                        document.expiryDate!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.darkTextTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
