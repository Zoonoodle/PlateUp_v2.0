//
//  AuthViewModel.swift
//  PlateUp v2.0
//
//  Authentication state management with @Observable
//

import Foundation
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

// Use fully qualified Firebase User type to avoid confusion with PlateUp's User model

@Observable
class AuthViewModel {
    
    // MARK: - Published Properties
    var currentUser: PlateUp.User?
    var isSignedIn: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var authState: AuthState = .signedOut
    
    // MARK: - Form Properties
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var name: String = ""
    
    // MARK: - Dependencies
    private let firebaseService = FirebaseService.shared
    
    enum AuthState {
        case signedOut
        case signingIn
        case signingUp
        case signedIn
        case onboarding
        case error(String)
    }
    
    init() {
        checkAuthState()
    }
    
    // MARK: - Auth State Management
    
    func checkAuthState() {
        isLoading = true
        
        if let firebaseUser = firebaseService.currentUser {
            Task {
                do {
                    let user = try await firebaseService.getUserProfile(userId: firebaseUser.uid)
                    await MainActor.run {
                        self.currentUser = user
                        self.isSignedIn = true
                        self.authState = user.isProfileComplete ? .signedIn : .onboarding
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.authState = .onboarding
                        self.isLoading = false
                    }
                }
            }
        } else {
            isSignedIn = false
            authState = .signedOut
            isLoading = false
        }
    }
    
    // MARK: - Sign In
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        await MainActor.run {
            isLoading = true
            authState = .signingIn
            errorMessage = nil
        }
        
        do {
            let firebaseUser = try await firebaseService.signInWithEmail(email, password: password)
            let user = try await firebaseService.getUserProfile(userId: firebaseUser.uid)
            
            await MainActor.run {
                self.currentUser = user
                self.isSignedIn = true
                self.authState = user.isProfileComplete ? .signedIn : .onboarding
                self.isLoading = false
                self.clearForm()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.authState = .error(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Sign Up
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        await MainActor.run {
            isLoading = true
            authState = .signingUp
            errorMessage = nil
        }
        
        do {
            let firebaseUser = try await firebaseService.signUpWithEmail(email, password: password)
            let user = PlateUp.User(
                id: firebaseUser.uid,
                name: name,
                email: email
            )
            
            try await firebaseService.createUserProfile(user)
            
            await MainActor.run {
                self.currentUser = user
                self.isSignedIn = true
                self.authState = .onboarding
                self.isLoading = false
                self.clearForm()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.authState = .error(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try firebaseService.signOut()
            currentUser = nil
            isSignedIn = false
            authState = .signedOut
            clearForm()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Profile Completion
    
    func completeProfile() async {
        guard var user = currentUser else { return }
        
        isLoading = true
        
        do {
            user.lastActiveAt = Date()
            try await firebaseService.updateUserProfile(user)
            
            let updatedUser = user // Capture the value before async operation
            await MainActor.run {
                self.currentUser = updatedUser
                self.authState = .signedIn
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Account Deletion
    
    func deleteAccount() async {
        guard currentUser != nil else { return }
        
        isLoading = true
        
        do {
            try await firebaseService.deleteAccount()
            
            await MainActor.run {
                self.currentUser = nil
                self.isSignedIn = false
                self.authState = .signedOut
                self.isLoading = false
                self.clearForm()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Form Management
    
    func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
        if case .error = authState {
            authState = .signedOut
        }
    }
    
    // MARK: - Validation
    
    var isSignInFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail(email)
    }
    
    var isSignUpFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        !name.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}