abstract final class AppRoutes {
  static const today = '/today';
  static const reflect = '/reflect';
  static const newSession = '/reflect/new-session';
  static const sessionDetail = '/reflect/sessions/:sessionId';
  static const practice = '/practice';
  static const learn = '/learn';
  static const prepare = '/prepare';

  static String sessionDetailLocation(String sessionId) {
    return '/reflect/sessions/${Uri.encodeComponent(sessionId)}';
  }
}
