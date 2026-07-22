/// ==========================================
/// Datos simulados (mock) — reemplázalos por tu
/// backend/API real cuando lo tengas listo.
/// ==========================================

enum UserRole { admin, tecnico, cliente }

class AppUser {
  final String username;
  final String password;
  final String nombre;
  final UserRole role;
  final bool activo;

  const AppUser({
    required this.username,
    required this.password,
    required this.nombre,
    required this.role,
    this.activo = true,
  });
}

/// Mismos usuarios que la tabla de tu login web (micel/kevsolutions = Admin,
/// tec03..tec10 = Técnico), más el cliente VIP de la app.
const List<AppUser> mockUsers = [
  AppUser(username: 'micel', password: '1234', nombre: 'Administrador MiCel', role: UserRole.admin),
  AppUser(username: 'kevsolutions', password: '1234', nombre: 'Kevin Solutions', role: UserRole.admin),
  AppUser(username: 'tec03', password: '1234', nombre: 'Carlos Mamani', role: UserRole.tecnico),
  AppUser(username: 'tec04', password: '1234', nombre: 'Luis Choque', role: UserRole.tecnico),
  AppUser(username: 'tec05', password: '1234', nombre: 'Marco Apaza', role: UserRole.tecnico),
  AppUser(username: 'tec06', password: '1234', nombre: 'Ronald Flores', role: UserRole.tecnico),
  AppUser(username: 'tec07', password: '1234', nombre: 'David Quenta', role: UserRole.tecnico),
  AppUser(username: 'tec08', password: '1234', nombre: 'Freddy Callisaya', role: UserRole.tecnico),
  AppUser(username: 'tec09', password: '1234', nombre: 'Jhonny Ramos', role: UserRole.tecnico),
  AppUser(username: 'tec10', password: '1234', nombre: 'Rolando Vargas', role: UserRole.tecnico, activo: false),
  AppUser(username: 'jquispe', password: '1234', nombre: 'Juan Quispe', role: UserRole.cliente),
];

/// Sesión simple en memoria — al reiniciar la app se pierde (normal para un mock).
class Session {
  static AppUser? currentUser;
}

/// ===== STOCK (visto por Admin) =====
class StockItem {
  final String id;
  final String nombre;
  final int cantidad;
  final int minimo;
  final String categoria;

  const StockItem({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.minimo,
    required this.categoria,
  });

  bool get esCritico => cantidad <= (minimo * 0.5).floor();
  bool get esBajo => !esCritico && cantidad <= minimo;
}

const List<StockItem> mockStock = [
  StockItem(id: 'RPT-001', nombre: 'Pantalla iPhone 12', cantidad: 3, minimo: 6, categoria: 'Pantallas'),
  StockItem(id: 'RPT-002', nombre: 'Pantalla Samsung A32', cantidad: 9, minimo: 6, categoria: 'Pantallas'),
  StockItem(id: 'BAT-011', nombre: 'Batería iPhone 11', cantidad: 2, minimo: 8, categoria: 'Baterías'),
  StockItem(id: 'BAT-012', nombre: 'Batería Xiaomi Redmi 9', cantidad: 12, minimo: 8, categoria: 'Baterías'),
  StockItem(id: 'ACC-021', nombre: 'Mica templada universal', cantidad: 40, minimo: 15, categoria: 'Accesorios'),
  StockItem(id: 'CON-031', nombre: 'Conector de carga tipo C', cantidad: 5, minimo: 10, categoria: 'Repuestos'),
];

/// ===== ÓRDENES DE SERVICIO (vistas por Técnico y Admin) =====
class ServiceOrder {
  final String codigo;
  final String cliente;
  final String equipo;
  final String servicio;
  final String tecnico; // nombre del técnico asignado
  final String estado; // Recibido, Diagnóstico, Reparando, Listo
  final double precio;
  final bool pagado;

  const ServiceOrder({
    required this.codigo,
    required this.cliente,
    required this.equipo,
    required this.servicio,
    required this.tecnico,
    required this.estado,
    required this.precio,
    this.pagado = false,
  });

  /// Comisión estándar del técnico: 15% del valor del servicio, solo si ya está "Listo".
  double get comisionTecnico => estado == 'Listo' ? precio * 0.15 : 0;
}

const List<ServiceOrder> mockOrders = [
  ServiceOrder(codigo: 'ORD-2287', cliente: 'Ana Mamani', equipo: 'Samsung A32', servicio: 'Cambio de batería', tecnico: 'Carlos Mamani', estado: 'Listo', precio: 180, pagado: true),
  ServiceOrder(codigo: 'ORD-2288', cliente: 'Pedro Rojas', equipo: 'Xiaomi Redmi 9', servicio: 'Cambio de pantalla', tecnico: 'Carlos Mamani', estado: 'Reparando', precio: 320),
  ServiceOrder(codigo: 'ORD-2289', cliente: 'María Ticona', equipo: 'iPhone 11', servicio: 'Cambio de batería', tecnico: 'Luis Choque', estado: 'Listo', precio: 220, pagado: true),
  ServiceOrder(codigo: 'ORD-2290', cliente: 'Jorge Huanca', equipo: 'Motorola G8', servicio: 'Cambio de conector de carga', tecnico: 'Luis Choque', estado: 'Diagnóstico', precio: 150),
  ServiceOrder(codigo: 'ORD-2291', cliente: 'Juan Quispe', equipo: 'iPhone 13 Pro', servicio: 'Cambio de pantalla', tecnico: 'Marco Apaza', estado: 'Reparando', precio: 350),
  ServiceOrder(codigo: 'ORD-2292', cliente: 'Rosa Callisaya', equipo: 'iPhone 12', servicio: 'Cambio de pantalla', tecnico: 'Marco Apaza', estado: 'Listo', precio: 340, pagado: true),
];

/// Comisión total de un técnico (suma de todas sus órdenes marcadas "Listo").
double comisionTotalTecnico(String nombreTecnico) {
  return mockOrders
      .where((o) => o.tecnico == nombreTecnico && o.estado == 'Listo')
      .fold(0.0, (sum, o) => sum + o.comisionTecnico);
}