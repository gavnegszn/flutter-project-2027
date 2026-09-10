import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String? _username, _name;
  static bool _loggedIn = false;
  static bool _lastRegistration = false;
  static String? get currentUser => _username;
  static bool get lastRegistration => _lastRegistration;

  static Future<void> _saveAccounts(SharedPreferences p, Map<String, dynamic> data) async => p.setString('accounts', data.entries.map((e) => '${e.key}|${e.value['name']}|${e.value['password']}|${e.value['email'] ?? ''}').join('\n'));
  static Future<String?> signIn(String identifier, String password) async {
    final p = await SharedPreferences.getInstance();
    final key = identifier.trim().toLowerCase();
    final rows = (p.getString('accounts') ?? '').split('\n');
    for (final row in rows) { final parts = row.split('|'); if (parts.length >= 3 && (parts[0] == key || (parts.length >= 4 && parts[3] == key)) && parts[2] == password) { _username = parts[0]; _name = parts[1]; _loggedIn = true; _lastRegistration = false; await p.setBool('logged_in', true); await p.setString('current_user', _username!); await p.setString('current_name', _name!); return _name; } }
    return null;
  }
  static Future<String?> register(String name, String username, String email, String password) async {
    final p = await SharedPreferences.getInstance();
    final key = username.trim().toLowerCase();
    final accounts = <String, dynamic>{};
    for (final row in (p.getString('accounts') ?? '').split('\n')) { final x = row.split('|'); if (x.length >= 3) accounts[x[0]] = {'name': x[1], 'password': x[2], 'email': x.length >= 4 ? x[3] : ''}; }
    if (accounts.containsKey(key) || accounts.values.any((a) => a['email'] == email.trim().toLowerCase())) return 'EXISTS';
    accounts[key] = {'name': name.trim(), 'password': password, 'email': email.trim().toLowerCase()};
    await _saveAccounts(p, accounts);
    _username = key; _name = name.trim(); _loggedIn = true; _lastRegistration = true; await p.setBool('logged_in', true); await p.setString('current_user', key); await p.setString('current_name', _name!);
    return _name;
  }
  static Future<String?> currentName() async => _name;
  static Future<void> signOut() async { _loggedIn = false; final p = await SharedPreferences.getInstance(); await p.setBool('logged_in', false); }
  static Future<bool> isLoggedIn() async { final p = await SharedPreferences.getInstance(); _loggedIn = p.getBool('logged_in') ?? false; if (_loggedIn) { _username = p.getString('current_user'); _name = p.getString('current_name'); } return _loggedIn; }
}
