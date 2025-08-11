// Utility functions for API calls with retry logic

const axios = require('axios');

// Retry configuration
const DEFAULT_RETRY_OPTIONS = {
  maxRetries: 3,
  initialDelay: 1000, // 1 second
  maxDelay: 10000, // 10 seconds
  backoffFactor: 2,
  retryableStatuses: [429, 500, 502, 503, 504] // Rate limit and server errors
};

// Sleep utility
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Calculate exponential backoff delay
const calculateDelay = (attempt, initialDelay, maxDelay, backoffFactor) => {
  const delay = initialDelay * Math.pow(backoffFactor, attempt - 1);
  return Math.min(delay, maxDelay);
};

// Retry wrapper for axios requests
async function retryRequest(requestFn, options = {}) {
  const config = { ...DEFAULT_RETRY_OPTIONS, ...options };
  let lastError;

  for (let attempt = 1; attempt <= config.maxRetries; attempt++) {
    try {
      console.log(`Attempt ${attempt}/${config.maxRetries}...`);
      const response = await requestFn();
      return response;
    } catch (error) {
      lastError = error;
      
      // Check if error is retryable
      const status = error.response?.status;
      const isRetryable = config.retryableStatuses.includes(status) || 
                         error.code === 'ECONNRESET' || 
                         error.code === 'ETIMEDOUT';
      
      if (!isRetryable || attempt === config.maxRetries) {
        throw error;
      }

      // Calculate delay for next attempt
      const delay = calculateDelay(attempt, config.initialDelay, config.maxDelay, config.backoffFactor);
      console.log(`Request failed with ${status || error.code}. Retrying in ${delay}ms...`);
      
      await sleep(delay);
    }
  }

  throw lastError;
}

// Enhanced error response builder
function buildErrorResponse(error, apiName) {
  console.error(`${apiName} Error:`, error.response?.data || error.message);
  
  // Extract meaningful error information
  let errorMessage = 'An unexpected error occurred';
  let errorType = 'unknown_error';
  let statusCode = 500;

  if (error.response) {
    // API responded with error
    statusCode = error.response.status;
    errorMessage = error.response.data?.error?.message || 
                  error.response.data?.message || 
                  error.response.statusText ||
                  `API returned status ${statusCode}`;
    errorType = error.response.data?.error?.type || 'api_error';
    
    // Special handling for common errors
    if (statusCode === 429) {
      errorMessage = 'Rate limit exceeded. Please try again later.';
      errorType = 'rate_limit_error';
    } else if (statusCode === 401) {
      errorMessage = `${apiName} API key is invalid or not configured properly.`;
      errorType = 'authentication_error';
    } else if (statusCode === 402) {
      errorMessage = 'API quota exceeded or payment required.';
      errorType = 'quota_error';
    }
  } else if (error.code === 'ECONNRESET' || error.code === 'ETIMEDOUT') {
    errorMessage = 'Connection timeout. Please try again.';
    errorType = 'timeout_error';
    statusCode = 504;
  } else if (error.code === 'ENOTFOUND') {
    errorMessage = 'Unable to reach API server. Check your internet connection.';
    errorType = 'network_error';
    statusCode = 503;
  }

  return {
    error: errorMessage,
    message: errorMessage,
    type: errorType,
    statusCode,
    timestamp: new Date().toISOString()
  };
}

// Request timeout wrapper
function withTimeout(promise, timeoutMs = 30000) {
  return Promise.race([
    promise,
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Request timeout')), timeoutMs)
    )
  ]);
}

module.exports = {
  retryRequest,
  buildErrorResponse,
  withTimeout,
  sleep
};