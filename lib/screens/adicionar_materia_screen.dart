import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/materia.dart';
import '../widgets/custom_app_bar.dart';

class AdicionarMateriaScreen extends StatefulWidget {
  const AdicionarMateriaScreen({super.key});

  @override
  State<AdicionarMateriaScreen> createState() => _AdicionarMateriaScreenState();
}

class _AdicionarMateriaScreenState extends State<AdicionarMateriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  double _tempoEstudo = 1.0;
  bool _concluidoHoje = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _salvarMateria() {
    if (_formKey.currentState!.validate()) {
      final novaMateria = Materia(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        tempoEstudo: _tempoEstudo,
        concluidoHoje: _concluidoHoje,
        dataCriacao: DateTime.now(),
      );

      Navigator.pop(context, novaMateria);
    }
  }

  void _mostrarCaracteresEspeciais() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Caracteres Especiais'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'á', 'à', 'ã', 'â', 'é', 'ê', 'í', 'ó', 'ô', 'õ', 'ú', 'ç',
            'Á', 'À', 'Ã', 'Â', 'É', 'Ê', 'Í', 'Ó', 'Ô', 'Õ', 'Ú', 'Ç'
          ].map((char) => InkWell(
            onTap: () {
              final cursorPos = _nomeController.selection.baseOffset;
              final text = _nomeController.text;
              final newText = text.substring(0, cursorPos) + char + text.substring(cursorPos);
              _nomeController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: cursorPos + 1),
              );
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                char,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Adicionar Matéria'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nome da Matéria',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nomeController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          enableSuggestions: true,
                          autocorrect: true,
                          maxLength: 50,
                          decoration: InputDecoration(
                            hintText: 'Ex: Matemática, Física, História...',
                            prefixIcon: const Icon(Icons.book),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.text_fields),
                              onPressed: _mostrarCaracteresEspeciais,
                              tooltip: 'Caracteres especiais',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira o nome da matéria';
                            }
                            if (value.trim().length < 3) {
                              return 'O nome deve ter pelo menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tempo de Estudo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_tempoEstudo.toStringAsFixed(1)} horas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: _tempoEstudo,
                          min: 0.5,
                          max: 8.0,
                          divisions: 15,
                          label: '${_tempoEstudo.toStringAsFixed(1)}h',
                          onChanged: (value) {
                            setState(() => _tempoEstudo = value);
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '30 min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '8 horas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    title: const Text(
                      'Concluído hoje?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Marque se você já estudou esta matéria hoje',
                    ),
                    value: _concluidoHoje,
                    onChanged: (value) {
                      setState(() => _concluidoHoje = value ?? false);
                    },
                    secondary: Icon(
                      _concluidoHoje
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _concluidoHoje ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _salvarMateria,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Salvar'),
                      ),
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