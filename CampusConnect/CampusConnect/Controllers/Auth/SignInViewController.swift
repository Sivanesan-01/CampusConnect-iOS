//
//  SignInViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class SignInViewController: UIViewController {
    
    // MARK: - UI Elements
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
    
    private lazy var headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "building.columns.fill")
        iv.tintColor = Constants.Colors.primary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome Back!"
        label.font = Constants.Fonts.bold(28)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to your CampusConnect account"
        label.font = Constants.Fonts.regular(15)
        label.textColor = Constants.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailContainerView: UIView = { makeFieldContainer() }()
    private lazy var emailTextField: UITextField = {
        makeTextField(placeholder: "Email Address", icon: "envelope.fill")
    }()
    
    private lazy var passwordContainerView: UIView = { makeFieldContainer() }()
    private lazy var passwordTextField: UITextField = {
        let tf = makeTextField(placeholder: "Password", icon: "lock.fill")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var showPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        btn.tintColor = Constants.Colors.textLight
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return btn
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(Constants.Colors.primary, for: .normal)
        btn.titleLabel?.font = Constants.Fonts.medium(14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var signInButton: GradientButton = {
        let btn = GradientButton()
        btn.setTitle("Sign In", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var dividerLabel: UILabel = {
        let label = UILabel()
        label.text = "or continue with"
        label.font = Constants.Fonts.regular(14)
        label.textColor = Constants.Colors.textLight
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var googleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Sign in with Google", for: .normal)
        btn.setImage(UIImage(systemName: "globe"), for: .normal)
        btn.tintColor = Constants.Colors.textPrimary
        btn.titleLabel?.font = Constants.Fonts.medium(15)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = Constants.Layout.cornerRadius
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = Constants.Colors.divider.cgColor
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.05
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var signUpStack: UIStackView = {
        let label = UILabel()
        label.text = "Don't have an account? "
        label.font = Constants.Fonts.regular(14)
        label.textColor = Constants.Colors.textSecondary
        
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(Constants.Colors.primary, for: .normal)
        btn.titleLabel?.font = Constants.Fonts.semiBold(14)
        btn.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [label, btn])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [headerImageView, welcomeLabel, subtitleLabel,
         emailContainerView, passwordContainerView,
         forgotPasswordButton, signInButton, dividerLabel,
         googleButton, signUpStack, loadingIndicator].forEach {
            contentView.addSubview($0)
        }
        
        emailContainerView.addSubview(emailTextField)
        passwordContainerView.addSubview(passwordTextField)
        passwordContainerView.addSubview(showPasswordButton)
        
        NSLayoutConstraint.activate([
            // ScrollView fills safe area
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView fills scroll
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header Image
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            headerImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 70),
            headerImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Welcome Label
            welcomeLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Email Container
            emailContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            emailContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            emailTextField.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -16),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            
            // Password Container
            passwordContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 16),
            passwordContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            passwordContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -8),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -16),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            showPasswordButton.widthAnchor.constraint(equalToConstant: 24),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Forgot Password
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 10),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 24),
            signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            signInButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor),
            
            // Divider
            dividerLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 24),
            dividerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Google Button
            googleButton.topAnchor.constraint(equalTo: dividerLabel.bottomAnchor, constant: 16),
            googleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            googleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            googleButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Sign Up Stack
            signUpStack.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 30),
            signUpStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Factory Methods
    private func makeFieldContainer() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = Constants.Layout.cornerRadius
        v.layer.borderWidth = 1.5
        v.layer.borderColor = Constants.Colors.divider.cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.04
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
    
    private func makeTextField(placeholder: String, icon: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = Constants.Fonts.regular(15)
        tf.textColor = Constants.Colors.textPrimary
        tf.keyboardType = placeholder.contains("Email") ? .emailAddress : .default
        tf.autocapitalizationType = .none
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
        if loading {
            signInButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
            signInButton.setEnabled(false)
        } else {
            signInButton.setTitle("Sign In", for: .normal)
            loadingIndicator.stopAnimating()
            signInButton.setEnabled(true)
        }
    }
    
    // MARK: - Keyboard Handling
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
    
    // MARK: - Actions
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let icon = passwordTextField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        showPasswordButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @objc private func signInTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Missing Fields", message: "Please fill in all fields.")
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        setLoading(true)
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                switch result {
                case .success(let user):
                    let name = user.displayName ?? "Student"
                    SessionManager.shared.saveSession(uid: user.uid, email: email, name: name)
                    self?.navigateToHome()
                case .failure(let error):
                    self?.showAlert(title: "Sign In Failed",
                                   message: AuthManager.shared.errorMessage(for: error))
                }
            }
        }
    }
    
    @objc private func googleSignInTapped() {
        showAlert(title: "Google Sign In", message: "Google Sign-In requires SDK setup. Use email/password for now.")
    }
    
    @objc private func forgotPasswordTapped() {
        let alert = UIAlertController(title: "Reset Password",
                                      message: "Enter your email to receive a reset link.",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Email Address"
            tf.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
            AuthManager.shared.resetPassword(email: email) { success, message in
                DispatchQueue.main.async {
                    self?.showAlert(title: success ? "Email Sent" : "Error", message: message)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func signUpTapped() {
        // This uses the arrow identifier "signInToSignUp" defined in your Constants
        performSegue(withIdentifier: Constants.Segues.signInToSignUp, sender: nil)
    }

    
    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as? UITabBarController else { return }
        guard let window = view.window else { return }
        window.rootViewController = tabBar
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
    
    // MARK: - Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
