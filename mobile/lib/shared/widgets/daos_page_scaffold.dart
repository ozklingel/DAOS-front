import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/theme/app_colors.dart';

class DaosPageScaffold extends StatelessWidget {
  const DaosPageScaffold({
    super.key,
    required this.title,
    required this.searchHint,
    required this.body,
    this.onSearchChanged,
    this.showSearch = true,
    this.showBack = false,
    this.avatarInitial,
    this.avatarUrl,
    this.floatingActionButton,
  });

  final String title;
  final String searchHint;
  final Widget body;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearch;
  final bool showBack;
  final String? avatarInitial;
  final String? avatarUrl;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final initial = (avatarInitial ?? 'D').substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      body: Container(
      decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  if (showBack)
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.darkTextPrimary),
                    ),
                  GestureDetector(
                    onTap: () => context.push(RouteNames.profile),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                      child: avatarUrl == null
                          ? Text(
                              initial,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l.appBrand,
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkTextPrimary,
                    ),
              ),
            ),
            if (showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search, color: AppColors.darkTextTertiary),
                    filled: true,
                    fillColor: AppColors.darkSurface.withValues(alpha: 0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
      ),
    );
  }
}
