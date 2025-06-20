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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icono con efecto de sombra
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.person_add, 
                        size: 80, 
                        color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Card con el formulario
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            "Crear Cuenta",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
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
                          
                          // Confirmar Contraseña
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
                          
                          // Botón Registrarse
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading 
                                  ? null 
                                  : () {
                                      _fnRegistrarUsuario(
                                        _nameController.text.trim(),
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                        _confirmPasswordController.text.trim(),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.blue.shade200,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_add, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          "Registrarse",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Link a Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿Ya tienes cuenta?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/");
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Inicia sesión",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
      labelStyle: TextStyle(color: Colors.blue.shade600),
      prefixIcon: Icon(icon, color: Colors.blue.shade600),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Future<void> _fnRegistrarUsuario(
    String nombre,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Las contraseñas no coinciden"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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

      if (!mounted) return;
      
      Navigator.pushReplacementNamed(context, '/Feed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registro exitoso"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      
      String msg = switch (e.code) {
        'email-already-in-use' => "Ya existe una cuenta con ese correo",
        'weak-password' => "La contraseña es demasiado débil",
        'invalid-email' => "El correo electrónico no es válido",
        _ => "Error: ${e.message}",
      };
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error inesperado: $e"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      debugPrint("Error desconocido: $e");
    }
  }
}