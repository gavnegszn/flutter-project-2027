import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../state/app_state.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/xp_progress_bar.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final ValueChanged<bool> onThemeChanged;
  const ProfileScreen({super.key, required this.onLogout, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final profile = state.profile;
    return Scaffold(
      body: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 22), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your profile', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('Your progress, preferences, and rewards.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))])), IconButton.filledTonal(onPressed: () => _showSettings(context), icon: const Icon(Icons.tune_rounded), tooltip: 'Settings')]))),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverList(delegate: SliverChildListDelegate([
          _ProfileHero(name: profile.name, profile: profile),
          const SizedBox(height: 18),
          Row(children: [Expanded(child: _StatCard(icon: Icons.task_alt_rounded, label: 'Goals completed', value: '${state.completedGoalsCount}', color: const Color(0xFF00A884))), const SizedBox(width: 12), Expanded(child: _StatCard(icon: Icons.account_balance_wallet_rounded, label: 'Total saved', value: '\$${state.totalSavings.toStringAsFixed(0)}', color: const Color(0xFFFF9F1C)))]),
          const SizedBox(height: 30),
          Row(children: [Text('Achievements', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const Spacer(), Text('${state.achievements.where((item) => item.isUnlocked).length}/${state.achievements.length} unlocked', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 12),
          ...state.achievements.map((achievement) => Padding(padding: const EdgeInsets.only(bottom: 12), child: AchievementBadge(achievement: achievement))),
          const SizedBox(height: 24),
        ]))),
      ]),
    );
  }

  void _showSettings(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Settings', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('Personalize your experience and manage your account.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 18),
            _SettingTile(icon: Icons.dark_mode_outlined, title: 'Dark mode', subtitle: 'Use a softer appearance at night', trailing: Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: (value) { onThemeChanged(value); Navigator.pop(sheetContext); })),
            const SizedBox(height: 8),
            _SettingTile(icon: Icons.account_circle_outlined, title: 'Account', subtitle: 'Signed in securely on this device', trailing: const Icon(Icons.verified_rounded, color: Color(0xFF00A884))),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(onPressed: () async { await AuthService.signOut(); if (sheetContext.mounted) Navigator.pop(sheetContext); onLogout(); }, icon: const Icon(Icons.logout_rounded), label: const Text('Sign out')),
          ]),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget { final String name; final dynamic profile; const _ProfileHero({required this.name, required this.profile}); @override Widget build(BuildContext context) { final theme = Theme.of(context); final scheme = theme.colorScheme; return Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(colors: [scheme.primary, scheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: .22), blurRadius: 22, offset: const Offset(0, 10))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 58, height: 58, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle), child: Text(name.isEmpty ? 'U' : name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text('Financial trailblazer', style: TextStyle(color: Colors.white.withValues(alpha: .75), fontWeight: FontWeight.w600))]))]), const SizedBox(height: 24), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)), child: Theme(data: theme.copyWith(colorScheme: scheme.copyWith(primary: Colors.white, onSurface: Colors.white, onSurfaceVariant: Colors.white70, primaryContainer: Colors.white24)), child: XpProgressBar(profile: profile)))])); } }
class _StatCard extends StatelessWidget { final IconData icon; final String label; final String value; final Color color; const _StatCard({required this.icon, required this.label, required this.value, required this.color}); @override Widget build(BuildContext context) { final theme = Theme.of(context); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .45))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)), const SizedBox(height: 18), Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700))])); } }
class _SettingTile extends StatelessWidget { final IconData icon; final String title, subtitle; final Widget trailing; const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.trailing}); @override Widget build(BuildContext context) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .38), leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: trailing); }
