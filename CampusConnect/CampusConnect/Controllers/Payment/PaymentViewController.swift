//
//  PaymentViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class PaymentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var event: EventEntity?
    private var cardFormSection: UIView?
    private let months = (1...12).map { String(format: "%02d", $0) }
    private let years = (0...15).map { String(Calendar.current.component(.year, from: Date()) + $0) }
    
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
    
    private lazy var orderSummaryCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var eventTitleLabel: UILabel = {
        let l = UILabel()
        l.font = Constants.Fonts.semiBold(16)
        l.textColor = Constants.Colors.textPrimary
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var amountLabel: UILabel = {
        let l = UILabel()
        l.font = Constants.Fonts.bold(32)
        l.textColor = Constants.Colors.primary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var cardField: UITextField = makePayField("Card Number", icon: "creditcard.fill")
    private lazy var expiryField: UITextField = makePayField("MM / YY", icon: "calendar")
    private lazy var cvvField: UITextField = {
        let tf = makePayField("CVV", icon: "lock.fill")
        tf.isSecureTextEntry = true
        return tf
    }()
    private lazy var nameField: UITextField = makePayField("Cardholder Name", icon: "person.fill")
    
    private lazy var payButton: GradientButton = {
        let btn = GradientButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var secureLabel: UILabel = {
        let l = UILabel()
        l.text = "🔒 Payments are simulated for demo purposes"
        l.font = Constants.Fonts.regular(12)
        l.textColor = Constants.Colors.textLight
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment"
        view.backgroundColor = Constants.Colors.background
        setupUI()
        configureWithEvent()
        setupKeyboardDismiss()
        setupExpiryPicker()
        cardField.delegate = self
        nameField.delegate = self
        expiryField.delegate = self
        cvvField.delegate = self
    }
    
    private func setupExpiryPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        expiryField.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([done], animated: true)
        expiryField.inputAccessoryView = toolbar
    }
    
    // UIPickerView DataSource/Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 2 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? months.count : years.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? months[row] : years[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let m = months[pickerView.selectedRow(inComponent: 0)]
        let y = years[pickerView.selectedRow(inComponent: 1)]
        expiryField.text = "\(m)/\(y)"
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 1. Create the section
        let cardFormSection = makeCardFormSection()
        
        // 2. Add all views to contentView
        [orderSummaryCard, cardFormSection, payButton, secureLabel].forEach {
            contentView.addSubview($0)
        }
        
        [eventTitleLabel, amountLabel].forEach { orderSummaryCard.addSubview($0) }
        
        NSLayoutConstraint.activate([
            // ScrollView & Content
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Order Summary Card
            orderSummaryCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            orderSummaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            orderSummaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            eventTitleLabel.topAnchor.constraint(equalTo: orderSummaryCard.topAnchor, constant: 16),
            eventTitleLabel.leadingAnchor.constraint(equalTo: orderSummaryCard.leadingAnchor, constant: 16),
            eventTitleLabel.trailingAnchor.constraint(equalTo: orderSummaryCard.trailingAnchor, constant: -16),
            
            amountLabel.topAnchor.constraint(equalTo: eventTitleLabel.bottomAnchor, constant: 8),
            amountLabel.leadingAnchor.constraint(equalTo: orderSummaryCard.leadingAnchor, constant: 16),
            amountLabel.bottomAnchor.constraint(equalTo: orderSummaryCard.bottomAnchor, constant: -16),
            
            // Card Form Section (External Constraints Moved Here)
            cardFormSection.topAnchor.constraint(equalTo: orderSummaryCard.bottomAnchor, constant: 16),
            cardFormSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardFormSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Pay Button
            payButton.topAnchor.constraint(equalTo: cardFormSection.bottomAnchor, constant: 24),
            payButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            payButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Secure Label
            secureLabel.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 12),
            secureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            secureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func makeCardFormSection() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Card Details"
        label.font = Constants.Fonts.bold(18)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let expiryStack = UIStackView(arrangedSubviews: [wrapPayField(expiryField), wrapPayField(cvvField)])
        expiryStack.axis = .horizontal
        expiryStack.distribution = .fillEqually
        expiryStack.spacing = 12
        
        let stack = UIStackView(arrangedSubviews: [label, wrapPayField(nameField), wrapPayField(cardField), expiryStack])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            // Internal constraints ONLY
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func makePayField(_ placeholder: String, icon: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = Constants.Fonts.regular(15)
        tf.textColor = Constants.Colors.textPrimary
        tf.translatesAutoresizingMaskIntoConstraints = false
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = Constants.Colors.textLight
        iconView.contentMode = .scaleAspectFit
        let c = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
        iconView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        c.addSubview(iconView)
        tf.leftView = c
        tf.leftViewMode = .always
        return tf
    }
    
    private func wrapPayField(_ field: UITextField) -> UIView {
        let container = UIView()
        container.backgroundColor = Constants.Colors.background
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1.5
        container.layer.borderColor = Constants.Colors.divider.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        field.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(field)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 48),
            field.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            field.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            field.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }
    
    private func configureWithEvent() {
        guard let event = event else { return }
        eventTitleLabel.text = event.title
        amountLabel.text = "₹\(Int(event.price))"
        payButton.setTitle("Pay ₹\(Int(event.price))", for: .normal)
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    @objc private func payTapped() {
        // 1. Check if user already joined BEFORE processing payment
        guard let event = event, let eventID = event.id else { return }
        
        if CoreDataManager.shared.hasAlreadyParticipated(eventID: eventID) {
            showAlert("Already Registered", "You have already joined this event. One participant per account only.")
            return
        }
        
        // 2. Standard validation check
        guard let card = cardField.text, card.count >= 15,
              let cvv = cvvField.text, cvv.count >= 3 else {
            showAlert("Incomplete", "Please ensure all fields are filled correctly.")
            return
        }
        
        // 3. Start Processing
        payButton.setTitle("Processing...", for: .normal)
        payButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // 4. Save Participation to Core Data
            CoreDataManager.shared.addParticipation(
                eventID: eventID,
                eventTitle: event.title ?? "",
                date: Date()
            )
            
            // 5. Add Notification
            CoreDataManager.shared.addNotification(
                title: "Registration Confirmed!",
                body: "You've successfully joined \(event.title ?? "the event").",
                type: "event",
                eventID: eventID
            )
            
            self.showSuccessScreen()
        }
    }
    
    
    
    private func showSuccessScreen() {
        guard let event = event else { return }
        
        if let id = event.id {
            CoreDataManager.shared.addParticipation(eventID: id, eventTitle: event.title ?? "", date: Date())
        }
        
        let successVC = PaymentSuccessViewController()
        successVC.eventTitle = event.title ?? ""
        successVC.amount = "₹\(Int(event.price))"
        navigationController?.pushViewController(successVC, animated: true)
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func isValidLuhn(_ number: String) -> Bool {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        var sum = 0
        let digitStrings = cleanNumber.reversed().map { String($0) }
        
        for (index, digitString) in digitStrings.enumerated() {
            guard let digit = Int(digitString) else { return false }
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += (doubled > 9) ? (doubled - doubled % 9) : doubled // Simplified check
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
    
}

extension PaymentViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // 1. Force Name first: If trying to enter Card Number, check Name
        if textField == cardField {
            if nameField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
                showAlert("Step Missing", "Please enter the Cardholder Name first.")
                return false
            }
        }
        
        // 2. Check Card before Expiry/CVV
        if textField == expiryField || textField == cvvField {
            let cardNum = cardField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            if !isValidLuhn(cardNum) || cardNum.count < 15 {
                showAlert("Invalid Card", "Please provide a valid card number first.")
                return false
            }
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // CVV: Limit to 4 digits
        if textField == cvvField {
            return updatedText.count <= 4
        }
        
        // CARD NUMBER: Limit to 16 digits and perform IMMEDIATE check
        if textField == cardField {
            if updatedText.count > 16 { return false }
            
            // If they just finished typing 16 digits
            if updatedText.count == 16 {
                if !isValidLuhn(updatedText) {
                    // Immediate failure: Show alert and clear field
                    showAlert("Invalid Card", "The card number entered is invalid. Please retype.")
                    textField.text = ""
                    return false
                }
            }
        }
        return true
    }
}


// MARK: - Payment Success VC
class PaymentSuccessViewController: UIViewController {
    
    var eventTitle = ""
    var amount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        setupSuccessUI()
    }
    
    private func setupSuccessUI() {
        let successIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        successIcon.tintColor = Constants.Colors.success
        successIcon.contentMode = .scaleAspectFit
        successIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Payment Successful!"
        titleLabel.font = Constants.Fonts.bold(26)
        titleLabel.textColor = Constants.Colors.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let amountLabel = UILabel()
        amountLabel.text = amount
        amountLabel.font = Constants.Fonts.bold(40)
        amountLabel.textColor = Constants.Colors.success
        amountLabel.textAlignment = .center
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let eventLabel = UILabel()
        eventLabel.text = "You're registered for \(eventTitle)"
        eventLabel.font = Constants.Fonts.regular(16)
        eventLabel.textColor = Constants.Colors.textSecondary
        eventLabel.textAlignment = .center
        eventLabel.numberOfLines = 2
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = GradientButton()
        doneButton.setTitle("Back to Home", for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [successIcon, titleLabel, amountLabel, eventLabel, doneButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            successIcon.widthAnchor.constraint(equalToConstant: 100),
            successIcon.heightAnchor.constraint(equalToConstant: 100),
            doneButton.widthAnchor.constraint(equalToConstant: 240),
            doneButton.heightAnchor.constraint(equalToConstant: 52),
            
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    @objc private func doneTapped() {
        guard let window = view.window else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBar")
        window.rootViewController = tabBar
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
}
