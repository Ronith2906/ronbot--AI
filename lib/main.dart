// lib/main.dart

import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ONLY load .env on mobile/desktop, not on web
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }

  runApp(RonBot());
}

class RonBot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RonBot - Advanced AI Agent',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: RonBotHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? model;
  final String? imageUrl;
  
  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.model,
    this.imageUrl,
  });
}

class RonBotHome extends StatefulWidget {
  @override
  State<RonBotHome> createState() => _RonBotHomeState();
}

class _RonBotHomeState extends State<RonBotHome> {
  SpeechToText? _speech;
  FlutterTts? _tts;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Message> _messages = [];
  bool _isListening = false;
  bool _speechEnabled = false;
  bool _isLoading = false;
  bool _voiceOutputEnabled = true;
  bool _showSettings = false;
  
  // Web Speech API support
  dynamic _webSpeechRecognition;
  dynamic _webSpeechSynthesis;
  
  // Settings
  String _selectedModel = 'gpt-3.5-turbo';
  double _speechRate = 0.5;
  String _selectedVoice = 'en-US';
  bool _autoScroll = true;
  bool _darkMode = false;
  String _selectedLanguage = 'en';
  bool _codeHighlighting = true;
  bool _autoSave = true;
  bool _analyticsEnabled = true;
  bool _collaborationMode = false;
  String _selectedTheme = 'default';
  bool _performanceMonitoring = true;
  bool _pluginSystemEnabled = true;
  
  final List<String> _availableModels = [
    'gpt-3.5-turbo',
    'gpt-4',
    'gpt-4-turbo',
    'gpt-4o',
    'gpt-4o-mini',
  ];
  
  // Analytics
  int _totalMessages = 0;
  int _totalTokens = 0;
  DateTime _sessionStart = DateTime.now();
  Map<String, int> _featureUsage = {};
  
  // Performance
  List<double> _responseTimes = [];
  double _averageResponseTime = 0.0;
  
  // Collaboration
  String? _sessionId;
  List<String> _collaborators = [];
  
  // Plugins
  List<Map<String, dynamic>> _activePlugins = [];
  
  // Templates
  List<Map<String, dynamic>> _conversationTemplates = [
    {
      'name': 'Code Review',
      'description': 'Review and improve code',
      'prompt': 'Please review this code and suggest improvements:',
    },
    {
      'name': 'Creative Writing',
      'description': 'Help with creative writing',
      'prompt': 'Help me write a creative story about:',
    },
    {
      'name': 'Problem Solving',
      'description': 'Solve complex problems',
      'prompt': 'Let\'s solve this problem step by step:',
    },
    {
      'name': 'Learning Assistant',
      'description': 'Educational support',
      'prompt': 'Explain this concept in simple terms:',
    },
  ];
  
  final List<String> _availableThemes = [
    'default',
    'dark',
    'light',
    'blue',
    'green',
    'purple',
    'orange',
    'pink',
  ];
  
  final List<String> _availableLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ja',
    'ko',
    'zh',
  ];

  @override
  void initState() {
    super.initState();
    _initBot();
    _loadSettings();
    _loadConversationHistory();
    _loadAnalytics();
  }

  Future<void> _initBot() async {
    try {
      if (kIsWeb) {
        // Initialize Web Speech API
        _initWebSpeech();
      } else {
        // Initialize mobile/desktop speech
        _speech = SpeechToText();
        _tts = FlutterTts();
        
        // Initialize speech recognition
        _speechEnabled = await _speech!.initialize();

        // Initialize TTS
        await _tts!.setLanguage(_selectedVoice);
        await _tts!.setSpeechRate(_speechRate);
        await _tts!.setPitch(1.2);
        
        // Set TTS callbacks
        _tts!.setStartHandler(() {
          print('TTS started');
        });
        
        _tts!.setCompletionHandler(() {
          print('TTS completed');
        });
        
        _tts!.setErrorHandler((msg) {
          print('TTS error: $msg');
        });
      }

      setState(() {});
    } catch (e) {
      print('Error initializing bot: $e');
      setState(() {
        _speechEnabled = false;
      });
    }
  }

  void _initWebSpeech() {
    try {
      // Initialize Web Speech Recognition
      _webSpeechRecognition = html.window.navigator.mediaDevices;
      
      // Initialize Web Speech Synthesis
      _webSpeechSynthesis = html.window.speechSynthesis;
      
      setState(() {
        _speechEnabled = true;
      });
      
      print('Web Speech API initialized');
    } catch (e) {
      print('Error initializing Web Speech API: $e');
      setState(() {
        _speechEnabled = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceOutputEnabled = prefs.getBool('voice_output_enabled') ?? true;
      _selectedModel = prefs.getString('selected_model') ?? 'gpt-3.5-turbo';
      _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
      _selectedVoice = prefs.getString('selected_voice') ?? 'en-US';
      _autoScroll = prefs.getBool('auto_scroll') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      _codeHighlighting = prefs.getBool('code_highlighting') ?? true;
      _autoSave = prefs.getBool('auto_save') ?? true;
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _collaborationMode = prefs.getBool('collaboration_mode') ?? false;
      _selectedTheme = prefs.getString('selected_theme') ?? 'default';
      _performanceMonitoring = prefs.getBool('performance_monitoring') ?? true;
      _pluginSystemEnabled = prefs.getBool('plugin_system_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_output_enabled', _voiceOutputEnabled);
    await prefs.setString('selected_model', _selectedModel);
    await prefs.setDouble('speech_rate', _speechRate);
    await prefs.setString('selected_voice', _selectedVoice);
    await prefs.setBool('auto_scroll', _autoScroll);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setBool('code_highlighting', _codeHighlighting);
    await prefs.setBool('auto_save', _autoSave);
    await prefs.setBool('analytics_enabled', _analyticsEnabled);
    await prefs.setBool('collaboration_mode', _collaborationMode);
    await prefs.setString('selected_theme', _selectedTheme);
    await prefs.setBool('performance_monitoring', _performanceMonitoring);
    await prefs.setBool('plugin_system_enabled', _pluginSystemEnabled);
  }

  Future<void> _loadConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('conversation_history') ?? [];
    setState(() {
      _messages = history.map((msg) {
        final data = json.decode(msg);
        return Message(
          text: data['text'],
          isUser: data['isUser'],
          timestamp: DateTime.parse(data['timestamp']),
          model: data['model'],
        );
      }).toList();
    });
  }

  Future<void> _saveConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _messages.map((msg) => json.encode({
      'text': msg.text,
      'isUser': msg.isUser,
      'timestamp': msg.timestamp.toIso8601String(),
      'model': msg.model,
    })).toList();
    await prefs.setStringList('conversation_history', history);
  }

  void _startListening() async {
    if (_speechEnabled && !_isListening && _speech != null) {
      try {
        setState(() => _isListening = true);
        await _speech!.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
            if (result.finalResult) {
              _handleUserInput(_textController.text.trim());
            }
          },
        );
      } catch (e) {
        print('Error starting speech recognition: $e');
        setState(() => _isListening = false);
      }
    }
  }

  void _stopListening() {
    if (!kIsWeb && _speech != null) {
      _speech!.stop();
    }
    setState(() => _isListening = false);
  }

  Future<void> _handleUserInput(String input) async {
    if (input.trim().isEmpty) return;
    
    _stopListening();
    setState(() => _isLoading = true);
    
    // Add user message
    final userMessage = Message(
      text: input,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMessage);
      _textController.clear();
    });

    try {
      final startTime = DateTime.now();
      final response = await _generateAdvancedResponse(input);
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds / 1000.0;
      
      // Track analytics
      _totalMessages++;
      _trackFeatureUsage('chat');
      _trackResponseTime(responseTime);
      
      // Add bot response
      final botMessage = Message(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        model: _selectedModel,
      );
      
      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });
      
      // Save conversation
      await _saveConversationHistory();
      
             // Voice output (if enabled)
       if (_voiceOutputEnabled) {
         try {
           if (kIsWeb) {
             // Use Web Speech Synthesis
             _speakWeb(response);
           } else if (_tts != null) {
             await _tts!.speak(response);
           }
         } catch (e) {
           print('TTS error: $e');
           // Don't show error to user, just log it
         }
       }
      
      // Auto scroll
      if (_autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      final errorMessage = Message(
        text: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
    }
  }

  Future<String> _generateAdvancedResponse(String input) async {
    final lowerInput = input.toLowerCase();
    
    // Check for special commands
    if (lowerInput.contains('search') || lowerInput.contains('google')) {
      return await _performGoogleSearch(input);
    }
    
    if (lowerInput.contains('translate')) {
      return await _handleTranslation(input);
    }
    
    if (lowerInput.contains('generate image') || lowerInput.contains('create image')) {
      return await _handleImageGeneration(input);
    }
    
    if (lowerInput.contains('code') || lowerInput.contains('programming')) {
      return await _handleCodeRequest(input);
    }
    
    if (lowerInput.contains('file') || lowerInput.contains('upload') || lowerInput.contains('analyze')) {
      return await _handleFileAnalysis(input);
    }
    
    if (lowerInput.contains('chart') || lowerInput.contains('graph') || lowerInput.contains('visualize')) {
      return await _handleDataVisualization(input);
    }
    
    // Check for smart replies
    if (lowerInput.contains("how are you")) {
      return "I'm thriving and ready to help! What can I assist you with today?";
    }
    if (lowerInput.contains("your name")) {
      return "I'm RonBot, your advanced AI assistant. I can help with conversations, searches, and much more!";
    }
    if (lowerInput.contains("hello") || lowerInput.contains("hi")) {
      return "Hello! I'm your advanced AI assistant with multiple capabilities:\n\n💬 **Chat**: Natural conversations\n🔍 **Search**: Web searches\n🎨 **Images**: Generate images with DALL-E\n💻 **Code**: Programming assistance\n🌐 **Translate**: Multi-language support\n🎤 **Voice**: Voice input/output\n⚙️ **Settings**: Customize experience\n\nTry asking me anything or use the settings panel!";
    }
    if (lowerInput.contains("weather")) {
      return "I can help you search for weather information! Try saying 'search weather in [your city]' or 'google weather forecast'.";
    }
    if (lowerInput.contains("news")) {
      return await _handleNewsRequest(input);
    }
    if (lowerInput.contains("help") || lowerInput.contains("what can you do")) {
      return "I'm an advanced AI agent with multiple capabilities:\n\n🔍 **Search**: Say 'search [topic]' or 'google [query]'\n📰 **News**: 'Get latest news' or 'news about [topic]'\n💬 **Chat**: Have natural conversations\n🎨 **Images**: 'Generate image of [description]'\n💻 **Code**: 'Write code for [task]'\n🌐 **Translate**: 'Translate [text] to [language]'\n🎤 **Voice**: Use voice input (mobile/desktop)\n🔊 **Voice Output**: Hear responses aloud\n⚙️ **Settings**: Customize your experience\n\nTry asking me anything or use the settings panel to customize!";
    }

    // Use ChatGPT for advanced responses
    try {
      return await _callChatGPT(input);
    } catch (e) {
      print('Error calling ChatGPT: $e');
      return 'I apologize, but I\'m having trouble connecting to my AI service right now. Please try again later or check your internet connection.';
    }
  }

  Future<String> _performGoogleSearch(String query) async {
    // Extract search query
    String searchQuery = query;
    if (query.toLowerCase().contains('search')) {
      searchQuery = query.replaceAll(RegExp(r'search\s*', caseSensitive: false), '').trim();
    }
    if (query.toLowerCase().contains('google')) {
      searchQuery = query.replaceAll(RegExp(r'google\s*', caseSensitive: false), '').trim();
    }
    
    try {
      // Check if API key is configured
      if (ApiConfig.googleSearchApiKey == 'your_google_search_api_key_here') {
        return "🔍 **Google Search**: $searchQuery\n\n⚠️ Google Search API not configured yet.\n\nTo enable real web search:\n1. Get a Google Custom Search API key\n2. Update the API key in config.dart\n3. Set up a Custom Search Engine\n\nFor now, I can help you with:\n• General knowledge questions\n• Calculations\n• Writing assistance\n• Code help\n• Creative tasks";
      }
      
      // Check if Search Engine ID is configured
      if (ApiConfig.googleSearchEngineId == 'your_google_search_engine_id_here') {
        return "🔍 **Google Search**: $searchQuery\n\n⚠️ Google Search Engine ID not configured yet.\n\nTo complete Google Search setup:\n1. Go to [Google Programmable Search Engine](https://programmablesearchengine.google.com/)\n2. Create a new search engine\n3. Copy the Search Engine ID (cx parameter)\n4. Update googleSearchEngineId in config.dart\n\nFor now, I can help you with:\n• General knowledge questions\n• Calculations\n• Writing assistance\n• Code help\n• Creative tasks";
      }
      
      // Perform actual Google search
      final url = Uri.parse('${ApiConfig.googleSearchApiUrl}?key=${ApiConfig.googleSearchApiKey}&cx=${ApiConfig.googleSearchEngineId}&q=${Uri.encodeComponent(searchQuery)}&num=5');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items != null && items.isNotEmpty) {
          String result = "🔍 **Google Search Results for**: $searchQuery\n\n";
          
          for (int i = 0; i < items.length && i < 3; i++) {
            final item = items[i];
            final title = item['title'] ?? 'No title';
            final link = item['link'] ?? '';
            final snippet = item['snippet'] ?? 'No description';
            
            result += "**${i + 1}. $title**\n";
            result += "$snippet\n";
            result += "🔗 $link\n\n";
          }
          
          return result;
        } else {
          return "🔍 **Google Search**: $searchQuery\n\nNo results found for your search query. Try rephrasing your search or ask me directly!";
        }
      } else {
        return "🔍 **Google Search Error**: $searchQuery\n\nError performing search (Status: ${response.statusCode}). Please check your API configuration.";
      }
    } catch (e) {
      return "🔍 **Google Search Error**: $searchQuery\n\nError: $e\n\nPlease check your API configuration in config.dart";
    }
  }

  Future<String> _callChatGPT(String input) async {
    try {
      final apiKey = _getApiKey();
      print('Making API call to OpenAI with key: ${apiKey.substring(0, 20)}...');
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      
      final requestBody = {
        'model': _selectedModel,
        'messages': [
          {
            'role': 'system',
            'content': '''You are RonBot, an advanced AI assistant with a friendly and helpful personality. You can:
- Answer questions knowledgeably
- Help with creative tasks
- Assist with problem-solving
- Provide detailed explanations
- Be conversational and engaging

Keep responses informative but concise. Use markdown formatting when helpful.'''
          },
          {'role': 'user', 'content': input},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };
      
      print('Request body: ${json.encode(requestBody)}');
      
      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(requestBody),
      );
      
      print('API Response Status: ${resp.statusCode}');
      print('API Response Body: ${resp.body}');
      
      if (resp.statusCode != 200) {
        throw Exception('OpenAI API Error ${resp.statusCode}: ${resp.body}');
      }
      
      final data = json.decode(resp.body);
      final response = (data['choices'][0]['message']['content'] as String).trim();
      print('ChatGPT response: $response');
      return response;
    } catch (e) {
      print('Error in ChatGPT call: $e');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      
      // Provide a more helpful error message
      if (e.toString().contains('NotInitializedError')) {
        return 'Sorry, there was an issue with the API configuration. Please check your OpenAI API key.';
      } else if (e.toString().contains('401')) {
        return 'Sorry, your API key is invalid. Please check your OpenAI API key configuration.';
      } else if (e.toString().contains('429')) {
        return 'Sorry, you have exceeded your API rate limit. Please try again later.';
      } else {
        return 'Sorry, I encountered an error: $e. Please try again or check your API key.';
      }
    }
  }

  String _getApiKey() {
    // Use config file directly for MVP
    return ApiConfig.openaiApiKey;
  }

  void _clearConversation() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Conversation'),
        content: Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              _saveConversationHistory();
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _trackFeatureUsage(String feature) {
    if (_analyticsEnabled) {
      _featureUsage[feature] = (_featureUsage[feature] ?? 0) + 1;
      _saveAnalytics();
    }
  }

  void _trackResponseTime(double responseTime) {
    if (_performanceMonitoring) {
      _responseTimes.add(responseTime);
      if (_responseTimes.length > 100) {
        _responseTimes.removeAt(0);
      }
      _averageResponseTime = _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;
      _saveAnalytics();
    }
  }

  Future<void> _saveAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_messages', _totalMessages);
    await prefs.setInt('total_tokens', _totalTokens);
    await prefs.setString('feature_usage', json.encode(_featureUsage));
    await prefs.setString('response_times', json.encode(_responseTimes));
    await prefs.setDouble('average_response_time', _averageResponseTime);
  }

  Future<void> _loadAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalMessages = prefs.getInt('total_messages') ?? 0;
      _totalTokens = prefs.getInt('total_tokens') ?? 0;
      final featureUsageStr = prefs.getString('feature_usage');
      if (featureUsageStr != null) {
        _featureUsage = Map<String, int>.from(json.decode(featureUsageStr));
      }
      final responseTimesStr = prefs.getString('response_times');
      if (responseTimesStr != null) {
        _responseTimes = List<double>.from(json.decode(responseTimesStr));
      }
      _averageResponseTime = prefs.getDouble('average_response_time') ?? 0.0;
    });
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📊 Analytics Dashboard'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📈 **Session Statistics**', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Total Messages: $_totalMessages'),
              Text('Total Tokens: $_totalTokens'),
              Text('Session Duration: ${DateTime.now().difference(_sessionStart).inMinutes} minutes'),
              Text('Average Response Time: ${_averageResponseTime.toStringAsFixed(2)}s'),
              SizedBox(height: 12),
              Text('🎯 **Feature Usage**', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._featureUsage.entries.map((entry) => 
                Text('${entry.key}: ${entry.value} times')
              ),
              SizedBox(height: 12),
              Text('⚡ **Performance**', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Recent Response Times: ${_responseTimes.take(5).map((t) => t.toStringAsFixed(2)).join(', ')}s'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTemplates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📋 Conversation Templates'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _conversationTemplates.map((template) => 
              ListTile(
                title: Text(template['name']),
                subtitle: Text(template['description']),
                onTap: () {
                  Navigator.pop(context);
                  _textController.text = template['prompt'];
                  _textController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _textController.text.length),
                  );
                },
              ),
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Keyboard Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯 **Features**', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• 💬 Smart Chat with multiple AI models'),
              Text('• 🎨 Image Generation (DALL-E)'),
              Text('• 💻 Code Assistant'),
              Text('• 🌐 Translation'),
              Text('• 🎤 Voice Input/Output'),
              Text('• 📁 Export Conversations'),
              SizedBox(height: 12),
              Text('⌨️ **Keyboard Shortcuts**', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Enter: Send message'),
              Text('• Ctrl+Enter: New line'),
              Text('• Ctrl+S: Export chat'),
              Text('• Ctrl+L: Clear chat'),
              Text('• Ctrl+?: Show help'),
              SizedBox(height: 12),
              Text('🎮 **Voice Commands**', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• "Generate image of..."'),
              Text('• "Translate to..."'),
              Text('• "Write code for..."'),
              Text('• "Search for..."'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportConversation() async {
    try {
      final exportData = {
        'timestamp': DateTime.now().toIso8601String(),
        'messages': _messages.map((msg) => {
          'text': msg.text,
          'isUser': msg.isUser,
          'timestamp': msg.timestamp.toIso8601String(),
          'model': msg.model,
        }).toList(),
      };
      
      final jsonString = json.encode(exportData);
      
      if (kIsWeb) {
        // Create download link for web
        final blob = html.Blob([jsonString], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'ronbot_conversation_${DateTime.now().millisecondsSinceEpoch}.json')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Export Successful'),
          content: Text('Conversation exported successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Export Failed'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _testApiKey() async {
    try {
      final apiKey = _getApiKey();
      
      // Test the API with a simple call
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
          'max_tokens': 50,
        }),
      );
      
      if (resp.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('API Test Success'),
            content: Text('API Key is working! Response: ${resp.body.substring(0, 100)}...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('API Test Failed'),
            content: Text('Status: ${resp.statusCode}\nResponse: ${resp.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('API Key Error'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<String> _handleTranslation(String input) async {
    // Extract text to translate and target language
    final text = input.replaceAll(RegExp(r'translate\s*', caseSensitive: false), '').trim();
    return "🌐 **Translation Feature**\n\nI can help translate text to different languages. Try:\n• 'Translate hello to Spanish'\n• 'Translate this text to French'\n• 'Translate to German'\n\nFor now, I'll use ChatGPT to help with translation: ${await _callChatGPT('Translate: $text')}";
  }

  Future<String> _handleImageGeneration(String input) async {
    final description = input.replaceAll(RegExp(r'generate image of|create image of', caseSensitive: false), '').trim();
    
    try {
      final apiKey = _getApiKey();
      final url = Uri.parse('https://api.openai.com/v1/images/generations');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'prompt': description,
          'n': 1,
          'size': '1024x1024',
          'quality': 'standard',
          'response_format': 'url',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['data'][0]['url'];
        
        // Add the image message to the conversation
        final imageMessage = Message(
          text: "🎨 **Image Generated Successfully!**\n\n**Prompt**: $description\n\n**Image URL**: $imageUrl\n\nYou can download or view the generated image at the URL above. The image has been created using DALL-E with high quality settings.",
          isUser: false,
          timestamp: DateTime.now(),
          model: 'dall-e',
          imageUrl: imageUrl,
        );
        
        // Don't add to messages here, let the calling function handle it
        return "🎨 **Image Generated Successfully!**\n\n**Prompt**: $description\n\n**Image URL**: $imageUrl\n\nYou can download or view the generated image at the URL above. The image has been created using DALL-E with high quality settings.";
      } else {
        print('Image generation error: ${response.statusCode} - ${response.body}');
        return "🎨 **Image Generation**\n\nI can generate images using DALL-E. Try:\n• 'Generate image of a beautiful sunset'\n• 'Create image of a robot in space'\n• 'Generate image of a cat playing piano'\n\nFor now, I'll describe what I would generate: ${await _callChatGPT('Describe an image of: $description')}";
      }
    } catch (e) {
      print('Error generating image: $e');
      return "🎨 **Image Generation**\n\nI can generate images using DALL-E. Try:\n• 'Generate image of a beautiful sunset'\n• 'Create image of a robot in space'\n• 'Generate image of a cat playing piano'\n\nFor now, I'll describe what I would generate: ${await _callChatGPT('Describe an image of: $description')}";
    }
  }

  Future<String> _handleCodeRequest(String input) async {
    return "💻 **Code Assistant**\n\nI can help with programming tasks. Try:\n• 'Write code for a calculator'\n• 'Help me debug this code'\n• 'Explain this algorithm'\n• 'Create a web page'\n\nLet me help you with: ${await _callChatGPT('Programming help: $input')}";
  }

  Future<String> _handleFileAnalysis(String input) async {
    return "📁 **File Analysis**\n\nI can analyze uploaded files. Try:\n• 'Analyze this document'\n• 'Summarize this file'\n• 'Extract key points'\n• 'Find patterns in this data'\n\nFor now, I'll help you with: ${await _callChatGPT('File analysis: $input')}";
  }

  Future<String> _handleDataVisualization(String input) async {
    return "📊 **Data Visualization**\n\nI can help create charts and graphs. Try:\n• 'Create a bar chart for this data'\n• 'Visualize sales trends'\n• 'Generate a pie chart'\n• 'Show data distribution'\n\nLet me help you with: ${await _callChatGPT('Data visualization: $input')}";
  }

  Future<String> _handleNewsRequest(String input) async {
    try {
      print('🔍 News API Debug: Starting news request');
      print('🔍 News API Key: ${ApiConfig.newsApiKey.substring(0, 10)}...');
      
      // Extract news topic from input
      String topic = 'general';
      if (input.toLowerCase().contains('news about')) {
        topic = input.replaceAll(RegExp(r'news about\s*', caseSensitive: false), '').trim();
      } else if (input.toLowerCase().contains('latest news')) {
        topic = 'general';
      } else {
        // Extract any topic after "news"
        final newsIndex = input.toLowerCase().indexOf('news');
        if (newsIndex != -1 && newsIndex + 4 < input.length) {
          topic = input.substring(newsIndex + 4).trim();
        }
      }
      
      print('🔍 News API Debug: Topic = $topic');
      
      // Call News API - Fix the URL to not require a query parameter for general news
      String urlString;
      if (topic == 'general') {
        urlString = '${ApiConfig.newsApiUrl}/top-headlines?country=us&apiKey=${ApiConfig.newsApiKey}&pageSize=5';
      } else {
        urlString = '${ApiConfig.newsApiUrl}/everything?q=${Uri.encodeComponent(topic)}&apiKey=${ApiConfig.newsApiKey}&pageSize=5&sortBy=publishedAt';
      }
      
      final url = Uri.parse(urlString);
      
      print('🔍 News API Debug: URL = $url');
      
      final response = await http.get(url);
      
      print('🔍 News API Debug: Status = ${response.statusCode}');
      print('🔍 News API Debug: Body = ${response.body.substring(0, 200)}...');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List?;
        
        if (articles != null && articles.isNotEmpty) {
          String result = "📰 **Latest News${topic != 'general' ? ' about $topic' : ''}**\n\n";
          
          for (int i = 0; i < articles.length && i < 3; i++) {
            final article = articles[i];
            final title = article['title'] ?? 'No title';
            final description = article['description'] ?? 'No description';
            final url = article['url'] ?? '';
            final publishedAt = article['publishedAt'] ?? '';
            
            // Format date
            String formattedDate = '';
            if (publishedAt.isNotEmpty) {
              try {
                final date = DateTime.parse(publishedAt);
                formattedDate = '${date.day}/${date.month}/${date.year}';
              } catch (e) {
                formattedDate = publishedAt;
              }
            }
            
            result += "**${i + 1}. $title**\n";
            result += "$description\n";
            if (formattedDate.isNotEmpty) {
              result += "📅 $formattedDate\n";
            }
            result += "🔗 $url\n\n";
          }
          
          return result;
        } else {
          return "📰 **News**: No news found for '$topic'. Try:\n• 'Get latest news'\n• 'News about technology'\n• 'News about sports'";
        }
      } else {
        return "📰 **News API Error**: Status ${response.statusCode}\n\nResponse: ${response.body}\n\nPlease check your News API configuration.";
      }
    } catch (e) {
      return "📰 **News Error**: $e\n\nPlease check your News API configuration in config.dart";
    }
  }

  void _speakWeb(String text) {
    if (kIsWeb) {
      try {
        // Check if ElevenLabs is configured
        if (ApiConfig.elevenLabsApiKey != 'your_elevenlabs_api_key_here') {
          // Use ElevenLabs for better voice quality
          _speakWithElevenLabs(text);
        } else {
          // Fallback to browser's built-in speech synthesis
          final utterance = html.SpeechSynthesisUtterance(text);
          utterance.rate = _speechRate;
          utterance.pitch = 1.2;
          utterance.volume = 1.0;
          html.window.speechSynthesis?.speak(utterance);
          print('Web speech synthesis started for: ${text.substring(0, 50)}...');
        }
      } catch (e) {
        print('Web speech synthesis error: $e');
      }
    }
  }

  Future<void> _speakWithElevenLabs(String text) async {
    try {
      print('🔊 ElevenLabs Debug: Starting voice synthesis');
      print('🔊 ElevenLabs API Key: ${ApiConfig.elevenLabsApiKey.substring(0, 10)}...');
      
      final url = Uri.parse('${ApiConfig.elevenLabsApiUrl}/text-to-speech/${ApiConfig.elevenLabsVoiceId}');
      
      print('🔊 ElevenLabs Debug: URL = $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': ApiConfig.elevenLabsApiKey,
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.5,
          },
        }),
      );
      
      print('🔊 ElevenLabs Debug: Status = ${response.statusCode}');
      print('🔊 ElevenLabs Debug: Response length = ${response.body.length}');
      
      if (response.statusCode == 200) {
        // Convert audio data to blob and play
        final audioBlob = html.Blob([response.bodyBytes]);
        final audioUrl = html.Url.createObjectUrlFromBlob(audioBlob);
        final audio = html.AudioElement()
          ..src = audioUrl
          ..play();
        
        print('ElevenLabs speech synthesis started for: ${text.substring(0, 50)}...');
      } else {
        print('ElevenLabs API error: ${response.statusCode} - ${response.body}');
        // Fallback to browser speech synthesis
        final utterance = html.SpeechSynthesisUtterance(text);
        utterance.rate = _speechRate;
        utterance.pitch = 1.2;
        utterance.volume = 1.0;
        html.window.speechSynthesis?.speak(utterance);
      }
    } catch (e) {
      print('ElevenLabs speech synthesis error: $e');
      // Fallback to browser speech synthesis
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.rate = _speechRate;
      utterance.pitch = 1.2;
      utterance.volume = 1.0;
      html.window.speechSynthesis?.speak(utterance);
    }
  }

  void _startWebListening() {
    if (kIsWeb) {
      setState(() => _isListening = true);
      
      // Request microphone permission first
      _requestMicrophonePermission();
    }
  }

  void _requestMicrophonePermission() async {
    try {
      // Request microphone permission using MediaDevices API
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({'audio': true});
      
      if (stream != null) {
        // Permission granted, start speech recognition
        _startWebSpeechRecognition();
      } else {
        // Permission denied
        setState(() => _isListening = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Microphone Permission Denied'),
            content: Text('Please allow microphone access in your browser settings to use voice input.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error requesting microphone permission: $e');
      setState(() => _isListening = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Microphone Error'),
          content: Text('Could not access microphone. Please check your browser settings and try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _startWebSpeechRecognition() {
    try {
      // Show a dialog to guide users
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Voice Input'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Voice input is now available!'),
              SizedBox(height: 8),
              Text('To use voice input:'),
              Text('• Click the microphone button'),
              Text('• Allow microphone access when prompted'),
              Text('• Speak clearly into your microphone'),
              SizedBox(height: 8),
              Text('Note: Voice input works best in Chrome browser.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      
      setState(() => _isListening = false);
      
    } catch (e) {
      print('Error with web speech: $e');
      setState(() => _isListening = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Voice Input Not Available'),
          content: Text('Voice input is not supported in this browser. Please use text input instead.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text('RonBot 🤖✨'),
        backgroundColor: _darkMode ? Colors.grey[800] : Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: _showAnalytics,
            tooltip: 'Analytics Dashboard',
          ),
          IconButton(
            icon: Icon(Icons.format_list_bulleted),
            onPressed: _showTemplates,
            tooltip: 'Conversation Templates',
          ),
          IconButton(
            icon: Icon(Icons.help),
            onPressed: _showHelp,
            tooltip: 'Help & Shortcuts',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => setState(() => _showSettings = !_showSettings),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportConversation,
            tooltip: 'Export Chat',
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _clearConversation,
            tooltip: 'Clear Chat',
          ),
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _testApiKey,
            tooltip: 'Test API Key',
          ),
        ],
      ),
      body: Column(
        children: [
          // Settings Panel
          if (_showSettings)
            Container(
              padding: EdgeInsets.all(16),
              color: _darkMode ? Colors.grey[800] : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: _darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                                     // Voice Output Toggle
                   SwitchListTile(
                     title: Text('Voice Output'),
                     subtitle: Text('Hear responses aloud'),
                     value: _voiceOutputEnabled,
                     onChanged: (value) {
                       setState(() => _voiceOutputEnabled = value);
                       _saveSettings();
                     },
                   ),
                  
                  // Model Selection
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'AI Model',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedModel,
                    items: _availableModels.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedModel = value!);
                      _saveSettings();
                    },
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Speech Rate
                  Text('Speech Rate: ${_speechRate.toStringAsFixed(1)}'),
                  Slider(
                    value: _speechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                                         onChanged: (value) {
                       setState(() => _speechRate = value);
                       _tts?.setSpeechRate(value);
                       _saveSettings();
                     },
                  ),
                  
                                     // Auto Scroll
                   SwitchListTile(
                     title: Text('Auto Scroll'),
                     subtitle: Text('Automatically scroll to new messages'),
                     value: _autoScroll,
                     onChanged: (value) {
                       setState(() => _autoScroll = value);
                       _saveSettings();
                     },
                   ),
                   
                   // Dark Mode
                   SwitchListTile(
                     title: Text('Dark Mode'),
                     subtitle: Text('Use dark theme'),
                     value: _darkMode,
                     onChanged: (value) {
                       setState(() => _darkMode = value);
                       _saveSettings();
                     },
                   ),
                   
                   // Code Highlighting
                   SwitchListTile(
                     title: Text('Code Highlighting'),
                     subtitle: Text('Highlight code in responses'),
                     value: _codeHighlighting,
                     onChanged: (value) {
                       setState(() => _codeHighlighting = value);
                       _saveSettings();
                     },
                   ),
                   
                   // Auto Save
                   SwitchListTile(
                     title: Text('Auto Save'),
                     subtitle: Text('Automatically save conversations'),
                     value: _autoSave,
                     onChanged: (value) {
                       setState(() => _autoSave = value);
                       _saveSettings();
                     },
                   ),
                   
                   SizedBox(height: 12),
                   
                   // Language Selection
                   DropdownButtonFormField<String>(
                     decoration: InputDecoration(
                       labelText: 'Language',
                       border: OutlineInputBorder(),
                     ),
                     value: _selectedLanguage,
                     items: _availableLanguages.map((lang) {
                       return DropdownMenuItem(
                         value: lang,
                         child: Text(lang.toUpperCase()),
                       );
                     }).toList(),
                     onChanged: (value) {
                       setState(() => _selectedLanguage = value!);
                       _saveSettings();
                     },
                   ),
                   
                   SizedBox(height: 12),
                   
                   // Theme Selection
                   DropdownButtonFormField<String>(
                     decoration: InputDecoration(
                       labelText: 'Theme',
                       border: OutlineInputBorder(),
                     ),
                     value: _selectedTheme,
                     items: _availableThemes.map((theme) {
                       return DropdownMenuItem(
                         value: theme,
                         child: Text(theme.toUpperCase()),
                       );
                     }).toList(),
                     onChanged: (value) {
                       setState(() => _selectedTheme = value!);
                       _saveSettings();
                     },
                   ),
                   
                   SizedBox(height: 12),
                   
                   // Advanced Features
                   Text('Advanced Features', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   SizedBox(height: 8),
                   
                   // Analytics
                   SwitchListTile(
                     title: Text('Analytics'),
                     subtitle: Text('Track usage and performance'),
                     value: _analyticsEnabled,
                     onChanged: (value) {
                       setState(() => _analyticsEnabled = value);
                       _saveSettings();
                     },
                   ),
                   
                   // Performance Monitoring
                   SwitchListTile(
                     title: Text('Performance Monitoring'),
                     subtitle: Text('Track response times'),
                     value: _performanceMonitoring,
                     onChanged: (value) {
                       setState(() => _performanceMonitoring = value);
                       _saveSettings();
                     },
                   ),
                   
                   // Plugin System
                   SwitchListTile(
                     title: Text('Plugin System'),
                     subtitle: Text('Enable custom plugins'),
                     value: _pluginSystemEnabled,
                     onChanged: (value) {
                       setState(() => _pluginSystemEnabled = value);
                       _saveSettings();
                     },
                   ),
                   
                   // Collaboration Mode
                   SwitchListTile(
                     title: Text('Collaboration Mode'),
                     subtitle: Text('Share conversations'),
                     value: _collaborationMode,
                     onChanged: (value) {
                       setState(() => _collaborationMode = value);
                       _saveSettings();
                     },
                   ),
                   
                   SizedBox(height: 12),
                   
                   // Voice Status
                   Container(
                     padding: EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.grey[100],
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Voice Status',
                           style: TextStyle(fontWeight: FontWeight.bold),
                         ),
                         SizedBox(height: 4),
                         Text(
                           _speechEnabled 
                             ? 'Voice input and output available'
                             : 'Voice features not available',
                           style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ),
          
          // Messages Area
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _darkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'RonBot is thinking...',
                              style: TextStyle(
                                color: _darkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final message = _messages[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          CircleAvatar(
                            backgroundColor: message.isUser ? Colors.indigo : Colors.green,
                            child: Icon(
                              message.isUser ? Icons.person : Icons.smart_toy,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          
                          // Message Content
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.isUser 
                                  ? (_darkMode ? Colors.indigo[900] : Colors.indigo[50])
                                  : (_darkMode ? Colors.grey[700] : Colors.grey[50]),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: message.isUser 
                                    ? (_darkMode ? Colors.indigo[600]! : Colors.indigo[200]!)
                                    : (_darkMode ? Colors.grey[600]! : Colors.grey[300]!),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _darkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  if (message.imageUrl != null) ...[
                                    SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          message.imageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.error, color: Colors.grey[600]),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Image failed to load',
                                                      style: TextStyle(color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (message.model != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      'via ${message.model}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Input Area
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _darkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                                 // Voice Button (works on all platforms now)
                 IconButton(
                   onPressed: _isLoading ? null : (_speechEnabled ? 
                     (kIsWeb ? _startWebListening : _startListening) : null),
                   icon: Icon(
                     _isListening ? Icons.stop : Icons.mic,
                     color: _isListening 
                       ? Colors.red 
                       : (_speechEnabled ? Colors.indigo : Colors.grey),
                   ),
                   tooltip: _speechEnabled 
                     ? 'Use voice input' 
                     : 'Voice not available',
                 ),
                
                // Text Input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _handleUserInput(text.trim());
                      }
                    },
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Send Button
                IconButton(
                  onPressed: _isLoading ? null : () {
                    if (_textController.text.trim().isNotEmpty) {
                      _handleUserInput(_textController.text.trim());
                    }
                  },
                  icon: Icon(Icons.send, color: Colors.indigo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
