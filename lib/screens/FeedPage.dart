import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'PropertyDetailPage.dart';

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

  Future<String> obtenerNombreUsuario(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.exists ? (doc.data()?['nombre'] ?? 'Desconocido') : 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ArriendApp"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: azul,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/MyProfile'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _crearPropiedad,
              icon: const Icon(Icons.add_home),
              label: const Text("Crear propiedad"),
              style: FilledButton.styleFrom(
                backgroundColor: azul,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
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

                      final imagenUrl = data['imagenUrl'] as String?;
                      final titulo = data['titulo'] ?? 'Sin título';
                      final descripcion = data['descripcion'] ?? 'Sin descripción';
                      final precio = data['precio'] ?? 0;
                      final estacionamiento = data['estacionamiento'] == true ? 'Sí' : 'No';
                      final total = data['totalHabitaciones'] ?? 0;
                      final disponibles = data['habitacionesDisponibles'] ?? 0;
                      final creadorUid = data['creadoPor'];

                      return FutureBuilder<String>(
                        future: obtenerNombreUsuario(creadorUid),
                        builder: (context, snapshotNombre) {
                          final nombreArrendador = snapshotNombre.data ?? 'Arrendador';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailPage(data: data),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imagenUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imagenUrl,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      titulo,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.directions_car, color: azul, size: 20),
                                        const SizedBox(width: 4),
                                        Text("Estacionamiento: $estacionamiento"),
                                        const SizedBox(width: 16),
                                        Icon(Icons.bed, color: azul, size: 20),
                                        const SizedBox(width: 4),
                                        Text("Habitaciones: $disponibles/$total"),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 20),
                                            const SizedBox(width: 4),
                                            Text(nombreArrendador),
                                          ],
                                        ),
                                        Text(
                                          "\$$precio CLP",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: azul,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estás en Home
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/MyProfile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
