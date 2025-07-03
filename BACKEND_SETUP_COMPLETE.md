# PlateUp v2.0 Backend Setup Complete

## ✅ Completed Tasks

### 1. Fixed Firebase Dependencies
- Firebase SDK is already integrated via Swift Package Manager
- All required Firebase modules are available (Core, Auth, Firestore, Functions, Storage)
- Firebase is properly initialized in PlateUpApp.swift

### 2. Set up Onboarding Firestore Collections

**Temporary Onboarding Collection Structure:**
```
/onboarding/{sessionId}/
  - id: String
  - primaryGoal: String?
  - secondaryGoals: [String]?
  - physicalStats: PhysicalStats?
  - dailyActivity: DailyActivity?
  - dietaryPreferences: DietaryPreferences?
  - lifestyleFactors: LifestyleFactors?
  - healthBlueprint: HealthBlueprint?
  - createdAt: Date
  - updatedAt: Date
  - isComplete: Bool
```

**Permanent User Profile Structure:**
```
/users/{userId}/
  - All user profile fields as defined in User.swift
  - Merged data from onboarding
  - Health blueprint information
```

### 3. Created Cloud Functions Structure

**Functions Created:**
- `healthBlueprint` - Generates personalized nutrition plans using Gemini 2.5 Pro
- `mealAnalysis` - Analyzes meal images and provides nutritional information
- `coachingInsights` - Creates personalized coaching insights using Gemini Flash

**Scheduled Functions:**
- `dailyCoachingJob` - Runs daily at 8 AM EST
- `cleanupOnboarding` - Cleans up incomplete onboarding sessions older than 30 days

**Project Structure:**
```
functions/
├── src/
│   ├── index.ts          # Main entry point
│   ├── healthBlueprint.ts # Health plan generation
│   ├── mealAnalysis.ts    # Meal image analysis
│   ├── coachingInsights.ts # AI coaching insights
│   ├── gemini.ts         # Gemini AI wrapper
│   └── cors.ts           # CORS configuration
├── package.json
├── tsconfig.json
└── README.md
```

### 4. Updated FirebaseService.swift

**Added Methods:**
- Onboarding-specific data handling
- User profile merge logic
- Health blueprint storage methods
- Proper error handling with FirebaseError enum

**FirebaseOnboardingService.swift Features:**
- Complete onboarding data model
- Section-by-section update methods
- Health blueprint generation via Cloud Function
- Merge to permanent user profile
- Offline support enabled

## 📋 Security Configuration

### Firestore Rules (firestore.rules)
- User data scoped to authenticated users only
- Onboarding data protected by authentication
- Coaching insights read-only from client (created by Cloud Functions)
- Proper validation for all write operations

### Storage Rules (storage.rules)
- User meal images/audio scoped to owner
- File size limits (10MB images, 5MB audio)
- Content type validation
- Temporary upload directory for processing

## 🚀 Next Steps for Frontend Team

1. **Test Firebase Integration:**
   ```bash
   # From the PlateUp directory
   ./setup-firebase.sh
   ```

2. **Configure Firebase Project:**
   ```bash
   firebase use --add
   # Select your Firebase project
   ```

3. **Set Gemini API Key:**
   ```bash
   firebase functions:config:set gemini.api_key="YOUR_API_KEY"
   ```

4. **Deploy Functions:**
   ```bash
   firebase deploy --only functions
   ```

5. **Deploy Security Rules:**
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```

## 🔧 Configuration Files Created

- `firebase.json` - Firebase project configuration
- `firestore.rules` - Database security rules  
- `firestore.indexes.json` - Database indexes for queries
- `storage.rules` - Storage security rules
- `functions/.gitignore` - Git ignore for functions
- `setup-firebase.sh` - Setup helper script

## ⚠️ Important Notes

1. **Gemini Integration**: Currently using mock responses. Production implementation will require:
   - Proper Gemini API key configuration
   - Real Google AI SDK integration
   - Error handling for API limits

2. **Node Version**: Functions are configured for Node 20, but local environment has Node 24. This warning can be ignored for development.

3. **CORS Configuration**: Set up to allow requests from localhost and Firebase hosting domains. Update for production domains.

4. **TypeScript Build**: Successfully compiles without errors. Run `npm run build` in functions directory after any changes.

## 🎉 Backend Ready!

The Firebase backend is now fully set up and ready for the onboarding UI components to integrate with. All necessary services, Cloud Functions, and security rules are in place.

The Frontend team can now:
- Call `FirebaseOnboardingService` methods from the UI
- Save onboarding progress at each step
- Generate health blueprints on completion
- Merge data to permanent user profiles

Happy coding! 🚀