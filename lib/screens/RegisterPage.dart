import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade600),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Icon(Icons.account_circle, size: 64, color: Colors.blue.shade600),
                const SizedBox(height: 16),
                Text(
                  "Crea tu cuenta",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Nombre
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: _buildInputDecoration(
                    label: "Nombre completo",
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    label: "Correo electrónico",
                    icon: Icons.email,
                  ),
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: _buildInputDecoration(
                    label: "Contraseña",
                    icon: Icons.lock,
                    suffix: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue.shade600,
                      ),
                      onPressed: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmar contraseña
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  decoration: _buildInputDecoration(
                    label: "Confirmar contraseña",
                    icon: Icons.lock,
                    suffix: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue.shade600,
                      ),
                      onPressed: () {
                        setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón registrarse
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      fnRegistrarUsuario(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                      );
                    },
                    label: const Text("Registrarse"),
                    icon: const Icon(Icons.person_add),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/");
                  },
                  child: Text(
                    "¿Ya tienes cuenta? Inicia sesión",
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fnRegistrarUsuario(
    String nombre,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.blue.shade600,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(cred.user!.uid)
          .set({
        "nombre": nombre,
        "email": email,
        "uid": cred.user!.uid,
        "tipo": "arrendatario", // Default
        "fechaRegistro": FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/Feed');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registro exitoso"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, "/feed");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ya existe una cuenta con ese correo"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error desconocido: $e");
    }
  }
}
