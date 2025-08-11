# 🚀 Heroku Deployment Guide for AI Career Coach

## Prerequisites
- Heroku CLI installed
- Git repository set up
- Heroku account created

## Step 1: Prepare Your Application

1. Ensure all required files are in place:
   - `package.json` - Node.js dependencies
   - `server.js` - Express backend server
   - `Procfile` - Heroku process configuration
   - `.env.example` - Environment variables template

## Step 2: Create Heroku App

```bash
# Login to Heroku
heroku login

# Create a new Heroku app
heroku create your-ai-career-coach-app

# Or link to existing app
heroku git:remote -a your-ai-career-coach-app
```

## Step 3: Set Environment Variables

Set all required API keys in Heroku:

```bash
# OpenAI API Key (REQUIRED)
heroku config:set OPENAI_API_KEY=sk-your-openai-api-key-here

# Optional: Other API Keys
heroku config:set ELEVENLABS_API_KEY=your-elevenlabs-key
heroku config:set NEWS_API_KEY=your-news-api-key
heroku config:set GOOGLE_SEARCH_API_KEY=your-google-api-key
heroku config:set GOOGLE_SEARCH_ENGINE_ID=your-search-engine-id

# Verify configuration
heroku config
```

## Step 4: Deploy to Heroku

```bash
# Add all files
git add .

# Commit changes
git commit -m "Add backend server for OpenAI API"

# Push to Heroku
git push heroku main

# Or if you're on a different branch
git push heroku your-branch:main
```

## Step 5: Verify Deployment

```bash
# Open your app
heroku open

# Check logs if there are issues
heroku logs --tail

# Check app status
heroku ps
```

## Step 6: Test the Application

1. Visit your app URL: `https://your-ai-career-coach-app.herokuapp.com`
2. Check the API health endpoint: `https://your-ai-career-coach-app.herokuapp.com/api/health`
3. Open the AI Career Coach interface: `https://your-ai-career-coach-app.herokuapp.com/ai_career_coach.html`

## Troubleshooting

### Common Issues and Solutions

1. **503 Service Unavailable**
   - Check logs: `heroku logs --tail`
   - Ensure Procfile is correct
   - Verify package.json has all dependencies

2. **OpenAI API Errors**
   - Verify API key is set: `heroku config:get OPENAI_API_KEY`
   - Check API key validity
   - Ensure you have API credits

3. **Application Error**
   - Check for missing dependencies
   - Verify Node.js version in package.json
   - Look for syntax errors in server.js

### Debug Commands

```bash
# View real-time logs
heroku logs --tail

# Restart the app
heroku restart

# Check dyno status
heroku ps

# Run a one-off command
heroku run node --version
heroku run npm list

# Access bash shell
heroku run bash
```

## Security Best Practices

1. **Never commit API keys to Git**
   - Use environment variables
   - Add `.env` to `.gitignore`

2. **Use HTTPS only**
   - Heroku provides SSL by default
   - Redirect HTTP to HTTPS if needed

3. **Monitor API usage**
   - Set up alerts for OpenAI usage
   - Implement rate limiting if needed

## Scaling Your App

```bash
# Check current dyno status
heroku ps

# Scale to multiple dynos (paid feature)
heroku ps:scale web=2

# Enable auto-scaling (if available)
heroku autoscale:enable
```

## Monitoring

```bash
# View metrics
heroku metrics

# Set up alerts
heroku alerts:add

# Use Heroku dashboard for detailed monitoring
```

## Updating Your App

```bash
# Make changes locally
# Test thoroughly

# Commit and push
git add .
git commit -m "Update description"
git push heroku main

# Monitor deployment
heroku logs --tail
```

## Free Tier Limitations

- Apps sleep after 30 minutes of inactivity
- Limited to 550-1000 dyno hours per month
- Cold starts may be slow

## Useful Heroku Addons

```bash
# Add logging service
heroku addons:create papertrail

# Add monitoring
heroku addons:create newrelic

# Add error tracking
heroku addons:create rollbar
```

## Support

If you encounter issues:
1. Check Heroku status: https://status.heroku.com/
2. Review logs carefully
3. Ensure all environment variables are set
4. Verify API keys are valid and have credits

Your AI Career Coach should now be live on Heroku! 🎉