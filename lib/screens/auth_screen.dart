import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final ValueChanged<String> onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() { _name.dispose(); _username.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    final result = _register
        ? await AuthService.register(_name.text, _username.text, _email.text, _password.text)
        : await AuthService.signIn(_username.text, _password.text);
    if (!mounted) return;
    if (result == null || result == 'EXISTS') {
      setState(() { _busy = false; _error = result == 'EXISTS' ? 'That username or email is already in use.' : 'We could not find a matching account.'; });
      return;
    }
    widget.onAuthenticated(result);
  }

  void _switchMode() => setState(() { _register = !_register; _error = null; _form.currentState?.reset(); });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    final scheme = theme.colorScheme;
    final form = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
        decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .98), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withValues(alpha: .15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .14), blurRadius: 36, offset: const Offset(0, 16))]),
        child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _BrandMark(color: scheme.primary),
          const SizedBox(height: 22),
          Text(_register ? 'Create your account' : 'Welcome back', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(_register ? 'Build better money habits, one step at a time.' : 'Sign in to continue your financial journey.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.45)),
          const SizedBox(height: 28),
          if (_register) ...[_field(controller: _name, label: 'Full name', icon: Icons.person_outline_rounded, validator: (value) => value == null || value.trim().length < 2 ? 'Enter your name' : null), const SizedBox(height: 14)],
          _field(controller: _username, label: _register ? 'Username' : 'Username or email', icon: Icons.alternate_email_rounded, validator: (value) => value == null || value.trim().length < 3 ? 'Enter a valid username or email' : null),
          if (_register) ...[const SizedBox(height: 14), _field(controller: _email, label: 'Email address', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email address' : null)],
          const SizedBox(height: 14),
          _field(controller: _password, label: 'Password', icon: Icons.lock_outline_rounded, obscure: _obscure, suffix: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)), validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 14), child: _InlineError(text: _error!)),
          const SizedBox(height: 22),
          FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_register ? 'Create account' : 'Sign in'), const SizedBox(width: 8), const Icon(Icons.arrow_forward_rounded, size: 19)])),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: Divider(color: scheme.outlineVariant.withValues(alpha: .7))), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.2))), Expanded(child: Divider(color: scheme.outlineVariant.withValues(alpha: .7)))]),
          TextButton(onPressed: _busy ? null : _switchMode, child: Text(_register ? 'Already have an account?  Sign in' : 'New here?  Create an account', style: const TextStyle(fontWeight: FontWeight.w800))),
        ])),
      ),
    );
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [scheme.primary.withValues(alpha: .93), scheme.secondary.withValues(alpha: .92)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: SafeArea(child: Stack(children: [Positioned(top: -120, right: -70, child: _Glow(color: Colors.white.withValues(alpha: .12), size: 300)), Positioned(bottom: -140, left: -80, child: _Glow(color: Colors.white.withValues(alpha: .09), size: 310)), Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: isWide ? Row(mainAxisSize: MainAxisSize.min, children: [_AuthPitch(theme: theme), const SizedBox(width: 54), form]) : form))]))));
  }

  Widget _field({required TextEditingController controller, required String label, required IconData icon, required String? Function(String?) validator, TextInputType? keyboardType, bool obscure = false, Widget? suffix}) => TextFormField(controller: controller, keyboardType: keyboardType, obscureText: obscure, validator: validator, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), suffixIcon: suffix));
}

class _BrandMark extends StatelessWidget { final Color color; const _BrandMark({required this.color}); @override Widget build(BuildContext context) => Center(child: Container(width: 62, height: 62, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Icon(Icons.auto_graph_rounded, color: color, size: 34))); }
class _InlineError extends StatelessWidget { final String text; const _InlineError({required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.error), const SizedBox(width: 9), Expanded(child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.w600)))])); }
class _Glow extends StatelessWidget { final Color color; final double size; const _Glow({required this.color, required this.size}); @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)); }
class _AuthPitch extends StatelessWidget { final ThemeData theme; const _AuthPitch({required this.theme}); @override Widget build(BuildContext context) => SizedBox(width: 330, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.savings_rounded, size: 52, color: Colors.white), const SizedBox(height: 20), Text('A clearer way\nto grow your money.', style: theme.textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1.05)), const SizedBox(height: 18), Text('Track your spending, protect your progress, and turn financial goals into daily wins.', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: .83), height: 1.45)), const SizedBox(height: 26), const _PitchLine(icon: Icons.check_circle_rounded, text: 'Your data stays tied to your account'), const _PitchLine(icon: Icons.check_circle_rounded, text: 'Gamified progress that keeps you moving'), const _PitchLine(icon: Icons.check_circle_rounded, text: 'Light and dark modes for every moment')])) ; }
class _PitchLine extends StatelessWidget { final IconData icon; final String text; const _PitchLine({required this.icon, required this.text}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))) ])); }
