import 'dart:async';

import 'package:carol_libreria/producto_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'main.dart'; // Asegúrate de importar la pantalla de inicio de sesión si no está en otro archivo

class AdminPage extends StatefulWidget {
  final String? userEmail;
  AdminPage({Key? key, required this.userEmail}) : super(key: key);
  @override
  _AdminPage createState() => _AdminPage();
}

class _AdminPage extends State<AdminPage> {
  Timer? _inactivityTimer;

  // Función para cerrar sesión
  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Inicia o reinicia el temporizador de inactividad
  void _startInactivityTimer() {
    _inactivityTimer?.cancel(); // Cancela el temporizador si ya estaba activo
    _inactivityTimer = Timer(Duration(seconds: 30), () {
      cerrarSesion(); // Cierra sesión después de 1 minuto de inactividad
    });
  }

  // Reinicia el temporizador en cada interacción
  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  @override
  void initState() {
    super.initState();
    _startInactivityTimer(); // Inicia el temporizador cuando se carga la pantalla
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel(); // Cancela el temporizador al cerrar la pantalla
    super.dispose();
  }

  void usuarios() {
    _resetInactivityTimer();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(userEmail: widget.userEmail,)),
    );
  }

  void productos() {
    _resetInactivityTimer();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProductoScreen(userEmail: widget.userEmail!,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer, // Reinicia el temporizador al detectar toques en la pantalla
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 157, 176, 255), // Color del AppBar
          title: Text('Gestión'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gestión de Usuarios',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 157, 176, 255),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: usuarios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 157, 176, 255),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Usuarios', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Gestión de Productos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 157, 176, 255),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: productos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 157, 176, 255),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Productos', style: TextStyle(color: Colors.white)),
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
