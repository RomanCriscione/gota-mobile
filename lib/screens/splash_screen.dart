import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {

    final usuario =
        await AuthService.obtenerUsuarioActual();

    if (!mounted) return;

    if (usuario != null) {

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );

    } else {

      Navigator.pushReplacementNamed(
        context,
        '/login',
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              SizedBox(
                width: 96,
                height: 96,
                child: SvgPicture.asset(
                  'assets/icons/rating_cup.svg',
                ),
              ),

            const SizedBox(height: 22),

            const Text(
              'Gota',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172C6D),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Descubrí tu próximo café',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 28),

            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}