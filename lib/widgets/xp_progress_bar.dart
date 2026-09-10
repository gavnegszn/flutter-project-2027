import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class XpProgressBar extends StatelessWidget {
  final UserProfile profile;

  const XpProgressBar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMax = profile.level >= 6;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  'Level ${profile.level}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              isMax ? 'MAX LEVEL' : '${profile.xp} / ${profile.xpRequiredForNextLevel} XP',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: LinearProgressIndicator(value: profile.levelProgress, minHeight: 12, backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: .5), valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary))),
          if (profile.levelProgress > .16) Positioned.fill(child: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 7), child: Text('${(profile.levelProgress * 100).round()}%', style: TextStyle(fontSize: 9, color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w900))))),
        ]),
      ],
    );
  }
}
