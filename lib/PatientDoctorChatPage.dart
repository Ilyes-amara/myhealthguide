import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserProvider.dart';
import 'DoctorProvider.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class PatientDoctorChatPage extends StatefulWidget {
  final Map<String, dynamic>? doctorInfo;

  const PatientDoctorChatPage({super.key, this.doctorInfo});

  @override
  State<PatientDoctorChatPage> createState() => _PatientDoctorChatPageState();

  // Add a static method to handle route arguments
  static PatientDoctorChatPage routeWithArguments(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      return PatientDoctorChatPage(doctorInfo: arguments);
    }
    return const PatientDoctorChatPage();
  }
}

class _PatientDoctorChatPageState extends State<PatientDoctorChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initialize with chat history or welcome message
    _loadChatHistory();
  }

  void _loadChatHistory() {
    // In a real app, this would load from a database or API
    // For now, we'll add some mock messages
    setState(() {
      _messages = [
        ChatMessage(
          text:
              "Hello, I'm Dr. ${widget.doctorInfo?['name'] ?? 'Smith'}. How can I help you today?",
          isFromDoctor: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    });
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add patient's message
    setState(() {
      _messages.add(
        ChatMessage(text: text, isFromDoctor: false, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate doctor typing
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = false;
        // Add doctor's response (in a real app, this would come from the backend)
        _messages.add(
          ChatMessage(
            text: _generateMockResponse(text),
            isFromDoctor: true,
            timestamp: DateTime.now(),
          ),
        );
      });

      _scrollToBottom();
    });
  }

  // Mock response generator - in a real app, this would be replaced by API calls
  String _generateMockResponse(String query) {
    query = query.toLowerCase();

    if (query.contains('appointment') || query.contains('schedule')) {
      return "I see you'd like to schedule an appointment. I have availability next Monday and Wednesday. Would either of those days work for you?";
    }

    if (query.contains('pain') || query.contains('hurt')) {
      return "I'm sorry to hear you're in pain. Can you describe the location and intensity? Also, how long have you been experiencing this?";
    }

    if (query.contains('prescription') ||
        query.contains('medicine') ||
        query.contains('medication')) {
      return "Regarding your medication, please make sure you're following the prescribed dosage. If you're experiencing side effects, we should discuss adjusting your prescription.";
    }

    if (query.contains('thank')) {
      return "You're welcome! Don't hesitate to reach out if you have any other concerns.";
    }

    // Default responses
    final List<String> defaultResponses = [
      "Could you provide more details about your symptoms?",
      "How long have you been experiencing these issues?",
      "Have you noticed any patterns or triggers for your symptoms?",
      "Are you currently taking any medications?",
      "Let's discuss this more during your next visit, but in the meantime, try to rest and stay hydrated.",
    ];

    return defaultResponses[Random().nextInt(defaultResponses.length)];
  }

  @override
  Widget build(BuildContext context) {
    final doctorInfo =
        widget.doctorInfo ??
        {
          'name': 'Dr. Smith',
          'specialty': 'General Practitioner',
          'photoUrl': null,
        };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 20,
              backgroundImage:
                  doctorInfo['photoUrl'] != null
                      ? NetworkImage(doctorInfo['photoUrl'])
                      : null,
              child:
                  doctorInfo['photoUrl'] == null
                      ? Icon(Icons.person, color: Colors.blue.shade800)
                      : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doctorInfo['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctorInfo['specialty'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade200),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video call feature coming soon!'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show doctor info
              _showDoctorInfo(doctorInfo);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat message area
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
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
                    'Doctor is typing...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Message input area
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
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attachment feature coming soon!'),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
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
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _sendMessage(_messageController.text),
                  backgroundColor: Colors.blue.shade700,
                  elevation: 0,
                  mini: true,
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
            color: Colors.blue.shade700.withOpacity(
              0.5 + 0.5 * sin((value * 2 * pi) + (index * pi / 2)),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isFromDoctor = message.isFromDoctor;
    final formattedDate = _formatDate(message.timestamp);
    final formattedTime = _formatTime(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment:
            isFromDoctor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Date label (only show for first message of the day)
          if (_shouldShowDate(message, _messages.indexOf(message)))
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ),

          // Message bubble
          Row(
            mainAxisAlignment:
                isFromDoctor ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFromDoctor) ...[
                CircleAvatar(
                  backgroundColor: Colors.blue.shade700,
                  radius: 16,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isFromDoctor ? Colors.white : Colors.blue.shade100,
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
                          color:
                              isFromDoctor
                                  ? Colors.black87
                                  : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isFromDoctor) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  radius: 16,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade700,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Format time as HH:MM
  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  // Format date as "Today", "Yesterday", or "MMM dd, yyyy"
  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  // Check if we should show the date label
  bool _shouldShowDate(ChatMessage message, int index) {
    if (index == 0) return true;

    final previousMessage = _messages[index - 1];
    final messageDate = DateTime(
      message.timestamp.year,
      message.timestamp.month,
      message.timestamp.day,
    );
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );

    return messageDate != previousDate;
  }

  void _showDoctorInfo(Map<String, dynamic> doctorInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage:
                        doctorInfo['photoUrl'] != null
                            ? NetworkImage(doctorInfo['photoUrl'])
                            : null,
                    child:
                        doctorInfo['photoUrl'] == null
                            ? Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.blue.shade800,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorInfo['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          doctorInfo['specialty'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'About',
                doctorInfo['bio'] ?? 'No information available',
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Contact',
                doctorInfo['phoneNumber'] ?? 'No contact available',
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Location',
                doctorInfo['clinicAddress'] ?? 'No location available',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to appointment booking
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment booking coming soon!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
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
  final bool isFromDoctor;
  final DateTime timestamp;
  final String? attachmentUrl;

  ChatMessage({
    required this.text,
    required this.isFromDoctor,
    required this.timestamp,
    this.attachmentUrl,
  });
}
