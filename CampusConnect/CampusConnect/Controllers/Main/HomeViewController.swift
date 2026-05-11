//
//  HomeViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Data
    private var allEvents: [EventEntity] = []
    private var filteredEvents: [EventEntity] = []
    private var dynamicCategories: [String] = ["All"]
    private var selectedCategoryIndex = 0
    
    // MARK: - UI
    private lazy var headerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear // Changed from .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var mainScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(14)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.bold(22)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notificationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bell.fill"), for: .normal)  // Changed to "bell.fill" without badge
        btn.tintColor = Constants.Colors.primary
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var notificationBadge: UIView = {
        let badge = UIView()
        badge.backgroundColor = .red
        badge.layer.cornerRadius = 6
        badge.isHidden = true  // Hidden by default
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()
    
    private lazy var profileImageButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.1)
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        btn.layer.borderWidth = 2
        btn.layer.borderColor = Constants.Colors.primary.withAlphaComponent(0.3).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        // Default icon
        let iconImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        iconImage.tintColor = Constants.Colors.primary
        iconImage.contentMode = .scaleAspectFill
        iconImage.tag = 999 // Tag for easy access
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(iconImage)
        
        NSLayoutConstraint.activate([
            iconImage.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            iconImage.widthAnchor.constraint(equalTo: btn.widthAnchor, constant: -4),
            iconImage.heightAnchor.constraint(equalTo: btn.heightAnchor, constant: -4)
        ])
        
        return btn
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search events, clubs..."
        sb.searchBarStyle = .minimal
        sb.layer.cornerRadius = 14
        sb.clipsToBounds = true
        sb.backgroundColor = .white
        sb.layer.borderWidth = 1.5
        sb.layer.borderColor = Constants.Colors.divider.cgColor
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Add this as a separate property
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.setTitleColor(Constants.Colors.primary, for: .normal)
        button.titleLabel?.font = Constants.Fonts.medium(14)
        return button
    }()
    
    private lazy var sectionHeaderStack: UIStackView = {
        let popularLabel = UILabel()
        popularLabel.text = "Popular Events"
        popularLabel.font = Constants.Fonts.bold(20)
        popularLabel.textColor = Constants.Colors.textPrimary
        
        // Use the extracted seeAllButton here
        let stack = UIStackView(arrangedSubviews: [popularLabel, UIView(), seeAllButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var eventsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.register(EventCardCell.self, forCellWithReuseIdentifier: EventCardCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var startClubButton: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Start a Club"
        config.image = UIImage(systemName: "plus.circle.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = Constants.Colors.primary.withAlphaComponent(0.1)
        config.baseForegroundColor = Constants.Colors.primary
        config.cornerStyle = .large
        btn.configuration = config
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(startClubTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var addEventButton: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Add Event"
        config.image = UIImage(systemName: "calendar.badge.plus")
        config.imagePadding = 8
        config.baseBackgroundColor = Constants.Colors.accent.withAlphaComponent(0.1)
        config.baseForegroundColor = Constants.Colors.accent
        config.cornerStyle = .large
        btn.configuration = config
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(addEventTapped), for: .touchUpInside)
        return btn
    }()
    
    private var eventsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. Comment out these original background lines:
        // view.backgroundColor = Constants.Colors.background
        // view.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.04)
        
        // 2. Add this line:
        setupGradientBackground()
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
        
        setupUI()
        setupDelegates()
        loadData()
        
        // NEW: Listen for notification badge updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBadgeUpdate),
            name: NSNotification.Name("UpdateNotificationBadge"),
            object: nil
        )
    }
    
    // NEW: Handle badge update notification
    @objc private func handleBadgeUpdate() {
        updateNotificationBadge()
    }
    
    // Don't forget to remove observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        updateGreeting()
        loadProfileImage()
        updateNotificationBadge()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentView)
        
        let actionStack = UIStackView(arrangedSubviews: [startClubButton, addEventButton])
        actionStack.axis = .horizontal
        actionStack.distribution = .fillEqually
        actionStack.spacing = 12
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.addSubview(notificationBadge)
        
        [headerView, searchBar, actionStack, categoryCollectionView,
         sectionHeaderStack, eventsCollectionView].forEach { contentView.addSubview($0) }
        
        [greetingLabel, nameLabel, notificationButton, profileImageButton].forEach { headerView.addSubview($0) }
        
        eventsCollectionViewHeightConstraint = eventsCollectionView.heightAnchor.constraint(equalToConstant: 600)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            profileImageButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            profileImageButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            profileImageButton.widthAnchor.constraint(equalToConstant: 36),
            profileImageButton.heightAnchor.constraint(equalToConstant: 36),
            
            notificationButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            notificationButton.trailingAnchor.constraint(equalTo: profileImageButton.leadingAnchor, constant: -12),
            notificationButton.widthAnchor.constraint(equalToConstant: 36),
            notificationButton.heightAnchor.constraint(equalToConstant: 36),
            
            greetingLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            nameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -14),
            
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
            
            // Action Stack
            actionStack.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionStack.heightAnchor.constraint(equalToConstant: 50),
            
            // Category CollectionView
            categoryCollectionView.topAnchor.constraint(equalTo: actionStack.bottomAnchor, constant: 16),
            categoryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 42),
            
            // Section Header
            sectionHeaderStack.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 20),
            sectionHeaderStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionHeaderStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Events CollectionView
            eventsCollectionView.topAnchor.constraint(equalTo: sectionHeaderStack.bottomAnchor, constant: 14),
            eventsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            eventsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            eventsCollectionViewHeightConstraint,
            eventsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            notificationBadge.topAnchor.constraint(equalTo: notificationButton.topAnchor, constant: 6),
            notificationBadge.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor, constant: -6),
            notificationBadge.widthAnchor.constraint(equalToConstant: 12),
            notificationBadge.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    private func setupDelegates() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        searchBar.delegate = self
    }
    
    private func loadData() {
        allEvents = CoreDataManager.shared.fetchAllEvents()
        
        // 1. Get all clubs saved by students
        let savedClubs = CoreDataManager.shared.fetchAllClubs().compactMap { $0.name }
        
        // 2. Define your default "fixed" categories
        let fixed = ["TechClub", "CulturalClub", "SportsClub", "BizClub", "PhotoClub"]
        
        // 3. Combine them, remove duplicates using Set, and sort them
        let uniqueClubs = Array(Set(fixed + savedClubs)).sorted()
        
        // 4. Set the final list with "All" at the beginning
        dynamicCategories = ["All"] + uniqueClubs
        
        categoryCollectionView.reloadData()
        filterByCategory(index: selectedCategoryIndex)
    }
    
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        switch hour {
        case 5..<12: greeting = "Good Morning ☀️"
        case 12..<17: greeting = "Good Afternoon 🌤"
        case 17..<21: greeting = "Good Evening 🌇"
        default: greeting = "Good Night 🌙"
        }
        greetingLabel.text = greeting
        nameLabel.text = SessionManager.shared.userName
    }
    
    private func filterByCategory(index: Int) {
        if index == 0 {
            filteredEvents = allEvents
        } else {
            let selectedName = dynamicCategories[index]
            // Filters events if the clubName matches the pill you tapped
            filteredEvents = allEvents.filter { $0.clubName == selectedName }
        }
        eventsCollectionView.reloadData()
        updateCollectionViewHeight()
    }
    
    
    
    private func updateCollectionViewHeight() {
        let columns: CGFloat = 2
        let spacing: CGFloat = 12
        let padding: CGFloat = 20
        let width = (UIScreen.main.bounds.width - padding * 2 - spacing) / columns
        let cardHeight: CGFloat = 260
        let rows = ceil(CGFloat(filteredEvents.count) / columns)
        let totalHeight = rows * cardHeight + (rows - 1) * spacing
        eventsCollectionViewHeightConstraint.constant = max(totalHeight, 260)
        view.layoutIfNeeded()
    }
    
    // MARK: - Background Gradient Setup
    private var backgroundGradientLayer: CAGradientLayer?
    
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        
        // Using your project's gradient constants with a light opacity for a subtle spread
        gradient.colors = [
            Constants.Colors.gradientStart.withAlphaComponent(0.08).cgColor,
            Constants.Colors.gradientEnd.withAlphaComponent(0.08).cgColor
        ]
        
        // Spreads diagonlly from top-left to bottom-right
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
    
    // MARK: - Actions
    @objc private func notificationTapped() {
        tabBarController?.selectedIndex = 2
    }
    
    @objc private func profileButtonTapped() {
        tabBarController?.selectedIndex = 4
    }
    
    @objc private func startClubTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ClubFormationViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func addEventTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddEventViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - CollectionView DataSource & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView { return dynamicCategories.count }
        return filteredEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            cell.configure(title: dynamicCategories[indexPath.item], isSelected: indexPath.item == selectedCategoryIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCardCell.identifier, for: indexPath) as! EventCardCell
            let event = filteredEvents[indexPath.item]
            cell.configure(with: event)
            cell.onFavoriteTapped = { [weak self] in
                guard let self = self, let eventID = event.id else { return }
                if CoreDataManager.shared.isFavorite(eventID: eventID) {
                    CoreDataManager.shared.removeFavorite(eventID: eventID)
                } else {
                    CoreDataManager.shared.addFavorite(eventID: eventID)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            let text = dynamicCategories[indexPath.item]
            let width = text.size(withAttributes: [.font: Constants.Fonts.medium(14)]).width + 32
            return CGSize(width: width, height: 40)
        } else {
            let spacing: CGFloat = 12
            let padding: CGFloat = 20
            let width = (collectionView.bounds.width - padding - spacing) / 2
            return CGSize(width: width, height: 260)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategoryIndex = indexPath.item
            categoryCollectionView.reloadData()
            filterByCategory(index: indexPath.item)
        } else {
            let event = filteredEvents[indexPath.item]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { return }
            detailVC.event = event
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - SearchBar Delegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredEvents = allEvents
        } else {
            filteredEvents = allEvents.filter {
                ($0.title ?? "").lowercased().contains(searchText.lowercased()) ||
                ($0.venue ?? "").lowercased().contains(searchText.lowercased()) ||
                ($0.clubName ?? "").lowercased().contains(searchText.lowercased())
            }
        }
        eventsCollectionView.reloadData()
        updateCollectionViewHeight()
    }  
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func loadProfileImage() {
        guard let profile = CoreDataManager.shared.fetchUserProfile(),
              let imageName = profile.profileImageName else {
            // No saved image, show default icon
            if let iconView = profileImageButton.viewWithTag(999) as? UIImageView {
                iconView.image = UIImage(systemName: "person.crop.circle.fill")
                iconView.tintColor = Constants.Colors.primary
            }
            return
        }
        
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(imageName)
        
        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            // Remove the icon and set the actual image
            if let iconView = profileImageButton.viewWithTag(999) as? UIImageView {
                iconView.image = image
                iconView.contentMode = .scaleAspectFill
                iconView.tintColor = nil
            }
        }
    }
    
    private func updateNotificationBadge() {
        let notifications = CoreDataManager.shared.fetchNotifications()
        let hasUnread = notifications.contains { !$0.isRead }
        notificationBadge.isHidden = !hasUnread
    }
    
    @objc private func seeAllTapped() {
        // 1. Reset UI selection
        selectedCategoryIndex = 0
        categoryCollectionView.reloadData()
        
        // 2. Fetch all events
        filteredEvents = CoreDataManager.shared.fetchAllEvents()
        
        // 3. Refresh Data
        eventsCollectionView.reloadData()
        
        // 4. CRITICAL FIX: Update the height constraint so the UI expands to show all events
        updateCollectionViewHeight()
        
        // 5. Scroll to top
        if !filteredEvents.isEmpty {
            eventsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
    }
}
