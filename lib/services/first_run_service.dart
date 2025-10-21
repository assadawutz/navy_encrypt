import 'package:shared_preferences/shared_preferences.dart';

class FirstRunService {
  static const String _firstRunKey = 'first_run_completed';

  const FirstRunService();

  Future<bool> consumeFirstRunFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasCompleted = prefs.getBool(_firstRunKey) ?? false;
    if (hasCompleted) {
      return false;
    }

    await prefs.setBool(_firstRunKey, true);
    return true;
  }
}
