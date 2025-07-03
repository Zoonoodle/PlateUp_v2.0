#!/bin/bash

# Fix Firebase GoogleService-Info.plist integration

echo "🔧 Fixing Firebase GoogleService-Info.plist integration..."

PROJECT_DIR="/Users/brennenprice/Documents/PlateUp_v2/PlateUp"
PLIST_FILE="$PROJECT_DIR/GoogleService-Info.plist"

# Check if plist file exists
if [ ! -f "$PLIST_FILE" ]; then
    echo "❌ GoogleService-Info.plist not found at $PLIST_FILE"
    echo "📥 Please download it from Firebase Console: https://console.firebase.google.com/"
    exit 1
fi

echo "✅ Found GoogleService-Info.plist"

# Instructions for manual fix
echo ""
echo "🛠️  MANUAL FIX REQUIRED:"
echo "1. Open PlateUp.xcodeproj in Xcode"
echo "2. Right-click on 'PlateUp' folder in Project Navigator"
echo "3. Select 'Add Files to PlateUp'"
echo "4. Navigate to and select: $PLIST_FILE"
echo "5. Make sure these are checked:"
echo "   ✅ Add to target: PlateUp"
echo "   ✅ Copy items if needed"
echo "6. Click 'Add'"
echo ""
echo "🔍 VERIFY:"
echo "1. Select PlateUp target → Build Phases"
echo "2. Expand 'Copy Bundle Resources'"
echo "3. Confirm GoogleService-Info.plist is listed"
echo ""
echo "🧹 THEN:"
echo "1. Product → Clean Build Folder"
echo "2. Rebuild and test on device"

# Check if we can validate the plist content
if command -v plutil >/dev/null 2>&1; then
    echo ""
    echo "🔍 Validating plist content..."
    if plutil -lint "$PLIST_FILE" >/dev/null 2>&1; then
        echo "✅ GoogleService-Info.plist is valid"
        
        # Extract key info
        BUNDLE_ID=$(plutil -extract BUNDLE_ID raw "$PLIST_FILE" 2>/dev/null || echo "Not found")
        PROJECT_ID=$(plutil -extract PROJECT_ID raw "$PLIST_FILE" 2>/dev/null || echo "Not found")
        
        echo "📋 Bundle ID: $BUNDLE_ID"
        echo "📋 Project ID: $PROJECT_ID"
        
        # Check if bundle ID matches
        if [ "$BUNDLE_ID" != "BiteAI.PlateUp" ]; then
            echo "⚠️  WARNING: Bundle ID mismatch!"
            echo "   Expected: BiteAI.PlateUp"
            echo "   Found: $BUNDLE_ID"
            echo "   You may need to update your Firebase project configuration"
        fi
    else
        echo "❌ GoogleService-Info.plist appears to be corrupted"
        echo "   Please re-download from Firebase Console"
    fi
fi

echo ""
echo "🚀 After completing these steps, your Firebase error should be resolved!"