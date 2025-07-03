#!/bin/bash

# Firebase Configuration Script for PlateUp
# This script adds Firebase SDK to the Xcode project

echo "Configuring Firebase for PlateUp..."

# Function to add a package to pbxproj
add_firebase_to_pbxproj() {
    local PBXPROJ="/Users/brennenprice/Documents/PlateUp_v2/PlateUp/PlateUp.xcodeproj/project.pbxproj"
    local BACKUP="${PBXPROJ}.backup"
    
    # Create backup
    cp "$PBXPROJ" "$BACKUP"
    
    # Generate UUIDs for Firebase references
    PACKAGE_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    
    # Firebase product references
    FIREBASE_CORE_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    FIREBASE_AUTH_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    FIREBASE_FIRESTORE_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    FIREBASE_FUNCTIONS_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    FIREBASE_STORAGE_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    FIREBASE_ANALYTICS_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    FIREBASE_VERTEXAI_REF=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    
    # Create a Python script to modify the pbxproj file
    cat > modify_pbxproj.py << 'EOF'
import sys
import re

def add_firebase_to_project(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Find the end of PBXBuildFile section to add Firebase framework references
    build_file_section = re.search(r'/\* End PBXBuildFile section \*/', content)
    if not build_file_section:
        print("Could not find PBXBuildFile section")
        return False
    
    # Add Firebase framework build files
    firebase_build_files = """		""" + sys.argv[2] + """ /* FirebaseCore in Frameworks */ = {isa = PBXBuildFile; productRef = """ + sys.argv[3] + """ /* FirebaseCore */; };
		""" + sys.argv[4] + """ /* FirebaseAuth in Frameworks */ = {isa = PBXBuildFile; productRef = """ + sys.argv[5] + """ /* FirebaseAuth */; };
		""" + sys.argv[6] + """ /* FirebaseFirestore in Frameworks */ = {isa = PBXBuildFile; productRef = """ + sys.argv[7] + """ /* FirebaseFirestore */; };
		""" + sys.argv[8] + """ /* FirebaseFunctions in Frameworks */ = {isa = PBXBuildFile; productRef = """ + sys.argv[9] + """ /* FirebaseFunctions */; };
		""" + sys.argv[10] + """ /* FirebaseStorage in Frameworks */ = {isa = PBXBuildFile; productRef = """ + sys.argv[11] + """ /* FirebaseStorage */; };
		""" + sys.argv[12] + """ /* FirebaseAnalytics in Frameworks */ = {isa = PBXBuildFile; productRef = """ + sys.argv[13] + """ /* FirebaseAnalytics */; };
		""" + sys.argv[14] + """ /* FirebaseVertexAI in Frameworks */ = {isa = PBXBuildFile; productRef = """ + sys.argv[15] + """ /* FirebaseVertexAI */; };
"""
    
    content = content[:build_file_section.start()] + firebase_build_files + "\n" + content[build_file_section.start():]
    
    # Add to Frameworks build phase
    frameworks_pattern = r'(4C20BC3A2E13016600D509A8 /\* Frameworks \*/ = \{[^}]+files = \(\s*)'
    frameworks_match = re.search(frameworks_pattern, content, re.DOTALL)
    if frameworks_match:
        firebase_frameworks = """				""" + sys.argv[2] + """ /* FirebaseCore in Frameworks */,
				""" + sys.argv[4] + """ /* FirebaseAuth in Frameworks */,
				""" + sys.argv[6] + """ /* FirebaseFirestore in Frameworks */,
				""" + sys.argv[8] + """ /* FirebaseFunctions in Frameworks */,
				""" + sys.argv[10] + """ /* FirebaseStorage in Frameworks */,
				""" + sys.argv[12] + """ /* FirebaseAnalytics in Frameworks */,
				""" + sys.argv[14] + """ /* FirebaseVertexAI in Frameworks */,
"""
        content = content[:frameworks_match.end()] + firebase_frameworks + content[frameworks_match.end():]
    
    # Add package product dependencies to main target
    main_target_pattern = r'(4C20BC3C2E13016600D509A8[^}]+packageProductDependencies = \(\s*)'
    main_target_match = re.search(main_target_pattern, content, re.DOTALL)
    if main_target_match:
        firebase_dependencies = """				""" + sys.argv[3] + """ /* FirebaseCore */,
				""" + sys.argv[5] + """ /* FirebaseAuth */,
				""" + sys.argv[7] + """ /* FirebaseFirestore */,
				""" + sys.argv[9] + """ /* FirebaseFunctions */,
				""" + sys.argv[11] + """ /* FirebaseStorage */,
				""" + sys.argv[13] + """ /* FirebaseAnalytics */,
				""" + sys.argv[15] + """ /* FirebaseVertexAI */,
"""
        content = content[:main_target_match.end()] + firebase_dependencies + content[main_target_match.end():]
    
    # Add package reference to project
    project_pattern = r'(4C20BC352E13016600D509A8 /\* Project object \*/ = \{[^}]+mainGroup[^;]+;)'
    project_match = re.search(project_pattern, content, re.DOTALL)
    if project_match:
        package_reference = """
			packageReferences = (
				""" + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */,
			);"""
        content = content[:project_match.end()] + package_reference + content[project_match.end():]
    
    # Add XCRemoteSwiftPackageReference section
    swiftpm_section = re.search(r'/\* End XCConfigurationList section \*/', content)
    if swiftpm_section:
        package_ref_section = """
/* Begin XCRemoteSwiftPackageReference section */
		""" + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */ = {
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/firebase/firebase-ios-sdk.git";
			requirement = {
				kind = upToNextMajorVersion;
				minimumVersion = 11.0.0;
			};
		};
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		""" + sys.argv[3] + """ /* FirebaseCore */ = {
			isa = XCSwiftPackageProductDependency;
			package = """ + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseCore;
		};
		""" + sys.argv[5] + """ /* FirebaseAuth */ = {
			isa = XCSwiftPackageProductDependency;
			package = """ + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseAuth;
		};
		""" + sys.argv[7] + """ /* FirebaseFirestore */ = {
			isa = XCSwiftPackageProductDependency;
			package = """ + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseFirestore;
		};
		""" + sys.argv[9] + """ /* FirebaseFunctions */ = {
			isa = XCSwiftPackageProductDependency;
			package = """ + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseFunctions;
		};
		""" + sys.argv[11] + """ /* FirebaseStorage */ = {
			isa = XCSwiftPackageProductDependency;
			package = """ + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseStorage;
		};
		""" + sys.argv[13] + """ /* FirebaseAnalytics */ = {
			isa = XCSwiftPackageProductDependency;
			package = """ + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseAnalytics;
		};
		""" + sys.argv[15] + """ /* FirebaseVertexAI */ = {
			isa = XCSwiftPackageProductDependency;
			package = """ + sys.argv[16] + """ /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseVertexAI;
		};
/* End XCSwiftPackageProductDependency section */
"""
        content = content[:swiftpm_section.end()] + "\n" + package_ref_section + content[swiftpm_section.end():]
    
    # Write the modified content
    with open(file_path, 'w') as f:
        f.write(content)
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 17:
        print("Usage: modify_pbxproj.py <file_path> <build_refs...> <package_ref>")
        sys.exit(1)
    
    if add_firebase_to_project(sys.argv[1]):
        print("Successfully added Firebase to project")
    else:
        print("Failed to add Firebase to project")
        sys.exit(1)
EOF

    # Generate build file references
    BUILD_CORE=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    BUILD_AUTH=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    BUILD_FIRESTORE=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    BUILD_FUNCTIONS=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    BUILD_STORAGE=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    BUILD_ANALYTICS=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)
    BUILD_VERTEXAI=$(uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]' | cut -c1-24)

    # Run the Python script
    python3 modify_pbxproj.py "$PBXPROJ" \
        "$BUILD_CORE" "$FIREBASE_CORE_REF" \
        "$BUILD_AUTH" "$FIREBASE_AUTH_REF" \
        "$BUILD_FIRESTORE" "$FIREBASE_FIRESTORE_REF" \
        "$BUILD_FUNCTIONS" "$FIREBASE_FUNCTIONS_REF" \
        "$BUILD_STORAGE" "$FIREBASE_STORAGE_REF" \
        "$BUILD_ANALYTICS" "$FIREBASE_ANALYTICS_REF" \
        "$BUILD_VERTEXAI" "$FIREBASE_VERTEXAI_REF" \
        "$PACKAGE_REF"
    
    # Clean up
    rm -f modify_pbxproj.py
}

# Main script execution
echo "This script will modify the Xcode project to add Firebase dependencies."
echo "A backup will be created at project.pbxproj.backup"
echo ""
read -p "Do you want to continue? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    add_firebase_to_pbxproj
    
    echo ""
    echo "Firebase dependencies have been added to the project."
    echo ""
    echo "Next steps:"
    echo "1. Close Xcode if it's open"
    echo "2. Open PlateUp.xcodeproj in Xcode"
    echo "3. Wait for Swift Package Manager to resolve dependencies"
    echo "4. Make sure GoogleService-Info.plist is added to the project:"
    echo "   - Drag GoogleService-Info.plist into the project navigator"
    echo "   - Check 'Copy items if needed'"
    echo "   - Add to target: PlateUp"
    echo "5. Clean build folder (Cmd+Shift+K)"
    echo "6. Build the project (Cmd+B)"
    echo ""
    echo "If the build still fails, you may need to:"
    echo "- Delete DerivedData: ~/Library/Developer/Xcode/DerivedData"
    echo "- Reset package caches: File > Packages > Reset Package Caches"
else
    echo "Operation cancelled."
fi