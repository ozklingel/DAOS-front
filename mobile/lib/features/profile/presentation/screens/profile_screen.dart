import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/features/hub/presentation/providers/hub_providers.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/widgets/daos_page_scaffold.dart';
import 'package:taskmail/shared/widgets/hub_menu_card.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => DaosPageScaffold(
        title: l.profileTitle,
        searchHint: l.searchBar,
        showSearch: false,
        body: const ShimmerLoading(itemCount: 4),
      ),
      error: (e, _) => DaosPageScaffold(
        title: l.profileTitle,
        searchHint: l.searchBar,
        showSearch: false,
        body: ErrorView(error: e, onRetry: () => ref.invalidate(profileProvider)),
      ),
      data: (profile) => DaosPageScaffold(
        title: l.profileTitle,
        searchHint: l.searchBar,
        showSearch: false,
        showBack: true,
        avatarInitial: profile.fullName,
        avatarUrl: profile.avatarUrl,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundImage:
                    profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                child: profile.avatarUrl == null
                    ? Text(
                        profile.fullName.substring(0, 1),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            HubMenuCard(
              title: l.personalDetails,
              icon: Icons.person_outline,
              subtitleLines: [
                '${l.fullNameLabel}: ${profile.fullName}',
                '${l.dateOfBirthLabel}: ${profile.dateOfBirth}',
                '${l.emailLabel}: ${profile.email}',
              ],
            ),
            const SizedBox(height: 12),
            HubMenuCard(
              title: l.accountSettings,
              icon: Icons.settings_outlined,
              subtitleLines: [
                '${l.usernameLabel}: ${profile.username}',
                '${l.twoFactorLabel}: ${profile.twoFactorEnabled ? l.enabled : l.disabled}',
              ],
            ),
            const SizedBox(height: 12),
            HubMenuCard(
              title: l.subscriptionDetails,
              icon: Icons.diamond_outlined,
              subtitleLines: [
                profile.subscriptionPlan,
                '${l.expiresLabel}: ${profile.subscriptionExpires}',
              ],
            ),
            const SizedBox(height: 12),
            HubMenuCard(
              title: l.securitySection,
              icon: Icons.shield_outlined,
              subtitleLines: [l.changePassword, l.connectedDevices],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.comingSoon)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
