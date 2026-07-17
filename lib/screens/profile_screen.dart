import 'package:flutter/material.dart';

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

  Future<void> cerrarSesion() async {
    await AuthService.logout();

    if (!mounted) return;

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

    return 'Usuario de Gota';
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

                Center(
                  child: CircleAvatar(
                    radius: 54,
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
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              )
                            : null,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  usuario.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      usuario.isOwner
                          ? 'Dueño de cafetería'
                          : 'Usuario de Gota',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Nombre'),
                        subtitle: Text(nombre),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(usuario.email),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Tipo de cuenta'),
                        subtitle: Text(
                          usuario.isOwner
                              ? 'Dueño de cafetería'
                              : 'Usuario',
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
              ],
            ),
          );
        },
      ),
    );
  }
}