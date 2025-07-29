@echo off
echo 🚀 Deploying RonBot to GitHub Pages...
echo.

echo 📦 Building Flutter web app...
flutter build web --release --base-href "/ronbot--AI/"

echo.
echo 📁 Copying build files...
xcopy /E /I /Y "build\web\*" "web\"

echo.
echo 🔄 Committing and pushing changes...
git add .
git commit -m "Deploy Flutter app to GitHub Pages"
git push origin fresh-start

echo.
echo ✅ Deployment complete!
echo 🌐 Your demo should be available at:
echo    https://ronith2906.github.io/ronbot--AI/
echo.
pause 