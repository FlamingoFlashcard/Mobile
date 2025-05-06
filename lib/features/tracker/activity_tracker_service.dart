import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ActivityTrackerService {
  int activeSeconds = 0;
  Timer? _activityTimer;
  late SharedPreferences prefs;

  final void Function()? onUpdate;

  ActivityTrackerService({this.onUpdate});

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = prefs.getString('lastActiveDate');
    final savedSeconds = prefs.getInt('activeSeconds') ?? 0;

    if (savedDate == today) {
      activeSeconds = savedSeconds;
    } else {
      await prefs.setString('lastActiveDate', today);
      await prefs.setInt('activeSeconds', 0);
      activeSeconds = 0;
    }
  }

  void startTracking() {
    _activityTimer ??= Timer.periodic(Duration(seconds: 1), (timer) {
      activeSeconds++;
      prefs.setInt('activeSeconds', activeSeconds);
      if (onUpdate != null) onUpdate!();
    });
  }

  void stopTracking() {
    _activityTimer?.cancel();
    _activityTimer = null;
  }

  void dispose() {
    stopTracking();
  }
}
