import 'dart:async';
import 'package:carol_libreria/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:carol_libreria/db_helper.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  final String? userEmail;
  HomeScreen({Key? key, required this.userEmail}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Map<String, dynamic>> _allUser = [];
  bool _isLoading = true;

  // Colores personalizados
  final Color primaryColor = Color.fromARGB(255, 157, 176, 255); // Nuevo color azul
  final Color backgroundColor = Color(0xFFE0E0E0); // Fondo gris claro
  final Color appBarColor = Color.fromARGB(255, 157, 176, 255); // Mismo color azul para AppBar
  final Color buttonColor = Color.fromARGB(255, 157, 176, 255); // Color azul para botones
  final Color deleteColor = Colors.redAccent; // Color para eliminar
  final Color iconColor = Color.fromARGB(255, 153, 168, 227); // Color gris más fuerte para los íconos

  // Temporizador de inactividad
  Timer? _inactivityTimer;

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(minutes: 1), cerrarSesion);
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void regresar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminPage(userEmail: widget.userEmail!)),
    );
  }

  void _refreshUser() async {
    final user = await SQLHelper.getAllUser();
    setState(() {
      _allUser = user;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshUser();
    _resetInactivityTimer(); // Inicia el temporizador al cargar la pantalla
  }

  final TextEditingController _nombreEditingController = TextEditingController();
  final TextEditingController _usuarioEditingController = TextEditingController();
  final TextEditingController _correoEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  final TextEditingController _rolEditingController = TextEditingController();

  Future<void> _addUser() async {
    int rol = int.parse(_rolEditingController.text);
    await SQLHelper.createUser(
      _nombreEditingController.text,
      _usuarioEditingController.text,
      _correoEditingController.text,
      _passEditingController.text,
      rol,
    );
    _refreshUser();
  }

  Future<void> _updateUser(int id) async {
    int rol = int.parse(_rolEditingController.text);
    await SQLHelper.updateUser(
      id,
      _nombreEditingController.text,
      _usuarioEditingController.text,
      _correoEditingController.text,
      _passEditingController.text,
      rol,
    );
    _refreshUser();
  }

  Future<void> _deleteUser(int id) async {
    await SQLHelper.deleteUser(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: deleteColor,
      content: Text("Se ha eliminado un registro"),
    ));
    _refreshUser();
  }

  void muestraDatos(int? id) {
    _resetInactivityTimer(); // Reinicia el temporizador al abrir el formulario
    if (id != null) {
      final existingUser = _allUser.firstWhere((element) => element['id'] == id);
      _nombreEditingController.text = existingUser['nombre'];
      _usuarioEditingController.text = existingUser['usuario'] ?? "";
      _correoEditingController.text = existingUser['correo'] ?? "";
      _passEditingController.text = existingUser['pass'] ?? "";
      _rolEditingController.text = existingUser['rol'].toString();
    } else {
      _nombreEditingController.clear();
      _usuarioEditingController.clear();
      _correoEditingController.clear();
      _passEditingController.clear();
      _rolEditingController.clear();
    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nombreEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nombre",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _usuarioEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Usuario",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _correoEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Correo",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Contraseña",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _rolEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Rol",
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addUser();
                  } else {
                    await _updateUser(id);
                  }
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Registrar Usuario" : "Actualizar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer, // Reinicia el temporizador en cualquier toque
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text("Registros del Administrador"),
          backgroundColor: appBarColor,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _allUser.length,
                itemBuilder: (context, index) => Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _allUser[index]['nombre'],
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              muestraDatos(_allUser[index]['id']);
                            },
                            icon: Icon(Icons.edit, color: iconColor),
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteUser(_allUser[index]['id']);
                            },
                            icon: Icon(Icons.delete, color: iconColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Alinea los botones horizontalmente
            children: [
              FloatingActionButton(
                onPressed: regresar,
                backgroundColor: const Color.fromARGB(255, 157, 176, 255),
                child: Icon(Icons.home, size: 40, color: Color(0xFFF0F0F0)),
              ),
              FloatingActionButton(
                onPressed: cerrarSesion,
                backgroundColor: const Color.fromARGB(255, 157, 176, 255),
                child: Icon(Icons.logout, size: 40, color: Color(0xFFF0F0F0)),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => muestraDatos(null),
          backgroundColor: const Color.fromARGB(255, 157, 176, 255),
          child: Icon(Icons.add, size: 40, color: Color(0xFFF0F0F0)),
        ),
      ),
    );
  }
}
