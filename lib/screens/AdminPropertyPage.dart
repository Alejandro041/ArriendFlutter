import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPropertyPage extends StatelessWidget {
  const AdminPropertyPage({super.key});

  Future<void> eliminarPropiedad(BuildContext context, String propId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("\u00bfEliminar propiedad?"),
        content: const Text("Esta acci\u00f3n no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
        ],
      ),
    );
    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('propiedades').doc(propId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Propiedad eliminada."), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      appBar: AppBar(
        title: const Text("Gestionar Propiedades"),
        foregroundColor: Colors.white,
        backgroundColor: azul,
        leading: const BackButton(),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('propiedades').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final titulo = data['titulo'] ?? 'Sin título';
              final direccion = data['direccion'] ?? 'Sin dirección';
              final precio = data['precio']?.toString() ?? '0';
              final imagenUrl = data['imagenUrl'] ?? '';
              final habitaciones = data['habitaciones'] ?? '-';
              final estacionamiento = data['estacionamiento'] ?? '-';
              final creadoPor = data['creadoPorNombre'] ?? 'Desconocido';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imagenUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: Image.network(imagenUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Dirección: $direccion"),
                          Text("Habitaciones: $habitaciones | Estacionamiento: $estacionamiento"),
                          Text("Precio: \$${precio} CLP"),
                          Text("Publicado por: $creadoPor"),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarPropiedad(context, doc.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
