import 'package:go_router/go_router.dart';
import 'package:habit_flow/features/splash/ui/screens/splash_screen.dart';
import 'package:habit_flow/features/habits/ui/screens/home_screen.dart';
import 'package:habit_flow/features/auth/ui/screens/login_screen.dart';
import 'package:habit_flow/features/auth/ui/screens/register_screen.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
