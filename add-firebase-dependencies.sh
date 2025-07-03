#!/bin/bash

# Script to add Firebase dependencies to PlateUp project

echo "Adding Firebase dependencies to PlateUp project..."

# Create a temporary Package.swift to help with dependency resolution
cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PlateUp",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "PlateUp",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseVertexAI", package: "firebase-ios-sdk")
            ]
        )
    ]
)
EOF

echo "Package.swift created. Please follow these steps in Xcode:"
echo ""
echo "1. Open PlateUp.xcodeproj in Xcode"
echo "2. Select the PlateUp project in the navigator"
echo "3. Select the PlateUp target"
echo "4. Go to the 'General' tab"
echo "5. Scroll down to 'Frameworks, Libraries, and Embedded Content'"
echo "6. Click the '+' button"
echo "7. Select 'Add Other...' -> 'Add Package Dependency...'"
echo "8. Enter URL: https://github.com/firebase/firebase-ios-sdk.git"
echo "9. Set version to 'Up to Next Major Version' from 11.0.0"
echo "10. Add these products to PlateUp target:"
echo "    - FirebaseCore"
echo "    - FirebaseAuth"
echo "    - FirebaseFirestore"
echo "    - FirebaseFunctions"
echo "    - FirebaseStorage"
echo "    - FirebaseAnalytics"
echo "    - FirebaseVertexAI"
echo ""
echo "11. Also drag GoogleService-Info.plist into the project navigator"
echo "    - Make sure to check 'Copy items if needed'"
echo "    - Add to target: PlateUp"
echo ""
echo "After adding dependencies, clean and rebuild the project."

# Clean up temporary Package.swift
rm -f Package.swift