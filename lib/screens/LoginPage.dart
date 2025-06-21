import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = false;

  // Correo que puede ingresar sin verificación
  final String correoExento = 'admin@admin.cl';

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
                      child: Icon(
                        Icons.account_circle_rounded,
                        size: 80,
                        color: Colors.blue,
                      ),
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
                            "Iniciar Sesión",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
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
                                  color: Colors.blue.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Olvidé contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/PasswordForget");
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                "¿Olvidaste tu contraseña?",
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        _fnIniciarSesion(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.blue.shade200,
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            "Iniciar Sesión",
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

                  // Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿No tienes cuenta?",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/Register");
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Regístrate",
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

  Future<void> _fnIniciarSesion(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Por favor ingresa todos los datos"),
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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) throw Exception("No se pudo obtener el usuario");

      // Validar verificación de correo, salvo para correo exento
      if (!user.emailVerified &&
          user.email!.toLowerCase() != correoExento.toLowerCase()) {
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Tu correo no está verificado. Revisa tu bandeja de entrada.",
            ),
            action: SnackBarAction(
              label: "Reenviar",
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await user.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Correo de verificación reenviado"),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error al reenviar: $e"),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              },
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      // Obtener rol desde Firestore
      final doc =
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();

      if (!doc.exists) throw Exception("No se encontró el documento del usuario");

      final tipo = doc.data()?['tipo'];

      if (!mounted) return;

      if (tipo == 'admin') {
        Navigator.pushReplacementNamed(context, '/AdminPage');
      } else {
        Navigator.pushReplacementNamed(context, '/Feed');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      String msg = switch (e.code) {
        'user-not-found' => "Usuario no encontrado",
        'wrong-password' => "Contraseña incorrecta",
        'invalid-credential' => "Credenciales inválidas",
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
    }
  }
}
