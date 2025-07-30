@echo off
echo 🚀 Setting up RonBot Web Application...

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js version: 
node --version

REM Install dependencies
echo 📦 Installing dependencies...
npm install

if %errorlevel% equ 0 (
    echo ✅ Dependencies installed successfully!
) else (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist .env (
    echo 📝 Creating .env file...
    (
        echo # RonBot Web Application Environment Variables
        echo VITE_APP_NAME=RonBot
        echo VITE_APP_VERSION=1.0.0
        echo VITE_API_URL=http://localhost:3000
    ) > .env
    echo ✅ .env file created
)

echo.
echo 🎉 Setup completed successfully!
echo.
echo To start the development server, run:
echo   npm run dev
echo.
echo To build for production, run:
echo   npm run build
echo.
echo Happy coding! 🤖
pause 