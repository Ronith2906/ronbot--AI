# RonBot Web Application

A modern, responsive web-based AI chatbot built with React, TypeScript, and Tailwind CSS. This is the web version of your Flutter RonBot application with enhanced features and a beautiful UI.

## Features

- 🤖 **Intelligent Chat Interface** - Modern chat UI with smooth animations
- 🎤 **Voice Input** - Speech-to-text functionality using Web Speech API
- 🎨 **Dark/Light Mode** - Toggle between themes with smooth transitions
- ⚙️ **Settings Panel** - Customize voice, theme, and language preferences
- 📱 **Responsive Design** - Works perfectly on desktop, tablet, and mobile
- 🎭 **Smooth Animations** - Powered by Framer Motion for delightful interactions
- 🔧 **TypeScript** - Full type safety and better development experience

## Quick Start

### Prerequisites

- Node.js (version 16 or higher)
- npm or yarn package manager

### Installation

1. Navigate to the web directory:
```bash
cd web
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and visit `http://localhost:3000`

### Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Project Structure

```
web/
├── src/
│   ├── components/
│   │   ├── ChatMessage.tsx      # Individual chat message component
│   │   ├── VoiceRecorder.tsx    # Voice input functionality
│   │   └── SettingsPanel.tsx    # Settings configuration panel
│   ├── App.tsx                  # Main application component
│   ├── main.tsx                 # React entry point
│   ├── index.css                # Global styles and Tailwind imports
│   └── types.ts                 # TypeScript type definitions
├── public/                      # Static assets
├── package.json                 # Dependencies and scripts
├── vite.config.ts              # Vite configuration
├── tailwind.config.js          # Tailwind CSS configuration
└── postcss.config.js           # PostCSS configuration
```

## Key Features Explained

### Voice Recognition
- Uses the Web Speech API for real-time speech-to-text
- Supports multiple languages
- Visual feedback during recording
- Automatic transcript display

### Responsive Design
- Mobile-first approach
- Adaptive chat bubbles
- Touch-friendly interface
- Optimized for all screen sizes

### Dark Mode
- System preference detection
- Manual toggle option
- Smooth theme transitions
- Persistent settings

### Settings Panel
- Voice input configuration
- Theme selection
- Language preferences
- About information

## Customization

### Adding New Responses
Edit the `generateRonResponse` function in `App.tsx` to add new conversation patterns:

```typescript
const generateRonResponse = (input: string): string => {
  const lowerInput = input.toLowerCase()
  
  if (lowerInput.includes('your custom pattern')) {
    return "Your custom response"
  }
  
  return "Default response"
}
```

### Styling
- Modify `tailwind.config.js` for theme customization
- Edit `src/index.css` for component-specific styles
- Use Tailwind utility classes for rapid styling

### Adding New Features
1. Create new components in `src/components/`
2. Add types to `src/types.ts`
3. Import and use in `App.tsx`

## Browser Compatibility

- Chrome/Edge (recommended for voice features)
- Firefox
- Safari
- Mobile browsers

**Note:** Voice recognition works best in Chrome and Edge browsers.

## Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

### Code Style

The project uses:
- TypeScript for type safety
- ESLint for code linting
- Prettier for code formatting
- Tailwind CSS for styling

## Deployment

### Vercel (Recommended)
1. Push your code to GitHub
2. Connect your repository to Vercel
3. Deploy automatically

### Netlify
1. Build the project: `npm run build`
2. Upload the `dist` folder to Netlify

### Static Hosting
1. Run `npm run build`
2. Upload the contents of `dist` to your web server

## Future Enhancements

- [ ] OpenAI API integration
- [ ] Message history persistence
- [ ] File upload support
- [ ] Multi-language support
- [ ] Advanced voice synthesis
- [ ] Chat export functionality
- [ ] User authentication
- [ ] Real-time collaboration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is part of the RonBot application suite.

---

**Built with ❤️ using React, TypeScript, and Tailwind CSS** 