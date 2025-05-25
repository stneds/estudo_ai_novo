import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/materia.dart';

class StorageService {
  static const String _materiasKey = 'materias';
  static const String _progressoKey = 'progresso_diario';

  static Future<void> salvarMaterias(List<Materia> materias) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> materiasJson = materias
          .map((materia) => jsonEncode(materia.toJson()))
          .toList();
      await prefs.setStringList(_materiasKey, materiasJson);
    } catch (e) {
      print('Erro ao salvar matérias: $e');
    }
  }

  static Future<List<Materia>> carregarMaterias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? materiasJson = prefs.getStringList(_materiasKey);

      if (materiasJson == null) return [];

      return materiasJson
          .map((json) => Materia.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Erro ao carregar matérias: $e');
      return [];
    }
  }

  static Future<void> salvarProgressoDiario(Map<String, dynamic> progresso) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hoje = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('${_progressoKey}_$hoje', jsonEncode(progresso));
    } catch (e) {
      print('Erro ao salvar progresso: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> carregarProgressoSemanal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> progressoSemanal = [];

      for (int i = 0; i < 7; i++) {
        final data = DateTime.now().subtract(Duration(days: i));
        final dataString = data.toIso8601String().split('T')[0];
        final progressoJson = prefs.getString('${_progressoKey}_$dataString');

        if (progressoJson != null) {
          final progresso = jsonDecode(progressoJson);
          progresso['data'] = dataString;
          progressoSemanal.add(progresso);
        }
      }

      return progressoSemanal;
    } catch (e) {
      print('Erro ao carregar progresso semanal: $e');
      return [];
    }
  }

  static Future<void> limparDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}