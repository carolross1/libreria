import 'package:carol_libreria/confirmarCodigo.dart';
import 'package:carol_libreria/db_helper.dart';
import 'package:carol_libreria/main.dart';
import 'package:carol_libreria/mainHelper.dart';
import 'package:carol_libreria/register_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class restablecerContraScreen extends StatefulWidget {
  @override
  State<restablecerContraScreen> createState() => _restablecerContraScreen();
}

class _restablecerContraScreen extends State<restablecerContraScreen> {
  bool _showErrorMessages = false;
  String _errorMessage = '';
  bool _isButtonEnabled = false;
  Timer? _timer;
  final Duration _timeoutDuration = Duration(seconds: 60);

  final TextEditingController _correoEditingController =
      TextEditingController();

  void _validateInputs() {
    _errorMessage = '';
    bool hasError = false;

    // Validar correo electrónico
    String email = _correoEditingController.text;
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _errorMessage += "✘ Correo NO válido.\n";
      hasError = true;
    } else {
      _errorMessage += "✔ Correo válido.\n";
    }

    setState(() {
      _showErrorMessages = true;
      _isButtonEnabled = !hasError && _correoEditingController.text.isNotEmpty;
    });
  }

  void _startTimeout() {
    // Reiniciar el temporizador desde cero cada vez
    _timer?.cancel(); // Cancelar cualquier temporizador anterior
    _timer =
        Timer(_timeoutDuration, abandonnerPage); // Iniciar el nuevo temporizador
  }

  void _resetTimer() {
    _startTimeout(); // Reiniciar el temporizador
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  void abandonnerPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  void initState() {
    super.initState();
    _startTimeout(); // Iniciar el temporizador cuando se cree la pantalla
    _correoEditingController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _correoEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _resetTimer, // Reiniciar el temporizador cuando se toca la pantalla
        child: Scaffold(
          appBar: AppBar(
            title: Text("Nueva Contraseña",
            style: TextStyle(
            color: Colors.white,
          ),
            ),
            backgroundColor: Color.fromARGB(255, 157, 176, 255),
            actions: [
              IconButton(
                onPressed: abandonnerPage,
                icon: Icon(
                  Icons.logout,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                tooltip: "Salir",
              ),
            ],
          ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          body: Center(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Asegura que los hijos estén centrados horizontalmente
        children: [
          Center( // Asegura el centrado del texto
            child: Text(
              '¿Cuál es tu correo electrónico?',
              textAlign: TextAlign.center, // Alinea el texto dentro de su propio espacio
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 157, 176, 255),
              ),
            ),
          ),

                    SizedBox(height: 20),
                    Form(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _correoEditingController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _resetTimer(),
                          ),
                          SizedBox(height: 20),
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
                                                ? const Color.fromARGB(255, 157, 176, 255)
                                                : const Color.fromARGB(255, 179, 103, 255),
                                            size: 20,
                                          ),
                                          SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              error.replaceFirst(
                                                  RegExp(r'[✔✘]'), ''),
                                              style: TextStyle(
                                                color: error.startsWith('✔')
                                                    ? const Color.fromARGB(255, 157, 176, 255)
                                                    : const Color.fromARGB(255, 179, 103, 255),
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
                                    register_user(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isButtonEnabled
                                  ? const Color.fromARGB(255, 157, 176, 255)
                                  : const Color.fromARGB(255, 157, 176, 255),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Enviar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void register_user(BuildContext context) async {
    final response =
        await SQLHelper.isEmailRegistered(_correoEditingController.text);

    String generateCode() {
      final random = Random();
      return List.generate(6, (_) => random.nextInt(10)).join();
    }

    void register_user() async {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => RegisterScreen()));
    }

    if (response == true) {
      _cancelTimer();
      final String generatedCode = generateCode();
      await MailHelper1.sendConfirmationCode(
          _correoEditingController.text, generatedCode);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmCodeScreen(
            email: _correoEditingController.text,
            sentCode: generatedCode,
          ),
        ),
      );
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Ha ocurrido un error'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text('Correo no encontrado'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: register_user,
                        child: const Text('Registrarse'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, 'Cancelar'),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              ));
    }
  }
}
