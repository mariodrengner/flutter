import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_flow/features/quote/state/quote_notifier.dart';
import 'package:habit_flow/features/auth/state/auth/auth_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:habit_flow/core/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;

      final user = ref.read(authProvider);
      print('👤 Current user: ${user?.email ?? "null"}, Guest: ${user?.guestMode ?? false}');

      if (user != null) {
        print('➡️  Navigating to home');
        context.go(AppRoutes.home);
      } else {
        print('➡️  Navigating to login');
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quoteNotifier = ref.watch(quoteProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: const Color.fromRGBO(228, 132, 255, 0.724),
                child: Text(
                  'Willkommen zu Habit Flow',
                  style: GoogleFonts.robotoMono(
                    textStyle: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle_outline, size: 48),
              SizedBox(height: 20),
              quoteNotifier.when(
                data: (data) => Text("${data.quote} - ${data.author}"),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
