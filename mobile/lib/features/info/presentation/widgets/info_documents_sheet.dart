import 'package:flutter/material.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/widgets/hub_menu_card.dart';
import 'package:taskmail/theme/app_colors.dart';

Future<void> showInfoCategorySheet(
  BuildContext context, {
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
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
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
                                showInfoDocumentDetail(context, doc);
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

Future<void> showInfoDocumentDetail(BuildContext context, InfoDocumentData doc) {
  final l = AppLocalizations.of(context);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(hubIconForKey(doc.icon), color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doc.title,
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
              doc.categoryTitle,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (doc.summary != null && doc.summary!.isNotEmpty) ...[
              const SizedBox(height: 12),
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
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.dismiss),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _InfoDocumentTile extends StatelessWidget {
  const _InfoDocumentTile({required this.document, required this.onTap});

  final InfoDocumentData document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkGlass,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(hubIconForKey(document.icon), color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
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
