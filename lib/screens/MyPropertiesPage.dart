import 'package:arriendapp/screens/DetailArrendadorPropertyPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'PropertyDetailPage.dart';

class Mypropertiespage extends StatelessWidget {
  const Mypropertiespage({super.key});

  // SIN orderBy para evitar requerir un índice
  Stream<QuerySnapshot> obtenerPropiedadesDelUsuario(String uid) {
    print("[DEBUG] Escuchando propiedades del usuario con UID: $uid");
    return FirebaseFirestore.instance
        .collection('propiedades')
        .where('creadoPorId', isEqualTo: uid)
        // .orderBy('fechaPublicacion', descending: true) // Se omite por ahora
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;
    final user = FirebaseAuth.instance.currentUser;

    print("[DEBUG] Usuario autenticado: ${user?.uid}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Propiedades"),
        backgroundColor: azul,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          user == null
              ? const Center(child: Text("Usuario no autenticado"))
              : StreamBuilder<QuerySnapshot>(
                stream: obtenerPropiedadesDelUsuario(user.uid),
                builder: (context, snapshot) {
                  print("[DEBUG] Snapshot state: ${snapshot.connectionState}");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("[DEBUG] Error en snapshot: ${snapshot.error}");
                    return const Center(
                      child: Text("Error al cargar propiedades"),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    print("[DEBUG] Snapshot sin datos.");
                    return const Center(
                      child: Text("No se encontraron propiedades."),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  print(
                    "[DEBUG] Cantidad de propiedades encontradas: ${docs.length}",
                  );

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("Aún no has publicado propiedades."),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      print("[DEBUG] Propiedad #$index: $data");

                      final imagenUrl = data['imagenUrl'] as String?;
                      final titulo = data['titulo'] ?? 'Sin título';
                      final descripcion =
                          data['descripcion'] ?? 'Sin descripción';
                      final precio = data['precio'] ?? 0;
                      final estacionamiento =
                          data['estacionamiento'] == true ? 'Sí' : 'No';
                      final total = data['totalHabitaciones'] ?? 0;
                      final disponibles = data['habitacionesDisponibles'] ?? 0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DetailArrendadorPropertyPage(
                                    data: data,
                                    idDocumento: docs[index].id,
                                  ),
                            ),
                          );
                        },

                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  descripcion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      color: azul,
                                      size: 20,
                                    ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(""),
                                    Text(
                                      "\$$precio CLP",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
              ),
    );
  }
}
