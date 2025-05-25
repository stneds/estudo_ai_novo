import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../services/storage_service.dart';
import '../widgets/materia_card.dart';
import '../widgets/custom_app_bar.dart';
import 'adicionar_materia_screen.dart';
import 'resumo_screen.dart';  // ← IMPORT ADICIONADO
import 'desempenho_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Materia> materias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMaterias();
  }

  Future<void> _carregarMaterias() async {
    setState(() => isLoading = true);

    try {
      final materiasCarregadas = await StorageService.carregarMaterias();
      setState(() {
        materias = materiasCarregadas;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _mostrarErro('Erro ao carregar matérias');
    }
  }

  Future<void> _toggleConcluido(int index) async {
    setState(() {
      materias[index] = materias[index].copyWith(
        concluidoHoje: !materias[index].concluidoHoje,
      );
    });

    await StorageService.salvarMaterias(materias);
    await _salvarProgressoDiario();
  }

  Future<void> _deletarMateria(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${materias[index].nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => materias.removeAt(index));
      await StorageService.salvarMaterias(materias);
      await _salvarProgressoDiario();
    }
  }

  Future<void> _salvarProgressoDiario() async {
    final totalMaterias = materias.length;
    final materiasCompletas = materias.where((m) => m.concluidoHoje).length;
    final tempoTotal = materias
        .where((m) => m.concluidoHoje)
        .fold(0.0, (sum, m) => sum + m.tempoEstudo);

    await StorageService.salvarProgressoDiario({
      'totalMaterias': totalMaterias,
      'materiasCompletas': materiasCompletas,
      'tempoTotal': tempoTotal,
    });
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Estuda Aí',
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DesempenhoScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : materias.isEmpty
          ? _buildEmptyState()
          : _buildMateriasList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdicionarMateriaScreen()),
          );

          if (resultado != null && resultado is Materia) {
            setState(() => materias.add(resultado));
            await StorageService.salvarMaterias(materias);
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma matéria cadastrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no + para adicionar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriasList() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResumoItem(
                'Total',
                materias.length.toString(),
                Icons.book,
              ),
              _buildResumoItem(
                'Concluídas',
                materias.where((m) => m.concluidoHoje).length.toString(),
                Icons.check_circle,
              ),
              _buildResumoItem(
                'Horas',
                materias
                    .where((m) => m.concluidoHoje)
                    .fold(0.0, (sum, m) => sum + m.tempoEstudo)
                    .toStringAsFixed(1),
                Icons.timer,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: materias.length,
            itemBuilder: (context, index) {
              return MateriaCard(
                materia: materias[index],
                onTap: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResumoScreen(),
                      settings: RouteSettings(arguments: materias[index]),
                    ),
                  );
                  if (resultado == true) {
                    _carregarMaterias();
                  }
                },
                onToggleConcluido: () => _toggleConcluido(index),
                onDelete: () => _deletarMateria(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResumoItem(String label, String valor, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}