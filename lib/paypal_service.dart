import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

class PayPalService {
  static const String clientId = 'AUgus7JTa7g2YErejDBdvTguj0BtYALjY-a6tUJtXJc4tWftuPp-gd0ekkaIxlXPtzjZqApCO5hSEyUj';
  static const String secretKey = 'ECR82ORllK1SeQwccMVvHDbPt8muAvPbABdqgmHgPef9h6L1chAV5ERyczldkuFI4XR1UBLxQ4fEllGg';

  static Future<void> makePayment({
    required BuildContext context,
    required List<Map<String, dynamic>> cartItems,
    required String userEmail,
    required Function(Map<String, dynamic>) onSuccess,
  }) async {
    // Calcular el monto total
    double totalAmount = cartItems.fold(0, (sum, item) => 
      sum + (item['price'] * item['cantidad']));

    // Convertir items del carrito al formato de PayPal
    final paypalItems = cartItems.map((item) => {
      "name": item['name'],
      "quantity": item['cantidad'],
      "price": item['price'].toString(),
      "currency": "MXN"
    }).toList();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
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
            print('Pago exitoso: $params');
            
            final transactionDetails = {
              'paymentId': params['paymentId'] ?? '',
              'orderId': params['data']?['orderID'] ?? params['orderID'] ?? '',
              'payerId': params['data']?['payerID'] ?? params['payerID'] ?? '',
              'status': 'COMPLETED',
              'fecha': DateTime.now().toString(),
              'monto': totalAmount.toStringAsFixed(2),
              'moneda': 'MXN',
              'userEmail': userEmail
            };
            
            onSuccess(transactionDetails);
          },
          onError: (error) {
            print("Error: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error en el pago: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
          onCancel: (params) {
            print("Cancelado: $params");
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