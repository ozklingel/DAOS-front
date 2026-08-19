import 'package:flutter/material.dart';
import 'package:daos/theme/app_colors.dart';

/// Bottom sheet wrapper that leaves room for the tab bar and adds a close control.
class SettingsSheetScaffold extends StatelessWidget {
  const SettingsSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.expandBody = false,
  });

  final String title;
  final Widget child;
  final bool expandBody;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    bool isScrollControlled = false,
  }) {
    final maxHeight = MediaQuery.of(context).size.height * 0.72;
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: isScrollControlled,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: AppColors.darkBackgroundMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(maxHeight: maxHeight),
      builder: (ctx) => SettingsSheetScaffold(
        title: title,
        expandBody: isScrollControlled,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (expandBody) Expanded(child: child) else child,
        ],
      ),
    );
  }
}
