import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Mypropertiespage extends StatelessWidget {
  const Mypropertiespage({super.key});

  Future<List<Map<String, dynamic>>> obtenerPropiedadesDelUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('propiedades')
        .where('creadoPor', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Propiedades")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerPropiedadesDelUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar las propiedades"));
          }

          final propiedades = snapshot.data;

          if (propiedades == null || propiedades.isEmpty) {
            return const Center(child: Text("No has publicado ninguna propiedad aún."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: propiedades.length,
            itemBuilder: (context, index) {
              final propiedad = propiedades[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(propiedad['titulo'] ?? 'Sin título'),
                  subtitle: Text("${propiedad['precio'] ?? 0} CLP/mes"),
                  trailing: propiedad['disponible'] == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.red),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
