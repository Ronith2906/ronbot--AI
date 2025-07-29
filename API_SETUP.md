# 🔑 API Setup Guide - Google Search & ElevenLabs

## 🚀 Quick Setup

### 1. Update `config.dart`

Replace the placeholder values in `config.dart` with your actual API keys:

```dart
class ApiConfig {
  // OpenAI API Key (for ChatGPT and DALL-E)
  static const String openaiApiKey = 'sk-your-actual-openai-key-here';
  
  // Google Custom Search API Key (for web search functionality)
  static const String googleSearchApiKey = 'your-actual-google-search-api-key';
  static const String googleSearchEngineId = 'your-actual-search-engine-id';
  
  // ElevenLabs API Key (for voice synthesis)
  static const String elevenLabsApiKey = 'your-actual-elevenlabs-api-key';
  static const String elevenLabsVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Default voice
}
```

## 🔍 Google Custom Search API Setup

### Step 1: Get Google API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the "Custom Search API"
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy your API key

### Step 2: Create Custom Search Engine
1. Go to [Google Programmable Search Engine](https://programmablesearchengine.google.com/)
2. Click "Create a search engine"
3. Enter any website (e.g., `https://www.google.com`)
4. Get your Search Engine ID (cx parameter)
5. Copy the Search Engine ID

### Step 3: Configure in RonBot
Update `config.dart`:
```dart
static const String googleSearchApiKey = 'your-google-api-key';
static const String googleSearchEngineId = 'your-search-engine-id';
```

## 🔊 ElevenLabs Voice Setup

### Step 1: Get ElevenLabs API Key
1. Go to [ElevenLabs](https://elevenlabs.io/)
2. Sign up for a free account
3. Go to your profile → API Key
4. Copy your API key

### Step 2: Choose a Voice
1. Go to [ElevenLabs Voice Library](https://elevenlabs.io/voice-library)
2. Browse available voices
3. Copy the Voice ID (e.g., `21m00Tcm4TlvDq8ikWAM` for Rachel)

### Step 3: Configure in RonBot
Update `config.dart`:
```dart
static const String elevenLabsApiKey = 'your-elevenlabs-api-key';
static const String elevenLabsVoiceId = 'your-chosen-voice-id';
```

## 🎯 Testing Your Setup

### Test Google Search
1. Run the app: `flutter run -d chrome`
2. Type: "search Flutter development"
3. Should show real Google search results

### Test ElevenLabs Voice
1. Enable voice output in settings
2. Send a message
3. Should hear high-quality voice synthesis

## 🔧 Troubleshooting

### Google Search Issues
- **Error 403**: Check API key and enable Custom Search API
- **No results**: Verify Search Engine ID is correct
- **Quota exceeded**: Check your Google Cloud billing

### ElevenLabs Issues
- **Error 401**: Check API key is correct
- **No audio**: Check Voice ID exists
- **Slow response**: Normal for high-quality synthesis

### General Issues
- **API key not found**: Ensure `config.dart` is updated
- **CORS errors**: Use Chrome browser for web testing
- **Network errors**: Check internet connection

## 💡 Advanced Configuration

### Multiple Voices
You can add more voice options:
```dart
class VoiceConfig {
  static const Map<String, String> voices = {
    'Rachel': '21m00Tcm4TlvDq8ikWAM',
    'Adam': 'pNInz6obpgDQGcFmaJgB',
    'Sam': 'AZnzlk1XvdvUeBnXmlld',
  };
}
```

### Custom Search Settings
Configure search parameters:
```dart
static const int searchResultsCount = 5;
static const String searchLanguage = 'en';
static const bool searchImages = false;
```

## 🚀 Running with New APIs

### Web (Recommended)
```bash
flutter run -d chrome
```

### Mobile/Desktop
```bash
flutter run
```

## 📊 API Usage Limits

### Google Custom Search
- **Free tier**: 100 searches/day
- **Paid**: $5 per 1000 searches

### ElevenLabs
- **Free tier**: 10,000 characters/month
- **Paid**: $22/month for 30,000 characters

## 🔒 Security Notes

- Never commit API keys to version control
- Use environment variables for production
- Monitor API usage to avoid charges
- Rotate keys regularly

## 🎉 Success Indicators

✅ **Google Search**: Real web results appear  
✅ **ElevenLabs**: High-quality voice synthesis  
✅ **No errors**: Clean console output  
✅ **Fast responses**: Quick API calls  

Your RonBot is now powered by real Google Search and ElevenLabs voice synthesis! 🚀 