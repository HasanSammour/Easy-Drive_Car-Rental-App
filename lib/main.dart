import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:easydrive/providers/auth_provider.dart';
import 'package:easydrive/providers/car_provider.dart';
import 'package:easydrive/services/firebase_service.dart';
import 'package:easydrive/screens/auth/login_screen.dart';
import 'package:easydrive/screens/customer/home_screen.dart';
import 'package:easydrive/utils/theme.dart';

import 'screens/admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EasyDrive',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

// Update the AuthWrapper widget in main.dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.user != null) {
      return authProvider.user!.isAdmin 
          ? const AdminHomeScreen()
          : const HomeScreen();
    }

    return const LoginScreen();
  }
}