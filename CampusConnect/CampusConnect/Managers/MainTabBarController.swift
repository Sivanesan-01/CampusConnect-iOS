//
//  MainTabBarController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 09/05/26.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    private var notificationBadgeView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupAppearance()
        setupNotificationBadge()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNotificationBadge),
            name: NSNotification.Name("UpdateNotificationBadge"),
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNotificationBadge()
    }

    // CRITICAL: This fixes the navigation issue
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: false)
        }
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear

        let itemAppearance = UITabBarItemAppearance()
        
        itemAppearance.normal.titleTextAttributes = [
            .font: Constants.Fonts.medium(11),
            .foregroundColor: Constants.Colors.textLight
        ]
        itemAppearance.selected.titleTextAttributes = [
            .font: Constants.Fonts.bold(11),
            .foregroundColor: Constants.Colors.primary
        ]
        
        appearance.stackedLayoutAppearance = itemAppearance
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.tintColor = Constants.Colors.primary
        tabBar.unselectedItemTintColor = Constants.Colors.textLight
    }

    private func setupNotificationBadge() {
        guard let tabBarItems = tabBar.items, tabBarItems.count > 2 else { return }

        let badgeView = UIView()
        badgeView.backgroundColor = Constants.Colors.primary
        badgeView.layer.cornerRadius = 5
        badgeView.isHidden = true
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        
        notificationBadgeView = badgeView
        tabBar.addSubview(badgeView)

        let tabWidth = tabBar.frame.width / CGFloat(tabBarItems.count)
        let xPosition = tabWidth * 2.5 + 8

        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalToConstant: 10),
            badgeView.heightAnchor.constraint(equalToConstant: 10),
            badgeView.centerXAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: xPosition),
            badgeView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: 6)
        ])
    }

    @objc func updateNotificationBadge() {
        let notifications = CoreDataManager.shared.fetchNotifications()
        let hasUnread = notifications.contains { !$0.isRead }
        
        notificationBadgeView?.isHidden = !hasUnread
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
