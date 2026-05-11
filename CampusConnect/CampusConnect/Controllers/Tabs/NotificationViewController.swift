//
//  NotificationViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class NotificationViewController: UIViewController {
    
    private var notifications: [NotificationEntity] = []
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        
        setupGradientBackground()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        setupRightButton()
        setupUI()
        loadNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotifications()
    }
    
    private func setupRightButton() {
        let btn = UIBarButtonItem(title: "Mark All as Read", style: .plain,
                                  target: self, action: #selector(markAllRead))
        btn.tintColor = Constants.Colors.primary
        navigationItem.rightBarButtonItem = btn
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadNotifications() {
        notifications = CoreDataManager.shared.fetchNotifications()
        tableView.reloadData()
        updateBadges()
    }
    
    @objc private func markAllRead() {
        notifications.forEach { CoreDataManager.shared.markNotificationRead($0) }
        loadNotifications()
        NotificationCenter.default.post(name: NSNotification.Name("UpdateNotificationBadge"), object: nil)
    }
    
    // MARK: - Background Gradient Setup
    private var backgroundGradientLayer: CAGradientLayer?
    
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        
        // Using the exact same colors and opacity as your Home screen
        gradient.colors = [
            Constants.Colors.gradientStart.withAlphaComponent(0.08).cgColor,
            Constants.Colors.gradientEnd.withAlphaComponent(0.08).cgColor
        ]
        
        // Spreads diagonally from top-left to bottom-right
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        view.layer.insertSublayer(gradient, at: 0)
        self.backgroundGradientLayer = gradient
    }
    
    // Ensures the gradient resizes correctly if the screen bounds change
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { notifications.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as! NotificationCell
        cell.configure(with: notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        CoreDataManager.shared.markNotificationRead(notification)
        loadNotifications()
    }
    
    // NEW: Helper method to update all badges
    private func updateBadges() {
        // Update tab bar badge
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateNotificationBadge()
        }
        
        // Notify HomeViewController to update its badge (using NotificationCenter)
        NotificationCenter.default.post(name: NSNotification.Name("UpdateNotificationBadge"), object: nil)
    }
}
