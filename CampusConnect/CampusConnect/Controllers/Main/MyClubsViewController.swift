//
//  MyClubsViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 10/05/26.
//

import UIKit

class MyClubsViewController: UIViewController {
    
    private var joinedClubs: [(name: String, eventCount: Int)] = []
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(MyClubCell.self, forCellReuseIdentifier: MyClubCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var emptyStateView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: "person.3.slash.fill"))
        icon.tintColor = Constants.Colors.textLight
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No Clubs Yet"
        label.font = Constants.Fonts.semiBold(18)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let sub = UILabel()
        sub.text = "Join events or start a club to see them here"
        sub.font = Constants.Fonts.regular(14)
        sub.textColor = Constants.Colors.textLight
        sub.textAlignment = .center
        sub.numberOfLines = 0
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
            stack.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -40)
        ])
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Clubs"
        
        // 1. Comment out this original line:
        // view.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.04)
        
        // 2. Add this line:
        setupGradientBackground()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadClubs()
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
    
    private func loadClubs() {
        let clubNames = CoreDataManager.shared.getJoinedClubs()
        
        joinedClubs = clubNames.map { clubName in
            let events = CoreDataManager.shared.fetchEvents(forClubName: clubName)
            return (name: clubName, eventCount: events.count)
        }
        
        tableView.reloadData()
        emptyStateView.isHidden = !joinedClubs.isEmpty
        tableView.isHidden = joinedClubs.isEmpty
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

extension MyClubsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinedClubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyClubCell.identifier, for: indexPath) as! MyClubCell
        let club = joinedClubs[indexPath.row]
        cell.configure(clubName: club.name, eventCount: club.eventCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clubName = joinedClubs[indexPath.row].name
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "SelectedClubEventsViewController") as? SelectedClubEventsViewController else { return }
        
        detailVC.clubName = clubName
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
