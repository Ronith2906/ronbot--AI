# RonBot Web Application - Deployment Guide

This guide will help you deploy your RonBot web application to various platforms.

## Prerequisites

- Node.js 16+ installed
- Git repository set up
- All dependencies installed (`npm install`)

## Build the Application

First, build the application for production:

```bash
npm run build
```

This creates a `dist` folder with optimized files ready for deployment.

## Deployment Options

### 1. Vercel (Recommended)

Vercel is the easiest way to deploy React applications.

#### Steps:
1. **Install Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Deploy:**
   ```bash
   vercel
   ```

3. **Follow the prompts:**
   - Link to existing project or create new
   - Set build command: `npm run build`
   - Set output directory: `dist`
   - Set install command: `npm install`

4. **Your app will be live at:** `https://your-project.vercel.app`

#### Automatic Deployments:
- Connect your GitHub repository to Vercel
- Every push to main branch will auto-deploy
- Preview deployments for pull requests

### 2. Netlify

#### Steps:
1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Deploy:**
   ```bash
   netlify deploy --prod --dir=dist
   ```

3. **Or drag and drop:**
   - Go to [netlify.com](https://netlify.com)
   - Drag the `dist` folder to deploy

### 3. GitHub Pages

#### Steps:
1. **Add homepage to package.json:**
   ```json
   {
     "homepage": "https://yourusername.github.io/your-repo-name"
   }
   ```

2. **Install gh-pages:**
   ```bash
   npm install --save-dev gh-pages
   ```

3. **Add scripts to package.json:**
   ```json
   {
     "scripts": {
       "predeploy": "npm run build",
       "deploy": "gh-pages -d dist"
     }
   }
   ```

4. **Deploy:**
   ```bash
   npm run deploy
   ```

### 4. Firebase Hosting

#### Steps:
1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login:**
   ```bash
   firebase login
   ```

3. **Initialize:**
   ```bash
   firebase init hosting
   ```

4. **Configure:**
   - Public directory: `dist`
   - Single-page app: `Yes`
   - GitHub actions: `No`

5. **Deploy:**
   ```bash
   firebase deploy
   ```

### 5. AWS S3 + CloudFront

#### Steps:
1. **Create S3 bucket**
2. **Upload dist folder contents**
3. **Configure static website hosting**
4. **Set up CloudFront distribution**
5. **Configure custom domain (optional)**

### 6. Traditional Web Server

#### Steps:
1. **Upload files:**
   - Upload contents of `dist` folder to your web server
   - Ensure `index.html` is in the root directory

2. **Configure server:**
   - Set up proper MIME types
   - Enable gzip compression
   - Configure caching headers

## Environment Variables

Create a `.env.production` file for production environment variables:

```env
VITE_APP_NAME=RonBot
VITE_APP_VERSION=1.0.0
VITE_API_URL=https://your-api-domain.com
```

## Performance Optimization

### 1. Enable Compression
- Gzip compression for text files
- Brotli compression for modern browsers

### 2. Caching Headers
```nginx
# Nginx configuration
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. CDN Configuration
- Use a CDN for static assets
- Configure proper cache headers
- Enable HTTP/2

## Security Considerations

### 1. HTTPS
- Always use HTTPS in production
- Redirect HTTP to HTTPS
- Use HSTS headers

### 2. Content Security Policy
Add CSP headers to prevent XSS attacks:

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com;">
```

### 3. Security Headers
```nginx
# Nginx security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

## Monitoring and Analytics

### 1. Google Analytics
Add to `index.html`:
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### 2. Error Tracking
Consider adding Sentry or similar error tracking service.

## Troubleshooting

### Common Issues:

1. **404 errors on refresh:**
   - Configure server to serve `index.html` for all routes
   - Use HashRouter instead of BrowserRouter

2. **Build errors:**
   - Check Node.js version
   - Clear node_modules and reinstall
   - Check for TypeScript errors

3. **Performance issues:**
   - Enable code splitting
   - Optimize images
   - Use lazy loading

## Support

For deployment issues:
1. Check the platform's documentation
2. Review build logs
3. Test locally first
4. Check browser console for errors

---

**Happy Deploying! 🚀** 