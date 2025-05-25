import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static const String _baseUrl = 'https://pt.wikipedia.org/w/api.php';

  static Future<List<String>> buscarTemasRelacionados(String materia) async {
    try {
      final url = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'opensearch',
        'search': materia,
        'limit': '5',
        'namespace': '0',
        'format': 'json',
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.length >= 2 && data[1] is List) {
          return List<String>.from(data[1]);
        }
      }

      return [];
    } catch (e) {
      print('Erro ao buscar temas na Wikipedia: $e');
      return [];
    }
  }

  static Future<String> buscarResumo(String titulo) async {
    try {
      final url = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'query',
        'format': 'json',
        'prop': 'extracts',
        'exintro': 'true',
        'explaintext': 'true',
        'exsentences': '2',
        'titles': titulo,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pages = data['query']['pages'];

        if (pages != null && pages.isNotEmpty) {
          final firstPage = pages.values.first;
          return firstPage['extract'] ?? 'Sem resumo disponível';
        }
      }

      return 'Erro ao buscar resumo';
    } catch (e) {
      print('Erro ao buscar resumo: $e');
      return 'Erro ao buscar resumo';
    }
  }
}