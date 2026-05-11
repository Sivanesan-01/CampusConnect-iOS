//
//  SelectedClubEventsViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 10/05/26.
//

import UIKit

class SelectedClubEventsViewController: UIViewController {
    
    var clubName: String = ""
    private var clubEvents: [EventEntity] = []
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var emptyStateView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: "calendar.badge.exclamationmark"))
        icon.tintColor = Constants.Colors.textLight
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No Events Found"
        label.font = Constants.Fonts.semiBold(18)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let sub = UILabel()
        sub.text = "This club hasn't posted any events yet"
        sub.font = Constants.Fonts.regular(14)
        sub.textColor = Constants.Colors.textLight
        sub.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [icon, label, sub])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(stack)
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60),
            stack.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = clubName
        
        // 1. Comment out this original line:
        // view.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.04)
        
        // 2. Add this line:
        setupGradientBackground()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        setupUI()
        loadEvents()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadEvents() {
        clubEvents = CoreDataManager.shared.fetchEvents(forClubName: clubName)
        tableView.reloadData()
        emptyStateView.isHidden = !clubEvents.isEmpty
        tableView.isHidden = clubEvents.isEmpty
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

extension SelectedClubEventsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as! FavoriteCell
        cell.configure(with: clubEvents[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = clubEvents[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { return }
        detailVC.event = event
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
