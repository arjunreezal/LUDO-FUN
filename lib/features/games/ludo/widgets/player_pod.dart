import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/common.dart';
import '../models/ludo_constants.dart';
import '../models/player_seat.dart';

/// One seat's card beside the board: who it is, how many tokens are home,
/// whether it is their turn and their final place.
class PlayerPod extends StatelessWidget {
  const PlayerPod({
    super.key,
    required this.seat,
    required this.subtitle,
    required this.tokensHome,
    required this.active,
    required this.placementLabel,
    this.alignEnd = false,
  });

  final PlayerSeat seat;
  final String subtitle;
  final int tokensHome;
  final bool active;
  final String? placementLabel;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seatColor = LudoPalette.seat(seat.color);
    final avatar = PlayerAvatar(
      name: seat.name,
      color: seatColor,
      size: 38,
      icon: seat.isComputer ? Icons.smart_toy_rounded : null,
    );
    final details = Flexible(
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            seat.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var i = 0; i < LudoConstants.tokensPerPlayer; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < tokensHome
                        ? seatColor
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  placementLabel ?? subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: placementLabel != null
                        ? seatColor
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        placementLabel != null ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? seatColor.withValues(alpha: 0.16)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? seatColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignEnd
            ? <Widget>[details, const SizedBox(width: 10), avatar]
            : <Widget>[avatar, const SizedBox(width: 10), details],
      ),
    );
  }
}
