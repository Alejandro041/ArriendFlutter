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
  final TextEditingController _totalHabitacionesController =
      TextEditingController();
  final TextEditingController _habitacionesDisponiblesController =
      TextEditingController();
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

  final List<String> _opcionesServicios = ["Wifi", "Agua", "Luz", "Gas"];

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

    // Obtener nombre del usuario desde Firestore
    final usuarioDoc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
    final nombreUsuario = usuarioDoc.data()?['nombre'] ?? 'Sin nombre';

    String? imageUrl;
    if (_imagenSeleccionada != null) {
      final storageRef = FirebaseStorage.instance.ref().child(
        'propiedades/${DateTime.now().millisecondsSinceEpoch}_${_imagenSeleccionada!.name}',
      );

      final uploadTask = await storageRef.putFile(
        File(_imagenSeleccionada!.path),
      );
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('propiedades').add({
      'titulo': _tituloController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'precio': double.tryParse(_precioController.text.trim()) ?? 0.0,
      'totalHabitaciones':
          int.tryParse(_totalHabitacionesController.text.trim()) ?? 0,
      'habitacionesDisponibles':
          int.tryParse(_habitacionesDisponiblesController.text.trim()) ?? 0,
      'direccion': _direccionController.text.trim(),
      'estacionamiento': _tieneEstacionamiento,
      'universidadCercana': _universidadSeleccionada,
      'servicios': _servicios,
      'imagenUrl': imageUrl,
      'disponible': true,
      'creadoPorId': user.uid,
      'creadoPorNombre': nombreUsuario,
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
    final azul = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/Feed');
          },
        ),
        title: const Text("Crea Tú Propiedad"),
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
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: "Título",
                  prefixIcon: Icon(Icons.title, color: azul),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descripción",
                  prefixIcon: Icon(Icons.description, color: azul),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Precio mensual",
                  hintText: "Ej: 350000 o 350.000 (en CLP)",
                  prefixIcon: Icon(Icons.attach_money, color: azul),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo requerido";
                  if (double.tryParse(value) == null)
                    return "Ingrese un número válido";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalHabitacionesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Total habitaciones",
                        hintText: "Ej: 4",
                        prefixIcon: Icon(Icons.meeting_room, color: azul),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Requerido";
                        if (int.tryParse(value) == null)
                          return "Número inválido";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _habitacionesDisponiblesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Disponibles",
                        hintText: "Ej: 3",
                        prefixIcon: Icon(Icons.bed, color: azul),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Requerido";
                        final total = int.tryParse(
                          _totalHabitacionesController.text,
                        );
                        final disponibles = int.tryParse(value);
                        if (disponibles == null) return "Número inválido";
                        if (total != null && disponibles > total)
                          return "Mayor que total";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text("¿Tiene estacionamiento?"),
                secondary: Icon(Icons.drive_eta, color: azul),
                value: _tieneEstacionamiento,
                onChanged: (val) => setState(() => _tieneEstacionamiento = val),
                activeColor: azul,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: "Dirección",
                  prefixIcon: Icon(Icons.location_on, color: azul),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Universidad cercana (opcional)",
                  prefixIcon: Icon(Icons.school, color: azul),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _universidadSeleccionada,
                items:
                    _universidades
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                onChanged:
                    (val) => setState(() => _universidadSeleccionada = val),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.checklist, color: azul),
                  const SizedBox(width: 8),
                  const Text("Servicios incluidos (opcional)"),
                ],
              ),
              ..._opcionesServicios.map(
                (servicio) => CheckboxListTile(
                  title: Text(servicio),
                  value: _servicios.contains(servicio),
                  activeColor: azul,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _servicios.add(servicio);
                      } else {
                        _servicios.remove(servicio);
                      }
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _imagenSeleccionada != null
                        ? kIsWeb
                            ? Image.network(
                              _imagenSeleccionada!.path,
                              height: 150,
                            )
                            : Image.file(
                              File(_imagenSeleccionada!.path),
                              height: 150,
                            )
                        : const Text("Ninguna imagen seleccionada"),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _seleccionarImagen,
                      icon: const Icon(Icons.image),
                      label: const Text("Seleccionar imagen"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azul,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _publicarPropiedad();
                    }
                  },
                  icon: const Icon(Icons.publish),
                  label: const Text("Publicar propiedad"),
                  style: FilledButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
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
