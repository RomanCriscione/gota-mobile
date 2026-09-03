import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> usuarioFuture;

  @override
  void initState() {
    super.initState();
    usuarioFuture = AuthService.obtenerUsuarioActual();
  }

  Future<void> recargarPerfil() async {
    setState(() {
      usuarioFuture = AuthService.obtenerUsuarioActual();
    });

    await usuarioFuture;
  }

  Future<void> abrirFlujoCafeteria(User usuario) async {
    if (usuario.isOwner) {
      Navigator.pushNamed(
        context,
        '/create-cafe',
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            '¿Tenés una cafetería?',
          ),
          content: const Text(
            'Al continuar, tu cuenta de Gota se configurará '
            'como cuenta de dueño para que puedas sumar '
            'tu cafetería.',
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
              child: const Text(
                'Continuar como dueño',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    final convertido =
        await AuthService.convertirEnDueno();

    if (!mounted) return;

    if (!convertido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pudimos configurar tu cuenta. '
            'Intentá nuevamente.',
          ),
        ),
      );
      return;
    }

    await recargarPerfil();

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      '/create-cafe',
    );
  }

Future<void> cerrarSesion() async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          '¿Cerrar sesión?',
        ),
        content: const Text(
          'Vas a tener que volver a ingresar para usar tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                false,
              );
            },
            child: const Text(
              'Cancelar',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            child: const Text(
              'Cerrar sesión',
            ),
          ),
        ],
      );
    },
  );

  if (confirmar != true || !mounted) {
    return;
  }

  await AuthService.logout();

  if (!mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}

Future<void> eliminarCuenta() async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          'Esta acción es permanente. Se eliminará tu cuenta de Gota '
          'y no vas a poder recuperarla.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Eliminar cuenta'),
          ),
        ],
      );
    },
  );

  if (confirmar != true || !mounted) {
    return;
  }

  final eliminado = await AuthService.eliminarCuenta();

  if (!mounted) return;

  if (!eliminado) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No pudimos eliminar tu cuenta. Intentá nuevamente.',
        ),
      ),
    );

    return;
  }

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}

  String obtenerNombre(User usuario) {
    final nombreCompleto = [
      usuario.firstName.trim(),
      usuario.lastName.trim(),
    ].where((parte) => parte.isNotEmpty).join(' ');

    if (nombreCompleto.isNotEmpty) {
      return nombreCompleto;
    }

    if (usuario.email.trim().isNotEmpty) {
      return usuario.email;
    }

    return 'Gota';
    }

  Future<void> abrirEnlace(String url) async {
    final uri = Uri.parse(url);

    final abierto = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pudimos abrir el enlace.',
          ),
        ),
      );
    }
  }

  Future<void> abrirEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'hola@gogota.ar',
      queryParameters: {
        'subject': 'Contacto desde Gota',
      },
    );

    final abierto = await launchUrl(uri);

    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pudimos abrir tu aplicación de correo.',
          ),
        ),
      );
    }
  }

  Future<void> mostrarEditarPerfil(User usuario) async {
    final firstNameController = TextEditingController(
      text: usuario.firstName,
    );

    final lastNameController = TextEditingController(
      text: usuario.lastName,
    );

    

    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (guardar != true || !mounted) {
      firstNameController.dispose();
      lastNameController.dispose();
      return;
    }

    final error = await AuthService.actualizarPerfil(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
    );

    firstNameController.dispose();
    lastNameController.dispose();

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
      return;
    }

    await recargarPerfil();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Perfil actualizado.',
        ),
      ),
    );
    }

    Future<void> mostrarCambiarContrasena() async {
      final currentPasswordController =
          TextEditingController();

      final newPasswordController =
          TextEditingController();

      final confirmPasswordController =
          TextEditingController();

      final guardar = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Cambiar contraseña',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText:
                        'Contraseña actual',
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller:
                      newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText:
                        'Nueva contraseña',
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller:
                      confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText:
                        'Repetir nueva contraseña',
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
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );

      if (guardar != true || !mounted) {
        currentPasswordController.dispose();
        newPasswordController.dispose();
        confirmPasswordController.dispose();
        return;
      }

      final error =
          await AuthService.cambiarContrasena(
        currentPassword:
            currentPasswordController.text,
        newPassword:
            newPasswordController.text,
        confirmPassword:
            confirmPasswordController.text,
      );

      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contraseña actualizada.',
          ),
        ),
      );
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<User?>(
        future: usuarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.black45,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No pudimos cargar tu perfil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Revisá tu conexión e intentá nuevamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: recargarPerfil,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final usuario = snapshot.data!;
          final nombre = obtenerNombre(usuario);

          return RefreshIndicator(
            onRefresh: recargarPerfil,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFE8EEF9),
                          backgroundImage:
                              usuario.avatar != null &&
                                      usuario.avatar!.trim().isNotEmpty
                                  ? NetworkImage(usuario.avatar!)
                                  : null,
                          child:
                              usuario.avatar == null ||
                                      usuario.avatar!.trim().isEmpty
                                  ? Text(
                                      nombre.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    )
                                  : null,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        usuario.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          usuario.isOwner
                              ? 'Dueño de cafetería'
                              : 'Usuario de Gota',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF172C6D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tu cuenta',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),

                          TextButton.icon(
                            onPressed: () {
                              mostrarEditarPerfil(usuario);
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                            ),
                            label: const Text('Editar'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _ProfileInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: usuario.email,
                      ),

                      const SizedBox(height: 14),

                      _ProfileInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Tipo de cuenta',
                        value: usuario.isOwner
                            ? 'Dueño de cafetería'
                            : 'Usuario de Gota',
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: mostrarCambiarContrasena,
                          icon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          label: const Text(
                            'Cambiar contraseña',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_cafe_outlined,
                            color: Color(0xFF1E3A8A),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              usuario.isOwner
                                  ? 'Tu cafetería en Gota'
                                  : '¿Tenés una cafetería?',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF172C6D),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        usuario.isOwner
                            ? 'Sumá tu cafetería y hacé que forme parte '
                                'del mapa cafetero de Gota.'
                            : 'Sumá tu cafetería a Gota y hacé que más '
                                'personas puedan descubrirla.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF4B5563),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            abrirFlujoCafeteria(usuario);
                          },
                          icon: Icon(
                            usuario.isOwner
                                ? Icons.add
                                : Icons.storefront_outlined,
                          ),
                          label: Text(
                            usuario.isOwner
                                ? 'Sumar cafetería'
                                : 'Soy dueño de una cafetería',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                        
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sobre Gota',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 10),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF1E3A8A),
                        ),
                        title: const Text('Sitio web'),
                        subtitle: const Text('gogota.ar'),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                        ),
                        onTap: () {
                          abrirEnlace(
                            'https://gogota.ar',
                          );
                        },
                      ),

                      const Divider(),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF1E3A8A),
                        ),
                        title: const Text('Instagram'),
                        subtitle: const Text('@app.gota'),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                        ),
                        onTap: () {
                          abrirEnlace(
                            'https://www.instagram.com/app.gota/',
                          );
                        },
                      ),

                      const Divider(),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xFF1E3A8A),
                        ),
                        title: const Text('Contacto'),
                        subtitle: const Text(
                          'hola@gogota.ar',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                        ),
                        onTap: abrirEmail,
                      ),

                      const Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.privacy_tip_outlined,
            color: Color(0xFF1E3A8A),
          ),
          title: const Text(
            'Política de privacidad',
          ),
          trailing: const Icon(
            Icons.open_in_new_rounded,
            size: 18,
          ),
          onTap: () {
            abrirEnlace(
              'https://gogota.ar/privacidad/',
            );
          },
        ),

        const Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.description_outlined,
            color: Color(0xFF1E3A8A),
          ),
          title: const Text(
            'Términos y condiciones',
          ),
          trailing: const Icon(
            Icons.open_in_new_rounded,
            size: 18,
          ),
          onTap: () {
            abrirEnlace(
              'https://gogota.ar/terminos/',
            );
          },
        ),

        const Divider(),

        const Padding(
          padding: EdgeInsets.only(
            top: 8,
            bottom: 2,
          ),
          child: Center(
            child: Text(
              'Gota · versión 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ),
        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: cerrarSesion,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton.icon(
                    onPressed: eliminarCuenta,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFB91C1C),
                    ),
                    label: const Text(
                      'Eliminar cuenta',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF1E3A8A),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}