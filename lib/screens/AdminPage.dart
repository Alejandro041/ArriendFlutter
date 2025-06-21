import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  final Color azul = Colors.blue.shade600;

  AdminPage({super.key});

  void _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double alturaPantalla = MediaQuery.of(context).size.height;
    final double alturaBoton = alturaPantalla * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      appBar: AppBar(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        title: const Text("Panel de Administrador"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _botonAdmin(
              context,
              icono: Icons.people_alt,
              texto: "Gestionar Usuarios",
              ruta: '/AdminUsersPage',
              altura: alturaBoton,
            ),
            _botonAdmin(
              context,
              icono: Icons.assignment_ind,
              texto: "Solicitudes de Arrendador",
              ruta: '/AdminSolicityPage',
              altura: alturaBoton,
            ),
            _botonAdmin(
              context,
              icono: Icons.home_work_outlined,
              texto: "Gestionar Propiedades",
              ruta: '/AdminPropertyPage',
              altura: alturaBoton,
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonAdmin(BuildContext context,
      {required IconData icono,
      required String texto,
      required String ruta,
      required double altura}) {
    return SizedBox(
      width: double.infinity,
      height: altura,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, ruta),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 48, color: azul),
            const SizedBox(height: 12),
            Text(
              texto,
              style: TextStyle(fontSize: 18, color: azul, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
