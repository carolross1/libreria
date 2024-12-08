import 'package:flutter/material.dart';
import 'package:carol_libreria/db_helper.dart';
import 'main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  List<Map<String, dynamic>> _allUser = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isButtonEnabled = false;

  final TextEditingController _nombreEditingController = TextEditingController();
  final TextEditingController _usuarioEditingController = TextEditingController();
  final TextEditingController _correoEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  final _rolEditingController = 2;

  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _refreshUser() async {
    final user = await SQLHelper.getAllUser();
    setState(() {
      _allUser = user;
      _isLoading = false;
    });
  }

  Future<void> _addUser() async {
    try {
      await SQLHelper.createUser(
        _nombreEditingController.text,
        _usuarioEditingController.text,
        _correoEditingController.text,
        _passEditingController.text,
        _rolEditingController,
      );
      _refreshUser();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registro exitoso'),
          backgroundColor: Colors.green,
        ),
      );
      _nombreEditingController.clear();
      _usuarioEditingController.clear();
      _correoEditingController.clear();
      _passEditingController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _validateInputs() {
    setState(() {
      _errorMessage = '';
      _isButtonEnabled = false;

      // Validaciones en tiempo real
      if (_usuarioEditingController.text.length < 3) {
        _errorMessage += "El nombre de usuario debe ser más largo.\n";
      }

      String password = _passEditingController.text;
      _hasLetter = RegExp(r'[a-zA-Z]').allMatches(password).isNotEmpty;
      _hasNumber = RegExp(r'[0-9]').allMatches(password).isNotEmpty;
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').allMatches(password).isNotEmpty;

      // Activar el botón si todas las validaciones son correctas
      _isButtonEnabled = !_errorMessage.isNotEmpty &&
          _nombreEditingController.text.isNotEmpty &&
          _usuarioEditingController.text.isNotEmpty &&
          _correoEditingController.text.isNotEmpty &&
          _passEditingController.text.isNotEmpty &&
          _hasLetter &&
          _hasNumber &&
          _hasSpecialChar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 157, 176, 255),
        title: Text("Registro de usuarios", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white), // Icono de salida
            onPressed: cerrarSesion,
            tooltip: 'Salir',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    TextField(
                      controller: _nombreEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Nombre",
                        errorText: _nombreEditingController.text.isEmpty
                            ? 'Por favor ingresa tu nombre.'
                            : null,
                      ),
                      onChanged: (value) {
                        _validateInputs();
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _usuarioEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Usuario",
                        errorText: _usuarioEditingController.text.length < 3
                            ? 'El nombre de usuario debe tener al menos 3 caracteres.'
                            : null,
                      ),
                      onChanged: (value) {
                        _validateInputs();
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _correoEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Correo",
                        errorText: !_correoEditingController.text.contains('@')
                            ? 'Por favor ingresa un correo válido.'
                            : null,
                      ),
                      onChanged: (value) {
                        _validateInputs();
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Contraseña",
                        errorText: (_passEditingController.text.length < 3 ||
                                RegExp(r'[0-9]').allMatches(_passEditingController.text).length < 2 ||
                                RegExp(r'[!@#$%^&*(),.?":{}|<>]').allMatches(_passEditingController.text).length < 1)
                            ? 'La contraseña debe tener 3 letras, 2 números y 1 carácter especial.'
                            : null,
                      ),
                      onChanged: (value) {
                        _validateInputs();
                      },
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    // Indicadores visuales de la contraseña
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordCheck("Debe contener al menos 3 letras", _hasLetter),
                        _buildPasswordCheck("Debe contener al menos 2 números", _hasNumber),
                        _buildPasswordCheck("Debe contener al menos 1 carácter especial", _hasSpecialChar),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () async {
                              await _addUser();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 157, 176, 255),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Registrarse",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 157, 176, 255),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPasswordCheck(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Color.fromARGB(255, 157, 176, 255) : Colors.red,
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
