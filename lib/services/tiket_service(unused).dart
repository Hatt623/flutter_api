import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_api/models/tiket_model.dart';

class TiketService {
  static const tiketUrl = 'http://127.0.0.1:8000/api/tikets';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<TiketModel> listtikets() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(tiketUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TiketModel.fromJson(json);
    } 
    
    else {
      throw Exception('Failed to load tikets');
    }
  }

  // Get single tikets by id
  static Future<TiketModel> showtiket(int id) async {
   final token =  await getToken(); 
   final response = await http.get(
    Uri.parse('$tiketUrl/$id'),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
   );

   if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TiketModel.fromJson(json);
    } 
    
    else {
      throw Exception('Failed to load tikets');
    }
  } 

  // create a new tiket setelah membuat order (otomatis)
  static Future<TiketModel> createTiket(
    int userId,
    int orderId,
    int eventId,
    String name,
    String location,
    String code,
    String startDate,
    String endDate,
    [
      Uint8List? imageBytes,
      String? imageName,
    ]) async {
    final token =  await getToken(); 
    final uri = Uri.parse(tiketUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();
    request.fields['order_id'] = orderId.toString();
    request.fields['event_id'] = eventId.toString();
    request.fields['name'] = name;
    request.fields['location'] = location;
    request.fields['code'] = code;
    request.fields['start_date'] = startDate;
    request.fields['end_date'] = endDate;
    
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
    return TiketModel.fromJson(json['data']);
  }

    // delete tiket
    static Future<bool> deleteTiket(int id) async {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$tiketUrl/$id'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      print('[DELETE tiket] Status code: ${response.statusCode}');
      print('[DELETE tiket] Response body: ${response.body}');
      return response.statusCode == 200;
    }
}