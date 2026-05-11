import UIKit

class EventDetailViewController: UIViewController {
    
    var event: EventEntity?
    
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
    
    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.15)
        iv.image = UIImage(systemName: "photo.fill")
        iv.tintColor = Constants.Colors.primary.withAlphaComponent(0.3)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var gradientView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        btn.layer.cornerRadius = 22
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.bold(24)
        label.textColor = Constants.Colors.textPrimary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var clubBadge: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.medium(12)
        label.textColor = Constants.Colors.primary
        label.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.1)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var participantsLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(14)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About Event"
        label.font = Constants.Fonts.bold(18)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(15)
        label.textColor = Constants.Colors.textSecondary
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = "Schedule"
        label.font = Constants.Fonts.bold(18)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleCard: UIView = makeScheduleCard()
    
    private lazy var participateButton: GradientButton = {
        let btn = GradientButton()
        btn.setTitle("Participate Now", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(participateTapped), for: .touchUpInside)
        return btn
    }()
    
    private var isFavorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = ""
        setupUI()
        configureWithEvent()
        setupBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradient()
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left.circle.fill"),
                                        style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [bannerImageView, gradientView, favoriteButton, cardView].forEach { contentView.addSubview($0) }
        [titleLabel, clubBadge, infoStackView, participantsLabel,
         aboutLabel, descriptionLabel, scheduleLabel, scheduleCard, participateButton].forEach { cardView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            bannerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 280),
            
            gradientView.topAnchor.constraint(equalTo: bannerImageView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: bannerImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            
            cardView.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: -30),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            clubBadge.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            clubBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            clubBadge.heightAnchor.constraint(equalToConstant: 24),
            
            infoStackView.topAnchor.constraint(equalTo: clubBadge.bottomAnchor, constant: 16),
            infoStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            participantsLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 12),
            participantsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            
            aboutLabel.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 24),
            aboutLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            scheduleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            scheduleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            
            scheduleCard.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 12),
            scheduleCard.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            scheduleCard.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            participateButton.topAnchor.constraint(equalTo: scheduleCard.bottomAnchor, constant: 24),
            participateButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            participateButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            participateButton.heightAnchor.constraint(equalToConstant: 56),
            participateButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30)
        ])
    }
    
    private func applyGradient() {
        gradientView.layer.sublayers?.removeAll()
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradientView.layer.addSublayer(gradient)
    }
    
    private func makeScheduleCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Constants.Colors.background
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let items: [(String, String)] = [
            ("calendar", "Registration Open"),
            ("clock", "Event Duration: 4-6 Hours"),
            ("person.2.fill", "Open to All Departments")
        ]
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        for item in items {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12
            row.alignment = .center
            
            let icon = UIImageView(image: UIImage(systemName: item.0))
            icon.tintColor = Constants.Colors.primary
            icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            let label = UILabel()
            label.text = item.1
            label.font = Constants.Fonts.regular(14)
            label.textColor = Constants.Colors.textSecondary
            
            row.addArrangedSubview(icon)
            row.addArrangedSubview(label)
            stack.addArrangedSubview(row)
        }
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func loadEventImage(imageName: String) -> UIImage? {
        if let assetImage = UIImage(named: imageName) {
            return assetImage
        }
        
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(imageName)
        
        if let imageData = try? Data(contentsOf: fileURL),
           let diskImage = UIImage(data: imageData) {
            return diskImage
        }
        
        return UIImage(systemName: "photo.fill")
    }
    
    private func configureWithEvent() {
        guard let event = event else { return }
        
        if let imageName = event.imageName {
            bannerImageView.image = loadEventImage(imageName: imageName)
        }
        
        titleLabel.text = event.title
        clubBadge.text = "  \(event.clubName ?? "Club")  "
        descriptionLabel.text = event.about
        participantsLabel.text = "👥 \(event.participantCount) students participating"
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let infoItems: [(String, String)] = [
            ("mappin.circle.fill", event.venue ?? ""),
            ("calendar.circle.fill", formattedDate(event.date)),
            ("clock.fill", formattedTime(event.date)),
            ("indianrupeesign.circle.fill", event.isPaid ? "₹\(Int(event.price))" : "Free Entry")
        ]
        
        for item in infoItems {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .center
            
            let icon = UIImageView(image: UIImage(systemName: item.0))
            icon.tintColor = Constants.Colors.primary
            icon.contentMode = .scaleAspectFit
            icon.widthAnchor.constraint(equalToConstant: 22).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            let label = UILabel()
            label.text = item.1
            label.font = Constants.Fonts.medium(14)
            label.textColor = Constants.Colors.textPrimary
            
            row.addArrangedSubview(icon)
            row.addArrangedSubview(label)
            infoStackView.addArrangedSubview(row)
        }
        
        if let id = event.id {
            isFavorite = CoreDataManager.shared.isFavorite(eventID: id)
            updateFavoriteButton()
            
            if CoreDataManager.shared.hasAlreadyParticipated(eventID: id) {
                participateButton.setTitle("✓ Registered", for: .normal)
                participateButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
                participateButton.setTitleColor(.white, for: .normal)
                participateButton.layer.borderWidth = 0
                participateButton.isEnabled = false
            } else {
                let paidTitle = event.isPaid ? "Pay & Participate — ₹\(Int(event.price))" : "Participate Now — FREE"
                participateButton.setTitle(paidTitle, for: .normal)
                
                participateButton.backgroundColor = Constants.Colors.primary
                participateButton.setTitleColor(.white, for: .normal)
                participateButton.layer.borderWidth = 0
                participateButton.isEnabled = true
            }
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM dd, yyyy"
        return fmt.string(from: date)
    }
    
    private func formattedTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: date)
    }
    
    private func updateFavoriteButton() {
        let icon = isFavorite ? "heart.fill" : "heart"
        let color: UIColor = isFavorite ? .systemPink : .white
        favoriteButton.setImage(UIImage(systemName: icon), for: .normal)
        favoriteButton.tintColor = color
    }
    
    @objc private func favoriteTapped() {
        guard let id = event?.id else { return }
        if isFavorite {
            CoreDataManager.shared.removeFavorite(eventID: id)
        } else {
            CoreDataManager.shared.addFavorite(eventID: id)
        }
        isFavorite.toggle()
        updateFavoriteButton()
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.5, 0.9, 1.1, 1.0]
        animation.duration = 0.4
        favoriteButton.layer.add(animation, forKey: nil)
    }
    
    @objc private func participateTapped() {
        guard let event = event else { return }
        
        if event.isPaid {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController else { return }
            paymentVC.event = event
            navigationController?.pushViewController(paymentVC, animated: true)
        } else {
            registerForEvent()
        }
    }
    
    func registerForEvent() {
        guard let event = event, let id = event.id else { return }
        
        CoreDataManager.shared.addParticipation(
            eventID: id,
            eventTitle: event.title ?? "",
            date: Date()
        )
        
        CoreDataManager.shared.addNotification(
            title: "Registration Confirmed! 🎉",
            body: "You've successfully joined \(event.title ?? "the event").",
            type: "event",
            eventID: id
        )
        
        let alert = UIAlertController(
            title: "🎉 Registered!",
            message: "You've successfully registered for \(event.title ?? "this event").",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
