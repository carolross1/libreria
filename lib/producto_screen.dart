import 'package:carol_libreria/mainHelper.dart'; // Asegúrate de importar tu MailHelper
import 'package:carol_libreria/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:carol_libreria/db_helper.dart';
import 'main.dart';
import 'dart:async';

class ProductoScreen extends StatefulWidget {
  final String? userEmail;
  ProductoScreen({Key? key, required this.userEmail}) : super(key: key);
  @override
  State<ProductoScreen> createState() => _ProductoScreen();
}

class _ProductoScreen extends State<ProductoScreen> {
  List<Map<String, dynamic>> _allProduct = [];
  Map<int, int> _carrito = {}; // Usar un Map para manejar la cantidad de cada producto
  bool _isLoading = true;
  

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
  }

  final TextEditingController _nombreProductoEditingController = TextEditingController();
  final TextEditingController _precioProductoEditingController = TextEditingController();
  final TextEditingController _cantidadProductoEditingController = TextEditingController();
  final TextEditingController _imagenProductoEditingController = TextEditingController();

  Future<void> _addProducto() async {
    double _precio = double.parse(_precioProductoEditingController.text);
    int _cantidadProducto = int.parse(_cantidadProductoEditingController.text);

    await SQLHelper.createProducto(
      _nombreProductoEditingController.text,
      _precio,
      _cantidadProducto,
      _imagenProductoEditingController.text
    );
    _refreshProducto();
  }

  Future<void> _updateProducto(int id, int nuevaCantidad) async {
    double _precio = double.parse(_precioProductoEditingController.text);
    
    await SQLHelper.updateProducto(
      id,
      _nombreProductoEditingController.text,
      _precio,
      nuevaCantidad,
      _imagenProductoEditingController.text,
    );
    _refreshProducto();
  }

  Future<void> _deleteProducto(int id) async {
    await SQLHelper.deleteProducto(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Producto eliminado"),
    ));
    _refreshProducto();
  }

  void muestraDatos(int? id) {
    if (id != null) {
      final existingProducto = _allProduct.firstWhere((element) => element['id'] == id);
      _nombreProductoEditingController.text = existingProducto['nombre_product']; 
      _precioProductoEditingController.text = existingProducto['precio'].toString(); 
      _cantidadProductoEditingController.text = existingProducto['cantidad_producto'].toString(); 
      _imagenProductoEditingController.text = existingProducto['imagen'] ?? ""; 
    } else {
      _nombreProductoEditingController.clear();
      _precioProductoEditingController.clear();
      _cantidadProductoEditingController.clear();
      _imagenProductoEditingController.clear();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTextField("Nombre", _nombreProductoEditingController),
              _buildTextField("Precio", _precioProductoEditingController),
              _buildTextField("Cantidad de productos", _cantidadProductoEditingController),
              _buildTextField("URL de la imagen", _imagenProductoEditingController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Color.fromARGB(255, 157, 176, 255),
                  ),
                  onPressed: () async {
                    if (id == null) {
                      await _addProducto();
                    } else {
                      int cantidadActual = int.parse(_cantidadProductoEditingController.text);
                      await _updateProducto(id, cantidadActual);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    id == null ? "Agregar Producto" : "Actualizar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: hint,
          labelStyle: TextStyle(color: Color.fromARGB(255, 157, 176, 255)),
          filled: true,
          fillColor: Color(0xFFE0F2F7),
        ),
      ),
    );
  }

  // Método para agregar producto al carrito
  void _agregarAlCarrito(int id) {
    final producto = _allProduct.firstWhere((element) => element['id'] == id);

    if (producto['cantidad_producto'] > 0) { // Verifica si hay cantidad disponible
      setState(() {
        // Verifica si el producto ya está en el carrito
        if (_carrito.containsKey(id)) {
          _carrito[id] = _carrito[id]! + 1; // Incrementa la cantidad
        } else {
          _carrito[id] = 1; // Agrega el producto al carrito
        }
        producto['cantidad_producto'] -= 1; // Reduce la cantidad del producto
      });
      
      // Mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${producto['nombre_product']} agregado al carrito. Cantidad en carrito: ${_carrito[id]}"),
        backgroundColor: Colors.blue, 
        duration: Duration(seconds: 2), // Duración del mensaje
      ));
    } else {
      // Mensaje de error por falta de cantidad
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No hay suficiente cantidad disponible"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2), // Duración del mensaje
      ));
    }
  }

  // Método para ver el carrito
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
                return Text("${producto['nombre_product']} - Cantidad: ${entry.value} - \$${producto['precio'] * entry.value}");
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Método para enviar el correo con el carrito
  void _enviarCorreoConCarrito() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("El carrito está vacío, agrega productos antes de enviar."),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // Recopila los productos del carrito
    List<Map<String, dynamic>> productos = _carrito.entries.map((entry) {
      final producto = _allProduct.firstWhere((element) => element['id'] == entry.key);
      return {
        'name': producto['nombre_product'],
        'price': producto['precio'],
        'imagen': producto['imagen'],
        'cantidad': entry.value, 
      };
    }).toList();

    // Envía el correo
    await MailHelper.sendCart(productos, widget.userEmail!);
 
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Correo enviado con éxito."),
      backgroundColor: Colors.blue, 
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F6F8),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 157, 176, 255),
        title: Text("Registro de libros"),
        actions: [
          IconButton(
            onPressed: cerrarSesion,
            icon: Icon(Icons.logout_outlined, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(15),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.6,
              ),
              itemCount: _allProduct.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                elevation: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Image.network(_allProduct[index]['imagen'], height: 100, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(_allProduct[index]['nombre_product'], style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("\$${_allProduct[index]['precio']}", style: TextStyle(color: Colors.green)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            _agregarAlCarrito(_allProduct[index]['id']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            muestraDatos(_allProduct[index]['id']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteProducto(_allProduct[index]['id']);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 157, 176, 255),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: _verCarrito,
            ),
            IconButton(
              icon: Icon(Icons.email, color: Colors.white), // Icono para enviar correo
              onPressed: _enviarCorreoConCarrito,
            ),
              IconButton(
                            icon: Icon(Icons.add, color: Colors.white), // Botón de añadir producto
                            onPressed: () {
                              muestraDatos(null); // Abre el formulario para añadir un nuevo producto
                            }
            ),
          ],
        ),
      ),
    );
    
    
  }
}
