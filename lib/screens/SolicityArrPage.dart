import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Solicityarrpage extends StatefulWidget {
  const Solicityarrpage({super.key});

  @override
  State<Solicityarrpage> createState() => _SolicityarrpageState();
}

class _SolicityarrpageState extends State<Solicityarrpage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  bool _aceptaTerminos = false;
  bool _enviando = false;

  Future<void> enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar los términos y condiciones.")),
      );
      return;
    }

    setState(() => _enviando = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('solicitudes_arrendador').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'nombreCompleto': _nombreController.text.trim(),
        'rut': _rutController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'motivo': _descripcionController.text.trim(),
        'fechaSolicitud': FieldValue.serverTimestamp(),
        'estado': 'pendiente',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud enviada. Te notificaremos pronto.")),
      );

      Navigator.pushReplacementNamed(context, '/Feed');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar la solicitud")),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulario para ser Arrendador"),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Completa este formulario para que podamos validar tu perfil como arrendador.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre completo",
                  prefixIcon: Icon(Icons.person, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _rutController,
                decoration: InputDecoration(
                  labelText: "RUT o ID",
                  prefixIcon: Icon(Icons.credit_card, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Teléfono de contacto",
                  prefixIcon: Icon(Icons.phone, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "¿Por qué deseas ser arrendador?",
                  prefixIcon: Icon(Icons.question_answer, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Este campo es requerido" : null,
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                value: _aceptaTerminos,
                activeColor: azul,
                onChanged: (val) => setState(() => _aceptaTerminos = val ?? false),
                title: const Text("Acepto los términos y condiciones de uso"),
              ),
              const SizedBox(height: 20),

              Center(
                child: FilledButton.icon(
                  onPressed: _enviando ? null : enviarSolicitud,
                  icon: const Icon(Icons.send),
                  label: Text(_enviando ? "Enviando..." : "Enviar solicitud"),
                  style: FilledButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
