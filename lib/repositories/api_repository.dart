import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiRepository {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Erro no login: $e");
      return {"erro": "Falha de conexão com o servidor"};
    }
  }

  Future<Map<String, dynamic>> cadastrar(Map<String, dynamic> dados) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Erro no cadastro: $e");
      return {"erro": "Falha de conexão com o servidor"};
    }
  }
}
