import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/theme/app_colors.dart';

/// Handles Microsoft redirect: /oauth/outlook?code=...&state=...
class OutlookOAuthCallbackScreen extends ConsumerStatefulWidget {
  const OutlookOAuthCallbackScreen({super.key});

  @override
  ConsumerState<OutlookOAuthCallbackScreen> createState() =>
      _OutlookOAuthCallbackScreenState();
}

class _OutlookOAuthCallbackScreenState
    extends ConsumerState<OutlookOAuthCallbackScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
  }

  Future<void> _complete() async {
    final l = AppLocalizations.of(context);
    final uri = GoRouterState.of(context).uri;
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    final error = uri.queryParameters['error'];
    final errorDesc = uri.queryParameters['error_description'];

    if (error != null) {
      setState(() => _error = errorDesc ?? error);
      return;
    }
    if (code == null || state == null) {
      setState(() => _error = l.outlookOAuthMissingCode);
      return;
    }

    try {
      final next = await ref.read(authStateProvider.notifier).completeOutlookWebOAuth(
            code: code,
            state: state,
          );
      if (!mounted) return;
      if (next == 'settings') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.outlookConnectedSuccess)),
        );
        context.go(RouteNames.settings);
      } else {
        context.go(RouteNames.dashboard);
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = l.errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _error == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      l.outlookOAuthCompleting,
                      style: const TextStyle(color: AppColors.darkTextSecondary),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.critical),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: Text(l.dismiss),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
