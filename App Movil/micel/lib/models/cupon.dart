class Cupon {
  final int id;
  final String titulo;
  final String? descripcion;
  final String codigo;
  final String descuentoTipo; // porcentaje | monto_fijo
  final double descuentoValor;
  final bool soloVip;
  final String? fechaVencimiento;

  Cupon({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.codigo,
    required this.descuentoTipo,
    required this.descuentoValor,
    required this.soloVip,
    required this.fechaVencimiento,
  });

  factory Cupon.fromJson(Map<String, dynamic> json) {
    return Cupon(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      codigo: json['codigo'] ?? '',
      descuentoTipo: json['descuento_tipo'] ?? 'monto_fijo',
      descuentoValor: double.tryParse('${json['descuento_valor']}') ?? 0,
      soloVip: json['solo_vip'] ?? false,
      fechaVencimiento: json['fecha_vencimiento'],
    );
  }

  String get etiquetaDescuento => descuentoTipo == 'porcentaje'
      ? '${descuentoValor.toStringAsFixed(0)}% OFF'
      : 'Bs ${descuentoValor.toStringAsFixed(0)} OFF';

  String get etiquetaVencimiento =>
      fechaVencimiento != null ? 'Vence el $fechaVencimiento' : 'Sin fecha de vencimiento';
}
