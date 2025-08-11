const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');
require('dotenv').config();

// Import utility functions
const { retryRequest, buildErrorResponse, withTimeout } = require('./server_utils');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files from the current directory
app.use(express.static('.'));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'AI Career Coach API is running',
    timestamp: new Date().toISOString()
  });
});

// OpenAI Chat endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const { messages, model = 'gpt-3.5-turbo', max_tokens = 1000 } = req.body;

    if (!process.env.OPENAI_API_KEY) {
      return res.status(500).json({
        error: 'OpenAI API key not configured',
        message: 'Please set OPENAI_API_KEY environment variable',
        type: 'configuration_error'
      });
    }

    // Validate request
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Messages array is required',
        type: 'validation_error'
      });
    }

    // Make API call with retry logic
    const response = await retryRequest(async () => {
      return await withTimeout(
        axios.post('https://api.openai.com/v1/chat/completions', {
          model,
          messages,
          max_tokens,
          temperature: 0.7
        }, {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
          },
          timeout: 25000 // 25 second timeout
        }),
        30000 // 30 second overall timeout
      );
    });

    res.json(response.data);
  } catch (error) {
    const errorResponse = buildErrorResponse(error, 'OpenAI');
    res.status(errorResponse.statusCode).json(errorResponse);
  }
});

// OpenAI Image Generation endpoint
app.post('/api/generate-image', async (req, res) => {
  try {
    const { prompt, size = '1024x1024', n = 1 } = req.body;

    if (!process.env.OPENAI_API_KEY) {
      return res.status(500).json({
        error: 'OpenAI API key not configured',
        message: 'Please set OPENAI_API_KEY environment variable'
      });
    }

    const response = await axios.post('https://api.openai.com/v1/images/generations', {
      prompt,
      size,
      n
    }, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('DALL-E API Error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'DALL-E API request failed',
      message: error.response?.data?.error?.message || error.message
    });
  }
});

// ElevenLabs Voice endpoint
app.post('/api/voice', async (req, res) => {
  try {
    const { text, voice_id = '21m00Tcm4TlvDq8ikWAM' } = req.body;

    if (!process.env.ELEVENLABS_API_KEY) {
      return res.status(500).json({
        error: 'ElevenLabs API key not configured',
        message: 'Please set ELEVENLABS_API_KEY environment variable'
      });
    }

    const response = await axios.post(
      `https://api.elevenlabs.io/v1/text-to-speech/${voice_id}`,
      { text },
      {
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': process.env.ELEVENLABS_API_KEY
        },
        responseType: 'arraybuffer'
      }
    );

    res.set('Content-Type', 'audio/mpeg');
    res.send(response.data);
  } catch (error) {
    console.error('ElevenLabs API Error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'ElevenLabs API request failed',
      message: error.message
    });
  }
});

// News API endpoint
app.get('/api/news', async (req, res) => {
  try {
    const { q, country = 'us', category = 'general' } = req.query;

    if (!process.env.NEWS_API_KEY) {
      return res.status(500).json({
        error: 'News API key not configured',
        message: 'Please set NEWS_API_KEY environment variable'
      });
    }

    const url = q 
      ? `https://newsapi.org/v2/everything?q=${encodeURIComponent(q)}&apiKey=${process.env.NEWS_API_KEY}`
      : `https://newsapi.org/v2/top-headlines?country=${country}&category=${category}&apiKey=${process.env.NEWS_API_KEY}`;

    const response = await axios.get(url);
    res.json(response.data);
  } catch (error) {
    console.error('News API Error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'News API request failed',
      message: error.response?.data?.message || error.message
    });
  }
});

// Google Search endpoint
app.get('/api/search', async (req, res) => {
  try {
    const { q } = req.query;

    if (!process.env.GOOGLE_SEARCH_API_KEY || !process.env.GOOGLE_SEARCH_ENGINE_ID) {
      return res.status(500).json({
        error: 'Google Search API not configured',
        message: 'Please set GOOGLE_SEARCH_API_KEY and GOOGLE_SEARCH_ENGINE_ID environment variables'
      });
    }

    const response = await axios.get('https://www.googleapis.com/customsearch/v1', {
      params: {
        key: process.env.GOOGLE_SEARCH_API_KEY,
        cx: process.env.GOOGLE_SEARCH_ENGINE_ID,
        q
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('Google Search API Error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'Google Search API request failed',
      message: error.response?.data?.error?.message || error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server Error:', err.stack);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`AI Career Coach Backend running on port ${PORT}`);
  console.log('Environment variables status:');
  console.log('- OPENAI_API_KEY:', process.env.OPENAI_API_KEY ? 'Set ✓' : 'Not set ✗');
  console.log('- ELEVENLABS_API_KEY:', process.env.ELEVENLABS_API_KEY ? 'Set ✓' : 'Not set ✗');
  console.log('- NEWS_API_KEY:', process.env.NEWS_API_KEY ? 'Set ✓' : 'Not set ✗');
  console.log('- GOOGLE_SEARCH_API_KEY:', process.env.GOOGLE_SEARCH_API_KEY ? 'Set ✓' : 'Not set ✗');
  console.log('- GOOGLE_SEARCH_ENGINE_ID:', process.env.GOOGLE_SEARCH_ENGINE_ID ? 'Set ✓' : 'Not set ✗');
});