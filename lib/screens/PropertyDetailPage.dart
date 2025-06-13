import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PropertyDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const PropertyDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['titulo'] ?? 'Detalle de Propiedad'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            data['imagenUrl'] != null
                ? Image.network(data['imagenUrl'], height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(height: 200, color: Colors.grey[300], child: const Center(child: Text("Sin imagen"))),
            const SizedBox(height: 16),

            Text(
              data['titulo'] ?? 'Sin título',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              data['descripcion'] ?? 'Sin descripción',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 8),
                Text("CLP ${data['precio']} / mes", style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.bed, size: 20),
                const SizedBox(width: 8),
                Text("Habitaciones: ${data['habitacionesDisponibles']}/${data['totalHabitaciones'] ?? '?'}"),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.directions_car, size: 20),
                const SizedBox(width: 8),
                Text("Estacionamiento: ${data['estacionamiento'] == true ? 'Sí' : 'No'}"),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text(data['direccion'] ?? 'Sin dirección'),
              ],
            ),
            const SizedBox(height: 8),

            if (data['universidadCercana'] != null)
              Row(
                children: [
                  const Icon(Icons.school, size: 20),
                  const SizedBox(width: 8),
                  Text("Cerca de: ${data['universidadCercana']}"),
                ],
              ),
            const SizedBox(height: 16),

            if (data['servicios'] != null && data['servicios'] is List)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Servicios incluidos:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...List<Widget>.from((data['servicios'] as List).map((s) => Text("- $s"))),
                ],
              ),

            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                onPressed: () {
                  final disponibles = data['habitacionesDisponibles'] ?? 0;
                  if (disponibles > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redirigiendo al pago...")));
                    // Aquí podrías redirigir a una pantalla de pago
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No hay habitaciones disponibles.")));
                  }
                },
                icon: const Icon(Icons.payment),
                label: const Text("Reservar o Pagar"),
                style: FilledButton.styleFrom(
                  backgroundColor: azul,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
