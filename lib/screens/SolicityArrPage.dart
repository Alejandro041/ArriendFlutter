import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Solicityarrpage extends StatefulWidget {
  const Solicityarrpage({super.key});

  @override
  State<Solicityarrpage> createState() => _SolicityarrpageState();
}

class _SolicityarrpageState extends State<Solicityarrpage> {
  Future<void> actualizarARolArrendador() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .set({"tipo": "arrendador"}, SetOptions(merge: true));


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Ahora eres arrendador!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/createProperty');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ocurrió un error al actualizar tu rol."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Convertirse en arrendador")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "¿Quieres publicar propiedades?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Al convertirte en arrendador podrás publicar propiedades en ArriendApp. "
              "Tu perfil será verificado y visible para los arrendatarios.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: actualizarARolArrendador,
              icon: const Icon(Icons.verified_user),
              label: const Text("Quiero ser arrendador"),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
