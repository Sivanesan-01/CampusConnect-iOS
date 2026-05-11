//
//  FavoritesViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    private var favoriteEvents: [EventEntity] = []
    
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
        
        let icon = UIImageView(image: UIImage(systemName: "heart.slash.fill"))
        icon.tintColor = Constants.Colors.textLight
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No Saved Events"
        label.font = Constants.Fonts.semiBold(18)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let sub = UILabel()
        sub.text = "Heart events to save them here"
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
        title = "Favorites"

        setupGradientBackground()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
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
    
    private func loadFavorites() {
        favoriteEvents = CoreDataManager.shared.fetchFavoriteEvents()
        tableView.reloadData()
        emptyStateView.isHidden = !favoriteEvents.isEmpty
        tableView.isHidden = favoriteEvents.isEmpty
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



extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { favoriteEvents.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as! FavoriteCell
        cell.configure(with: favoriteEvents[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 104 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = favoriteEvents[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { return }
        detailVC.event = event
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            guard let self = self else { return }
            let event = self.favoriteEvents[indexPath.row]
            if let id = event.id {
                CoreDataManager.shared.removeFavorite(eventID: id)
            }
            self.loadFavorites()
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "heart.slash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func loadImageFromDisk(fileName: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            return nil
        }
    }
    
}
