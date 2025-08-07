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
  final _newCategoryController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  int _correctAnswer = 0;
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _dataService.initialize();
    if (_dataService.categories.isNotEmpty) {
      _selectedCategory = _dataService.categories.first;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: Colors.red[600],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _showCategoryManagementDialog,
            tooltip: 'Manage Categories',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add New Question Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Add New Question',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Question Field
                      TextFormField(
                        controller: _questionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Question',
                          border: OutlineInputBorder(),
                          hintText: 'Enter your question here...',
                        ),
                        validator: (value) => value?.trim().isEmpty ?? true
                            ? 'Question is required'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Category Selection
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: _dataService.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                  _categoryController.text = value ?? '';
                                });
                              },
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please select a category'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('OR'),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                labelText: 'New Category',
                                border: OutlineInputBorder(),
                                hintText: 'Create new category',
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() => _selectedCategory = null);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Options
                      const Text(
                        'Answer Options:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                              border: const OutlineInputBorder(),
                              prefixIcon: CircleAvatar(
                                backgroundColor: _correctAnswer == index
                                    ? Colors.green
                                    : Colors.grey[300],
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: _correctAnswer == index
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) => value?.trim().isEmpty ?? true
                                ? 'Option ${index + 1} is required'
                                : null,
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Correct Answer Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Correct Answer:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: List.generate(4, (index) {
                                return ChoiceChip(
                                  label: Text(
                                    'Option ${String.fromCharCode(65 + index)}',
                                  ),
                                  selected: _correctAnswer == index,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _correctAnswer = index);
                                    }
                                  },
                                  selectedColor: Colors.green[300],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Add Question Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Question'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Question Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Questions: ${_dataService.questions.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Categories: ${_dataService.categories.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_dataService.categories.isNotEmpty) ...[
                      const Text(
                        'Questions per Category:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._dataService.getQuestionCountByCategory().entries.map((
                        entry,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '• ${entry.key}:',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${entry.value} questions',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Existing Questions Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Existing Questions (${_dataService.questions.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 400, // Fixed height for the list
                      child: _dataService.questions.isEmpty
                          ? const Center(
                              child: Text(
                                'No questions added yet.\nAdd your first question above!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _dataService.questions.length,
                              itemBuilder: (context, index) {
                                final question = _dataService.questions[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ExpansionTile(
                                    title: Text(
                                      question.question,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Category: ${question.category}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Options:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...question.options
                                                .asMap()
                                                .entries
                                                .map((
                                              entry,
                                            ) {
                                              final isCorrect = entry.key ==
                                                  question.correctAnswer;
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 2,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '${String.fromCharCode(65 + entry.key)}. ',
                                                    ),
                                                    Expanded(
                                                      child: Text(entry.value),
                                                    ),
                                                    if (isCorrect)
                                                      const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 20,
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () =>
                                                      _deleteQuestion(
                                                    question.id,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  label: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryManagementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manage Categories'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                // Add new category
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'New Category Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (_newCategoryController.text.trim().isNotEmpty) {
                          _addCategory(_newCategoryController.text.trim());
                          _newCategoryController.clear();
                          Navigator.of(context).pop();
                          _showCategoryManagementDialog(); // Refresh dialog
                        }
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Existing Categories:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _dataService.categories.length,
                    itemBuilder: (context, index) {
                      final category = _dataService.categories[index];
                      final questionCount =
                          _dataService.getQuestionsByCategory(category).length;

                      return ListTile(
                        title: Text(category),
                        subtitle: Text('$questionCount questions'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteCategoryConfirmation(
                            category,
                            questionCount,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryConfirmation(String category, int questionCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "$category"?\n\n'
            'This will also delete all $questionCount questions in this category.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCategory(category);
                Navigator.of(context).pop(); // Close confirmation
                Navigator.of(context).pop(); // Close category management
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addQuestion() async {
    if (_formKey.currentState?.validate() ?? false) {
      final category = _categoryController.text.trim().isNotEmpty
          ? _categoryController.text.trim()
          : _selectedCategory;

      if (category == null || category.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select or enter a category')),
        );
        return;
      }

      final question = Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: _questionController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctAnswer: _correctAnswer,
        category: category,
      );

      await _dataService.addQuestion(question);
      _clearForm();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteQuestion(String id) async {
    await _dataService.removeQuestion(id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question deleted!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _addCategory(String category) async {
    await _dataService.addCategory(category);
    setState(() {
      if (_selectedCategory == null) {
        _selectedCategory = category;
      }
    });
  }

  Future<void> _deleteCategory(String category) async {
    await _dataService.removeCategory(category);
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = _dataService.categories.isNotEmpty
            ? _dataService.categories.first
            : null;
      }
    });
  }

  void _clearForm() {
    _questionController.clear();
    _categoryController.clear();
    for (final controller in _optionControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswer = 0;
      _selectedCategory = _dataService.categories.isNotEmpty
          ? _dataService.categories.first
          : null;
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _categoryController.dispose();
    _newCategoryController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
