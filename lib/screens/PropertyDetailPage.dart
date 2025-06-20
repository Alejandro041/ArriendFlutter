import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String propertyId;

  const PropertyDetailPage({super.key, required this.data, required this.propertyId});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('propiedades')
        .doc(widget.propertyId)
        .collection('valoraciones')
        .doc(uid)
        .get();

    if (doc.exists && doc.data()?['valor'] != null) {
      setState(() => _userRating = (doc['valor'] as num).toDouble());
    }
  }

  Future<void> _setRating(double valor) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('propiedades')
        .doc(widget.propertyId)
        .collection('valoraciones')
        .doc(uid)
        .set({'valor': valor});

    setState(() => _userRating = valor);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final azul = Colors.blue.shade600;

    final titulo = data['titulo'] ?? 'Sin título';
    final descripcion = data['descripcion'] ?? 'Sin descripción';
    final direccion = data['direccion'] ?? 'Sin dirección';
    final precio = data['precio']?.toString() ?? '0';
    final habitaciones = "${data['habitacionesDisponibles']}/${data['totalHabitaciones'] ?? '?'}";
    final estacionamiento = data['estacionamiento'] == true ? 'Sí' : 'No';
    final arrendador = data['creadoPorNombre'] ?? 'No registrado';
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

            // Título
            Text(titulo, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Descripción
            Text(descripcion, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),

            // Habitaciones
            Row(
              children: [
                const Icon(Icons.bed_outlined, size: 24),
                const SizedBox(width: 8),
                Text("Habitaciones disponibles: ", style: const TextStyle(fontSize: 18)),
                Text(habitaciones, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            // Estacionamiento
            Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 24),
                const SizedBox(width: 8),
                Text("Estacionamiento: ", style: const TextStyle(fontSize: 18)),
                Text(
                  estacionamiento,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: estacionamiento == 'Sí' ? FontWeight.bold : FontWeight.normal,
                    color: estacionamiento == 'Sí' ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dirección
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 24),
                const SizedBox(width: 8),
                Text("Dirección: ", style: const TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(direccion, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Precio
            Row(
              children: [
                const Icon(Icons.attach_money_outlined, size: 24),
                const SizedBox(width: 8),
                Text("Precio: ", style: const TextStyle(fontSize: 18)),
                Text("CLP $precio / mes", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            // Universidad cercana
            Row(
              children: [
                const Icon(Icons.school_outlined, size: 24),
                const SizedBox(width: 8),
                Text("Universidad cercana: ", style: const TextStyle(fontSize: 18)),
                Text(
                  universidad ?? "No registrada",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: universidad != null ? FontWeight.bold : FontWeight.normal,
                    color: universidad != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Servicios
            const Text("Servicios incluidos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ["Wifi", "Agua", "Luz", "Gas"].map((serv) {
                final tiene = servicios.contains(serv);
                return Row(
                  children: [
                    Icon(tiene ? Icons.check_circle : Icons.cancel, color: tiene ? azul : Colors.grey, size: 20),
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
            const SizedBox(height: 20),

            // Arrendador
            Row(
              children: [
                const Icon(Icons.person_outline, size: 24),
                const SizedBox(width: 8),
                Text("Arrendador: ", style: const TextStyle(fontSize: 18)),
                Text(arrendador, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 24),

            // Valoración personal
            const Text("Tu calificación:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final valor = i + 1;
                return IconButton(
                  onPressed: () => _setRating(valor.toDouble()),
                  icon: Icon(
                    _userRating >= valor ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Botón de pago con confirmación
            Center(
              child: FilledButton.icon(
                onPressed: () async {
                  final disponibles = data['habitacionesDisponibles'] ?? 0;
                  if (disponibles <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No hay habitaciones disponibles.")),
                    );
                    return;
                  }

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("¿Confirmar pago?"),
                      content: const Text("¿Estás seguro de que deseas realizar el pago?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Sí, pagar"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Redirigiendo al pago...")),
                    );
                  }
                },
                icon: const Icon(Icons.payment),
                label: const Text("Reservar o Pagar", style: TextStyle(fontSize: 18)),
                style: FilledButton.styleFrom(
                  backgroundColor: azul,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
