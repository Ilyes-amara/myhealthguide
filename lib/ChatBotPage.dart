import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';

class HealthChatBot extends StatefulWidget {
  const HealthChatBot({super.key, required String topic});

  @override
  State<HealthChatBot> createState() => _HealthChatBotState();
}

class _HealthChatBotState extends State<HealthChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String selectedAI = 'General Health';
  dynamic _selectedImage; // Use dynamic type for web compatibility
  bool _isAnalyzing = false;

  final List<String> _aiOptions = [
    'General Health',
    'Corona Detection',
    'Nutrition Coach',
    'Mental Health',
    'Sleep Analysis',
  ];

  @override
  void initState() {
    super.initState();
    // Add welcome message on init
    Future.delayed(Duration.zero, () {
      _addWelcomeMessage(selectedAI);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _scrollToBottom();
    });
    // Simulate bot response after short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _getBotResponse(text);
    });
  }

  void _getBotResponse(String userMessage) {
    String response;
    if (selectedAI == 'Corona Detection') {
      response =
          "To check for COVID-19 symptoms via image analysis, please upload a chest X-ray or CT scan using the camera button below.";
    } else if (selectedAI == 'Nutrition Coach') {
      response =
          "Based on your recent meal logs, I suggest adding more vegetables to your diet. Would you like some healthy recipe recommendations?";
    } else if (userMessage.toLowerCase().contains('headache')) {
      response =
          "Headaches can be caused by various factors including stress, dehydration, or eye strain. How long have you been experiencing this symptom?";
    } else if (userMessage.toLowerCase().contains('appointment')) {
      response =
          "I can help you schedule an appointment. What specialist would you like to see, and what days work best for you?";
    } else {
      response =
          "I'm here to help with your health questions. Could you provide more details about your concern?";
    }
    setState(() {
      _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
      _scrollToBottom();
    });
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            // For web, we just store the XFile directly
            _selectedImage = pickedFile;
          } else {
            // For mobile platforms, we can convert to File
            _selectedImage = io.File(pickedFile.path);
          }
        });
        // Simulate image analysis
        _analyzeImage();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error picking image')));
    }
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate image analysis with a delay
    await Future.delayed(const Duration(seconds: 2));

    if (selectedAI == 'Corona Detection') {
      _processCoronaDetection();
    } else {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "I've uploaded this image. What would you like to know about it?",
            isUser: true,
            timestamp: DateTime.now(),
            image: _selectedImage,
          ),
        );
        _isAnalyzing = false;
      });

      // Bot response to image
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  "I see you've shared an image. How can I help you with this?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _scrollToBottom();
        });
      });
    }
  }

  void _processCoronaDetection() {
    bool isPositive = DateTime.now().millisecond % 2 == 0;
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "I'm analyzing this chest scan for potential COVID-19 indicators.",
          isUser: true,
          timestamp: DateTime.now(),
          image: _selectedImage,
        ),
      );
      _isAnalyzing = false;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        if (isPositive) {
          _messages.add(
            ChatMessage(
              text:
                  "⚠️ The scan analysis indicates possible COVID-19 related patterns. This is NOT a definitive diagnosis, but I recommend getting a PCR test and consulting with a healthcare professional immediately. Would you like me to help find testing centers near you?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        } else {
          _messages.add(
            ChatMessage(
              text:
                  "Based on AI analysis, no significant COVID-19 related patterns were detected in this scan. However, this is not a clinical diagnosis. If you're experiencing symptoms, please consult a healthcare provider. Would you like information about maintaining your respiratory health?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
        _scrollToBottom();
      });
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

  void _showAISelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This is important for larger content
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          // Limiting height to 70% of screen
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Select Health Assistant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose which specialized AI assistant you want to chat with',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Removed Expanded and replaced with Flexible
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _aiOptions.length,
                  itemBuilder: (context, index) {
                    return _buildAIOption(_aiOptions[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIOption(String option) {
    bool isSelected = selectedAI == option;
    IconData icon;
    Color color;
    switch (option) {
      case 'Corona Detection':
        icon = Icons.coronavirus;
        color = Colors.red;
        break;
      case 'Nutrition Coach':
        icon = Icons.restaurant_menu;
        color = Colors.green;
        break;
      case 'Mental Health':
        icon = Icons.psychology;
        color = Colors.purple;
        break;
      case 'Sleep Analysis':
        icon = Icons.nightlight;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.health_and_safety;
        color = Colors.teal;
    }
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        option,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(_getAIDescription(option)),
      trailing:
          isSelected
              ? const Icon(Icons.check_circle, color: Colors.teal)
              : null,
      onTap: () {
        setState(() {
          selectedAI = option;
        });
        Navigator.pop(context);
        _addWelcomeMessage(option);
      },
    );
  }

  void _addWelcomeMessage(String aiType) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: _getWelcomeMessage(aiType),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _scrollToBottom();
    });
  }

  String _getWelcomeMessage(String aiType) {
    switch (aiType) {
      case 'Corona Detection':
        return "I'm your COVID-19 detection assistant. Upload a chest X-ray or CT scan and I'll analyze it for potential COVID-19 indicators. Please note that this is not a replacement for professional medical diagnosis.";
      case 'Nutrition Coach':
        return "Hello! I'm your nutrition coach. I can help you track meals, suggest healthy recipes, and provide personalized nutrition advice based on your health goals.";
      case 'Mental Health':
        return "Hi there. I'm your mental wellness companion. I'm here to provide support, relaxation techniques, and mindfulness exercises. How are you feeling today?";
      case 'Sleep Analysis':
        return "Welcome to your sleep assistant. I can help analyze your sleep patterns and suggest improvements for better rest. Would you like to review your recent sleep data?";
      default:
        return "Hello! I'm your health assistant. How can I help you today?";
    }
  }

  String _getAIDescription(String aiType) {
    switch (aiType) {
      case 'Corona Detection':
        return "Analyze images for COVID-19 indicators";
      case 'Nutrition Coach':
        return "Get diet and meal planning advice";
      case 'Mental Health':
        return "Support for emotional wellbeing";
      case 'Sleep Analysis':
        return "Improve your sleep quality";
      default:
        return "General health assistance";
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Upload Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _getImage(ImageSource.camera);
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _getImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (selectedAI == 'Corona Detection')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'For COVID-19 detection, please upload a clear chest X-ray or CT scan image.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.teal, size: 32),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }

  void _showAIInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('About $selectedAI'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _getAIInfoContent(),
                const SizedBox(height: 16),
                if (selectedAI == 'Corona Detection')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Important Disclaimer:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This AI analysis is not a substitute for professional medical diagnosis. Always consult with a healthcare provider for proper evaluation and treatment.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getAIInfoContent() {
    switch (selectedAI) {
      case 'Corona Detection':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The Corona Detection AI uses image analysis to identify potential COVID-19 indicators in chest X-rays and CT scans.',
            ),
            SizedBox(height: 8),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Analyzes uploaded medical images'),
            Text('• Identifies potential COVID-19 patterns'),
            Text('• Provides risk assessment'),
            Text('• Recommends next steps based on analysis'),
          ],
        );
      case 'Nutrition Coach':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The Nutrition Coach AI helps you maintain a healthy diet tailored to your specific needs and goals.',
            ),
            SizedBox(height: 8),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Personalized nutrition advice'),
            Text('• Meal planning assistance'),
            Text('• Recipe recommendations'),
            Text('• Dietary goal tracking'),
          ],
        );
      default:
        return Text(
          'The $selectedAI assistant is designed to provide you with personalized health guidance and support.',
        );
    }
  }

  Widget _getAIAvatar({double size = 40}) {
    IconData icon;
    Color color;
    switch (selectedAI) {
      case 'Corona Detection':
        icon = Icons.coronavirus;
        color = Colors.red;
        break;
      case 'Nutrition Coach':
        icon = Icons.restaurant_menu;
        color = Colors.green;
        break;
      case 'Mental Health':
        icon = Icons.psychology;
        color = Colors.purple;
        break;
      case 'Sleep Analysis':
        icon = Icons.nightlight;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.health_and_safety;
        color = Colors.teal;
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color, size: size * 0.6),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _getAIAvatar(size: 60),
          const SizedBox(height: 16),
          Text(
            'Chat with $selectedAI',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              _getAIDescription(selectedAI),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: <Widget>[
              _buildSuggestionChip("What is my heart rate?"),
              _buildSuggestionChip("Do I need to exercise more?"),
              _buildSuggestionChip("Is my diet healthy?"),
              if (selectedAI == 'Corona Detection')
                _buildSuggestionChip("Check my X-ray", isUpload: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, {bool isUpload = false}) {
    return ActionChip(
      avatar: isUpload ? const Icon(Icons.upload, size: 16) : null,
      label: Text(text),
      onPressed: () {
        if (isUpload) {
          _showImageSourceDialog();
        } else {
          _sendMessage(text);
        }
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser) _getAIAvatar(size: 36),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.teal : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (message.image != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageAttachment(message.image),
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          message.isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return _messages.isEmpty
        ? _buildEmptyChatState()
        : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(_messages[index]);
          },
        );
  }

  Widget _buildAnalyzingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_selectedImage != null)
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageAttachment(_selectedImage),
              ),
            ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.teal),
          const SizedBox(height: 20),
          Text(
            selectedAI == 'Corona Detection'
                ? "Analyzing image for COVID-19 indicators..."
                : "Processing your image...",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                _showImageSourceDialog();
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
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (text) {
                  _sendMessage(text);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.teal),
              onPressed: () {
                _sendMessage(_messageController.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showAISelector,
          child: Row(
            children: <Widget>[
              _getAIAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      selectedAI,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to change assistant',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAIInfoDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // AI type indicator for Corona Detection
            if (selectedAI == 'Corona Detection')
              Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.coronavirus, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Upload a chest X-ray or CT scan for COVID-19 analysis',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.red),
                      onPressed: () {
                        _showImageSourceDialog();
                      },
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            // Chat messages or analyzing indicator
            Expanded(
              child:
                  _isAnalyzing
                      ? _buildAnalyzingIndicator()
                      : _buildChatMessages(),
            ),
            // Input field
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageAttachment(dynamic image) {
    if (image == null) return const SizedBox.shrink();

    if (kIsWeb) {
      // For web, image is an XFile
      return Image.network(
        (image as XFile).path,
        fit: BoxFit.cover,
        width: 200,
        height: 150,
      );
    } else {
      // For mobile, image is a File
      return Image.file(
        image as io.File,
        fit: BoxFit.cover,
        width: 200,
        height: 150,
      );
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final dynamic image;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.image,
  });
}
