class SessionEvent {
  final String nombre; // ID o nombre del usuario
  final String action; // "login" o "logout"
  final DateTime timestamp; // Fecha y hora del evento

  SessionEvent({
    required this.nombre,
    required this.action,
    required this.timestamp,
  });

  // Convertir a mapa para guardarlo
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Crear una instancia desde un mapa
  factory SessionEvent.fromMap(Map<String, dynamic> map) {
    return SessionEvent(
      nombre: map['userId'],
      action: map['action'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}