class Materia {
  final String id;
  final String nome;
  final double tempoEstudo;
  final bool concluidoHoje;
  final DateTime dataCriacao;
  final List<String> temasRelacionados;

  Materia({
    required this.id,
    required this.nome,
    required this.tempoEstudo,
    this.concluidoHoje = false,
    required this.dataCriacao,
    this.temasRelacionados = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tempoEstudo': tempoEstudo,
      'concluidoHoje': concluidoHoje,
      'dataCriacao': dataCriacao.toIso8601String(),
      'temasRelacionados': temasRelacionados,
    };
  }

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      nome: json['nome'],
      tempoEstudo: json['tempoEstudo'].toDouble(),
      concluidoHoje: json['concluidoHoje'] ?? false,
      dataCriacao: DateTime.parse(json['dataCriacao']),
      temasRelacionados: List<String>.from(json['temasRelacionados'] ?? []),
    );
  }

  Materia copyWith({
    String? nome,
    double? tempoEstudo,
    bool? concluidoHoje,
    List<String>? temasRelacionados,
  }) {
    return Materia(
      id: id,
      nome: nome ?? this.nome,
      tempoEstudo: tempoEstudo ?? this.tempoEstudo,
      concluidoHoje: concluidoHoje ?? this.concluidoHoje,
      dataCriacao: dataCriacao,
      temasRelacionados: temasRelacionados ?? this.temasRelacionados,
    );
  }
}