import 'dart:math';
import 'package:carol_libreria/admin_screen.dart';
import 'package:carol_libreria/confirmarCodigoLogin.dart';
import 'package:carol_libreria/db_helper.dart';
import 'package:carol_libreria/geo_screen.dart';
import 'package:carol_libreria/local_auth.dart';
import 'package:carol_libreria/mainHelper.dart';
import 'package:carol_libreria/restablecerContra.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:provider/provider.dart'; // Agregar esta importación
import 'theme_notifier.dart'; // Importar el archivo que contiene el ThemeNotifier

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener el tema actual del ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'CE Store',
      themeMode: themeNotifier.themeMode, // Establecer el tema actual
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema oscuro
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController _usuarioEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  int _rolEditingController = 2;
  bool _isPasswordVisible = false;
  String _errorMessage = '';
  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool auth = false;

  void registrarse() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void recuperarContrasena() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => restablecerContraScreen()),
    );
  }

   // Método para mostrar un cuadro de diálogo con el mensaje de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }


  // void login_user() async {
  //   List<Map<String, dynamic>> obtenerRol = await SQLHelper.getSingleUser(
  //     _usuarioEditingController.text, _passEditingController.text);
  //   final correo = obtenerRol[0]['correo'];

  //   if (obtenerRol.isNotEmpty){
  //     _rolEditingController = obtenerRol[0]['rol'];
  //   }

  //   bool _isLogin = await SQLHelper.login_user(
  //     _usuarioEditingController.text, _passEditingController.text, _rolEditingController);

  //   if (_isLogin && _rolEditingController == 1){
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => AdminPage(correoUser: correo)));
  //   } else if (_isLogin && _rolEditingController == 2){
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => UsuarioScreen(correoUser: correo)));
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Error'),
  //         content: Text('Usuario o contraseña incorrectos'),
  //       ),
  //     );
  //   }
  // }

  void login_user() async {
  List<Map<String, dynamic>> obtenerRol = await SQLHelper.getSingleUser(
    _usuarioEditingController.text,
    _passEditingController.text,
  );

  if (obtenerRol.isNotEmpty) {
    final correo = obtenerRol[0]['correo'];
    final rol = obtenerRol[0]['rol'];

    bool _isLogin = await SQLHelper.login_user(
      _usuarioEditingController.text,
      _passEditingController.text,
      rol,
    );

    String _generateConfirmationCode() {
  final random = Random();
  return String.fromCharCodes(
    List.generate(6, (_) => random.nextInt(10) + 48), // Código de 6 dígitos
  );
}


    if (_isLogin) {
      // Generar código único
      String code = _generateConfirmationCode();
      int expiry = DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch;

      // Guardar código en la base de datos
      await SQLHelper.saveConfirmationCodeLogin(correo, code, expiry);

      // Enviar código por correo
      await MailHelper1.sendConfirmationCode(correo, code);

      // Navegar a la pantalla de verificación
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            correo: correo,
            rol: rol,
          ),
        ),
      );
    } else {
      _showErrorDialog("Usuario o contraseña incorrectos");
    }
  } else {
    _showErrorDialog("Usuario o contraseña incorrectos");
  }
}


  void _validateInputs() {
    setState(() {
      _errorMessage = '';
      if (_usuarioEditingController.text.length < 3) {
        _errorMessage += "El nombre de usuario debe ser más largo.\n";
      }
      String password = _passEditingController.text;
      _hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}[]|<>]').hasMatch(password);
    });
  }

  Widget _buildPasswordCheck(String text, bool conditionMet) {
    return Row(
      children: [
        Icon(
          conditionMet ? Icons.check_circle : Icons.cancel,
          color: conditionMet ? Colors.green : Colors.red,
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 8, 44),
        title: Text(
          'CE Store',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.location_on, color: Colors.white),
            tooltip: 'Ubicación',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeolocatorWidget()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.brightness_6, color: Colors.white),
            tooltip: 'Cambiar Tema',
            onPressed: () {
              // Cambiar el tema al presionar el botón
              final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      floatingActionButton: auth == true
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final authen = await LocalAuth.authenticate();
                if (authen){
                  auth = false;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage(userEmail: "")));//se debe cambiar
                }
              },
              child: const Icon(Icons.fingerprint),
            ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  'https://steamuserimages-a.akamaihd.net/ugc/795364376392144071/C27E4FC2EF96E61787AB5524D35AAFE4D32DB942/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 9, 8, 44),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _usuarioEditingController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passEditingController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: !_isPasswordVisible,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPasswordCheck("Debe tener al menos 3 letras", _hasLetter),
                    _buildPasswordCheck("Debe tener al menos 2 números", _hasNumber),
                    _buildPasswordCheck("Debe tener al menos 1 carácter especial", _hasSpecialChar),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color.fromARGB(255, 9, 8, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(double.infinity, 0),
                  ),
                  onPressed: login_user,
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: registrarse,
                      child: Text(
                        'Regístrate aquí',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: recuperarContrasena,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
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
    );
  }
}