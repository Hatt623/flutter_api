import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_api/models/event_model.dart';

class EventService {
  static const eventUrl = 'http://127.0.0.1:8000/api/events';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<EventModel> listEvents() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(eventUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return EventModel.fromJson(json);
    } 
    
    else {
      throw Exception('Failed to load Events');
    }
  }

  // Get single events by id
  static Future<EventModel> showEvent(int id) async {
   final token =  await getToken(); 
   final response = await http.get(
    Uri.parse('$eventUrl/$id'),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
   );

   if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return EventModel.fromJson(json);
    } 
    
    else {
      throw Exception('Failed to load Events');
    }
  } 

  // create a new Event
  static Future<bool> createEvent(
    String name,
    String startDate,
    String endDate,
    String location,
    String description,
    int price,
    [
      Uint8List? imageBytes,
      String? imageName,
    ]) async {
    final token =  await getToken(); 
    final uri = Uri.parse(eventUrl);
    final request = http.MultipartRequest('POST', uri);

     request.fields['name'] = name;
      request.fields['start_date'] = startDate;
      request.fields['end_date'] = endDate;
      request.fields['location'] = location;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();

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
    print('Status: ${response.statusCode}');
    final responseBody = await response.stream.bytesToString();
    print('Body: $responseBody');
    return response.statusCode == 200;
  }

  // update exsting Event
  static Future<bool> updateEvent(
    int id,
    String name,
    String startDate,
    String endDate,
    String location,
    String description,
    int price,
    [
      Uint8List? imageBytes,
      String? imageName,
    ]) async {
      final token = await getToken();
      var request = http.MultipartRequest(
        'POST',
         Uri.parse('$eventUrl/$id?_method=PUT'),
      );

      request.fields['name'] = name;
      request.fields['start_date'] = startDate;
      request.fields['end_date'] = endDate;
      request.fields['location'] = location;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();

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
      print('Status: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Body: $responseBody');
      return response.statusCode == 200;
    }

    // delete Event
    static Future<bool> deleteEvent(int id) async {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$eventUrl/$id'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      print('[DELETE EVENT] Status code: ${response.statusCode}');
      print('[DELETE EVENT] Response body: ${response.body}');
      return response.statusCode == 200;
    }
}
