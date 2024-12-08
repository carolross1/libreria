import 'dart:math';

import 'package:sqflite/sqflite.dart' as sql;
import 'dart:convert';
import 'package:crypto/crypto.dart';


class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE user_app(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      nombre TEXT NOT NULL UNIQUE,
      usuario TEXT NOT NULL,
      correo TEXT NOT NULL,
      pass TEXT NOT NULL,
      rol INTEGER NOT NULL,
      createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute("""CREATE TABLE producto_app(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      nombre_product TEXT,
      precio DOUBLE,
      cantidad_producto INTEGER,
      imagen TEXT,
      createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute("""
    CREATE TABLE confirmation_codes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL,
      code TEXT NOT NULL,
      expiry INTEGER NOT NULL
    )""");

    await database.execute("""
    CREATE TABLE reset_password_codes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL,
      code TEXT NOT NULL,
      expiry INTEGER NOT NULL
    )""");

    await database.execute("""
      INSERT INTO user_app (nombre, usuario, correo, pass, rol, createdAT)
      VALUES ('admin', 'admin', 'carolrios347@gmail.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', '1', ''
    )""");

    await database.execute("""
      INSERT INTO user_app (nombre, usuario, correo, pass, rol, createdAT)
      VALUES ('sadmin', 'sadmin', 'cynthiajanethgranados@gmail.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', '1', ''
    )""");

    await database.execute("""
      INSERT INTO producto_app (nombre_product, precio, cantidad_producto, imagen, createdAT)
      VALUES ('Antes de diciembre', '450', '100', 'https://m.media-amazon.com/images/I/71huiTGJqGL.jpg', ''
    )""");

    await database.execute("""
      INSERT INTO producto_app (nombre_product, precio, cantidad_producto, imagen, createdAT)
      VALUES ('Harry Potter y la piedra filosofal', '420', '50', 'https://m.media-amazon.com/images/I/81dxFCnAp0L.AC_UF1000,1000_QL80.jpg', ''
    )""");

    await database.execute("""
      INSERT INTO producto_app (nombre_product, precio, cantidad_producto, imagen, createdAT)
      VALUES ('Todo lo que nunca fuimos', '256', '50', 'https://www.planetadelibros.com/usuaris/libros/fotos/290/original/portada_todo-lo-que-nunca-fuimos_alice-kellen_201901111422.jpg', ''
    )""");
    await database.execute("""
      INSERT INTO producto_app (nombre_product, precio, cantidad_producto, imagen, createdAT)
      VALUES ('Damián', '520', '50', 'https://m.media-amazon.com/images/I/61iOugQFnGL.AC_UF1000,1000_QL80.jpg', ''
    )""");

  }

static Future<int> updatePassword(
      String correo, String nuevaContrasenia) async {
    String contraHasheada = verificarPass(nuevaContrasenia);
    final db = await SQLHelper.db();
    final result = await db.update(
      'user_app',
      {'pass': contraHasheada},
      where: "correo = ?",
      whereArgs: [correo],
    );
    return result;
  }

  static Future<bool> isEmailRegistered(String email) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> result = await db.query(
      'user_app',
      where: 'correo = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  static String verificarPass(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database_app22.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  Future<List<String>> getPermissionsForUser(int userId) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> permiso_user = await db.query('rol_permiso',
        columns: ['rol'], where: 'userId = ?', whereArgs: [userId]);

    return List.generate(permiso_user.length, (index) {
      return permiso_user[index]['rol'].toString();
    });
  }

  static Future<int> createUser(String nombre, String usuario, String correo,
      String pass, int rol) async {
    try {
      String contraHasheada = verificarPass(pass);
      final db = await SQLHelper.db();
      final user_app = {
        'nombre': nombre,
        'usuario': usuario,
        'correo': correo,
        'pass': contraHasheada,
        'rol': rol
      };
      // Intentar insertar el usuario
      final id = await db.insert(
        'user_app',
        user_app,
        conflictAlgorithm:
            sql.ConflictAlgorithm.abort, // Evitar reemplazo automático
      );
      return id;
    } catch (e) {
      // Convertir el error a una cadena para analizarlo
      final errorMessage = e.toString();

      // Manejar conflictos específicos
      if (errorMessage.contains('UNIQUE constraint failed: user_app.correo')) {
        throw Exception('El correo ya está registrado.');
      } else if (errorMessage
          .contains('UNIQUE constraint failed: user_app.usuario')) {
        throw Exception('El nombre de usuario ya está en uso.');
      }

      // Lanzar cualquier otro error de la base de datos
      throw Exception(errorMessage);
    }
  }

  static Future<int> createProducto(String nombre_product, double precio,
      int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final producto_app = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': cantidad_producto,
      'imagen': imagen
    };
    final id = await db.insert('producto_app', producto_app,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<bool> login_user(String usuario, String pass, int rol) async {
    final db = await SQLHelper.db();
    String compararContra = verificarPass(pass);
    List<Map<String, dynamic>> user = await db.query('user_app',
        where: 'usuario = ? AND pass = ? AND rol = ?',
        whereArgs: [usuario, compararContra, rol]);

    if (user.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await SQLHelper.db();
    return db.query('user_app', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getAllProductos() async {
    final db = await SQLHelper.db();
    return db.query('producto_app', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleUser(
      String usuario, String pass) async {
    String contraHasheada = verificarPass(pass);
    final db = await SQLHelper.db();
    return db.query('user_app',
        where: "usuario = ? AND pass = ?",
        whereArgs: [usuario, contraHasheada],
        limit: 1);
  }

  static Future<int> updateUser(int id, String nombre, String usuario,
      String correo, String pass, int rol) async {
    // String contraHasheada = verificarPass(pass);
    final db = await SQLHelper.db();
    final user = {
      'nombre': nombre,
      'usuario': usuario,
      'correo': correo,
      'pass': pass,
      'rol': rol,
      'createdAT': DateTime.now().toString()
    };

    final result =
        await db.update('user_app', user, where: "id=?", whereArgs: [id]);
    return result;
  }

  static Future<bool> cambiarContraUser(String pass, String correo) async {
    final contrasena_Hash = verificarPass(pass);
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> result = await db.query(
      'user_app',
      where: 'correo = ?',
      whereArgs: [correo],
    );
    if (result.isNotEmpty) {
      final user = {
        'pass': contrasena_Hash,
      };
      final salio = await db
          .update('user_app', user, where: "correo=?", whereArgs: [correo]);
      //Esto si está bie, el salio sale con 1
      //print('BACKEND $salio');
      if (salio > 0) {
        return true;
      }
    }
    return false;
  }

  static Future<int> updateProducto(int id, String nombre_product,
      double precio, int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final product = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': cantidad_producto,
      'imagen': imagen,
      'createdAT': DateTime.now().toString()
    };

    final result = await db
        .update('producto_app', product, where: "id=?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteUser(int id) async {
    final db = await SQLHelper.db();
    await db.delete('user_app', where: "id=?", whereArgs: [id]);
  }
  // Método para eliminar usuario, con validación para no eliminar al superadministrador
// Future<void> deleteUser(int id, int rol) async {
//   if (rol == 3) {
//     throw Exception("No se puede eliminar al superadministrador.");
//   }
//   final db = await database();
//   await db.delete(
//     'user_app',
//     where: "id = ?",
//     whereArgs: [id],
//   );
// }

  static Future<void> deleteProducto(int id) async {
    final db = await SQLHelper.db();
    await db.delete('producto_app', where: "id=?", whereArgs: [id]);
  }

  static String generateConfirmationCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000))
        .toString(); // Generates 6-digit code
  }

  static Future<void> saveConfirmationCode(String email, String code) async {
    final db = await SQLHelper.db();

    // Delete any existing codes for this email
    await db.delete(
      'reset_password_codes',
      where: 'email = ?',
      whereArgs: [email],
    );

    // Save new code with expiry time (10 minutes from now)
    final expiryTime =
        DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch;
    await db.insert('reset_password_codes', {
      'email': email,
      'code': code,
      'expiry': expiryTime,
    });
  }

  static Future<bool> verifyConfirmationCode(String email, String code) async {
    final db = await SQLHelper.db();
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await db.query(
      'reset_password_codes',
      where: 'email = ? AND code = ? AND expiry > ?',
      whereArgs: [email, code, now],
    );

    if (result.isNotEmpty) {
      // Delete the used code
      await db.delete(
        'reset_password_codes',
        where: 'email = ?',
        whereArgs: [email],
      );
      return true;
    }
    return false;
  }

  static Future<void> saveConfirmationCode1(
      String email, String code, int expiry) async {
    final db = await SQLHelper.db();

    // Eliminar cualquier código anterior asociado al correo
    await db
        .delete('reset_password_codes', where: 'email = ?', whereArgs: [email]);

    // Insertar el nuevo código
    await db.insert('reset_password_codes', {
      'email': email,
      'code': code,
      'expiry': expiry,
    });
  }

  // Método para obtener el rol del usuario según el email
  Future<int> getRoleByEmail(String email) async {
    final db = await SQLHelper.db(); // Accede a la base de datos

    // Realiza la consulta para obtener el usuario por email
    var result = await db.query(
      'usuarios', // Suponiendo que la tabla de usuarios es 'usuarios'
      where: 'email = ?',
      whereArgs: [email],
    );

    // Verifica si el resultado contiene datos
    if (result.isNotEmpty) {
      var user = result.first; // Obtiene el primer (y único) usuario encontrado
      if (user.containsKey('rol')) {
        // Verifica si el campo 'rol' existe en la fila
        return user['rol']
            as int; // Devuelve el rol (asegúrate de que sea del tipo esperado)
      } else {
        throw Exception('Campo "rol" no encontrado en la base de datos');
      }
    } else {
      throw Exception('Usuario no encontrado');
    }
  }

  static Future<void> saveConfirmationCodeLogin(String email, String code, int expiry) async {
  final db = await SQLHelper.db();
  await db.insert('confirmation_codes', {
    'email': email,
    'code': code,
    'expiry': expiry,
  });
}

static Future<bool> validateConfirmationCode(String email, String code) async {
  final db = await SQLHelper.db();
  final result = await db.query(
    'confirmation_codes',
    where: 'email = ? AND code = ? AND expiry > ?',
    whereArgs: [email, code, DateTime.now().millisecondsSinceEpoch],
  );

  if (result.isNotEmpty) {
    // Eliminar el código tras la validación
    await db.delete(
      'confirmation_codes',
      where: 'email = ? AND code = ?',
      whereArgs: [email, code],
    );
    return true;
  }
  return false;
}


}