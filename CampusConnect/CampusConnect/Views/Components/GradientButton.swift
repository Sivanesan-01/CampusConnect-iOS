//
//  GradientButton.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            Constants.Colors.gradientStart.cgColor,
            Constants.Colors.gradientEnd.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = Constants.Layout.cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = Constants.Layout.cornerRadius
        clipsToBounds = true
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Constants.Fonts.semiBold(16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : 0.6
    }
}
