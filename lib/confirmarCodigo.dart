import 'package:carol_libreria/cambiarContra.dart';
import 'package:carol_libreria/main.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Para Timer

class ConfirmCodeScreen extends StatefulWidget {
  final String email;
  final String sentCode;

  ConfirmCodeScreen({required this.email, required this.sentCode});

  @override
  _ConfirmCodeScreenState createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  late Timer _timer;
  int _seconds = 60; // Tiempo inicial de 60 segundos

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  // Iniciar el temporizador
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer.cancel(); // Detener el temporizador cuando llegue a 0
          abandonarPage(); // Ir a la pantalla de inicio de sesión
        }
      });
    });
  }

  // Función para ir a la pantalla de inicio de sesión
  void abandonarPage() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancelar el temporizador cuando la pantalla se destruya
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Código de Confirmación'),
        backgroundColor: Color.fromARGB(255, 157, 176, 255),
      ),
      backgroundColor: Color(0xFFDFE7E4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reestablecer Contraseña',
                // style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 157, 176, 255),
              ),
              ),
              SizedBox(height: 20),
              Text(
                'Ingresa el código que enviamos a:',
                textAlign: TextAlign.center,
                // style: TextStyle(
                //   fontWeight: FontWeight.bold,
                //   fontSize: 16,
                // ),
                style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 149, 170, 255),
              ),
              ),
              
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
          
              ),
              SizedBox(height: 16),
              Text(
                'Tienes $_seconds segundos para confirmar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 226, 157, 255)),

              ),
              SizedBox(height: 16),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Ingrese el Código',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (codeController.text == widget.sentCode) {
                    _cancelTimer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CambiarContraScreen(correo: widget.email),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('El código es incorrecto'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 157, 176, 255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                ),
                child: Text(
                  'Confirmar',
                  // style: TextStyle(fontWeight: FontWeight.bold),
                  style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}