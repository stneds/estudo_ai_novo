import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/storage_service.dart';
import '../widgets/custom_app_bar.dart';

class DesempenhoScreen extends StatefulWidget {
  const DesempenhoScreen({super.key});

  @override
  State<DesempenhoScreen> createState() => _DesempenhoScreenState();
}

class _DesempenhoScreenState extends State<DesempenhoScreen> {
  bool isLoading = true;

  // Dados do mês
  int totalMateriasEstudadas = 0;
  double totalHorasEstudadas = 0;
  List<double> horasPorDiaSemana = [0, 0, 0, 0, 0, 0, 0]; // 0=Dom até 6=Sáb
  Map<String, double> horasPorDia = {};

  // Controle de mês
  DateTime mesAtual = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarDadosDoMes();
  }

  Future<void> _carregarDadosDoMes() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      // Resetar dados
      horasPorDiaSemana = [0, 0, 0, 0, 0, 0, 0];
      horasPorDia.clear();
      totalHorasEstudadas = 0;
      totalMateriasEstudadas = 0;

      // Definir período do mês
      final primeiroDia = DateTime(mesAtual.year, mesAtual.month, 1);
      final ultimoDia = DateTime(mesAtual.year, mesAtual.month + 1, 0);

      final prefs = await SharedPreferences.getInstance();

      // Buscar dados de cada dia do mês
      for (DateTime data = primeiroDia;
      data.isBefore(ultimoDia.add(const Duration(days: 1)));
      data = data.add(const Duration(days: 1))) {

        final dataString = data.toIso8601String().split('T')[0];
        final progressoJson = prefs.getString('progresso_diario_$dataString');

        if (progressoJson != null) {
          try {
            final progresso = jsonDecode(progressoJson);
            final horas = (progresso['tempoTotal'] ?? 0).toDouble();
            final materiasCompletas = progresso['materiasCompletas'] ?? 0;

            // Adicionar ao total
            totalHorasEstudadas += horas;
            totalMateriasEstudadas += materiasCompletas is int ? materiasCompletas : 0;

            // Adicionar ao dia da semana (0=Dom, 1=Seg, ..., 6=Sáb)
            final diaSemana = data.weekday == 7 ? 0 : data.weekday;
            horasPorDiaSemana[diaSemana] += horas;

            // Adicionar ao mapa de dias
            horasPorDia[dataString] = horas;
          } catch (e) {
            print('Erro ao processar dados do dia $dataString: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro geral ao carregar dados: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mudarMes(int incremento) {
    setState(() {
      mesAtual = DateTime(mesAtual.year, mesAtual.month + incremento);
    });
    _carregarDadosDoMes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Desempenho Mensal'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor de mês
              _buildSeletorMes(),
              const SizedBox(height: 16),

              // Cards de resumo
              _buildCardsResumo(),
              const SizedBox(height: 24),

              // Gráfico de horas por dia da semana
              _buildGraficoSemanal(),
              const SizedBox(height: 24),

              // Calendário visual
              _buildCalendarioMensal(),
              const SizedBox(height: 24),

              // Mensagem motivacional
              _buildMensagemMotivacional(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeletorMes() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _mudarMes(-1),
            ),
            Text(
              '${mesAtual.month}/${mesAtual.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: mesAtual.month == DateTime.now().month &&
                  mesAtual.year == DateTime.now().year
                  ? null
                  : () => _mudarMes(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsResumo() {
    return Row(
      children: [
        Expanded(
          child: _buildResumoCard(
            'Total de Horas',
            totalHorasEstudadas.toStringAsFixed(1),
            Icons.timer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildResumoCard(
            'Matérias Estudadas',
            totalMateriasEstudadas.toString(),
            Icons.book,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoSemanal() {
    final maxY = _calcularMaxY();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total de Horas por Dia da Semana',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Soma de todas as horas estudadas em cada dia da semana',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final dias = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
                    final quantidadeDias = _contarDiasNoMes(group.x);
                    return BarTooltipItem(
                      '${dias[group.x]}\n${rod.toY.toStringAsFixed(1)} horas\n($quantidadeDias ${quantidadeDias == 1 ? "vez" : "vezes"} no mês)',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY > 10 ? 5 : 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}h',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final dias = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
                      if (value.toInt() >= 0 && value.toInt() < dias.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dias[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!),
              ),
              barGroups: List.generate(7, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: horasPorDiaSemana[index],
                      color: _getCorDiaSemana(index),
                      width: 30,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarioMensal() {
    final primeiroDia = DateTime(mesAtual.year, mesAtual.month, 1);
    final ultimoDia = DateTime(mesAtual.year, mesAtual.month + 1, 0);
    final diasNoMes = ultimoDia.day;
    final primeiroDiaSemana = primeiroDia.weekday == 7 ? 0 : primeiroDia.weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calendário de Estudos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Cabeçalho dos dias da semana
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                      .map((dia) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        dia,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Grade do calendário
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final dia = index - primeiroDiaSemana + 1;

                    if (dia < 1 || dia > diasNoMes) {
                      return const SizedBox();
                    }

                    final data = DateTime(mesAtual.year, mesAtual.month, dia);
                    final dataString = data.toIso8601String().split('T')[0];
                    final horas = horasPorDia[dataString] ?? 0;

                    return Container(
                      decoration: BoxDecoration(
                        color: horas > 0
                            ? Colors.blue.withOpacity(horas.clamp(0, 8) / 8)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: data.day == DateTime.now().day &&
                              data.month == DateTime.now().month &&
                              data.year == DateTime.now().year
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dia.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: horas > 0 ? Colors.white : Colors.black,
                            ),
                          ),
                          if (horas > 0)
                            Text(
                              '${horas.toStringAsFixed(1)}h',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMensagemMotivacional() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.amber[600],
            ),
            const SizedBox(height: 8),
            Text(
              _getMensagemMotivacional(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCard(String titulo, String valor, IconData icon, Color cor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: cor),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCorDiaSemana(int index) {
    final cores = [
      Colors.red[400]!,      // Domingo
      Colors.blue[600]!,     // Segunda
      Colors.green[600]!,    // Terça
      Colors.orange[600]!,   // Quarta
      Colors.purple[600]!,   // Quinta
      Colors.teal[600]!,     // Sexta
      Colors.indigo[600]!,   // Sábado
    ];
    return index >= 0 && index < cores.length ? cores[index] : Colors.grey;
  }

  int _contarDiasNoMes(int diaSemana) {
    final primeiroDia = DateTime(mesAtual.year, mesAtual.month, 1);
    final ultimoDia = DateTime(mesAtual.year, mesAtual.month + 1, 0);
    int contador = 0;

    for (DateTime data = primeiroDia;
    data.isBefore(ultimoDia.add(const Duration(days: 1)));
    data = data.add(const Duration(days: 1))) {
      final diaSemanaData = data.weekday == 7 ? 0 : data.weekday;
      if (diaSemanaData == diaSemana) {
        contador++;
      }
    }

    return contador;
  }

  double _calcularMaxY() {
    double maxHoras = 0;
    for (var horas in horasPorDiaSemana) {
      if (horas > maxHoras) maxHoras = horas;
    }
    return maxHoras == 0 ? 10 : (maxHoras + 5).ceilToDouble();
  }

  String _getMensagemMotivacional() {
    if (totalHorasEstudadas == 0) {
      return 'Comece sua jornada de estudos este mês! 🚀';
    } else if (totalHorasEstudadas < 20) {
      return 'Bom começo! Continue assim e alcance seus objetivos! 💪';
    } else if (totalHorasEstudadas < 50) {
      return 'Excelente dedicação! Você está no caminho certo! 🌟';
    } else {
      return 'Parabéns pela incrível dedicação! Você é inspirador! 🏆';
    }
  }
}