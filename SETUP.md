# RonBot Advanced AI Agent - Setup Guide

## 🚀 Features

Your RonBot now includes:
- **💬 Advanced Chat Interface** with conversation history
- **🤖 Multiple AI Models** (GPT-3.5, GPT-4, GPT-4 Turbo)
- **🔊 Voice Input/Output** (mobile/desktop)
- **⚙️ Settings Panel** with customization options
- **🔍 Google Search Integration** (placeholder)
- **📱 Responsive Design** for web and mobile
- **💾 Persistent Storage** for conversations and settings

## 🔑 Setup Instructions

### 1. OpenAI API Key Setup

**For Web:**
Run the app with your API key:
```bash
flutter run -d chrome --dart-define=OPENAI_API_KEY=your_actual_api_key_here
```

**For Mobile/Desktop:**
Create a `.env` file in the project root:
```
OPENAI_API_KEY=your_actual_api_key_here
```

### 2. Get Your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Go to API Keys section
4. Create a new API key
5. Copy the key and use it in the setup above

### 3. Running the App

**Web:**
```bash
flutter run -d chrome --dart-define=OPENAI_API_KEY=your_key
```

**Mobile:**
```bash
flutter run
```

**Desktop:**
```bash
flutter run -d windows  # or macos, linux
```

## 🎯 How to Use

### Basic Chat
- Type messages in the text field
- Press Enter or click Send
- Get intelligent responses from ChatGPT

### Voice Features (Mobile/Desktop)
- Click the microphone button
- Speak your message
- Hear responses aloud (if enabled)

### Settings Panel
- Click the settings icon in the top-right
- Customize:
  - Voice output on/off
  - AI model selection
  - Speech rate
  - Auto-scroll behavior

### Advanced Features
- **Search Commands**: Say "search [topic]" or "google [query]"
- **Help**: Ask "what can you do?" or "help"
- **Conversation History**: All chats are saved automatically
- **Clear Chat**: Use the delete button to start fresh

## 🔧 Customization

### Adding More AI Models
Edit the `_availableModels` list in `lib/main.dart`:
```dart
final List<String> _availableModels = [
  'gpt-3.5-turbo',
  'gpt-4',
  'gpt-4-turbo',
  'your-custom-model',
];
```

### Adding Google Search
To implement actual Google search:
1. Get a Google Custom Search API key
2. Add the search logic in `_performGoogleSearch()`
3. Replace the placeholder response with actual search results

### Voice Customization
- Change speech rate in settings
- Modify voice language in `_selectedVoice`
- Add more voice options

## 🛠️ Troubleshooting

### API Key Issues
- Ensure your OpenAI API key is valid
- Check that you have sufficient credits
- Verify the key is properly set in the environment

### Voice Not Working
- Voice features only work on mobile/desktop
- Check microphone permissions
- Ensure voice output is enabled in settings

### Web Issues
- Clear browser cache
- Check console for errors
- Ensure proper CORS settings

## 🎨 UI Customization

The app uses Material Design 3 with:
- Indigo primary color
- Rounded corners and shadows
- Responsive layout
- Dark/light theme support

## 📱 Platform Support

- ✅ **Web**: Full chat functionality, no voice
- ✅ **Android**: Full features including voice
- ✅ **iOS**: Full features including voice
- ✅ **Windows**: Full features including voice
- ✅ **macOS**: Full features including voice
- ✅ **Linux**: Full features including voice

## 🔮 Future Enhancements

- [ ] Real Google Search integration
- [ ] Image generation with DALL-E
- [ ] File upload and analysis
- [ ] Multi-language support
- [ ] Custom themes
- [ ] Export conversations
- [ ] Voice cloning
- [ ] Real-time collaboration

## 📄 License

This project is for educational purposes. Please respect OpenAI's terms of service. 