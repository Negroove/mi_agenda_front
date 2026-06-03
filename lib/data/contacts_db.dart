import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';

class ContactsDb {
  Database? _db;

  Future<void> open() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'contacts.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE contacts(
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            apellido TEXT NOT NULL,
            telefono TEXT NOT NULL,
            email TEXT NOT NULL
          );
        ''');
      },
    );
  }

  Future<List<Contact>> getAll() async {
    final rows = await _db!.query('contacts', orderBy: 'apellido, nombre');
    return rows
        .map(
          (m) => Contact(
            id: m['id'] as String,
            nombre: m['nombre'] as String,
            apellido: m['apellido'] as String,
            telefono: m['telefono'] as String,
            email: m['email'] as String,
          ),
        )
        .toList();
  }

  Future<void> insert(Contact c) async {
    await _db!.insert('contacts', {
      'id': c.id,
      'nombre': c.nombre,
      'apellido': c.apellido,
      'telefono': c.telefono,
      'email': c.email,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Contact c) async {
    await _db!.update(
      'contacts',
      {
        'nombre': c.nombre,
        'apellido': c.apellido,
        'telefono': c.telefono,
        'email': c.email,
      },
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<void> deleteById(String id) async {
    await _db!.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
