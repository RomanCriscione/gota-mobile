import 'dart:io';
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

  Future<void> recuperarContrasena() async {
    final emailRecuperacionController = TextEditingController(
      text: emailController.text.trim(),
    );

    final enviar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Recuperar contraseña',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresá el email de tu cuenta y te enviaremos '
                'un enlace para restablecer tu contraseña.',
              ),

              const SizedBox(height: 16),

              TextField(
                controller: emailRecuperacionController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Enviar enlace'),
            ),
          ],
        );
      },
    );

    if (enviar != true || !mounted) {
      emailRecuperacionController.dispose();
      return;
    }

    final email = emailRecuperacionController.text.trim();

    if (email.isEmpty) {
      emailRecuperacionController.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresá tu email.',
          ),
        ),
      );

      return;
    }

    final emailRegex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      emailRecuperacionController.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresá un email válido.',
          ),
        ),
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final error = await AuthService.recuperarContrasena(
      email: email,
    );

    emailRecuperacionController.dispose();

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Revisá tu correo',
          ),
          content: const Text(
            'Si existe una cuenta asociada a ese email, '
            'te enviamos las instrucciones para restablecer '
            'tu contraseña.\n\n'
            'Si no lo ves en unos minutos, revisá spam o promociones.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

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
    Future<void> ingresarConGoogle() async {
      setState(() {
        cargando = true;
      });

      try {
        final error = await AuthService.loginConGoogle();

        if (!mounted) return;

        if (error == AuthService.googleLoginCancelado) {
          return;
        }

        if (error == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
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

    Future<void> ingresarConApple() async {
      setState(() {
        cargando = true;
      });

      try {
        final error = await AuthService.loginConApple();

        if (!mounted) return;

        if (error == AuthService.googleLoginCancelado) {
          return;
        }

        if (error == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
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
                  autocorrect: false,
                  autofillHints: const [
                    AutofillHints.email,
                  ],
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
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [
                    AutofillHints.password,
                  ],
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

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: recuperarContrasena,
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

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

                const SizedBox(height: 18),

                Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        'o',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed:
                        cargando ? null : ingresarConGoogle,
                    icon: const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                    ),
                    label: const Text(
                      'Continuar con Google',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                                if (Platform.isIOS) ...[
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed:
                          cargando ? null : ingresarConApple,
                      icon: const Icon(
                        Icons.apple,
                        size: 24,
                      ),
                      label: const Text(
                        'Continuar con Apple',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

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