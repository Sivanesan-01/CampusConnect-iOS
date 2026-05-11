//
//  OTPViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class OTPViewController: UIViewController {
    
    var email: String = ""
    var onVerified: (() -> Void)?
    
    // MARK: - UI
    private lazy var dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.2
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope.badge.fill"))
        iv.tintColor = Constants.Colors.primary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Verify Your Email"
        label.font = Constants.Fonts.bold(22)
        label.textColor = Constants.Colors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.regular(14)
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var otpTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter OTP Code"
        tf.textAlignment = .center
        tf.font = Constants.Fonts.bold(24)
        tf.keyboardType = .numberPad
        tf.backgroundColor = Constants.Colors.background
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 2
        tf.layer.borderColor = Constants.Colors.primary.cgColor
        tf.letterSpacing = 8
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var verifyButton: GradientButton = {
        let btn = GradientButton()
        btn.setTitle("Verify & Continue", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var resendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Resend OTP", for: .normal)
        btn.setTitleColor(Constants.Colors.primary, for: .normal)
        btn.titleLabel?.font = Constants.Fonts.medium(14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = Constants.Colors.textLight
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        descriptionLabel.text = "We've sent a verification email to\n\(email)\n\nFor this demo, tap 'Verify' to continue."
    }
    
    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(cardView)
        
        [iconImageView, titleLabel, descriptionLabel, otpTextField,
         verifyButton, resendButton, closeButton].forEach { cardView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            
            iconImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            iconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            otpTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            otpTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 40),
            otpTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -40),
            otpTextField.heightAnchor.constraint(equalToConstant: 56),
            
            verifyButton.topAnchor.constraint(equalTo: otpTextField.bottomAnchor, constant: 20),
            verifyButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            verifyButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            verifyButton.heightAnchor.constraint(equalToConstant: 52),
            
            resendButton.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 12),
            resendButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            resendButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func verifyTapped() {
        // In production, verify the OTP code here.
        // For demo: just dismiss and proceed
        dismiss(animated: true) { [weak self] in
            self?.onVerified?()
        }
    }
    
    @objc private func resendTapped() {
        AuthManager.shared.resetPassword(email: email) { _, _ in }
        let alert = UIAlertController(title: "Sent!", message: "Verification email resent.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension UITextField {
    var letterSpacing: CGFloat {
        get { return 0 }
        set {
            if let text = self.text {
                let attrString = NSMutableAttributedString(string: text)
                attrString.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: text.count))
                self.attributedText = attrString
            }
        }
    }
}
