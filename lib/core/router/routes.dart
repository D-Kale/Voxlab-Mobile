class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String map = '/map';
  static const String practice = '/practice';
  static const String game = '/practice/game/:slug';
  static const String analyze = '/analyze';
  static const String profile = '/profile';
  static const String exercise = '/exercise/:id';
  static const String exerciseComplete = '/exercise/complete';
  static const String authWall = '/auth-wall';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static String exercisePath(String id) => '/exercise/$id';

  static String gamePath(String slug) => '/practice/game/$slug';
}
