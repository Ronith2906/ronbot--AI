#!/bin/bash

echo "🚀 Setting up RonBot Web Application..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "Download from: https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Node.js version 16 or higher is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully!"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
# RonBot Web Application Environment Variables
VITE_APP_NAME=RonBot
VITE_APP_VERSION=1.0.0
VITE_API_URL=http://localhost:3000
EOF
    echo "✅ .env file created"
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "To start the development server, run:"
echo "  npm run dev"
echo ""
echo "To build for production, run:"
echo "  npm run build"
echo ""
echo "Happy coding! 🤖" 