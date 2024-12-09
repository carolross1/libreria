import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

class PayPalService {
  static const String clientId = 'AWMNfG7yK5QdAq5TUcGjihljEjqgpQiCdfyFQim8YE-YzhKx9MnPRcfgQ6m-OJVH4RenZdgjaqnvmI-2';
  static const String secretKey = 'EF9goQvR7Hu2fBtkb-h0xiRuazksuVFGy_2TrRlE7XqdrlaHJ_m3R9dg3GMcvzjVA1qGh7M9M2HFHWnA';

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