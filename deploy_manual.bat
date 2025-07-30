@echo off
echo 🚀 Manual Deployment to GitHub Pages
echo.

echo 📦 Building Flutter web app...
flutter build web --release --base-href "/ronbot--AI/"

echo.
echo 📁 Creating deployment files...
if not exist "web_deploy" mkdir web_deploy
xcopy /E /I /Y "build\web\*" "web_deploy\"

echo.
echo 📝 Creating index.html for GitHub Pages...
echo ^<!DOCTYPE html^> > web_deploy\index.html
echo ^<html^> >> web_deploy\index.html
echo ^<head^> >> web_deploy\index.html
echo   ^<meta charset="UTF-8"^> >> web_deploy\index.html
echo   ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> web_deploy\index.html
echo   ^<title^>RonBot - Advanced AI Assistant^</title^> >> web_deploy\index.html
echo   ^<style^> >> web_deploy\index.html
echo     body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh; } >> web_deploy\index.html
echo     .container { max-width: 800px; margin: 0 auto; text-align: center; } >> web_deploy\index.html
echo     .logo { font-size: 4em; margin-bottom: 20px; } >> web_deploy\index.html
echo     h1 { font-size: 2.5em; margin-bottom: 20px; } >> web_deploy\index.html
echo     .subtitle { font-size: 1.3em; margin-bottom: 30px; opacity: 0.9; } >> web_deploy\index.html
echo     .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 40px 0; } >> web_deploy\index.html
echo     .feature { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.2); } >> web_deploy\index.html
echo     .feature-icon { font-size: 2em; margin-bottom: 10px; } >> web_deploy\index.html
echo     .feature-title { font-weight: bold; margin-bottom: 5px; } >> web_deploy\index.html
echo     .feature-desc { font-size: 0.9em; opacity: 0.8; } >> web_deploy\index.html
echo     .cta-button { display: inline-block; background: rgba(255,255,255,0.2); color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; margin: 20px 10px; transition: all 0.3s ease; border: 2px solid rgba(255,255,255,0.3); } >> web_deploy\index.html
echo     .cta-button:hover { background: rgba(255,255,255,0.3); transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.3); } >> web_deploy\index.html
echo   ^</style^> >> web_deploy\index.html
echo ^</head^> >> web_deploy\index.html
echo ^<body^> >> web_deploy\index.html
echo   ^<div class="container"^> >> web_deploy\index.html
echo     ^<div class="logo"^>🤖^</div^> >> web_deploy\index.html
echo     ^<h1^>RonBot^</h1^> >> web_deploy\index.html
echo     ^<p class="subtitle"^>Advanced AI Assistant with Voice Synthesis & Real-time News^</p^> >> web_deploy\index.html
echo     ^<div class="features"^> >> web_deploy\index.html
echo       ^<div class="feature"^> >> web_deploy\index.html
echo         ^<div class="feature-icon"^>💬^</div^> >> web_deploy\index.html
echo         ^<div class="feature-title"^>AI Chat^</div^> >> web_deploy\index.html
echo         ^<div class="feature-desc"^>Intelligent conversations with ChatGPT^</div^> >> web_deploy\index.html
echo       ^</div^> >> web_deploy\index.html
echo       ^<div class="feature"^> >> web_deploy\index.html
echo         ^<div class="feature-icon"^>🎨^</div^> >> web_deploy\index.html
echo         ^<div class="feature-title"^>Image Generation^</div^> >> web_deploy\index.html
echo         ^<div class="feature-desc"^>Create images with DALL-E AI^</div^> >> web_deploy\index.html
echo       ^</div^> >> web_deploy\index.html
echo       ^<div class="feature"^> >> web_deploy\index.html
echo         ^<div class="feature-icon"^>🔊^</div^> >> web_deploy\index.html
echo         ^<div class="feature-title"^>Voice Synthesis^</div^> >> web_deploy\index.html
echo         ^<div class="feature-desc"^>High-quality AI voices with ElevenLabs^</div^> >> web_deploy\index.html
echo       ^</div^> >> web_deploy\index.html
echo       ^<div class="feature"^> >> web_deploy\index.html
echo         ^<div class="feature-icon"^>📰^</div^> >> web_deploy\index.html
echo         ^<div class="feature-title"^>Real-time News^</div^> >> web_deploy\index.html
echo         ^<div class="feature-desc"^>Latest headlines and breaking news^</div^> >> web_deploy\index.html
echo       ^</div^> >> web_deploy\index.html
echo     ^</div^> >> web_deploy\index.html
echo     ^<a href="https://github.com/Ronith2906/ronbot--AI" class="cta-button"^>📁 View on GitHub^</a^> >> web_deploy\index.html
echo     ^<p style="margin-top: 30px; opacity: 0.7;"^>Built with ❤️ using Flutter & AI APIs^</p^> >> web_deploy\index.html
echo   ^</div^> >> web_deploy\index.html
echo ^</body^> >> web_deploy\index.html
echo ^</html^> >> web_deploy\index.html

echo.
echo 📤 Adding files to git...
git add web_deploy\*
git commit -m "Add manual deployment files"

echo.
echo 🚀 Pushing to GitHub...
git push origin fresh-start

echo.
echo ✅ Manual deployment complete!
echo 🌐 Your demo should be available at:
echo    https://ronith2906.github.io/ronbot--AI/
echo.
pause 