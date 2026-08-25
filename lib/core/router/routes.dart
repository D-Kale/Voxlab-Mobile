class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String map = '/map';
  static const String practice = '/practice';
  static const String analyze = '/analyze';
  static const String profile = '/profile';
  static const String track = '/track/:id';
  static const String module = '/module/:id';
  static const String lesson = '/lesson/:id';
  static const String exercise = '/exercise/:id';
  static const String exerciseComplete = '/exercise/complete';
  static const String authWall = '/auth-wall';
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static String trackPath(int id) => '/track/$id';
  static String modulePath(int id) => '/module/$id';
  static String lessonPath(int id) => '/lesson/$id';
  static String exercisePath(String id) => '/exercise/$id';
}
