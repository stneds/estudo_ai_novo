import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../services/wikipedia_service.dart';
import '../widgets/custom_app_bar.dart';

class ResumoScreen extends StatefulWidget {
  const ResumoScreen({super.key});

  @override
  State<ResumoScreen> createState() => _ResumoScreenState();
}

class _ResumoScreenState extends State<ResumoScreen> {
  late Materia materia;
  List<String> temasRelacionados = [];
  bool isLoading = false;
  String? erroMensagem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    materia = ModalRoute.of(context)!.settings.arguments as Materia;
    _buscarTemasRelacionados();
  }

  Future<void> _buscarTemasRelacionados() async {
    setState(() {
      isLoading = true;
      erroMensagem = null;
    });

    try {
      final temas = await WikipediaService.buscarTemasRelacionados(materia.nome);

      if (mounted) {
        setState(() {
          temasRelacionados = temas;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          erroMensagem = 'Erro ao buscar temas relacionados';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: materia.nome,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buscarTemasRelacionados,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações da Matéria',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.book,
                        'Matéria',
                        materia.nome,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.timer,
                        'Tempo de Estudo',
                        '${materia.tempoEstudo.toStringAsFixed(1)} horas',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.check_circle,
                        'Status',
                        materia.concluidoHoje ? 'Concluído' : 'Pendente',
                        statusColor: materia.concluidoHoje ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Adicionado em',
                        _formatarData(materia.dataCriacao),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Temas Relacionados (Wikipedia)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (erroMensagem != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            erroMensagem!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (temasRelacionados.isEmpty)
                  Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Nenhum tema relacionado encontrado',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...temasRelacionados.map((tema) => FutureBuilder<String>(
                    future: WikipediaService.buscarResumo(tema),
                    builder: (context, snapshot) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.article,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tema,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (snapshot.connectionState == ConnectionState.waiting)
                                  const LinearProgressIndicator()
                                else if (snapshot.hasData)
                                  Text(
                                    snapshot.data!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                else
                                  Text(
                                    'Erro ao carregar resumo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red[700],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? statusColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}