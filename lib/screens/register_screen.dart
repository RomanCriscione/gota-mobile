import 'package:flutter/material.dart';

import '../services/auth_service.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool cargando = false;
  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;

  Future<void> crearCuenta() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completá todos los campos',
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
            'Ingresá un email válido',
          ),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener al menos 8 caracteres',
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas no coinciden',
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
      final error = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (error == null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
      }
    } catch (_) {
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

  Future<void> crearCuentaConGoogle() async {
    setState(() {
      cargando = true;
    });

    try {
      final error =
          await AuthService.loginConGoogle();

      if (!mounted) return;

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Crear una cuenta',
        ),
      ),
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
                  width: 150,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Sumate a Gota',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Guardá, descubrí y recomendá cafeterías',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 36),

                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: ocultarPassword,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [
                    AutofillHints.newPassword,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    helperText: 'Mínimo 8 caracteres',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarPassword = !ocultarPassword;
                        });
                      },
                      icon: Icon(
                        ocultarPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: ocultarConfirmacion,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [
                    AutofillHints.newPassword,
                  ],
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();

                    if (!cargando) {
                      crearCuenta();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Repetir contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarConfirmacion = !ocultarConfirmacion;
                        });
                      },
                      icon: Icon(
                        ocultarConfirmacion
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: cargando ? null : crearCuenta,
                    child: cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 16,
                            ),
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
                        cargando ? null : crearCuentaConGoogle,
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

                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: cargando
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'Ya tengo una cuenta',
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