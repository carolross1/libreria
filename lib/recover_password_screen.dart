// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'db_helper.dart';
// import 'main.dart';
// import 'mainHelper.dart'; 

// class RecuperarPassScreen extends StatelessWidget {
//   final TextEditingController _emailController = TextEditingController();

//   // Función para generar una contraseña aleatoria
//   String _generateRandomPassword() {
//     const letras = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
//     const numeros = '0123456789';
//     const caracteresEspeciales = '!@#\$%^&*()_+[]{}|;:,.<>?';

//     Random random = Random();

//     String password = '';
//     password += String.fromCharCode(letras.codeUnitAt(random.nextInt(letras.length)));
//     password += String.fromCharCode(letras.codeUnitAt(random.nextInt(letras.length)));
//     password += String.fromCharCode(letras.codeUnitAt(random.nextInt(letras.length)));
//     password += numeros[random.nextInt(numeros.length)];
//     password += numeros[random.nextInt(numeros.length)];
//     password += caracteresEspeciales[random.nextInt(caracteresEspeciales.length)];

//     return password;
//   }

//   void regresar(BuildContext context) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//   }

//   // Función para enviar el correo y actualizar la contraseña
//   void _sendRecoveryEmail(BuildContext context) async {
//     final email = _emailController.text;
//     final users = await SQLHelper.getAllUser();
//     final user = users.firstWhere((user) => user['correo'] == email);

//     if (user != null) {
//       String nuevaContrasenia = _generateRandomPassword();
//       await SQLHelper.updatePassword(email, nuevaContrasenia);
//       await MailHelper1.sendRecoveryEmail(email, nuevaContrasenia);

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Recuperación de Contraseña'),
//           content: Text('Se han enviado las instrucciones de recuperación al correo $email'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Regresar al inicio
//               },
//               child: Text('Aceptar'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('No se encontró un usuario con ese correo electrónico'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Aceptar'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 157, 176, 255),
//         title: Text(
//           'CAROL LIBRERIA',
//           style: TextStyle(
//             fontFamily: 'DancingScript',
//             fontSize: 26,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             letterSpacing: 1.2,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Image.network(
//                   'https://img.freepik.com/vector-premium/libro-luna-estrellas-el_730620-510344.jpg',
//                   height: 150,
//                   width: 150,
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'Recuperar Contraseña',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 35,
//                     fontWeight: FontWeight.bold,
//                     color: const Color.fromARGB(255, 157, 176, 255),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Correo Electrónico',
//                     prefixIcon: Icon(Icons.email),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16.0),
//                     backgroundColor: const Color.fromARGB(255, 157, 176, 255),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   onPressed: () => _sendRecoveryEmail(context),
//                   child: Text(
//                     'Enviar Instrucciones',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16.0),
//                     backgroundColor: Colors.redAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   onPressed: () => regresar(context),
//                   child: Text(
//                     'Regresar',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
