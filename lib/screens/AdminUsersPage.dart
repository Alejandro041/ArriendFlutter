import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  Future<void> eliminarUsuario(BuildContext context, String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Confirmar eliminación?"),
        content: const Text("Esta acción eliminará al usuario y sus propiedades."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    final props = await FirebaseFirestore.instance
        .collection('propiedades')
        .where('creadoPorUid', isEqualTo: uid)
        .get();

    for (final doc in props.docs) {
      await doc.reference.delete();
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Usuario y propiedades eliminadas."),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      appBar: AppBar(
        title: const Text("Usuarios Registrados"),
        backgroundColor: azul,
        foregroundColor: Colors.white,
        leading: const BackButton(),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final usuarios = snapshot.data!.docs;

          if (usuarios.isEmpty) {
            return const Center(
              child: Text(
                "No hay usuarios registrados.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final data = usuarios[index].data() as Map<String, dynamic>;
              final nombre = data['nombre'] ?? 'Sin nombre';
              final correo = data['email'] ?? 'Sin correo';
              final tipo = data['tipo'] ?? 'desconocido';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.person, size: 24),
                  ),
                  title: Text(
                    nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(correo, style: const TextStyle(fontSize: 14)),
                      Text("Rol: $tipo", style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eliminarUsuario(context, usuarios[index].id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
