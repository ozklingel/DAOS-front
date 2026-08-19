import 'package:flutter/material.dart';
import 'package:daos/l10n/app_localizations.dart';
import 'package:daos/theme/app_colors.dart';

/// Branded DAOS logo — used on splash and home loading states.
class DaosLogo extends StatefulWidget {
  const DaosLogo({
    super.key,
    this.size = 96,
    this.showTitle = true,
    this.showTagline = false,
    this.animate = true,
  });

  final double size;
  final bool showTitle;
  final bool showTagline;
  final bool animate;

  @override
  State<DaosLogo> createState() => _DaosLogoState();
}

class _DaosLogoState extends State<DaosLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulse = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.35, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final iconSize = widget.size * 0.46;
    final radius = widget.size * 0.26;

    Widget mark = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA), Color(0xFF38BDF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: iconSize * 0.55),
          Positioned(
            bottom: widget.size * 0.18,
            right: widget.size * 0.2,
            child: Icon(Icons.task_alt_rounded, color: Colors.white.withValues(alpha: 0.92), size: iconSize * 0.42),
          ),
        ],
      ),
    );

    if (widget.animate) {
      mark = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulse.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: _glow.value),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: mark,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        if (widget.showTitle) ...[
          SizedBox(height: widget.size * 0.28),
          Text(
            l.appTitle,
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: widget.size * 0.34,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ],
        if (widget.showTagline) ...[
          const SizedBox(height: 8),
          Text(
            l.splashTagline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class DashboardLoadingView extends StatelessWidget {
  const DashboardLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DaosLogo(size: 108, showTitle: true, showTagline: true),
            const SizedBox(height: 36),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              l.loadingDashboard,
              style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
