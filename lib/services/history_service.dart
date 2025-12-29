import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';

class HistoryService {
  static const String _key = 'scan_history';

  static Future<void> saveScan(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];

    history.add(jsonEncode(result.toJson()));
    await prefs.setStringList(_key, history);
  }

  static Future<List<ScanResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];

    return history
        .map((item) => ScanResult.fromJson(jsonDecode(item)))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
