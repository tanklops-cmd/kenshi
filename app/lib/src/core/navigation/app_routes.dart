abstract final class AppRoutes {
  static const today = '/today';
  static const reflect = '/reflect';
  static const newSession = '/reflect/new-session';
  static const sessionDetail = '/reflect/sessions/:sessionId';
  static const practice = '/practice';
  static const newPracticeTopic = '/practice/new-topic';
  static const practiceTopicDetail = '/practice/topics/:topicId';
  static const learn = '/learn';
  static const prepare = '/prepare';

  static String sessionDetailLocation(String sessionId) {
    return '/reflect/sessions/${Uri.encodeComponent(sessionId)}';
  }

  static String practiceTopicDetailLocation(String topicId) {
    return '/practice/topics/${Uri.encodeComponent(topicId)}';
  }
}
