// import 'package:app/admin_screen.dart';
// import 'package:app/db_helper.dart';
// import 'package:app/user_screen.dart';
// import 'package:flutter/material.dart';

// class VerificationScreen extends StatefulWidget {
//   final String correo;
//   final int rol;

//   VerificationScreen({required this.correo, required this.rol});

//   @override
//   _VerificationScreenState createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   final TextEditingController _codeController = TextEditingController();
//   String? _savedCode;
//   DateTime? _codeExpiry;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCode(); // Cargar el código y la hora de expiración
//   }

//   void _loadSavedCode() {
//     // Aquí deberías cargar el código guardado y su expiración
//     _savedCode = ""; // Código enviado al correo
//     _codeExpiry; // Hora de expiración
//   }

//   void _verifyCode() async {
//   bool isValid = await SQLHelper.verifyConfirmationCode(widget.correo, _codeController.text.trim());

//   if (isValid) {
//     // Redirigir según el rol
//     if (widget.rol == 1) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => AdminPage(correoUser: widget.correo))
//       );
//     } else if (widget.rol == 2) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => UsuarioScreen(correoUser: widget.correo))
//       );
//     }
//   } else {
//     _showErrorDialog("Código incorrecto o expirado.");
//   }
// }


//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Error'),
//         content: Text(message),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Verificación de Código"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               "Ingresa el código de confirmación enviado a tu correo",
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             TextFormField(
//               controller: _codeController,
//               decoration: InputDecoration(
//                 labelText: 'Código',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _verifyCode,
//               child: Text("Verificar"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:carol_libreria/admin_screen.dart';
import 'package:carol_libreria/db_helper.dart';
import 'package:carol_libreria/producto.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  final String correo;
  final int rol;

  VerificationScreen({required this.correo, required this.rol});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  void _verifyCode() async {
    final code = _codeController.text;
    final isValid = await SQLHelper.validateConfirmationCode(widget.correo, code);

    if (isValid) {
      if (widget.rol == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage(userEmail: widget.correo)),
        );
      } else if (widget.rol == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UsuarioScreen(userEmail: widget.correo)),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Código inválido o expirado.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verificación de Código')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Introduce el código enviado a tu correo.'),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Código'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: _verifyCode,
              child: Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}