import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_api/models/post_model.dart';

class PostService {
  static const postUrl = 'http://127.0.0.1:8000/api/posts';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<PostModel> listPosts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(postUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PostModel.fromJson(json);
    } 
    
    else {
      throw Exception('Failed to load posts');
    }
  }

  // Get single product by id
  static Future<PostModel> showPost(int id) async {
   final token =  await getToken(); 
   final response = await http.get(
    Uri.parse('$postUrl/$id'),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
   );

   if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PostModel.fromJson(json);
    } 
    
    else {
      throw Exception('Failed to load posts');
    }
  } 

  // create a new post
  static Future<bool> createPost(
    String title,
    String content,
    int status,
    [
      Uint8List? imageBytes,
      String? imageName,
    ]) async {
    final token =  await getToken(); 
    final uri = Uri.parse(postUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['status'] = status.toString();

    if (imageBytes != null && imageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
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

  // update exsting post
  static Future<bool> updatePost(
    int id,
    String title,
    String content,
    int status,
    [
      Uint8List? imageBytes,
      String? imageName,
    ]) async {
      final token = await getToken();
      var request = http.MultipartRequest(
        'POST',
         Uri.parse('$postUrl/$id?_method=PUT'),
      );

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['status'] = status.toString();

      if (imageBytes != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
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

    // delete post
    static Future<bool> deletePost(int id) async {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$postUrl/$id'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      print('[DELETE EVENT] Status code: ${response.statusCode}');
      print('[DELETE EVENT] Response body: ${response.body}');
      return response.statusCode == 200;
    }
}
