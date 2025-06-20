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
  final TextEditingController _imageUrlController = TextEditingController();

  bool _hasParking = false;
  String? _selectedUniversity;
  List<String> _services = [];

  final List<String> _universities = [
    "UCM", "UTalca", "Autónoma", "Santo Tomás", "Otra",
  ];
  final List<String> _serviceOptions = ["Wifi", "Agua", "Luz", "Gas"];

  late String propertyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    _imageUrlController.text = data['imagenUrl'] ?? '';
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

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
      'imagenUrl': _imageUrlController.text.trim(),
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
              _buildTextField("Título", _titleController, Icons.title, azul),
              const SizedBox(height: 12),
              _buildTextField("Descripción", _descriptionController, Icons.description, azul, maxLines: 3),
              const SizedBox(height: 12),
              _buildNumberField("Precio mensual", _priceController, Icons.attach_money, azul),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildNumberField("Total habitaciones", _totalRoomsController, Icons.meeting_room, azul)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumberField("Disponibles", _availableRoomsController, Icons.bed, azul)),
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
              _buildTextField("Dirección", _addressController, Icons.location_on, azul),
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

              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: "URL de imagen (opcional)",
                  prefixIcon: Icon(Icons.link, color: azul),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),

              if (_imageUrlController.text.isNotEmpty)
                Center(
                  child: Image.network(_imageUrlController.text, height: 150, errorBuilder: (context, error, stackTrace) {
                    return const Text("No se pudo cargar la imagen");
                  }),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, Color color, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value!.isEmpty ? "Campo requerido" : null,
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, IconData icon, Color color) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo requerido";
        if (double.tryParse(value) == null) return "Número inválido";
        return null;
      },
    );
  }
}