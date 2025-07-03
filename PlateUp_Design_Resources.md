# PlateUp v2.0 Design Resources & Development Guide

**Last Updated:** June 30, 2025  
**Purpose:** Comprehensive resource collection for PlateUp v2.0 development with latest technology documentation and best practices

---

## 📚 Table of Contents

1. [SwiftUI 6 & @Observable](#swiftui-6--observable)
2. [Firebase iOS SDK](#firebase-ios-sdk)
3. [Mobile App UI/UX Best Practices](#mobile-app-uiux-best-practices)
4. [Google Gemini AI Integration](#google-gemini-ai-integration)
5. [Project-Specific Architecture](#project-specific-architecture)
6. [Quick Reference Links](#quick-reference-links)

---

## 🎨 SwiftUI 6 & @Observable

### Official Documentation
- **Apple Developer - Migration Guide**: [Migrating from ObservableObject to @Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- **Apple Developer - Observation Framework**: [Observation Documentation](https://developer.apple.com/documentation/observation)

### Key Features & Implementation

#### @Observable Macro Benefits
- **Simplified State Management**: No longer need `@ObservedObject`, `ObservableObject`, and `@Published`
- **Performance Improvements**: Only triggers view redraws for properties actually used in the view
- **Platform Requirements**: iOS 17+, iPadOS 17+, macOS 14+, tvOS 17+, watchOS 10+

#### Code Migration Example
```swift
// Old ObservableObject approach
class UserViewModel: ObservableObject {
    @Published var name = ""
    @Published var score = 0
}

// New @Observable approach
import Observation

@Observable
class UserViewModel {
    var name = ""
    var score = 0
}
```

#### Usage in Views
```swift
// Use @State instead of @StateObject
struct ContentView: View {
    @State private var viewModel = UserViewModel()
    
    var body: some View {
        // View automatically updates when used properties change
    }
}

// For bindings, use @Bindable
struct EditView: View {
    @Bindable var viewModel: UserViewModel
    
    var body: some View {
        TextField("Name", text: $viewModel.name)
    }
}
```

### Important Notes
- @Observable is NOT a drop-in replacement for ObservableObject
- Use `@State` with @Observable (not `@StateObject`)
- Import `Observation` framework (or just `SwiftUI` which includes it)
- Supports tracking optionals and collections (unlike ObservableObject)

---

## 🔥 Firebase iOS SDK

### Official Documentation
- **Add Firebase to iOS**: [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- **Firebase Authentication**: [Auth Documentation](https://firebase.google.com/docs/auth)
- **Cloud Firestore**: [Firestore Documentation](https://firebase.google.com/docs/firestore/quickstart)
- **Cloud Functions**: [Functions Documentation](https://firebase.google.com/docs/functions)
- **GitHub Repository**: [firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk)

### Installation Methods

#### Swift Package Manager (Recommended)
```swift
dependencies: [
    .package(
        name: "Firebase",
        url: "https://github.com/firebase/firebase-ios-sdk.git",
        from: "11.0.0"
    )
]
```

#### CocoaPods
```ruby
pod 'FirebaseCore'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'FirebaseFunctions'
pod 'FirebaseStorage'
pod 'FirebaseAnalytics'
```

### Integration Steps
1. Create Firebase project in [Firebase Console](https://console.firebase.google.com/)
2. Download `GoogleService-Info.plist` and add to Xcode project
3. Initialize Firebase in App Delegate or App struct
4. Configure security rules for Firestore
5. Deploy Cloud Functions using Firebase CLI

### PlateUp-Specific Firebase Services
- **Authentication**: Apple Sign In, Google Sign In, Email/Password
- **Firestore Collections**: users, meals, coaching_sessions, clarification_feedback
- **Cloud Functions**: AI processing, coaching generation, data aggregation
- **Storage**: Meal images, voice recordings
- **Analytics**: User engagement, feature usage tracking

---

## 📱 Mobile App UI/UX Best Practices

### Apple Human Interface Guidelines
- **Official HIG**: [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- **iOS Design Guidelines**: [Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios/)

### 2024/2025 Design Principles

#### Core iOS Design Principles
1. **Consistency**: Maintain consistent patterns throughout the app
2. **Clarity**: Clean, uncluttered layouts with ample white space
3. **User Control**: Allow users to feel in control of interactions
4. **Accessibility**: Design with inclusivity from the start

#### Typography & Visual Design
- Use San Francisco font for optimal legibility
- Implement clear visual hierarchy
- Use color sparingly to indicate interactivity
- Maintain proper contrast ratios for accessibility

#### Navigation Best Practices
- Leverage iOS native gestures (swipe to go back)
- Keep navigation intuitive and predictable
- Use standard iOS navigation patterns
- Implement proper back button behavior

#### PlateUp-Specific Design Implementation
```swift
// Enhanced Green Color System
enum PlateUpColors {
    static let forestGreen = Color(hex: "0F4C3A")    // Headers, important text
    static let primaryGreen = Color(hex: "1B5E20")   // Main brand, CTAs
    static let mediumGreen = Color(hex: "2E7D32")    // Interactive elements
    static let accentGreen = Color(hex: "4CAF50")    // Success states
    static let lightGreen = Color(hex: "81C784")     // Backgrounds
    static let paleGreen = Color(hex: "C8E6C9")      // Cards, containers
    static let warmGreen = Color(hex: "689F38")      // Energy indicators
    static let coolGreen = Color(hex: "00695C")      // Sleep/recovery
    static let brightGreen = Color(hex: "76FF03")    // Achievements
}
```

### Common Mistakes to Avoid
- Using non-standard UI elements
- Creating cluttered layouts
- Choosing inappropriate typography
- Neglecting accessibility features
- Ignoring platform conventions

---

## 🤖 Google Gemini AI Integration

### Official Documentation
- **Gemini API Docs**: [Google AI for Developers](https://ai.google.dev/gemini-api/docs)
- **Firebase AI Logic SDK**: [Get Started with Firebase AI](https://firebase.google.com/docs/ai-logic/get-started)
- **Vertex AI Gemini**: [Google Cloud Documentation](https://cloud.google.com/vertex-ai/generative-ai/docs/models/gemini)

### Model Selection for PlateUp
- **Primary**: Gemini 1.5 Flash - Real-time coaching and fast responses
- **Secondary**: Gemini 1.5/2.5 Pro - Complex food recognition and detailed analysis

### Integration Options

#### Firebase AI Logic SDK (Recommended for Mobile)
```swift
// iOS Integration
import FirebaseCore
import FirebaseVertexAI

// Initialize Vertex AI
let vertex = VertexAI.vertexAI()

// Initialize generative model
let model = vertex.generativeModel(
    modelName: "gemini-1.5-flash",
    generationConfig: config
)
```

#### Key Features for PlateUp
1. **Multimodal Processing**: Text, images, audio support
2. **Function Calling**: Connect to external systems
3. **Streaming Responses**: Real-time coaching feedback
4. **Context Windows**: Long conversation memory

### API Access Plans
- **Spark Plan (Free)**: Good for development and testing
- **Blaze Plan (Pay-as-you-go)**: Required for production

---

## 🏗️ Project-Specific Architecture

### Development Workflow with Claude Code

#### Parallel Agent Configuration
```yaml
Agent_1_Frontend:
  Focus: SwiftUI 6, MVVM, UI Components
  Tools: Xcode, SwiftUI Preview, SF Symbols
  
Agent_2_Backend:
  Focus: Firebase, Cloud Functions, Security
  Tools: Firebase CLI, Node.js, TypeScript
  
Agent_3_AI:
  Focus: Gemini Integration, Prompt Engineering
  Tools: AI Studio, Vertex AI Console
  
Agent_4_QA:
  Focus: Testing, Performance, Monitoring
  Tools: XCTest, Firebase Performance, TestFlight
```

### MVVM Architecture Pattern
```swift
// Model
@Observable
class Meal: Identifiable {
    let id = UUID()
    var name: String
    var calories: Int
    var timestamp: Date
}

// ViewModel
@Observable
class MealViewModel {
    var meals: [Meal] = []
    private let repository: MealRepository
    
    func loadMeals() async {
        meals = await repository.fetchMeals()
    }
}

// View
struct MealListView: View {
    @State private var viewModel = MealViewModel()
    
    var body: some View {
        List(viewModel.meals) { meal in
            MealRow(meal: meal)
        }
        .task {
            await viewModel.loadMeals()
        }
    }
}
```

### File Structure
```
PlateUp_v2/
├── PlateUpApp.swift
├── Models/
│   ├── User.swift
│   ├── Meal.swift
│   └── CoachingInsight.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── MealViewModel.swift
│   └── CoachingViewModel.swift
├── Views/
│   ├── Onboarding/
│   ├── Dashboard/
│   ├── MealLogging/
│   └── Coaching/
├── Services/
│   ├── FirebaseService.swift
│   ├── GeminiService.swift
│   └── AnalyticsService.swift
├── Utilities/
│   ├── Extensions/
│   └── Constants.swift
└── Resources/
    ├── GoogleService-Info.plist
    └── Assets.xcassets
```

---

## 🔗 Quick Reference Links

### Essential Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS Quickstart](https://firebase.google.com/docs/ios/setup)
- [Gemini API Reference](https://ai.google.dev/gemini-api/docs)
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)

### Development Tools
- [Xcode 16+](https://developer.apple.com/xcode/)
- [Firebase Console](https://console.firebase.google.com/)
- [Google AI Studio](https://aistudio.google.com/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

### Testing & Deployment
- [TestFlight](https://developer.apple.com/testflight/)
- [Firebase Test Lab](https://firebase.google.com/docs/test-lab)
- [App Store Connect](https://appstoreconnect.apple.com/)

### Community Resources
- [Swift Forums](https://forums.swift.org/)
- [Firebase Community](https://firebase.google.com/community)
- [iOS Dev Weekly](https://iosdevweekly.com/)
- [SwiftUI Lab](https://swiftui-lab.com/)

---

## 📝 Development Checklist

### Week 1 Setup
- [ ] Create new Xcode project with SwiftUI 6
- [ ] Configure Firebase project
- [ ] Implement @Observable ViewModels
- [ ] Set up enhanced green color system
- [ ] Create basic navigation structure
- [ ] Initialize Gemini API connection
- [ ] Set up CI/CD with GitHub Actions

### Week 2-3 Core Features
- [ ] Implement authentication flow
- [ ] Build onboarding screens
- [ ] Create meal logging interface
- [ ] Integrate AI coaching system
- [ ] Implement clarification feedback
- [ ] Set up analytics tracking
- [ ] Create debugging dashboard

### Pre-Launch
- [ ] Performance optimization
- [ ] Accessibility audit
- [ ] Security review
- [ ] App Store submission prep
- [ ] Beta testing with TestFlight
- [ ] Documentation completion

---

**Note:** This document will be continuously updated as new resources and best practices emerge. Check back regularly for the latest information and updates.