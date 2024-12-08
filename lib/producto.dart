import 'package:carol_libreria/mainHelper.dart'; 
import 'package:carol_libreria/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:carol_libreria/db_helper.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'main.dart';
import 'dart:async';

class PayPalService {
  static const String clientId = 'AUgus7JTa7g2YErejDBdvTguj0BtYALjY-a6tUJtXJc4tWftuPp-gd0ekkaIxlXPtzjZqApCO5hSEyUj';
  static const String secretKey = 'ECR82ORllK1SeQwccMVvHDbPt8muAvPbABdqgmHgPef9h6L1chAV5ERyczldkuFI4XR1UBLxQ4fEllGg';

  static Future<void> makePayment({
    required BuildContext context,
    required List<Map<String, dynamic>> cartItems,
    required String userEmail,
    required Function(Map<String, dynamic>) onSuccess,
  }) async {
    final double totalAmount = cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['cantidad'])
    );

    final paypalItems = cartItems.map((item) => {
      "name": item['name'],
      "quantity": item['cantidad'],
      "price": item['price'].toString(),
      "currency": "MXN"
    }).toList();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UsePaypal(
          sandboxMode: true,
          clientId: clientId,
          secretKey: secretKey,
          returnURL: "https://samplesite.com/return",
          cancelURL: "https://samplesite.com/cancel",
          transactions: [
            {
              "amount": {
                "total": totalAmount.toStringAsFixed(2),
                "currency": "MXN",
              },
              "description": "Compra en Carol Libreria",
              "item_list": {
                "items": paypalItems,
              }
            }
          ],
          note: "Contacta a Carol Libreria para cualquier consulta",
          onSuccess: (Map params) {
            onSuccess({
              'paymentId': params['paymentId'] ?? '',
              'orderId': params['data']?['orderID'] ?? params['orderID'] ?? '',
              'payerId': params['data']?['payerID'] ?? params['payerID'] ?? '',
              'status': 'COMPLETED',
              'fecha': DateTime.now().toString(),
              'monto': totalAmount.toStringAsFixed(2),
              'moneda': 'MXN',
              'userEmail': userEmail
            });
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error en el pago: $error'),
              backgroundColor: Colors.red,
            ));
          },
          onCancel: (params) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pago cancelado'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
      ),
    );
  }
}

class UsuarioScreen extends StatefulWidget {
  final String? userEmail;
  UsuarioScreen({Key? key, required this.userEmail}) : super(key: key);
  @override
  State<UsuarioScreen> createState() => _UsuarioScreen();
}

class _UsuarioScreen extends State<UsuarioScreen> {
  List<Map<String, dynamic>> _allProduct = [];
  Map<int, int> _carrito = {};
  bool _isLoading = true;
  late Timer _timer;
  String _welcomeMessage = '';

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void regresar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminPage(userEmail: widget.userEmail!,)),
    );
  }

  void _refreshProducto() async {
    final product = await SQLHelper.getAllProductos();
    setState(() {
      _allProduct = product;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshProducto();
    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        _welcomeMessage = '¡Bienvenido, ${widget.userEmail}!';
      });
    });
  }

  void _agregarAlCarrito(int id) {
    final producto = _allProduct.firstWhere((element) => element['id'] == id);

    if (producto['cantidad_producto'] > 0) {
      setState(() {
        if (_carrito.containsKey(id)) {
          _carrito[id] = _carrito[id]! + 1;
        } else {
          _carrito[id] = 1;
        }
        producto['cantidad_producto'] -= 1;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${producto['nombre_product']} agregado al carrito. Cantidad: ${_carrito[id]}"),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No hay suficiente cantidad en stock"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _verCarrito() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Carrito"),
          content: SingleChildScrollView(
            child: ListBody(
              children: _carrito.entries.map((entry) {
                final producto = _allProduct.firstWhere((element) => element['id'] == entry.key);
                return Text(
                  "${producto['nombre_product']}\n"
                  "Cantidad: ${entry.value}\n"
                  "Total: \$${producto['precio'] * entry.value}"
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarCorreoConCarrito() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("El carrito está vacío"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    List<Map<String, dynamic>> productos = _carrito.entries.map((entry) {
      final producto = _allProduct.firstWhere((element) => element['id'] == entry.key);
      return {
        'name': producto['nombre_product'],
        'price': producto['precio'],
        'imagen': producto['imagen'],
        'cantidad': entry.value,
      };
    }).toList();

    await MailHelper.sendCart(productos, widget.userEmail!);
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Detalles enviados por correo con éxito"),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
    ));
  }

  Future<void> _pagarConPayPal() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("El carrito está vacío"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    try {
      List<Map<String, dynamic>> cartItems = _carrito.entries.map((entry) {
        final producto = _allProduct.firstWhere((element) => element['id'] == entry.key);
        return {
          'name': producto['nombre_product'],
          'price': producto['precio'],
          'cantidad': entry.value,
        };
      }).toList();

      await PayPalService.makePayment(
        context: context,
        cartItems: cartItems,
        userEmail: widget.userEmail!,
        onSuccess: (transactionDetails) async {
          setState(() => _carrito.clear());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("¡Pago realizado con éxito!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));
          await MailHelper.sendCart(cartItems, widget.userEmail!);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al procesar el pago: $e"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F6F8),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 157, 176, 255),
        title: Text("Libros en stock"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _welcomeMessage.isEmpty ? "Cargando..." : _welcomeMessage,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _allProduct.length,
                itemBuilder: (context, index) {
                  final producto = _allProduct[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    child: ListTile(
                      leading: Image.network(producto['imagen'] ?? '', width: 50, height: 50),
                      title: Text(producto['nombre_product']),
                      subtitle: Text("Precio: \$${producto['precio']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () => _agregarAlCarrito(producto['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "cart",
            backgroundColor: const Color.fromARGB(255, 157, 176, 255),
            onPressed: _verCarrito,
            child: Icon(Icons.shopping_cart, color: Colors.white),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "email",
            backgroundColor: const Color.fromARGB(255, 157, 176, 255),
            onPressed: _enviarCorreoConCarrito,
            child: Icon(Icons.email, color: Colors.white),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "payment",
            backgroundColor: const Color.fromARGB(255, 157, 176, 255),
            onPressed: _pagarConPayPal,
            child: Icon(Icons.payment, color: Colors.white),
          ),
        ],
      ),
    );
  }
}