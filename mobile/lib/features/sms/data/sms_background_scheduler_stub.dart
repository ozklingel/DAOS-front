/// No-op background SMS scheduler (web / unsupported platforms).
class SmsBackgroundScheduler {
  static Future<void> initialize({required bool debug}) async {}

  static Future<void> schedulePeriodic() async {}

  static Future<void> cancel() async {}
}
