# 🚀 Firebase Deployment Guide for PlateUp v2.0

## Overview
This guide will walk you through deploying all Firebase services for PlateUp v2.0.

## Prerequisites
- Firebase CLI installed (`npm install -g firebase-tools`)
- Access to the Firebase project (plateup-nutrition-app)
- Gemini API key from Google AI Studio

---

## 📋 Step 1: Install Firebase CLI
```bash
# If not already installed
npm install -g firebase-tools

# Verify installation
firebase --version
```

---

## 🔐 Step 2: Firebase Authentication
```bash
# Login to Firebase
firebase login

# Verify you're logged in
firebase projects:list
```

---

## 🚀 Step 3: Deploy Cloud Functions

### Option A: Use the Deployment Script (Recommended)
```bash
cd /Users/brennenprice/Documents/PlateUp_v2/PlateUp/functions
./deploy-functions.sh
```

### Option B: Manual Deployment
```bash
# Navigate to functions directory
cd /Users/brennenprice/Documents/PlateUp_v2/PlateUp/functions

# Set project
firebase use plateup-nutrition-app

# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy functions
firebase deploy --only functions
```

---

## 🔑 Step 4: Configure Environment Variables

### Set Gemini API Key (REQUIRED)
```bash
# Get your API key from: https://aistudio.google.com/app/apikey
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"
```

### Optional: Set other environment variables
```bash
# Set environment (optional)
firebase functions:config:set app.environment="production"

# View all config
firebase functions:config:get
```

---

## 📝 Step 5: Deploy Firestore Rules & Indexes
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

---

## 📦 Step 6: Deploy Storage Rules
```bash
# Deploy storage rules
firebase deploy --only storage:rules
```

---

## 🧪 Step 7: Test Your Deployment

### Test Cloud Functions
```bash
# List deployed functions
firebase functions:list

# View function logs
firebase functions:log

# Test a specific function (example)
curl https://us-central1-plateup-nutrition-app.cloudfunctions.net/healthBlueprint
```

### View in Firebase Console
1. Go to: https://console.firebase.google.com/project/plateup-nutrition-app/functions
2. Check that all functions are deployed:
   - `healthBlueprint`
   - `mealAnalysis`
   - `coachingInsights`
   - `generateMealPlan`
   - `generateRecipe`
   - `analyzeMealPattern`
   - `trackAIPerformance`
   - `dailyCoachingJob`
   - `cleanupOldOnboarding`

---

## ⚠️ Important Security Notes

1. **API Keys**: Never commit API keys to version control
2. **CORS**: The functions are configured to accept requests from your app
3. **Authentication**: Functions check for authenticated users
4. **Rate Limiting**: Functions have built-in rate limiting

---

## 🐛 Troubleshooting

### Common Issues:

1. **"Permission denied" error**
   ```bash
   # Make sure you're an owner/editor on the Firebase project
   firebase projects:add-alias
   ```

2. **"Functions not deploying"**
   ```bash
   # Check for TypeScript errors
   cd functions
   npm run build
   ```

3. **"API key not working"**
   ```bash
   # Redeploy after setting config
   firebase deploy --only functions
   ```

4. **"CORS errors in app"**
   - Check that your app's bundle ID matches Firebase config
   - Verify CORS settings in cors.ts

---

## 📊 Monitoring Your Functions

### View Logs
```bash
# All functions
firebase functions:log

# Specific function
firebase functions:log --only healthBlueprint

# Last 50 entries
firebase functions:log --lines 50
```

### Performance Monitoring
1. Go to Firebase Console > Functions
2. Click on any function to see:
   - Execution count
   - Median execution time
   - Error rate
   - Memory usage

---

## 🎯 Next Steps After Deployment

1. **Test the onboarding flow** in your iOS app
2. **Monitor function performance** in Firebase Console
3. **Set up alerts** for function errors
4. **Configure budget alerts** to monitor costs

---

## 💰 Cost Optimization Tips

1. **Function Memory**: Our functions use 512MB (optimal for our use case)
2. **Cold Starts**: Functions are configured to minimize cold starts
3. **Caching**: AI responses are cached where appropriate
4. **Cleanup Jobs**: Automated cleanup prevents data bloat

---

## 📞 Support

If you encounter issues:
1. Check Firebase Status: https://status.firebase.google.com/
2. View function logs for detailed errors
3. Ensure all environment variables are set correctly
4. Verify your Gemini API key has sufficient quota