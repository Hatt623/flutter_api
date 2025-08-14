import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_api/models/order_model.dart';

class OrderService {
  static const orderUrl = 'http://127.0.0.1:8000/api/orders';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<DataOrder>> listOrders() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse(orderUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (res.statusCode != 200) throw Exception('Failed to load orders');

    final jsonMap = jsonDecode(res.body);

    // Ambil field data
    final data = jsonMap['data'];

    if (data is List) {
      return data.map<DataOrder>((e) => DataOrder.fromJson(e)).toList();
    } else if (data is Map<String, dynamic>) {
      // backend kirim single object → bungkus ke list
      return [DataOrder.fromJson(data)];
    } else {
      return [];
    }
  }

  // Get single Orders by id
  static Future<OrderModel> showOrder(int id) async {
   final token =  await getToken(); 
   final response = await http.get(
    Uri.parse('$orderUrl/$id'),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
   );

   if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return OrderModel.fromJson(json);
    } 
    
    else {
      throw Exception('Failed to load Orders');
    }
  } 

  // create a new Order
    static Future<OrderModel> createOrder(
    String name,
    String startDate,
    String endDate,
    String location,
    String description,
    int price,
    int userId,
    int eventId,
    String code,
    int quantity,
    String status,
  ) async {
    final token = await getToken();
    final uri = Uri.parse(orderUrl);

    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'location': location,
        'description': description,
        'price': price,
        'user_id': userId,
        'event_id': eventId,
        'code': code,
        'quantity': quantity,
        'status': status,
      }),
    );

    final responseBody = response.body;
    print('Status: ${response.statusCode}');
    print('Body: $responseBody');

    if (response.statusCode != 200) {
      final errorJson = jsonDecode(responseBody);
      throw Exception(errorJson['message'] ?? 'Failed to create order');
    }

    final json = jsonDecode(responseBody);
    final order = OrderModel.fromJson(json['data']); 
    // print('Jumlah tiket: ${order.data?.tikets}'); debug
    print('Raw response: ${response.body}');
    return order;
  }

  // update exsting order
  static Future<OrderModel> updateOrder(
    int id,
    String status,
    [
      Uint8List? imageBytes,
      String? imageName,
    ]) async {
      final token = await getToken();
      var request = http.MultipartRequest(
        'POST',
         Uri.parse('$orderUrl/$id?_method=PATCH'),
      );
    request.fields['status'] = status;

      if (imageBytes != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
            contentType: MediaType('image', 'jpeg'),
          )
        );
      }

    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();
      print('Status: ${response.statusCode}'); //debug
    final responseBody = await response.stream.bytesToString();
      print('Body: $responseBody'); //debug

    final json = jsonDecode(responseBody); 
    return OrderModel.fromJson(json['data']);
    }

    // delete Order
    static Future<bool> deleteOrder(int id) async {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$orderUrl/$id'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      print('[DELETE Order] Status code: ${response.statusCode}');
      print('[DELETE Order] Response body: ${response.body}');
      return response.statusCode == 200;
    }
}