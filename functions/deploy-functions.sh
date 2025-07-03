#!/bin/bash

# PlateUp v2.0 - Firebase Cloud Functions Deployment Script
# This script will deploy all Cloud Functions to your Firebase project

echo "🚀 PlateUp v2.0 - Firebase Cloud Functions Deployment"
echo "===================================================="

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed!"
    echo "Please install it by running: npm install -g firebase-tools"
    exit 1
fi

# Check if we're in the functions directory
if [ ! -f "package.json" ]; then
    echo "❌ Please run this script from the functions directory"
    exit 1
fi

# Login to Firebase if needed
echo "📝 Checking Firebase authentication..."
firebase login:list &> /dev/null
if [ $? -ne 0 ]; then
    echo "🔐 Please login to Firebase:"
    firebase login
fi

# Select project
echo ""
echo "📋 Setting up Firebase project..."
firebase use plateup-nutrition-app

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Compile TypeScript
echo ""
echo "🔨 Compiling TypeScript..."
npm run build

# Set environment variables
echo ""
echo "🔐 Setting environment variables..."
echo "Note: You'll need to set your Gemini API key before the functions will work"
echo "Run: firebase functions:config:set gemini.api_key=\"YOUR_API_KEY\""

# Deploy functions
echo ""
echo "🚀 Deploying Cloud Functions..."
echo "This may take a few minutes..."

# Deploy all functions
firebase deploy --only functions

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Set your Gemini API key:"
echo "   firebase functions:config:set gemini.api_key=\"YOUR_API_KEY\""
echo ""
echo "2. Deploy Firestore rules and indexes:"
echo "   firebase deploy --only firestore"
echo ""
echo "3. Deploy Storage rules:"
echo "   firebase deploy --only storage"
echo ""
echo "4. View your functions in the Firebase Console:"
echo "   https://console.firebase.google.com/project/plateup-nutrition-app/functions"