// app_state.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  List<String> _alarmTimes = [];
  int _batteryThreshold = 20;

  List<String> get alarmTimes => _alarmTimes;
  int get batteryThreshold => _batteryThreshold;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _alarmTimes = prefs.getStringList('alarm_times') ?? [];
    _batteryThreshold = prefs.getInt('battery_threshold') ?? 20;
    notifyListeners();
  }

  void setAlarmTimes(List<String> times) async {
    _alarmTimes = times;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('alarm_times', _alarmTimes);
    notifyListeners();
  }

  void addAlarmTime(String time) async {
    if (!_alarmTimes.contains(time)) {
      _alarmTimes.add(time);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('alarm_times', _alarmTimes);
      notifyListeners();
    }
  }

  void removeAlarmTime(String time) async {
    _alarmTimes.remove(time);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('alarm_times', _alarmTimes);
    notifyListeners();
  }

  void clearAlarms() async {
    _alarmTimes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alarm_times');
    notifyListeners();
  }

  void setBatteryThreshold(int value) async {
    _batteryThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('battery_threshold', value);
    notifyListeners();
  }
}