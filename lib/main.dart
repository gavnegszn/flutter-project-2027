import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  bool _dark = false;

  ThemeData _theme(Brightness brightness) {
    const seed = Color(0xFF5B5CEB);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: brightness == Brightness.light ? seed : const Color(0xFFB9B9FF),
      secondary: brightness == Brightness.light ? const Color(0xFF00A9A5) : const Color(0xFF6EE7E2),
      surface: brightness == Brightness.light ? const Color(0xFFF9FAFF) : const Color(0xFF11131C),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
    return base.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF5F6FC) : const Color(0xFF0B0D14),
      textTheme: base.textTheme.apply(fontFamily: 'Segoe UI'),
      cardTheme: CardThemeData(color: scheme.surface, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light ? const Color(0xFFF6F7FB) : const Color(0xFF1A1D28),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: .55))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.primary, width: 1.7)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: BorderSide(color: scheme.outlineVariant))),
      navigationBarTheme: NavigationBarThemeData(height: 76, elevation: 0, backgroundColor: scheme.surface, indicatorColor: scheme.primaryContainer, labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 11, fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600))),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Gamified',
      debugShowCheckedModeBanner: false,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: _AuthGate(onThemeChanged: (value) => setState(() => _dark = value)),
    );
  }
}

class _AuthGate extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  const _AuthGate({required this.onThemeChanged});
  @override State<_AuthGate> createState() => _AuthGateState();
}
class _AuthGateState extends State<_AuthGate> {
  String? _name;
  String? _username;
  bool _loading = true;
  final Map<String, AppState> _states = {};
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    if (await AuthService.isLoggedIn()) {
      _name = await AuthService.currentName();
      _username = AuthService.currentUser;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _startSession(String name) async {
    final username = AuthService.currentUser;
    if (!mounted) return;
    setState(() {
      _name = name;
      _username = username;
    });
  }
  @override Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_name == null) return AuthScreen(onAuthenticated: _startSession);
    final key = _username ?? _name!;
    final state = _states.putIfAbsent(key, () => AppState(userName: _name, persistenceKey: key));
    if (AuthService.lastRegistration) state.persist();
    state.loadSaved(key);
    return AppStateProvider(notifier: state, child: MainNavigationScreen(onLogout: () => setState(() { _name = null; _username = null; }), onThemeChanged: widget.onThemeChanged));
  }
}
