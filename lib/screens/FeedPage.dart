import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<bool> esArrendador() async {
    if (currentUser == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(currentUser!.uid)
        .get();

    return doc.exists && doc.data()?['tipo'] == 'arrendador';
  }

  void _crearPropiedad() async {
    final autorizado = await esArrendador();
    if (autorizado) {
      Navigator.pushNamed(context, '/CreateProperty');
    } else {
      Navigator.pushNamed(context, '/SolicityArr');
    }
  }

  Stream<QuerySnapshot> obtenerPropiedades() {
    return FirebaseFirestore.instance
        .collection('propiedades')
        .orderBy('fechaPublicacion', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ArriendApp"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _crearPropiedad,
              icon: const Icon(Icons.add_home),
              label: const Text("Crear propiedad"),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: obtenerPropiedades(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No hay propiedades disponibles."));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(data['titulo'] ?? 'Sin título'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['descripcion'] ?? 'Sin descripción'),
                              const SizedBox(height: 4),
                              Text("Precio: \$${data['precio']}"),
                              Text("Habitaciones: ${data['habitacionesDisponibles']}"),
                              Text("Estacionamiento: ${data['estacionamiento'] == true ? 'Sí' : 'No'}"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
