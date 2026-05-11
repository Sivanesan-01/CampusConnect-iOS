//
//  EventCardCell.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class EventCardCell: UICollectionViewCell {
    static let identifier = "EventCardCell"
    
    private lazy var cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = Constants.Layout.cardCornerRadius
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var eventImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Constants.Layout.cardCornerRadius
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var gradientOverlay: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var categoryBadge: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.medium(11)
        label.textColor = .white
        label.backgroundColor = Constants.Colors.primary
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.semiBold(12)
        label.textColor = .white
        label.backgroundColor = Constants.Colors.success
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.semiBold(15)
        label.textColor = Constants.Colors.textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var venueLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(12)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.medium(12)
        label.textColor = Constants.Colors.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var participantsLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(11)
        label.textColor = Constants.Colors.textLight
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var onFavoriteTapped: (() -> Void)?
    private var isFavorited = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(eventImageView)
        cardView.addSubview(gradientOverlay)
        cardView.addSubview(categoryBadge)
        cardView.addSubview(priceLabel)
        cardView.addSubview(favoriteButton)
        cardView.addSubview(titleLabel)
        cardView.addSubview(venueLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(participantsLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            eventImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            eventImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            eventImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 150),
            
            gradientOverlay.topAnchor.constraint(equalTo: eventImageView.topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: eventImageView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: eventImageView.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: eventImageView.bottomAnchor),
            
            categoryBadge.topAnchor.constraint(equalTo: eventImageView.topAnchor, constant: 10),
            categoryBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            categoryBadge.heightAnchor.constraint(equalToConstant: 22),
            categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            priceLabel.topAnchor.constraint(equalTo: categoryBadge.bottomAnchor, constant: 6),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            priceLabel.heightAnchor.constraint(equalToConstant: 20),
            priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 45),
            
            favoriteButton.topAnchor.constraint(equalTo: eventImageView.topAnchor, constant: 10),
            favoriteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            venueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            venueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            venueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: venueLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            participantsLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            participantsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            participantsLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientToOverlay()
    }
    
    private func applyGradientToOverlay() {
        gradientOverlay.layer.sublayers?.removeAll()
        let gradient = CAGradientLayer()
        gradient.frame = gradientOverlay.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.3).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay.layer.insertSublayer(gradient, at: 0)
    }
    
    func configure(with event: EventEntity) {
        titleLabel.text = event.title
        venueLabel.text = "📍 \(event.venue ?? "")"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = "📅 \(formatter.string(from: event.date ?? Date()))"
        
        categoryBadge.text = " \(event.clubName ?? "Event") "
        priceLabel.text = event.isPaid ? " ₹\(Int(event.price)) " : " FREE "
        priceLabel.backgroundColor = event.isPaid ? Constants.Colors.accent : Constants.Colors.success
        participantsLabel.text = "\(event.participantCount) joined"
        
        if let imageName = event.imageName {
            eventImageView.image = loadEventImage(imageName: imageName)
        } else {
            eventImageView.image = UIImage(systemName: "photo.fill")
        }
        
        let isFav = CoreDataManager.shared.isFavorite(eventID: event.id ?? UUID())
        updateFavoriteButton(isFav)
    }
    
    private func updateFavoriteButton(_ isFav: Bool) {
        isFavorited = isFav
        let icon = isFav ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: icon), for: .normal)
        favoriteButton.tintColor = isFav ? .systemPink : .white
    }
    
    @objc private func favoriteTapped() {
        onFavoriteTapped?()
        isFavorited.toggle()
        updateFavoriteButton(isFavorited)
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.4, 0.9, 1.1, 1.0]
        animation.duration = 0.4
        favoriteButton.layer.add(animation, forKey: nil)
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
    
    private func loadImageFromDisk(fileName: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image from disk: \(error)")
            return nil
        }
    }
    
}
