import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../friends/friends_screen.dart';
import '../games/game_catalog/games_screen.dart';
import '../leaderboards/leaderboards_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Bottom navigation: Home, Games, Friends, Rankings, Profile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  void _select(int index) {
    if (index == _tab) {
      return;
    }
    context.services.feedback.button();
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: <Widget>[
          HomeScreen(onOpenTab: _select),
          const GamesScreen(),
          const FriendsScreen(),
          const LeaderboardsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _select,
        destinations: <NavigationDestination>[
          NavigationDestination(
              icon: const Icon(Icons.home_rounded), label: l10n.navHome),
          NavigationDestination(
              icon: const Icon(Icons.grid_view_rounded), label: l10n.navGames),
          NavigationDestination(
              icon: const Icon(Icons.people_alt_rounded),
              label: l10n.navFriends),
          NavigationDestination(
              icon: const Icon(Icons.leaderboard_rounded),
              label: l10n.navRankings),
          NavigationDestination(
              icon: const Icon(Icons.person_rounded), label: l10n.navProfile),
        ],
      ),
    );
  }
}

/// Tab indices, so screens can link to each other.
abstract final class HomeTabs {
  static const int home = 0;
  static const int games = 1;
  static const int friends = 2;
  static const int rankings = 3;
  static const int profile = 4;
}
