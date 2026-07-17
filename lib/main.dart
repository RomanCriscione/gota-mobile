import 'screens/nearby_cafes_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cafes_screen.dart';
import 'screens/my_map_screen.dart';
import 'services/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppState.cargarDatos();

  runApp(const GotaApp());
}

class GotaApp extends StatelessWidget {
  const GotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Gota',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
        ),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/cafes': (context) => const CafesScreen(),
        '/my-map': (context) => const MyMapScreen(),
        '/nearby': (context) => const NearbyCafesScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}