class Contact {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String? avatarUrl; 

  const Contact({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    this.avatarUrl,
  });

// Retorna las inciales del avatar en caso de no tener imagen
  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellido.isNotEmpty ? apellido[0] : '';
    return (n + a).toUpperCase();
  }

}
