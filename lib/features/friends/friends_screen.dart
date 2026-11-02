import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../core/widgets/common.dart';
import '../games/ludo/models/match_setup.dart';

/// Online friends arrive with the backend. Until then this tab explains that
/// and offers the one social mode that works now: pass and play.
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    return SafeArea(
      child: EmptyState(
        icon: Icons.people_alt_rounded,
        title: l10n.friendsOnlineTitle,
        body: l10n.friendsOnlineBody,
        action: FilledButton.icon(
          onPressed: () => Navigator.of(context)
              .pushNamed(AppRoutes.setup, arguments: MatchMode.passAndPlay),
          icon: const Icon(Icons.phone_android_rounded),
          label: Text(l10n.playOnThisDevice),
        ),
      ),
    );
  }
}
