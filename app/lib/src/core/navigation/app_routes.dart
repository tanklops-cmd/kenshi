abstract final class AppRoutes {
  static const today = '/today';
  static const reflect = '/reflect';
  static const newSession = '/reflect/new-session';
  static const sessionDetail = '/reflect/sessions/:sessionId';
  static const momentDetail = '/reflect/sessions/:sessionId/moments/:momentId';
  static const momentVideoPreview =
      '/reflect/sessions/:sessionId/moments/new-video';
  static const newGuidance = '/reflect/sessions/:sessionId/guidance/new';
  static const guidanceDetail =
      '/reflect/sessions/:sessionId/guidance/:guidanceId';
  static const practice = '/practice';
  static const newPracticeTopic = '/practice/new-topic';
  static const practiceTopicDetail = '/practice/topics/:topicId';
  static const learn = '/learn';
  static const learnCategory = '/learn/categories/:category';
  static const learnTopicDetail = '/learn/topics/:topicId';
  static const prepare = '/prepare';
  static const search = '/search';

  static String sessionDetailLocation(String sessionId) {
    return '/reflect/sessions/${Uri.encodeComponent(sessionId)}';
  }

  static String momentDetailLocation({
    required String sessionId,
    required String momentId,
  }) {
    return '/reflect/sessions/${Uri.encodeComponent(sessionId)}'
        '/moments/${Uri.encodeComponent(momentId)}';
  }

  static String momentVideoPreviewLocation(String sessionId) {
    return '/reflect/sessions/${Uri.encodeComponent(sessionId)}'
        '/moments/new-video';
  }

  static String newGuidanceLocation(String sessionId) {
    return '/reflect/sessions/${Uri.encodeComponent(sessionId)}/guidance/new';
  }

  static String guidanceDetailLocation({
    required String sessionId,
    required String guidanceId,
  }) {
    return '/reflect/sessions/${Uri.encodeComponent(sessionId)}'
        '/guidance/${Uri.encodeComponent(guidanceId)}';
  }

  static String practiceTopicDetailLocation(String topicId) {
    return '/practice/topics/${Uri.encodeComponent(topicId)}';
  }

  static String learnCategoryLocation(String category) {
    return '/learn/categories/${Uri.encodeComponent(category)}';
  }

  static String learnTopicDetailLocation(String topicId) {
    return '/learn/topics/${Uri.encodeComponent(topicId)}';
  }
}
