# 🚀 Deployment Guide - RonBot MVP

## 📋 Prerequisites

- Flutter SDK 3.0+
- Firebase CLI (for Firebase hosting)
- GitHub account
- API keys configured

## 🎯 Deployment Options

### Option 1: Firebase Hosting (Recommended)

#### Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
```

#### Step 2: Login to Firebase
```bash
firebase login
```

#### Step 3: Initialize Firebase
```bash
firebase init hosting
```

**Configuration:**
- Public directory: `build/web`
- Single-page app: `Yes`
- GitHub actions: `No`

#### Step 4: Build the App
```bash
flutter build web --release
```

#### Step 5: Deploy
```bash
firebase deploy
```

### Option 2: GitHub Pages

#### Step 1: Build for Web
```bash
flutter build web --release
```

#### Step 2: Configure GitHub Pages
1. Go to your repository settings
2. Navigate to "Pages"
3. Set source to "GitHub Actions"

#### Step 3: Create GitHub Action
Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - run: flutter pub get
      - run: flutter build web --release
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### Option 3: Netlify

#### Step 1: Build the App
```bash
flutter build web --release
```

#### Step 2: Deploy to Netlify
1. Drag and drop the `build/web` folder to Netlify
2. Or connect your GitHub repository

## 🔧 Environment Configuration

### For Production Deployment

1. **Create a production config file:**
```dart
// lib/config_prod.dart
class ApiConfig {
  static const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String elevenLabsApiKey = String.fromEnvironment('ELEVENLABS_API_KEY');
  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');
}
```

2. **Set environment variables:**
```bash
# Firebase
firebase functions:config:set openai.key="your-key"
firebase functions:config:set elevenlabs.key="your-key"
firebase functions:config:set news.key="your-key"

# Or use build arguments
flutter build web --dart-define=OPENAI_API_KEY=your-key
```

## 📱 Custom Domain Setup

### Firebase Hosting
1. Add custom domain in Firebase Console
2. Update DNS records
3. Wait for SSL certificate

### GitHub Pages
1. Add custom domain in repository settings
2. Create CNAME file in `build/web/`
3. Update DNS records

## 🔒 Security Considerations

### API Key Protection
- Never commit API keys to version control
- Use environment variables for production
- Consider using Firebase Functions as a backend proxy

### CORS Configuration
```javascript
// firebase.json
{
  "hosting": {
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Access-Control-Allow-Origin",
            "value": "*"
          }
        ]
      }
    ]
  }
}
```

## 📊 Performance Optimization

### Build Optimization
```bash
flutter build web --release --web-renderer html
```

### Asset Optimization
- Compress images
- Minify CSS/JS
- Enable gzip compression

## 🎯 SEO Setup

### Meta Tags
Update `web/index.html`:
```html
<meta name="description" content="RonBot - Advanced AI Assistant with voice synthesis and real-time news">
<meta name="keywords" content="AI, chatbot, Flutter, voice synthesis, news">
<meta property="og:title" content="RonBot AI Assistant">
<meta property="og:description" content="Advanced AI chatbot with voice features">
```

### Sitemap
Create `build/web/sitemap.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://yourdomain.com/</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

## 🚀 Post-Deployment Checklist

- [ ] Test all features work in production
- [ ] Verify API keys are secure
- [ ] Check mobile responsiveness
- [ ] Test voice features
- [ ] Verify news API works
- [ ] Update README with live demo link
- [ ] Share on LinkedIn and GitHub

## 📞 Support

For deployment issues:
1. Check Firebase/Netlify logs
2. Verify API key configuration
3. Test locally with production build
4. Check browser console for errors

---

**Your RonBot MVP is now ready for the world! 🌍** 