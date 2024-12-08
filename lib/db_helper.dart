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

    await database.execute("""
      INSERT INTO user_app (nombre, usuario, correo, pass, rol, createdAT)
      VALUES ('admin', 'admin', 'carolrios347@gmail.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', '1', ''
    )""");
  }



static String verificarPass(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  static Future<sql.Database> db() async {
    return sql.openDatabase("database_app934.db", version: 1,
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
  

  static Future<int> createUser(String nombre, String usuario, String correo, String pass, int rol) async {
    print(pass);
    String contraHasheada = verificarPass(pass);
    print(contraHasheada);
    final db = await SQLHelper.db();
    final user_app = {'nombre': nombre, 'usuario': usuario, 'correo': correo, 'pass': contraHasheada, 'rol': rol};
    final id = await db.insert('user_app', user_app,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> createProducto(String nombre_product, double precio, int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final producto_app = {'nombre_product': nombre_product, 'precio': precio, 'cantidad_producto': cantidad_producto, 'imagen': imagen};
    final id = await db.insert('producto_app', producto_app,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<bool> login_user(String usuario, String pass, int rol) async {
    final db = await SQLHelper.db();
    print(pass);
    String compararContra = verificarPass(pass);
    print(usuario);
    print(rol);
    print(compararContra);
    List<Map<String, dynamic>> user = await db.query('user_app',
        where: 'usuario = ? AND pass = ? AND rol = ?', whereArgs: [usuario, compararContra, rol]);

    if (user.isNotEmpty) {
      print("true");
      return true;
    } else {
      print("false");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await SQLHelper.db();
    print(db.query('user_app', orderBy: 'id'));
    return db.query('user_app', orderBy: 'id');
  }


  static Future<List<Map<String, dynamic>>> getAllProductos() async {
    final db = await SQLHelper.db();
    return db.query('producto_app', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleUser(String usuario, String pass) async {
    String contraHasheada = verificarPass(pass);
    final db = await SQLHelper.db();
    return db.query('user_app', where: "usuario = ? AND pass = ?", whereArgs: [usuario, contraHasheada], limit: 1);
  }

  static Future<int> updateUser(int id, String nombre, String usuario, String correo, String pass, int rol) async {
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
  static Future<int> updatePassword(String correo, String nuevaContrasenia) async {
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

  static Future<int> updateProducto(int id, String nombre_product, double precio, int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final product = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': cantidad_producto,
      'imagen': imagen,
      'createdAT': DateTime.now().toString()
    };

    final result =
        await db.update('producto_app', product, where: "id=?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteUser(int id) async {
    final db = await SQLHelper.db();
    await db.delete('user_app', where: "id=?", whereArgs: [id]);
  }

  static Future<void> deleteProducto(int id) async {
    final db = await SQLHelper.db();
    await db.delete('producto_app', where: "id=?", whereArgs: [id]);
  }
}