#!/bin/bash

# PlateUp Firebase Setup Script

echo "🔥 Setting up Firebase for PlateUp v2.0..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Navigate to functions directory
cd functions

echo "📦 Installing Cloud Functions dependencies..."
npm install

echo "🔨 Building TypeScript files..."
npm run build

cd ..

echo "✅ Firebase setup complete!"
echo ""
echo "Next steps:"
echo "1. Run 'firebase login' if you haven't already"
echo "2. Run 'firebase use --add' to select your project"
echo "3. Set up Gemini API key:"
echo "   firebase functions:config:set gemini.api_key='YOUR_API_KEY'"
echo "4. Deploy functions: 'firebase deploy --only functions'"
echo "5. Deploy security rules: 'firebase deploy --only firestore:rules,storage:rules'"