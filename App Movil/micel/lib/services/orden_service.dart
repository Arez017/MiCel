import 'api_client.dart';
import '../models/orden.dart';

class OrdenService {
  static Future<List<Orden>> misOrdenes() async {
    final data = await ApiClient.instance.get('/cliente/mis-ordenes');
    return (data as List).map((j) => Orden.fromJson(j as Map<String, dynamic>)).toList();
  }
}
