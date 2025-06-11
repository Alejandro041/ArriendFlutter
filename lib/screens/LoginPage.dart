import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                Icon(Icons.account_circle_rounded, size: 64, color: Colors.blue.shade600),
                const SizedBox(height: 16),
                Text(
                  "Bienvenido a ArriendApp",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    label: "Correo Electrónico",
                    icon: Icons.email,
                  ),
                ),

                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: _buildInputDecoration(
                    label: "Contraseña",
                    icon: Icons.lock,
                    suffix: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color:Colors.blue.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón login
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      fnIniciarSesion(
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
                    label: const Text("Iniciar Sesión"),
                    icon: const Icon(Icons.login),
                    style: FilledButton.styleFrom(
                      backgroundColor:Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Link registro
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/Register");
                  },
                  child:Text(
                    "¿No tienes cuenta? Regístrate",
                    style: TextStyle(color:Colors.blue.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        borderSide: BorderSide(color: Colors.blue.shade600),
      ),
    );
  }

  Future<void> fnIniciarSesion(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor agrega todos los datos"),
          backgroundColor:Colors.blue.shade600,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Inicio de sesión exitoso"),
          content: const Text("Bienvenido a la aplicación"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/Feed');
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = switch (e.code) {
        'user-not-found' => "Usuario no encontrado",
        'wrong-password' => "Contraseña incorrecta",
        _ => "Error: ${e.message}",
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
