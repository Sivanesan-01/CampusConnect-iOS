//
//  AuthManager.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    var currentUser: User? { Auth.auth().currentUser }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, name: String,
                completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else { return }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { _ in }
            
            // Send email verification (acts as OTP flow)
            user.sendEmailVerification { _ in }
            completion(.success(user))
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String,
                completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else { return }
            completion(.success(user))
        }
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            SessionManager.shared.clearSession()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, "Password reset email sent.")
            }
        }
    }
    
    // MARK: - Auth Error Messages
    func errorMessage(for error: Error) -> String {
        let err = error as NSError
        switch err.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Check your connection."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
