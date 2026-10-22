import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);
  final SharedPreferences _prefs;
  @override
  String? read(String key) => _prefs.getString(key);
  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
}
