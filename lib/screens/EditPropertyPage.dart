import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditPropertyPage extends StatefulWidget {
  const EditPropertyPage({super.key});

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalRoomsController = TextEditingController();
  final TextEditingController _availableRoomsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _hasParking = false;
  String? _selectedUniversity;
  List<String> _services = [];

  final List<String> _universities = ["UCM", "UTalca", "Autónoma", "Santo Tomás", "Otra"];
  final List<String> _serviceOptions = ["Wifi", "Agua", "Luz", "Gas"];

  XFile? _selectedImage;
  String? _currentImageUrl;
  late String propertyId;

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final data = args['data'] as Map<String, dynamic>;
    propertyId = args['idDocumento'];

    _titleController.text = data['titulo'] ?? '';
    _descriptionController.text = data['descripcion'] ?? '';
    _priceController.text = data['precio']?.toString() ?? '';
    _totalRoomsController.text = data['totalHabitaciones']?.toString() ?? '';
    _availableRoomsController.text = data['habitacionesDisponibles']?.toString() ?? '';
    _addressController.text = data['direccion'] ?? '';
    _hasParking = data['estacionamiento'] ?? false;
    _selectedUniversity = data['universidadCercana'];
    _services = List<String>.from(data['servicios'] ?? []);
    _currentImageUrl = data['imagenUrl'];

    super.didChangeDependencies();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _currentImageUrl;
    final ref = FirebaseStorage.instance
        .ref()
        .child('propiedades/${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}');
    final task = await ref.putFile(File(_selectedImage!.path));
    return await task.ref.getDownloadURL();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final imageUrl = await _uploadImage();

    await FirebaseFirestore.instance.collection('propiedades').doc(propertyId).update({
      'titulo': _titleController.text.trim(),
      'descripcion': _descriptionController.text.trim(),
      'precio': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'totalHabitaciones': int.tryParse(_totalRoomsController.text.trim()) ?? 0,
      'habitacionesDisponibles': int.tryParse(_availableRoomsController.text.trim()) ?? 0,
      'direccion': _addressController.text.trim(),
      'estacionamiento': _hasParking,
      'universidadCercana': _selectedUniversity,
      'servicios': _services,
      'imagenUrl': imageUrl,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Propiedad actualizada con éxito")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Propiedad"),
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
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Título",
                  prefixIcon: Icon(Icons.title, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descripción",
                  prefixIcon: Icon(Icons.description, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Precio mensual",
                  prefixIcon: Icon(Icons.attach_money, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo requerido";
                  if (double.tryParse(value) == null) return "Número inválido";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalRoomsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Total habitaciones",
                        prefixIcon: Icon(Icons.meeting_room, color: azul),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value!.isEmpty ? "Campo requerido" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _availableRoomsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Disponibles",
                        prefixIcon: Icon(Icons.bed, color: azul),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Campo requerido";
                        final total = int.tryParse(_totalRoomsController.text);
                        final disp = int.tryParse(value);
                        if (disp == null) return "Número inválido";
                        if (total != null && disp > total) return "Mayor que el total";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text("¿Tiene estacionamiento?"),
                value: _hasParking,
                activeColor: azul,
                onChanged: (val) => setState(() => _hasParking = val),
                secondary: Icon(Icons.drive_eta, color: azul),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Dirección",
                  prefixIcon: Icon(Icons.location_on, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Universidad cercana (opcional)",
                  prefixIcon: Icon(Icons.school, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedUniversity,
                items: _universities.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) => setState(() => _selectedUniversity = val),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.checklist, color: azul),
                  const SizedBox(width: 8),
                  const Text("Servicios incluidos (opcional)"),
                ],
              ),
              ..._serviceOptions.map(
                (serv) => CheckboxListTile(
                  title: Text(serv),
                  value: _services.contains(serv),
                  activeColor: azul,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _services.add(serv);
                      } else {
                        _services.remove(serv);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: Column(
                  children: [
                    _selectedImage != null
                        ? (kIsWeb
                            ? Image.network(_selectedImage!.path, height: 150)
                            : Image.file(File(_selectedImage!.path), height: 150))
                        : (_currentImageUrl != null
                            ? Image.network(_currentImageUrl!, height: 150)
                            : const Text("Ninguna imagen seleccionada")),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Cambiar imagen"),
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
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar cambios"),
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
