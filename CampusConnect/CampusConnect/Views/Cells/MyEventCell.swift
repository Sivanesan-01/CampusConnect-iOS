//
//  MyEventCell.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 10/05/26.
//

import UIKit

class MyEventCell: UITableViewCell {
    static let identifier = "MyEventCell"

    private lazy var cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var eventImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.1)
        iv.image = UIImage(systemName: "photo.fill")
        iv.tintColor = Constants.Colors.primary.withAlphaComponent(0.4)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        label.font = Constants.Fonts.regular(13)
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

    private lazy var registeredBadge: UILabel = {
        let label = UILabel()
        label.text = "✓ Registered"
        label.font = Constants.Fonts.semiBold(11)
        label.textColor = .white
        label.backgroundColor = Constants.Colors.success
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(cardView)
        [eventImageView, titleLabel, venueLabel, dateLabel, registeredBadge].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            eventImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            eventImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            eventImageView.widthAnchor.constraint(equalToConstant: 72),
            eventImageView.heightAnchor.constraint(equalToConstant: 72),

            registeredBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            registeredBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            registeredBadge.widthAnchor.constraint(equalToConstant: 90),
            registeredBadge.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: registeredBadge.leadingAnchor, constant: -8),

            venueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            venueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            venueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: venueLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }

    func configure(with event: EventEntity) {
        titleLabel.text = event.title
        venueLabel.text = "📍 \(event.venue ?? "")"

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = "📅 \(formatter.string(from: event.date ?? Date()))"

        if let imageName = event.imageName {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent(imageName)
            if let imageData = try? Data(contentsOf: fileURL) {
                eventImageView.image = UIImage(data: imageData)
            } else {
                eventImageView.image = UIImage(named: imageName) ?? UIImage(systemName: "photo.fill")
            }
        }
    }
}
