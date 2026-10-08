import 'api_client.dart';
import '../models/cupon.dart';

class CuponService {
  static Future<List<Cupon>> misCupones() async {
    final data = await ApiClient.instance.get('/cliente/cupones');
    return (data as List).map((j) => Cupon.fromJson(j as Map<String, dynamic>)).toList();
  }
}
