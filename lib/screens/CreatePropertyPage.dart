import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Createpropertypage extends StatefulWidget {
  const Createpropertypage({super.key});

  @override
  State<Createpropertypage> createState() => _CreatepropertypageState();
}

class _CreatepropertypageState extends State<Createpropertypage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _habitacionesController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _tieneEstacionamiento = false;
  String? _universidadSeleccionada;
  List<String> _servicios = [];

  final List<String> _universidades = [
    "UCM",
    "UTalca",
    "Autónoma",
    "Santo Tomás",
    "Otra",
  ];

  final List<String> _opcionesServicios = [
    "Wifi",
    "Agua",
    "Luz",
    "Gas",
  ];

  XFile? _imagenSeleccionada;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = pickedFile;
      });
    }
  }

  Future<void> _publicarPropiedad() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imageUrl;
    if (_imagenSeleccionada != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('propiedades/${DateTime.now().millisecondsSinceEpoch}_${_imagenSeleccionada!.name}');

      final uploadTask = await storageRef.putFile(File(_imagenSeleccionada!.path));
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('propiedades').add({
      'titulo': _tituloController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'precio': int.tryParse(_precioController.text.trim()) ?? 0,
      'habitacionesDisponibles': int.tryParse(_habitacionesController.text.trim()) ?? 0,
      'direccion': _direccionController.text.trim(),
      'estacionamiento': _tieneEstacionamiento,
      'universidadCercana': _universidadSeleccionada,
      'servicios': _servicios,
      'imagenUrl': imageUrl,
      'disponible': true,
      'creadoPor': user.uid,
      'fechaPublicacion': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Propiedad publicada exitosamente")),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, '/myProperties');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Propiedad")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: "Título"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Precio mensual"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _habitacionesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Habitaciones disponibles"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("¿Tiene estacionamiento?"),
                value: _tieneEstacionamiento,
                onChanged: (val) => setState(() => _tieneEstacionamiento = val),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: "Dirección"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Universidad cercana (opcional)"),
                value: _universidadSeleccionada,
                items: _universidades.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) => setState(() => _universidadSeleccionada = val),
              ),
              const SizedBox(height: 12),
              const Text("Servicios incluidos (opcional)"),
              ..._opcionesServicios.map((servicio) => CheckboxListTile(
                    title: Text(servicio),
                    value: _servicios.contains(servicio),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _servicios.add(servicio);
                        } else {
                          _servicios.remove(servicio);
                        }
                      });
                    },
                  )),
              const SizedBox(height: 12),
              _imagenSeleccionada != null
                  ? kIsWeb
                      ? Image.network(_imagenSeleccionada!.path, height: 150)
                      : Image.file(File(_imagenSeleccionada!.path), height: 150)
                  : const Text("Ninguna imagen seleccionada"),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.image),
                label: const Text("Seleccionar imagen"),
              ),
              const SizedBox(height: 24),
              Center(
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _publicarPropiedad();
                    }
                  },
                  child: const Text("Publicar propiedad"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
