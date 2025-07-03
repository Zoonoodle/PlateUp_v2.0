# Firebase Setup Instructions for PlateUp

The iOS project needs Firebase dependencies to be added via Swift Package Manager. Follow these steps:

## Quick Setup (Recommended)

1. **Open PlateUp.xcodeproj in Xcode**

2. **Add Firebase SDK Package:**
   - In Xcode, go to File → Add Package Dependencies...
   - Enter this URL: `https://github.com/firebase/firebase-ios-sdk.git`
   - Click "Add Package"
   - Version rule: Up to Next Major Version, starting from 11.0.0
   - Click "Add Package" again

3. **Select Firebase Products:**
   When prompted, add these products to the PlateUp target:
   - ✅ FirebaseAnalytics
   - ✅ FirebaseAuth  
   - ✅ FirebaseCore
   - ✅ FirebaseFirestore
   - ✅ FirebaseFunctions
   - ✅ FirebaseStorage
   - ✅ FirebaseVertexAI
   
   Click "Add Package"

4. **Add GoogleService-Info.plist to Project:**
   - In Finder, locate: `/Users/brennenprice/Documents/PlateUp_v2/PlateUp/GoogleService-Info.plist`
   - Drag this file into Xcode's project navigator (left sidebar)
   - In the dialog:
     - ✅ Check "Copy items if needed"
     - ✅ Add to targets: PlateUp
   - Click "Finish"

5. **Clean and Build:**
   - Press Cmd+Shift+K (Clean Build Folder)
   - Press Cmd+B (Build)

## Troubleshooting

If the build still fails:

1. **Reset Package Caches:**
   - File → Packages → Reset Package Caches
   - Wait for packages to re-download

2. **Delete Derived Data:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

3. **Ensure Minimum iOS Version:**
   - Select PlateUp project in navigator
   - Select PlateUp target
   - Under "Minimum Deployments", ensure iOS 17.0 or later

4. **Check Package Resolution:**
   - File → Packages → Resolve Package Versions

## Verification

After successful setup, you should see:
- Firebase packages listed under "Package Dependencies" in the project navigator
- GoogleService-Info.plist in your project files
- Build succeeds without Firebase import errors

## Current Firebase Usage in Project

The project uses these Firebase services:
- **FirebaseCore**: App initialization
- **FirebaseAuth**: User authentication
- **FirebaseFirestore**: Database
- **FirebaseFunctions**: Cloud functions
- **FirebaseStorage**: File storage
- **FirebaseAnalytics**: Analytics
- **FirebaseVertexAI**: Gemini AI integration

## Temporary Workaround

While setting up Firebase, the project includes `FirebaseStubs.swift` which provides temporary stub implementations. This file will be automatically ignored once Firebase is properly imported.