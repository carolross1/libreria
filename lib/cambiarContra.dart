import 'package:carol_libreria/db_helper.dart';
import 'package:carol_libreria/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CambiarContraScreen extends StatefulWidget {
  final String correo;

  CambiarContraScreen({Key? key, required this.correo}) : super(key: key);

  @override
  _CambiarContraScreenState createState() => _CambiarContraScreenState();
}

class _CambiarContraScreenState extends State<CambiarContraScreen> {
  bool _showErrorMessages = false;
  String _errorMessage = '';
  bool _isButtonEnabled = false;
  Timer? _timer;
  final Duration _timeoutDuration = Duration(seconds: 60);

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void laFun() async {
    final bool resultado = await compruebaContrasena();
    print("Resultado: $resultado");

    if (resultado == true) {
      _cancelTimer();
      abandonnerPage();
    }
  }

  Future<bool> compruebaContrasena() async {
    final resultat = await SQLHelper.cambiarContraUser(
        confirmPasswordController.text, widget.correo);
    return resultat;
  }

  @override
  void initState() {
    super.initState();
    _startTimeout();
    passwordController.addListener(_validateInputs);
    confirmPasswordController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _timer?.cancel();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    int letterCount = RegExp(r'[a-zA-Z]').allMatches(password).length;
    int numberCount = RegExp(r'[0-9]').allMatches(password).length;
    int specialCharCount = RegExp(r'[!@#$%^&*(),.?":{}|<>]').allMatches(password).length;

    String newErrorMessage = '';
    bool hasError = false;

    if (letterCount < 3) {
      newErrorMessage += '✘ La contraseña debe tener al menos 3 letras.\n';
      hasError = true;
    } else {
      newErrorMessage += "✔ Contiene al menos 3 letras.\n";
    }

    if (numberCount < 2) {
      newErrorMessage += '✘ La contraseña debe tener al menos 2 números.\n';
      hasError = true;
    } else {
      newErrorMessage += "✔ Contiene al menos 2 números.\n";
    }

    if (specialCharCount < 1) {
      newErrorMessage += '✘ La contraseña debe tener al menos 1 carácter especial.\n';
      hasError = true;
    } else {
      newErrorMessage += "✔ Contiene al menos 1 carácter especial.\n";
    }

    setState(() {
      _errorMessage = newErrorMessage;
      _showErrorMessages = true;
      _isButtonEnabled = !hasError && password.isNotEmpty && confirmPassword.isNotEmpty;
    });
  }

  void _startTimeout() {
    _timer = Timer(_timeoutDuration, abandonnerPage);
  }

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _startTimeout();
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  void abandonnerPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Contraseña'),
        backgroundColor: Color(0xFF008FF7),
      ),
      backgroundColor: Color(0xFFDFE7E4),
      body: GestureDetector(
        onTap: _resetTimer, // Reiniciar el temporizador al tocar cualquier área de la pantalla
        child: WillPopScope(
          onWillPop: () async {
            // Cancelar el temporizador si el usuario intenta regresar
            _cancelTimer();
            return true;
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ingresa tu Nueva Contraseña',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _resetTimer(), 
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _resetTimer(), 
                  ),
                  SizedBox(height: 16),
                  if (_showErrorMessages)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _errorMessage
                          .trim()
                          .split('\n')
                          .map((error) => Row(
                                children: [
                                  Icon(
                                    error.startsWith('✔')
                                        ? Icons.check_circle
                                        : Icons.close,
                                    color: error.startsWith('✔')
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      error.replaceFirst(RegExp(r'[✔✘]'), ''),
                                      style: TextStyle(
                                        color: error.startsWith('✔')
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            if (passwordController.text ==
                                confirmPasswordController.text) {
                              laFun();
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Las contraseñas no coinciden'),
                                  actions: [
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF008FF7),
                    ),
                    child: Text(
                      'Cambiar Contraseña',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}