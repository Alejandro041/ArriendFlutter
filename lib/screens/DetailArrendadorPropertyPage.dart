import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailArrendadorPropertyPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String idDocumento;

  const DetailArrendadorPropertyPage({
    super.key,
    required this.data,
    required this.idDocumento,
  });

  void eliminarPropiedad(BuildContext context) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Deseas eliminar esta propiedad? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      await FirebaseFirestore.instance
          .collection('propiedades')
          .doc(idDocumento)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Propiedad eliminada")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade600;

    final titulo = data['titulo'] ?? 'Sin título';
    final descripcion = data['descripcion'] ?? 'Sin descripción';
    final direccion = data['direccion'] ?? 'Sin dirección';
    final precio = data['precio']?.toString() ?? '0';
    final habitaciones = "${data['habitacionesDisponibles']}/${data['totalHabitaciones'] ?? '?'}";
    final estacionamiento = data['estacionamiento'] == true ? 'Sí' : 'No';
    final universidad = data['universidadCercana'];
    final servicios = data['servicios'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            data['imagenUrl'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data['imagenUrl'],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text("Sin imagen")),
                  ),
            const SizedBox(height: 20),

            Text(
              titulo,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Text(
              descripcion,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                const Icon(Icons.bed_outlined, size: 24),
                const SizedBox(width: 8),
                Text("Habitaciones: $habitaciones", style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Estacionamiento: $estacionamiento",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: estacionamiento == 'Sí' ? FontWeight.bold : FontWeight.normal,
                    color: estacionamiento == 'Sí' ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Dirección: $direccion",
                      style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.attach_money_outlined, size: 24),
                const SizedBox(width: 8),
                Text("Precio: CLP $precio / mes",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.school_outlined, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Universidad: ${universidad ?? 'No registrada'}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: universidad != null ? FontWeight.bold : FontWeight.normal,
                    color: universidad != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Servicios incluidos:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ["Wifi", "Agua", "Luz", "Gas"].map((serv) {
                final tiene = servicios.contains(serv);
                return Row(
                  children: [
                    Icon(
                      tiene ? Icons.check_circle : Icons.cancel,
                      color: tiene ? azul : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tiene ? serv : "$serv (no disponible)",
                      style: TextStyle(
                        fontSize: 16,
                        color: tiene ? Colors.black : Colors.grey,
                        fontWeight: tiene ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/editProperty',
                      arguments: {
                        'idDocumento': idDocumento,
                        'data': data,
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => eliminarPropiedad(context),
                  icon: const Icon(Icons.delete),
                  label: const Text("Eliminar"),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
