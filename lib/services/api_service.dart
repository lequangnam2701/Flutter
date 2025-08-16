import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<List<Place>> getAllPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places/getAllPlace'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching places: $e');
    }
  }
  
  static Future<List<Place>> getPopularPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places/popular'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching popular places: $e');
    }
  }
}
