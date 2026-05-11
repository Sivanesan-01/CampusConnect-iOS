//
//  MyClubCell.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 10/05/26.
//

import UIKit

class MyClubCell: UITableViewCell {
    static let identifier = "MyClubCell"
    
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
    
    private lazy var clubIconView: UIView = {
        let v = UIView()
        v.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var clubIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.3.fill")
        iv.tintColor = Constants.Colors.primary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var clubNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.semiBold(16)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var eventCountLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(13)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chevronIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = Constants.Colors.textLight
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        clubIconView.addSubview(clubIcon)
        [clubIconView, clubNameLabel, eventCountLabel, chevronIcon].forEach { cardView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            clubIconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            clubIconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            clubIconView.widthAnchor.constraint(equalToConstant: 56),
            clubIconView.heightAnchor.constraint(equalToConstant: 56),
            
            clubIcon.centerXAnchor.constraint(equalTo: clubIconView.centerXAnchor),
            clubIcon.centerYAnchor.constraint(equalTo: clubIconView.centerYAnchor),
            clubIcon.widthAnchor.constraint(equalToConstant: 28),
            clubIcon.heightAnchor.constraint(equalToConstant: 28),
            
            clubNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            clubNameLabel.leadingAnchor.constraint(equalTo: clubIconView.trailingAnchor, constant: 14),
            clubNameLabel.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -8),
            
            eventCountLabel.topAnchor.constraint(equalTo: clubNameLabel.bottomAnchor, constant: 4),
            eventCountLabel.leadingAnchor.constraint(equalTo: clubNameLabel.leadingAnchor),
            eventCountLabel.trailingAnchor.constraint(equalTo: clubNameLabel.trailingAnchor),
            
            chevronIcon.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronIcon.widthAnchor.constraint(equalToConstant: 12),
            chevronIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(clubName: String, eventCount: Int) {
        clubNameLabel.text = clubName
        eventCountLabel.text = "\(eventCount) event\(eventCount == 1 ? "" : "s")"
    }
}
