import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSolicityPage extends StatelessWidget {
  const AdminSolicityPage({super.key});

  Future<void> aprobar(BuildContext context, String uid) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
      'tipo': 'arrendador',
    });
    await FirebaseFirestore.instance.collection('solicitudes_arrendador').doc(uid).update({
      'estado': 'aprobado',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Solicitud aprobada."), backgroundColor: Colors.green),
    );
  }

  Future<void> rechazar(BuildContext context, String uid) async {
    await FirebaseFirestore.instance.collection('solicitudes_arrendador').doc(uid).update({
      'estado': 'rechazado',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Solicitud rechazada."), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      appBar: AppBar(
        title: const Text("Solicitudes de Arrendador"),
        backgroundColor: azul,
        foregroundColor: Colors.white,
        leading: const BackButton(),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('solicitudes_arrendador')
            .where('estado', isEqualTo: 'pendiente')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final solicitudes = snapshot.data!.docs;

          if (solicitudes.isEmpty) {
            return const Center(
              child: Text("No hay solicitudes pendientes.", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: solicitudes.length,
            itemBuilder: (context, index) {
              final data = solicitudes[index].data() as Map<String, dynamic>;
              final uid = data['uid'];
              final nombre = data['nombreCompleto'] ?? 'Sin nombre';
              final rut = data['rut'] ?? '-';
              final telefono = data['telefono'] ?? '-';
              final motivo = data['motivo'] ?? '-';
              final email = data['email'] ?? '-';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Correo: $email"),
                      Text("RUT: $rut"),
                      Text("Teléfono: $telefono"),
                      const SizedBox(height: 8),
                      const Text("Motivo:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(motivo),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => rechazar(context, uid),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text("Denegar", style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => aprobar(context, uid),
                            icon: const Icon(Icons.check, color: Colors.green),
                            label: const Text("Aprobar", style: TextStyle(color: Colors.green)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            
                          ),
                        ],
                      ),
                    ],
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
