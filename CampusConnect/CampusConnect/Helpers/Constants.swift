//
//  Constants.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

struct Constants {
    
    // MARK: - Colors
    struct Colors {
        static let primary = UIColor(hex: "#4F46E5")      // Indigo
        static let secondary = UIColor(hex: "#7C3AED")    // Purple
        static let accent = UIColor(hex: "#06B6D4")       // Cyan
        static let background = UIColor(hex: "#F8FAFC")
        static let cardBackground = UIColor.white
        static let textPrimary = UIColor(hex: "#0F172A")
        static let textSecondary = UIColor(hex: "#64748B")
        static let textLight = UIColor(hex: "#94A3B8")
        static let success = UIColor(hex: "#10B981")
        static let danger = UIColor(hex: "#EF4444")
        static let gradientStart = UIColor(hex: "#4F46E5")
        static let gradientEnd = UIColor(hex: "#7C3AED")
        static let divider = UIColor(hex: "#E2E8F0")
    }
    
    // MARK: - Fonts
    struct Fonts {
        static func bold(_ size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }
        static func semiBold(_ size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        static func medium(_ size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .medium)
        }
        static func regular(_ size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }
    
    // MARK: - Layout
    struct Layout {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 8
        static let cardCornerRadius: CGFloat = 20
        static let padding: CGFloat = 20
        static let smallPadding: CGFloat = 12
        static let buttonHeight: CGFloat = 56
        static let tabBarHeight: CGFloat = 83
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let isLoggedIn = "isLoggedIn"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let userUID = "userUID"
    }
    
    // MARK: - Segue Identifiers
    struct Segues {
        static let splashToSignIn = "splashToSignIn"
        static let splashToHome = "splashToHome"
        static let signInToHome = "signInToHome"
        static let signInToSignUp = "signInToSignUp"
        static let homeToEventDetail = "homeToEventDetail"
        static let homeToAddEvent = "homeToAddEvent"
        static let homeToClubFormation = "homeToClubFormation"
        static let eventDetailToPayment = "eventDetailToPayment"
        static let favoriteToEventDetail = "favoriteToEventDetail"
        static let notificationToEventDetail = "notificationToEventDetail"
    }
    
    // MARK: - Core Data
    struct CoreData {
        static let modelName = "CampusConnect"
        static let eventEntity = "EventEntity"
        static let clubEntity = "ClubEntity"
        static let userEntity = "UserEntity"
        static let favoriteEntity = "FavoriteEntity"
        static let participationEntity = "ParticipationEntity"
        static let notificationEntity = "NotificationEntity"
    }
}

// MARK: - UIColor Hex Extension
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
