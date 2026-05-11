//
//  ProfileViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var userProfile: UserEntity?
    
    private lazy var scrollView: UIScrollView = {
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
    
    private lazy var headerGradientView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var editImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        btn.tintColor = Constants.Colors.primary
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(editProfileImage), for: .touchUpInside)
        return btn
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.bold(22)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(14)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statsStack: UIStackView = {
        let ev = makeStatView("Events", value: "0")
        let fav = makeStatView("Favorites", value: "0")
        let clubs = makeStatView("Clubs", value: "0")
        
        // We keep the dividers but use .fillProportionally for better spacing logic
        let stack = UIStackView(arrangedSubviews: [ev, makeDivider(), fav, makeDivider(), clubs])
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.backgroundColor = .white
        
        // Styling
        stack.layer.cornerRadius = 20
        stack.layer.shadowColor = UIColor.black.cgColor
        stack.layer.shadowOpacity = 0.08
        stack.layer.shadowOffset = CGSize(width: 0, height: 4)
        stack.layer.shadowRadius = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    private lazy var infoCard: UIView = makeCard()
    private lazy var editButton: GradientButton = {
        let btn = GradientButton()
        btn.setTitle("Edit Profile", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log Out", for: .normal)
        btn.setTitleColor(Constants.Colors.danger, for: .normal)
        btn.titleLabel?.font = Constants.Fonts.semiBold(16)
        btn.backgroundColor = Constants.Colors.danger.withAlphaComponent(0.08)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = Constants.Colors.danger.withAlphaComponent(0.3).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        
        // 1. Comment out this original line:
        // view.backgroundColor = Constants.Colors.background
        
        // 2. Add this line:
        setupGradientBackground()
        
        setupUI()
        loadProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyHeaderGradient()
        
        // Add this new line here:
        backgroundGradientLayer?.frame = view.bounds
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [headerGradientView, profileImageView, editImageButton,
         nameLabel, emailLabel, statsStack, infoCard, editButton, logoutButton].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerGradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerGradientView.heightAnchor.constraint(equalToConstant: 200),
            
            profileImageView.topAnchor.constraint(equalTo: headerGradientView.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            editImageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            editImageButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            editImageButton.widthAnchor.constraint(equalToConstant: 28),
            editImageButton.heightAnchor.constraint(equalToConstant: 28),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: headerGradientView.bottomAnchor, constant: -16),
            
            statsStack.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 25),
            statsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsStack.heightAnchor.constraint(equalToConstant: 80),
            
            infoCard.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 20),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            editButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 20),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 14),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        let eventTap = UITapGestureRecognizer(target: self, action: #selector(eventsTapped))
        statsStack.arrangedSubviews[0].isUserInteractionEnabled = true
        statsStack.arrangedSubviews[0].addGestureRecognizer(eventTap)
        
        let favTap = UITapGestureRecognizer(target: self, action: #selector(favoritesTapped))
        statsStack.arrangedSubviews[2].isUserInteractionEnabled = true
        statsStack.arrangedSubviews[2].addGestureRecognizer(favTap)
        
        let clubTap = UITapGestureRecognizer(target: self, action: #selector(clubsTapped))
        statsStack.arrangedSubviews[4].isUserInteractionEnabled = true
        statsStack.arrangedSubviews[4].addGestureRecognizer(clubTap)
        
    }
    
    private func applyHeaderGradient() {
        headerGradientView.layer.sublayers?.removeAll()
        let gradient = CAGradientLayer()
        gradient.frame = headerGradientView.bounds
        gradient.colors = [Constants.Colors.gradientStart.cgColor, Constants.Colors.gradientEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        headerGradientView.layer.insertSublayer(gradient, at: 0)
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
        
        // Insert at 0 so it stays behind everything
        view.layer.insertSublayer(gradient, at: 0)
        self.backgroundGradientLayer = gradient
    }
    
    private func loadProfile() {
        let profile = CoreDataManager.shared.fetchUserProfile()
        self.userProfile = profile
        
        nameLabel.text = profile?.name ?? SessionManager.shared.userName
        emailLabel.text = profile?.email ?? SessionManager.shared.userEmail
        
        let eventCount = CoreDataManager.shared.fetchParticipations().count
        let favCount = CoreDataManager.shared.fetchFavoriteEvents().count
        let clubCount = CoreDataManager.shared.getJoinedClubs().count  // CHANGED THIS LINE
        
        if let statsSubviews = statsStack.arrangedSubviews as? [UIView] {
            updateStatView(statsSubviews[0], value: "\(eventCount)")
            updateStatView(statsSubviews[2], value: "\(favCount)")
            updateStatView(statsSubviews[4], value: "\(clubCount)")
        }
        updateInfoCard()
        
        // NEW: Load saved profile image
        if let imageName = profile?.profileImageName {
            loadProfileImage(imageName: imageName)
        }
    }
    
    
    private func updateStatView(_ view: UIView, value: String) {
        if let stack = view as? UIStackView,
           let valueLabel = stack.arrangedSubviews.first(where: { ($0 as? UILabel)?.font == Constants.Fonts.bold(20) }) as? UILabel {
            valueLabel.text = value
        }
    }
    
    private func makeStatView(_ title: String, value: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Constants.Fonts.bold(20)
        valueLabel.textColor = Constants.Colors.textPrimary
        valueLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Constants.Fonts.regular(12)
        titleLabel.textColor = Constants.Colors.textSecondary
        titleLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }
    
    
    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Colors.divider
        v.widthAnchor.constraint(equalToConstant: 1).isActive = true
        v.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return v
    }
    
    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 10
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let collegeDisplay = (userProfile?.college == nil || userProfile?.college == "") ? "Sri Krishna College of Engineering and Technology" : userProfile!.college!
        
        let skillsValue = userProfile?.skills ?? "Add your skills"
        let skillsDisplay = (userProfile?.skills == nil || userProfile?.skills == "") ? skillsValue : "Skills - \(skillsValue)"
        
        let items: [(String, String)] = [
            ("graduationcap.fill", userProfile?.department ?? "Add your Department"),
            ("building.fill", collegeDisplay),
            ("star.fill", userProfile?.year ?? "Add current Year of Study"),
            ("person.fill", userProfile?.name ?? SessionManager.shared.userName),
            ("bolt.fill", skillsDisplay)
        ]
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for item in items {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12
            row.alignment = .center
            
            let iconBG = UIView()
            iconBG.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.1)
            iconBG.layer.cornerRadius = 18
            iconBG.widthAnchor.constraint(equalToConstant: 36).isActive = true
            iconBG.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            let icon = UIImageView(image: UIImage(systemName: item.0))
            icon.tintColor = Constants.Colors.primary
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            iconBG.addSubview(icon)
            
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: iconBG.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: iconBG.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 18),
                icon.heightAnchor.constraint(equalToConstant: 18)
            ])
            
            let label = UILabel()
            label.text = item.1
            label.font = Constants.Fonts.regular(14)
            label.textColor = Constants.Colors.textPrimary
            label.numberOfLines = 0 // Changed to 0 to support long skill lists
            
            row.addArrangedSubview(iconBG)
            row.addArrangedSubview(label)
            stack.addArrangedSubview(row)
        }
        
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }
    
    @objc private func eventsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MyEventsViewController") as? MyEventsViewController {
            vc.title = "My Registered Events"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func favoritesTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as? FavoritesViewController {
            vc.title = "My Favorites"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func clubsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MyClubsViewController") as? MyClubsViewController {
            vc.title = "My Clubs"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func updateInfoCard() {
        infoCard.removeFromSuperview()
        editButton.removeFromSuperview()
        logoutButton.removeFromSuperview()
        
        infoCard = makeCard()
        contentView.addSubview(infoCard)
        contentView.addSubview(editButton)
        contentView.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            infoCard.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 20),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            editButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 20),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 52),
            
            logoutButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 14),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 52),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    
    
    @objc private func editProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            let imageName = "profile_\(UUID().uuidString).jpg"
            saveProfileImageToDisk(image: image, fileName: imageName)
            profileImageView.image = image
            let profile = userProfile ?? CoreDataManager.shared.fetchUserProfile()
            CoreDataManager.shared.saveUserProfile(
                name: profile?.name ?? SessionManager.shared.userName,
                email: profile?.email ?? SessionManager.shared.userEmail,
                phone: profile?.phone ?? "",
                department: profile?.department ?? "",
                college: profile?.college ?? "Sri Krishna College of Engineering and Technology",
                year: profile?.year ?? "",
                skills: profile?.skills ?? "",
                profileImageName: imageName
            )
            self.userProfile = CoreDataManager.shared.fetchUserProfile()
        }
    }
    
    @objc private func editProfileTapped() {
        showEditDialog()
    }
    
    
    private func saveProfileImageToDisk(image: UIImage, fileName: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(fileName)
        try? data.write(to: fileURL)
    }
    
    private func loadProfileImage(imageName: String) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(imageName)
        
        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
    }
    
    private func showEditDialog() {
        let alert = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .alert)
        
        alert.addTextField { tf in tf.placeholder = "Full Name" }
        alert.addTextField { tf in tf.placeholder = "Department" }
        alert.addTextField { tf in tf.placeholder = "Year (e.g. 3rd Year)" }
        alert.addTextField { tf in tf.placeholder = "Skills (comma-separated)" }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let fields = alert.textFields else { return }
            
            let name = (fields[0].text?.isEmpty ?? true) ? (self?.userProfile?.name ?? "") : fields[0].text!
            let dept = (fields[1].text?.isEmpty ?? true) ? (self?.userProfile?.department ?? "") : fields[1].text!
            let year = (fields[2].text?.isEmpty ?? true) ? (self?.userProfile?.year ?? "") : fields[2].text!
            let skills = (fields[3].text?.isEmpty ?? true) ? (self?.userProfile?.skills ?? "") : fields[3].text!
            
            let currentCollege = (self?.userProfile?.college == nil || self?.userProfile?.college == "") ? "Sri Krishna College of Engineering and Technology" : self!.userProfile!.college!
            let currentPhone = self?.userProfile?.phone ?? ""
            let currentImageName = self?.userProfile?.profileImageName  // NEW: Preserve image
            
            CoreDataManager.shared.saveUserProfile(
                name: name,
                email: SessionManager.shared.userEmail,
                phone: currentPhone,
                department: dept,
                college: currentCollege,
                year: year,
                skills: skills,
                profileImageName: currentImageName  // NEW: Pass existing image name
            )
            
            self?.loadProfile()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            AuthManager.shared.signOut { _ in
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                    let nav = storyboard.instantiateViewController(withIdentifier: "SignInNav")
                    guard let window = self?.view.window else { return }
                    window.rootViewController = nav
                    UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
