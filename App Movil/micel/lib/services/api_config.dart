/// Cambia esta URL según tu entorno.
/// Emulador Android → 10.0.2.2
/// iOS simulador / escritorio → localhost o tu .test
/// Celular físico → IP de tu PC en la red (ej. 192.168.x.x)
class ApiConfig {
  // Ejemplo Laravel Herd / Valet:
  static const String baseUrl = 'http://micel.test/api';
  // static const String baseUrl = 'http://10.0.2.2/api'; // Android emulator
  // static const String baseUrl = 'http://192.168.1.10/api'; // dispositivo físico
}
