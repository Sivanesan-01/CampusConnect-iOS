//
//  SessionManager.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import Foundation

class SessionManager {
    static let shared = SessionManager()
    private init() {}
    
    var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isLoggedIn) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.isLoggedIn) }
    }
    
    var userEmail: String {
        get { UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userEmail) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.userEmail) }
    }
    
    var userName: String {
        get { UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userName) ?? "Student" }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.userName) }
    }
    
    var userUID: String {
        get { UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userUID) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.userUID) }
    }
    
    func saveSession(uid: String, email: String, name: String) {
        isLoggedIn = true
        userUID = uid
        userEmail = email
        userName = name
        UserDefaults.standard.synchronize()
    }
    
    func clearSession() {
        isLoggedIn = false
        userUID = ""
        userEmail = ""
        userName = ""
        UserDefaults.standard.synchronize()
    }
}
