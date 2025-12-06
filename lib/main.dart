import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/firebase_options.dart';
import 'package:turnament/screens/login_screen.dart';
import 'package:turnament/screens/main_screen.dart';
import 'package:turnament/screens/splash_screen.dart';
import 'package:turnament/services/auth_service.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      debugPrint('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase already initialized');
    }

    await NotificationService().initialize();
    debugPrint('Notification Service initialized');

    // Initialize default data (safe to call repeatedly as it checks existence)
    debugPrint('Initializing default data...');
    // Don't await this to prevent blocking app startup if network is slow
    DatabaseService()
        .initializeDefaultData()
        .then((_) {
          debugPrint('Default data initialized');
        })
        .catchError((e) {
          debugPrint('Error initializing default data: $e');
        });
  } catch (e, stack) {
    debugPrint('Error during initialization: $e');
    debugPrint(stack.toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.error,
            onPrimary: AppColors.onPrimary,
            onSecondary: AppColors.onSecondary,
            onSurface: AppColors.onSurface,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
              .copyWith(
                displayLarge: AppTextStyles.heading1,
                displayMedium: AppTextStyles.heading2,
                bodyLarge: AppTextStyles.bodyLarge,
                bodyMedium: AppTextStyles.bodyMedium,
              ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: AppTextStyles.heading2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black, // Black text on Neon Green
              textStyle: AppTextStyles.button.copyWith(
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.user,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const LoginScreen() : const MainScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
