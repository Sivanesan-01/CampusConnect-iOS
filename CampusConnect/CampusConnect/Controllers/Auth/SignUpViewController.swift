//
//  SignUpViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private lazy var collegeField: UITextField = makeTextField("College Name", icon: "building.fill")
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        let text = "Already have an account? Login"
        let attributedString = NSMutableAttributedString(string: text)
        if let range = text.range(of: "Login") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.foregroundColor, value: Constants.Colors.primary, range: nsRange)
            attributedString.addAttribute(.font, value: Constants.Fonts.bold(14), range: nsRange)
        }
        
        label.attributedText = attributedString
        label.font = Constants.Fonts.regular(14)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
        label.addGestureRecognizer(tap)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    private lazy var titleLabel: UILabel = makeLabel("Create Account", font: Constants.Fonts.bold(28))
    private lazy var subtitleLabel: UILabel = makeLabel("Join the campus community today", font: Constants.Fonts.regular(15), color: Constants.Colors.textSecondary)
    
    private lazy var nameField: UITextField = makeTextField("Full Name", icon: "person.fill")
    private lazy var emailField: UITextField = {
        let tf = makeTextField("Email Address", icon: "envelope.fill")
        tf.keyboardType = .emailAddress
        return tf
    }()
    private lazy var phoneField: UITextField = {
        let tf = makeTextField("Phone Number", icon: "phone.fill")
        tf.keyboardType = .phonePad
        return tf
    }()
    private lazy var departmentField: UITextField = makeTextField("Department", icon: "graduationcap.fill")
    private lazy var passwordField: UITextField = {
        let tf = makeTextField("Password", icon: "lock.fill")
        tf.isSecureTextEntry = true
        return tf
    }()
    private lazy var confirmPasswordField: UITextField = {
        let tf = makeTextField("Confirm Password", icon: "lock.shield.fill")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var createAccountButton: GradientButton = {
        let btn = GradientButton()
        btn.setTitle("Create Account", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "By signing up, you agree to our Terms & Privacy Policy"
        label.font = Constants.Fonts.regular(12)
        label.textColor = Constants.Colors.textLight
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var pendingEmail: String = ""
    var pendingPassword: String = ""
    var pendingName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.background
        title = "Sign Up"
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let fields = [nameField, emailField, phoneField, collegeField, departmentField, passwordField, confirmPasswordField]
        let containers = fields.map { wrapInContainer($0) }
        
        let stackView = UIStackView(arrangedSubviews: containers)
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, subtitleLabel, stackView, createAccountButton, loadingIndicator, termsLabel, loginLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            createAccountButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            createAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            createAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            createAccountButton.heightAnchor.constraint(equalToConstant: 56),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: createAccountButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: createAccountButton.centerYAnchor),
            
            termsLabel.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 16),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
           //termsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
    
            loginLabel.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 20),
            loginLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            loginLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            loginLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func wrapInContainer(_ textField: UITextField) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = Constants.Layout.cornerRadius
        container.layer.borderWidth = 1.5
        container.layer.borderColor = Constants.Colors.divider.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.04
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textField)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 56),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }
    
    private func makeLabel(_ text: String, font: UIFont, color: UIColor = Constants.Colors.textPrimary) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeTextField(_ placeholder: String, icon: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = Constants.Fonts.regular(15)
        tf.textColor = Constants.Colors.textPrimary
        tf.autocapitalizationType = .words
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = Constants.Colors.textLight
        iconView.contentMode = .scaleAspectFit
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
        iconView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        container.addSubview(iconView)
        tf.leftView = container
        tf.leftViewMode = .always
        return tf
    }
    
    private func setLoading(_ loading: Bool) {
        createAccountButton.setEnabled(!loading)
        loading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        createAccountButton.setTitle(loading ? "" : "Create Account", for: .normal)
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = keyboardSize.height + 20
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    @objc private func createAccountTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let college = collegeField.text, !college.isEmpty,
              let department = departmentField.text, !department.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirm = confirmPasswordField.text, !confirm.isEmpty else {
            showAlert("Missing Fields", "Please fill in all fields.")
            return
        }
        
        guard password == confirm else {
            showAlert("Password Mismatch", "Passwords do not match.")
            return
        }
        
        guard password.count >= 6 else {
            showAlert("Weak Password", "Password must be at least 6 characters.")
            return
        }
        
        pendingEmail = email
        pendingPassword = password
        pendingName = name
        
        setLoading(true)
        AuthManager.shared.signUp(email: email, password: password, name: name) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                switch result {
                case .success(let user):
                    // 2. Update this call to include the college name
                    CoreDataManager.shared.saveUserProfile(
                        name: name,
                        email: email,
                        phone: phone,
                        department: department,
                        college: college,
                        year: "Add your year of study",
                        skills: "Add your skills"
                    )
                    
                    SessionManager.shared.saveSession(uid: user.uid, email: email, name: name)
                    self?.showOTPPopup()
                    
                case .failure(let error):
                    self?.showAlert("Sign Up Failed", AuthManager.shared.errorMessage(for: error))
                }
            }
        }
    }
    
    private func showOTPPopup() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        guard let otpVC = storyboard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController else { return }
        otpVC.email = pendingEmail
        otpVC.modalPresentationStyle = .overCurrentContext
        otpVC.modalTransitionStyle = .crossDissolve
        otpVC.onVerified = { [weak self] in
            self?.navigateToHome()
        }
        present(otpVC, animated: true)
    }
    
    @objc private func loginTapped() {
        // This takes the user back to the Sign In screen
        self.navigationController?.popViewController(animated: true)
    }
    
    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as? UITabBarController else { return }
        guard let window = view.window else { return }
        window.rootViewController = tabBar
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
