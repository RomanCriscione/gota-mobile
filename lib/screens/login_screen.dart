import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  bool cargando = false;

  Future<void> ingresar() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completá el email y la contraseña',
          ),
        ),
      );
      return;
    }

    final emailRegex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresá un email válido.',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      cargando = true;
    });

    try {
      final ok = await AuthService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (ok) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email o contraseña incorrectos',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pudimos conectarnos. Intentá nuevamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 20,
            ),
            child: Column(
              children: [

                Image.asset(
                  'assets/images/logo.png',
                  width: 170,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Bienvenido a Gota',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Descubrí tu próximo café',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 42),

                TextField(
                  controller: emailController,
                  focusNode: emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(
                      passwordFocus,
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();

                    if (!cargando) {
                      ingresar();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: cargando ? null : ingresar,
                    child: cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Ingresar',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(
                      Icons.login,
                    ),
                    label: const Text(
                      'Continuar con Google · Próximamente',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/register',
                    );
                  },
                  child: const Text(
                    'Crear una cuenta',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}