import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/locale/locale_provider.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/services/analytics_service.dart';

/// Fresh mobile portrait login (v2). Plain column list — large tappable buttons.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _googleLoading = false;
  bool _outlookLoading = false;
  bool _devLoading = false;

  bool get _busy => _googleLoading || _outlookLoading || _devLoading;

  Future<void> _run(String method, Future<void> Function() action) async {
    setState(() {
      if (method == 'google') _googleLoading = true;
      if (method == 'outlook') _outlookLoading = true;
      if (method == 'dev') _devLoading = true;
    });
    try {
      await action();
      if (method != 'dev') {
        await ref.read(analyticsServiceProvider).logLogin(method);
      }
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _googleLoading = false;
          _outlookLoading = false;
          _devLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: ColoredBox(
        color: const Color(0xFF0B1220),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, top + 12, 20, bottom + 32),
          children: [
            // Visible stamp so you can confirm the new build loaded on phone.
            const Text(
              'mobile UI v2',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                _Chip(
                  text: l.english,
                  selected: locale == 'en',
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale('en'),
                ),
                const SizedBox(width: 8),
                _Chip(
                  text: l.hebrew,
                  selected: locale == 'he',
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale('he'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.appTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.loginTagline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            if (kIsWeb && kDebugMode) ...[
              _Btn(
                label: l.devLogin,
                icon: Icons.developer_mode_rounded,
                loading: _devLoading,
                filled: true,
                onPressed: _busy
                    ? null
                    : () => _run(
                          'dev',
                          () => ref.read(authStateProvider.notifier).signInDev(),
                        ),
              ),
              const SizedBox(height: 16),
            ],
            _Btn(
              label: l.continueWithGoogle,
              icon: Icons.g_mobiledata_rounded,
              loading: _googleLoading,
              onPressed: _busy
                  ? null
                  : () => _run(
                        'google',
                        () => ref
                            .read(authStateProvider.notifier)
                            .signInWithGoogle(),
                      ),
            ),
            if (!kIsWeb) ...[
              const SizedBox(height: 16),
              _Btn(
                label: l.continueWithOutlook,
                icon: Icons.mail_outline_rounded,
                loading: _outlookLoading,
                onPressed: _busy
                    ? null
                    : () => _run(
                          'outlook',
                          () => ref
                              .read(authStateProvider.notifier)
                              .signInWithOutlook(),
                        ),
              ),
            ],
            if (!kIsWeb && kDebugMode) ...[
              const SizedBox(height: 16),
              _Btn(
                label: l.devLogin,
                icon: Icons.developer_mode_rounded,
                loading: _devLoading,
                onPressed: _busy
                    ? null
                    : () => _run(
                          'dev',
                          () => ref.read(authStateProvider.notifier).signInDev(),
                        ),
              ),
            ],
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              Text(
                ApiConstants.baseUrl,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              l.loginTerms,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2563EB) : const Color(0xFF1A2332),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              filled ? const Color(0xFF3B82F6) : const Color(0xFF1A2332),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: filled
                ? BorderSide.none
                : const BorderSide(color: Color(0x55FFFFFF), width: 1.5),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
