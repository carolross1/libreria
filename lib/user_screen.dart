import 'dart:async';
import 'package:carol_libreria/producto.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class UserPage extends StatefulWidget {
  final String? userEmail;
  UserPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  Timer? _inactivityTimer;

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: 30), () {
      cerrarSesion();
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void irATiendita() {
    _resetInactivityTimer();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UsuarioScreen(userEmail: widget.userEmail!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 157, 176, 255),
          title: Text('Opciones'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: irATiendita,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 157, 176, 255),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Ir a la Tiendita', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: cerrarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 157, 176, 255),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFFF1F6F8),
      ),
    );
  }
}
