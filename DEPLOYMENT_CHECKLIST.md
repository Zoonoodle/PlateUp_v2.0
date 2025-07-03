# ✅ PlateUp v2.0 Firebase Deployment Checklist

## Pre-Deployment Verification

### 🔍 Check These Files Exist:
- [x] `/functions/package.json` - Functions configuration
- [x] `/functions/tsconfig.json` - TypeScript configuration  
- [x] `/functions/lib/` - Compiled JavaScript files
- [x] `/firebase.json` - Firebase project configuration
- [x] `/firestore.rules` - Database security rules
- [x] `/firestore.indexes.json` - Database indexes
- [x] `/storage.rules` - Storage security rules

### 🔧 Functions Ready for Deployment:
- [x] **healthBlueprint** - Generates personalized nutrition plans
- [x] **mealAnalysis** - Analyzes meal images with AI
- [x] **coachingInsights** - Generates personalized coaching
- [x] **generateMealPlan** - Creates weekly meal plans
- [x] **generateRecipe** - AI-powered recipe generation
- [x] **analyzeMealPattern** - Pattern recognition for insights
- [x] **trackAIPerformance** - Monitors AI performance
- [x] **dailyCoachingJob** - Scheduled coaching updates
- [x] **cleanupOldOnboarding** - Automated data cleanup

---

## 🚀 Quick Deployment Commands

```bash
# 1. Navigate to functions directory
cd /Users/brennenprice/Documents/PlateUp_v2/PlateUp/functions

# 2. Run the deployment script
./deploy-functions.sh

# OR manually:
firebase deploy --only functions
```

---

## ⚡ After Deployment

### Set Gemini API Key (CRITICAL!)
```bash
firebase functions:config:set gemini.api_key="YOUR_API_KEY_HERE"
```

### Deploy Security Rules
```bash
firebase deploy --only firestore:rules,firestore:indexes,storage:rules
```

### Verify Deployment
```bash
# Check function status
firebase functions:list

# View recent logs
firebase functions:log --lines 20
```

---

## 🎯 Expected Result

After successful deployment, you should see:
```
✔  functions[healthBlueprint]: Successful create operation.
✔  functions[mealAnalysis]: Successful create operation.
✔  functions[coachingInsights]: Successful create operation.
✔  functions[generateMealPlan]: Successful create operation.
✔  functions[generateRecipe]: Successful create operation.
✔  functions[analyzeMealPattern]: Successful create operation.
✔  functions[trackAIPerformance]: Successful create operation.
✔  functions[dailyCoachingJob]: Successful create operation.
✔  functions[cleanupOldOnboarding]: Successful create operation.

✔  Deploy complete!
```

---

## 🔗 Firebase Console Links

After deployment, view your functions at:
- **Functions**: https://console.firebase.google.com/project/plateup-nutrition-app/functions
- **Firestore**: https://console.firebase.google.com/project/plateup-nutrition-app/firestore
- **Storage**: https://console.firebase.google.com/project/plateup-nutrition-app/storage

---

## ⏱️ Estimated Deployment Time: 3-5 minutes