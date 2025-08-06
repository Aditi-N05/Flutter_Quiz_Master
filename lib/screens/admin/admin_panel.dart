// lib/screens/admin/admin_panel.dart
import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../services/data_services.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _dataService = DataService();
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<TextEditingController> _optionControllers =
  List.generate(4, (index) => TextEditingController());
  int _correctAnswer = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Add New Question', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder()),
                      validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(labelText: 'Option ${index + 1}', border: const OutlineInputBorder()),
                          validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _correctAnswer,
                      decoration: const InputDecoration(labelText: 'Correct Answer', border: OutlineInputBorder()),
                      items: List.generate(4, (index) => DropdownMenuItem(value: index, child: Text('Option ${index + 1}'))),
                      onChanged: (value) => setState(() => _correctAnswer = value ?? 0),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addQuestion,
                      child: const Text('Add Question'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Existing Questions (${_dataService.questions.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _dataService.questions.length,
                        itemBuilder: (context, index) {
                          final question = _dataService.questions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(question.question),
                              subtitle: Text('Category: ${question.category}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteQuestion(question.id),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    if (_formKey.currentState?.validate() ?? false) {
      final q = Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: _questionController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctAnswer: _correctAnswer,
        category: _categoryController.text.trim(),
      );

      _dataService.addQuestion(q);
      _clearForm();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question added successfully!')));
    }
  }

  void _deleteQuestion(String id) {
    _dataService.removeQuestion(id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question deleted!')));
  }

  void _clearForm() {
    _questionController.clear();
    _categoryController.clear();
    for (final c in _optionControllers) {
      c.clear();
    }
    _correctAnswer = 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _categoryController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
