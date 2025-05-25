import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/materia.dart';

class MateriaCard extends StatelessWidget {
  final Materia materia;
  final VoidCallback onTap;
  final VoidCallback onToggleConcluido;
  final VoidCallback onDelete;

  const MateriaCard({
    super.key,
    required this.materia,
    required this.onTap,
    required this.onToggleConcluido,
    required this.onDelete,
  });

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inDays == 0) {
      return 'Hoje';
    } else if (diferenca.inDays == 1) {
      return 'Ontem';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM').format(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        materia.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: materia.concluidoHoje,
                      onChanged: (_) => onToggleConcluido(),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Ícone e tempo de estudo
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${materia.tempoEstudo.toStringAsFixed(1)} horas',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    // Separador
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 16),
                    // Ícone e data
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatarData(materia.dataCriacao),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: materia.concluidoHoje ? 1.0 : 0.3,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    materia.concluidoHoje ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}