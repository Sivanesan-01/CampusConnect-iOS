//
//  NotificationCell.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class NotificationCell: UITableViewCell {
    static let identifier = "NotificationCell"
    
    // MARK: - UI Elements
    private lazy var cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var iconContainerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.semiBold(14)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(13)
        label.textColor = Constants.Colors.textSecondary
        label.numberOfLines = 0 // Allow label to grow as much as needed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(11)
        label.textColor = Constants.Colors.textLight
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // A Vertical Stack to manage spacing between labels automatically
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, timeLabel])
        stack.axis = .vertical
        stack.spacing = 4 // Fixed gap between the "sandwiched" elements
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var unreadDot: UIView = {
        let v = UIView()
        v.backgroundColor = Constants.Colors.primary
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Layout
    private func setupUI() {
        contentView.addSubview(cardView)
        
        // Add elements to cardView
        cardView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        cardView.addSubview(textStackView)
        cardView.addSubview(unreadDot)
        
        NSLayoutConstraint.activate([
            // Card Constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Icon Constraints
            iconContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16), // Pin to top
            iconContainerView.widthAnchor.constraint(equalToConstant: 44),
            iconContainerView.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            // Text Stack Constraints (The Fix)
            textStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            textStackView.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: unreadDot.leadingAnchor, constant: -8),
            textStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
            
            // Unread Dot Constraints
            unreadDot.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            unreadDot.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            unreadDot.widthAnchor.constraint(equalToConstant: 10),
            unreadDot.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    // MARK: - Configuration
    func configure(with notification: NotificationEntity) {
        titleLabel.text = notification.title
        bodyLabel.text = notification.body
        unreadDot.isHidden = notification.isRead
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        timeLabel.text = formatter.localizedString(for: notification.createdAt ?? Date(), relativeTo: Date())
        
        // Setup appearance based on type
        switch notification.type {
        case "event":
            iconContainerView.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.15)
            iconImageView.tintColor = Constants.Colors.primary
            iconImageView.image = UIImage(systemName: "calendar.badge.plus")
        case "reminder":
            iconContainerView.backgroundColor = Constants.Colors.accent.withAlphaComponent(0.15)
            iconImageView.tintColor = Constants.Colors.accent
            iconImageView.image = UIImage(systemName: "bell.fill")
        case "club":
            iconContainerView.backgroundColor = Constants.Colors.secondary.withAlphaComponent(0.15)
            iconImageView.tintColor = Constants.Colors.secondary
            iconImageView.image = UIImage(systemName: "person.3.fill")
        default:
            iconContainerView.backgroundColor = Constants.Colors.textLight.withAlphaComponent(0.15)
            iconImageView.tintColor = Constants.Colors.textLight
            iconImageView.image = UIImage(systemName: "info.circle.fill")
        }
    }
}
