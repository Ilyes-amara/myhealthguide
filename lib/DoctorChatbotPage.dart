import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'DoctorProvider.dart';

class DoctorChatbotPage extends StatefulWidget {
  final String? initialQuery;

  const DoctorChatbotPage({super.key, this.initialQuery});

  @override
  _DoctorChatbotPageState createState() => _DoctorChatbotPageState();
}

class _DoctorChatbotPageState extends State<DoctorChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Diagnosis',
    'Treatment',
    'Medication',
    'Patient Management',
    'Medical Research',
    'Clinical Guidelines',
  ];

  // Sample medical knowledge base
  final Map<String, List<String>> _knowledgeBase = {
    'hypertension': [
      'Hypertension is defined as a systolic blood pressure ≥130 mmHg or a diastolic blood pressure ≥80 mmHg.',
      'First-line medications include thiazide diuretics, ACE inhibitors, ARBs, and calcium channel blockers.',
      'Lifestyle modifications include weight loss, DASH diet, sodium restriction, physical activity, and moderate alcohol consumption.',
    ],
    'diabetes': [
      'Type 2 diabetes diagnostic criteria: FPG ≥126 mg/dL, 2-hour PG ≥200 mg/dL during OGTT, A1C ≥6.5%, or random PG ≥200 mg/dL with symptoms.',
      'First-line therapy is typically metformin unless contraindicated.',
      'Target A1C is generally <7% for most nonpregnant adults with diabetes.',
    ],
    'asthma': [
      'Asthma is characterized by variable respiratory symptoms and expiratory airflow limitation.',
      'Treatment follows a stepwise approach based on symptom control and risk factors.',
      'Short-acting beta agonists (SABAs) are used for quick relief of symptoms.',
    ],
    'covid': [
      'COVID-19 is caused by the SARS-CoV-2 virus and primarily spreads through respiratory droplets.',
      'Common symptoms include fever, cough, fatigue, and loss of taste or smell.',
      'Vaccination remains the most effective preventive measure against severe disease.',
    ],
    'migraine': [
      'Migraine is a primary headache disorder characterized by recurrent headaches that are moderate to severe.',
      'Triptans are commonly used for acute treatment of migraine attacks.',
      'Preventive treatments include beta-blockers, anticonvulsants, and CGRP antagonists.',
    ],
  };

  @override
  void initState() {
    super.initState();

    // Add welcome message
    _addBotMessage(
      'Hello, I\'m your Medical AI Assistant. How can I help you today?',
      isInitial: true,
    );

    // Process initial query if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _messageController.text = widget.initialQuery!;
        _handleSubmitted(widget.initialQuery!);
      }
    });
  }

  void _addBotMessage(String text, {bool isInitial = false}) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });

    if (!isInitial) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate response
    final response = _generateResponse(text.toLowerCase());

    // Add bot response
    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
    });

    _scrollToBottom();
  }

  String _generateResponse(String query) {
    // Check for patient-related queries
    if (query.contains('patient') && query.contains('profile')) {
      return 'You can access patient profiles from the appointment details. Click on the patient name to view their complete medical history, contact information, and previous visit notes.';
    }

    if (query.contains('appointment') &&
        (query.contains('schedule') || query.contains('book'))) {
      return 'To manage your appointments, go to the Appointments tab in your dashboard. You can view, confirm, or reschedule appointments there. You can also set your availability in the Settings.';
    }

    if (query.contains('availability') || query.contains('schedule')) {
      return 'You can set your availability by going to Settings > Availability. There you can define your working hours, appointment duration, and specify days for home or online visits.';
    }

    if (query.contains('google calendar') || query.contains('sync')) {
      return 'You can connect your Google Calendar by going to Settings > Availability. Click on "Connect Calendar" to sync all your appointments automatically.';
    }

    // Check knowledge base for medical queries
    for (final entry in _knowledgeBase.entries) {
      if (query.contains(entry.key)) {
        final Random random = Random();
        return entry.value[random.nextInt(entry.value.length)];
      }
    }

    // Generic responses based on category
    switch (_selectedCategory) {
      case 'Diagnosis':
        return 'For diagnostic assistance, I recommend checking the latest clinical guidelines. Would you like me to provide specific diagnostic criteria for a condition?';
      case 'Treatment':
        return 'When considering treatment options, it\'s important to evaluate the latest evidence-based protocols. Is there a specific condition you\'re treating?';
      case 'Medication':
        return 'For medication information, I can provide details on dosing, contraindications, and potential interactions. Which medication are you interested in?';
      case 'Patient Management':
        return 'Effective patient management involves clear communication and follow-up. Would you like tips on improving patient adherence or managing chronic conditions?';
      case 'Medical Research':
        return 'I can help you find recent research publications on specific topics. What medical subject are you researching?';
      case 'Clinical Guidelines':
        return 'I can provide summaries of current clinical guidelines from major medical associations. Which condition are you looking for guidelines on?';
      default:
        // General responses
        final List<String> generalResponses = [
          'I can help you with medical information, patient management, and clinical guidelines. What specific information are you looking for?',
          'As your medical assistant, I can provide evidence-based information to support your clinical decisions. Could you be more specific about what you need?',
          'I\'m here to assist with your medical queries. For more accurate responses, please provide more details about your question.',
          'I can help with diagnostic criteria, treatment protocols, and medication information. What would you like to know more about?',
        ];

        return generalResponses[Random().nextInt(generalResponses.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Assistant'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('About Medical Assistant'),
                      content: const SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'This AI assistant is designed to help healthcare professionals with:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('• Clinical information and guidelines'),
                            Text('• Medication references'),
                            Text('• Diagnostic criteria'),
                            Text('• Patient management suggestions'),
                            Text('• Medical research summaries'),
                            SizedBox(height: 16),
                            Text(
                              'Note: This assistant provides information to support clinical decision-making but does not replace professional medical judgment.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Colors.blue.shade100,
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? Colors.blue.shade800
                                  : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Chat messages
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        3,
                        (index) => _buildPulsingDot(index),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assistant is typing...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask a medical question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _handleSubmitted(_messageController.text),
                  backgroundColor: Colors.blue.shade800,
                  elevation: 0,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.blue.shade800.withOpacity(
              0.5 + 0.5 * sin((value * 2 * pi) + (index * pi / 2)),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade800,
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.blue.shade900 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade800,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
