import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailHelper {
  static Future<void> sendCart(List<Map<String, dynamic>> productos, String correoUsuario, [String nombreUsuario = 'Usuario Anónimo']) async {
    // Información de autenticación
    String username = 'carolrios347@gmail.com'; 
    String password = 'hguo fhdw tbvm nmyx';    
    String destinoUsuario = correoUsuario;
    final smtpServer = gmail(username, password);

    // Calcular el total y la lista de productos
    double total = 0.0;
    String productListHtml = productos.map((producto) {
      double precio = producto['price'];
      int cantidad = producto['cantidad']; 
      total += precio * cantidad; // Sumar el total de la compra
      return """
      <div style="margin-bottom: 20px; border: 1px solid #ccc; padding: 10px; border-radius: 8px; background-color: #f9f9f9;">
        <h3 style="margin: 0; color: #005D8F;">${producto['name']}</h3>
        <p style="margin: 5px 0;">Precio: \$${precio.toStringAsFixed(2)}</p>
        <p style="margin: 5px 0;">Cantidad: $cantidad</p>
        <p style="margin: 5px 0;">Subtotal: \$${(precio * cantidad).toStringAsFixed(2)}</p>
        <img src="${producto['imagen']}" alt="${producto['name']}" width="60" style="border-radius: 4px; border: 1px solid #ddd;">
      </div>
      """;
    }).join();

    // Crear el mensaje para el usuario
    final messageUsuario = Message()
      ..from = Address(username, 'Carol Rios')
      ..recipients.add(destinoUsuario)  // Correo del usuario
      ..text = 'Este es el resumen de tu compra...'
      ..subject = 'Carol Libreria:)Resumen de tu compra - ${DateTime.now()}'
      ..html = """
        <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; background-color: #f0f0f0; color: #333; padding: 20px; }
              h1 { color: #94c1ff; }  /* Color #FF9DB0 */
              h2 { color: #94c1ff; }
              .total { font-size: 20px; font-weight: bold; }
            </style>
          </head>
          <body>
            <h1>Resumen de tu compra</h1>
            <div>
              $productListHtml
              <h2 class="total">Total: \$${total.toStringAsFixed(2)}</h2>
            </div>
            <p style="margin-top: 20px;">Gracias por comprar con nosotros. ¡Vuelve pronto...!</p>
          </body>
        </html>
      """;

    // Crear el mensaje para ti (administrador)
    final messageCarol = Message()
      ..from = Address(username, 'Carol Rios')
      ..recipients.add('carolrios347@gmail.com')  // Correo adicional para ti
      ..subject = 'Nueva compra realizada - ${DateTime.now()}'
      ..text = 'Se ha realizado una nueva compra...'
      ..html = """
        <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; background-color: #f0f0f0; color: #333; padding: 20px; }
              h1 { color: #94c1ff; }  /* Color #FF9DB0 */
              h2 { color: #94c1ff; }
              .total { font-size: 20px; font-weight: bold; }
              .usuario { font-weight: bold; color: #005D8F; }
            </style>
          </head>
          <body>
            <h1>Detalles de la compra realizada</h1>
            <p><span class="usuario">Usuario:</span> $nombreUsuario ($correoUsuario)</p>
            <div>
              $productListHtml
              <h2 class="total">Total: \$${total.toStringAsFixed(2)}</h2>
            </div>
            <p style="margin-top: 20px;">¡Una nueva compra ha sido realizada! Revisa los detalles.</p>
          </body>
        </html>
      """;

    try {
      // Enviar el correo al usuario
      final sendReportUsuario = await send(messageUsuario, smtpServer);
      print('Correo al usuario enviado: ${sendReportUsuario.toString()}');
      
      // Enviar el correo a Carol
      final sendReportCarol = await send(messageCarol, smtpServer);
      print('Correo a Carol enviado: ${sendReportCarol.toString()}');
      
      print('Los correos se han enviado exitosamente.');
    } on MailerException catch (e) {
      print('Error al enviar el correo: ${e.toString()}');
    }
  }
}
class MailHelper1 {
  static Future<void> sendRecoveryEmail(String correo, String nuevaContrasenia) async {
    String username = 'carolrios347@gmail.com'; 
    String password = 'hguo fhdw tbvm nmyx'; 

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Recuperación de Contraseña')
      ..recipients.add(correo)
      ..subject = 'Recuperación de Contraseña - ${DateTime.now()}'
      ..html = """
        <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; background-color: #f0f0f0; color: #333; padding: 20px; }
              h1 { color: #94c1ff; }
              p { margin: 5px 0; font-size: 16px; }
              .highlight { color: #005D8F; font-weight: bold; }
              .container {
                background-color: #ffffff;
                border: 1px solid #ddd;
                border-radius: 8px;
                padding: 20px;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
              }
              .footer {
                margin-top: 20px;
                font-size: 14px;
                color: #555;
              }
            </style>
          </head>
          <body>
            <h1>Recuperación de Contraseña</h1>
            <div class="container">
              
              <p>Hola,hemos recibido tu solicitud para restablecer tu contraseña.</p>
              <p>Tu nueva contraseña es:</p>
              <p class="highlight">$nuevaContrasenia</p>
              <p>Ingresa tu usuario y tu nueva contraseña para poder ingresar en la aplicación.</p>
            </div>
            <div class="footer">
              <p>Si no solicitaste este cambio, envia un correo a carolrios347@gmail.com.</p>
              <p>Gracias por usar nuestra aplicación.</p>
            </div>
          </body>
        </html>
      """;

    try {
      await send(message, smtpServer);
      print('Correo de recuperación enviado a $correo');
    } on MailerException catch (e) {
      print('Error al enviar el correo: $e');
    }
  }
}
