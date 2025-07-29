@echo off
echo 🌐 Starting RonBot Website Server...
echo.
echo 📱 Your website will be available at:
echo    http://localhost:8000
echo.
echo 🚀 Features Available:
echo    • 🤖 AI Chat with ChatGPT
echo    • 🎨 Image Generation with DALL-E
echo    • 🔊 Voice Synthesis with ElevenLabs
echo    • 📰 Real-time News
echo    • 🌐 Web Search
echo    • 📊 Analytics Dashboard
echo.
echo Press Ctrl+C to stop the server
echo.
cd build/web
python -m http.server 8000
pause 