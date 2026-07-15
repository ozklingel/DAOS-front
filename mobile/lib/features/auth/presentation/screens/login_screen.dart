import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/locale/locale_provider.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/services/analytics_service.dart';
import 'package:taskmail/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleLoading = false;
  bool _isOutlookLoading = false;
  bool _isDevLoading = false;

  Future<void> _signIn(Future<void> Function() signIn, String method) async {
    setState(() {
      if (method == 'google') {
        _isGoogleLoading = true;
      } else {
        _isOutlookLoading = true;
      }
    });

    try {
      await signIn();
      await ref.read(analyticsServiceProvider).logLogin(method);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isOutlookLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text(l.english)),
                    ButtonSegment(value: 'he', label: Text(l.hebrew)),
                  ],
                  selected: {ref.watch(localeProvider).languageCode},
                  onSelectionChanged: (selected) {
                    ref.read(localeProvider.notifier).setLocale(selected.first);
                  },
                ),
              ),
              const Spacer(flex: 2),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l.appTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l.loginTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
              ),
              const Spacer(flex: 2),
              _OAuthButton(
                label: l.continueWithGoogle,
                icon: Icons.g_mobiledata,
                isLoading: _isGoogleLoading,
                onPressed: auth.isLoading || _isOutlookLoading
                    ? null
                    : () => _signIn(
                          ref.read(authStateProvider.notifier).signInWithGoogle,
                          'google',
                        ),
              ),
              const SizedBox(height: 12),
              _OAuthButton(
                label: l.continueWithOutlook,
                icon: Icons.mail_outline,
                isLoading: _isOutlookLoading,
                onPressed: auth.isLoading || _isGoogleLoading || _isDevLoading
                    ? null
                    : () => _signIn(
                          ref.read(authStateProvider.notifier).signInWithOutlook,
                          'outlook',
                        ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Text(
                  'API: ${ApiConstants.baseUrl}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 12),
                _OAuthButton(
                  label: l.devLogin,
                  icon: Icons.developer_mode,
                  isLoading: _isDevLoading,
                  onPressed: auth.isLoading || _isGoogleLoading || _isOutlookLoading
                      ? null
                      : () async {
                          setState(() => _isDevLoading = true);
                          try {
                            await ref.read(authStateProvider.notifier).signInDev();
                          } on AppException catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isDevLoading = false);
                          }
                        },
                ),
              ],
              const SizedBox(height: 32),
              Text(
                l.loginTerms,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 22),
                  const SizedBox(width: 12),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
