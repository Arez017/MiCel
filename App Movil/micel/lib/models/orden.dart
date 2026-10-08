class Orden {
  final int id;
  final String code;
  final String device;
  final String service;
  final String status; // recepcion | diagnostico | en_proceso | listo
  final double monto;
  final String? tecnico;

  Orden({
    required this.id,
    required this.code,
    required this.device,
    required this.service,
    required this.status,
    required this.monto,
    required this.tecnico,
  });

  factory Orden.fromJson(Map<String, dynamic> json) {
    return Orden(
      id: json['id'],
      code: json['code'] ?? '',
      device: json['device'] ?? '',
      service: json['service'] ?? '',
      status: json['status'] ?? 'recepcion',
      monto: double.tryParse('${json['monto']}') ?? 0,
      tecnico: json['tecnico'],
    );
  }

  /// Índice para _ProgressSteps (0=recibido 1=diagnostico 2=reparando 3=listo)
  int get stepIndex {
    switch (status) {
      case 'diagnostico':
        return 1;
      case 'en_proceso':
        return 2;
      case 'listo':
        return 3;
      default:
        return 0;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'diagnostico':
        return 'En diagnóstico';
      case 'en_proceso':
        return 'En proceso';
      case 'listo':
        return 'Listo para recoger';
      default:
        return 'Recibido';
    }
  }
}
