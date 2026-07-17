import 'package:flutter/material.dart';

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
    return const Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.coffee,
              size: 100,
              color: Color(0xFF8B5E34),
            ),

            SizedBox(height: 20),

            Text(
              'Gota',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            CircularProgressIndicator(),

          ],
        ),
      ),
    );
  }
}