//
//  AddEventViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class AddEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    private let generalClubs = ["TechClub", "CulturalClub", "SportsClub", "BizClub", "PhotoClub", "Other (Type Name)"]
    private lazy var clubPicker = UIPickerView()
    private var priceFieldContainer: UIView?
    
    private var selectedLatitude: Double = 10.9394
    private var selectedLongitude: Double = 76.9540
    private lazy var locationPicker = UIPickerView()
    
    private let coimbatoreLocations: [(name: String, lat: Double, lon: Double)] = [
        ("SKCE&T Campus", 10.9394, 76.9540),
        ("Coimbatore Railway Station", 10.9964, 76.9672),
        ("Gandhipuram Central Bus Stand", 11.0182, 76.9657),
        ("Brookefields Mall", 11.0084, 76.9598),
        ("Prozone Mall", 11.0552, 76.9939),
        ("Fun Republic Mall", 11.0261, 77.0030),
        ("VOC Park", 11.0032, 76.9680),
        ("Gedee Car Museum", 11.0042, 76.9740),
        ("Kovai Kondattam", 10.9575, 76.8967),
        ("TNAU Campus", 11.0135, 76.9355),
        ("Coimbatore Institute of Technology", 11.0280, 77.0278),
        ("PSG College of Technology", 11.0247, 77.0028),
        ("Amrita Vishwa Vidyapeetham", 10.9000, 76.8973),
        ("Race Course", 11.0016, 76.9760),
        ("Singanallur Lake", 10.9859, 77.0229),
        ("Valankulam Lake", 10.9904, 76.9691),
        ("Codissia Trade Fair Complex", 11.0346, 77.0268),
        ("Nehru Stadium", 11.0019, 76.9667),
        ("RS Puram Market", 11.0104, 76.9492),
        ("Saibaba Temple", 11.0279, 76.9442)
    ]
    
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
    
    private lazy var imagePickerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = Constants.Colors.background
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 2
        btn.layer.borderColor = Constants.Colors.divider.cgColor
        
        btn.setTitle("Tap to add event image", for: .normal)
        btn.setTitleColor(Constants.Colors.textLight, for: .normal)
        btn.titleLabel?.font = Constants.Fonts.medium(14)
        btn.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        btn.tintColor = Constants.Colors.textLight
        btn.configuration = .plain()
        btn.configuration?.imagePadding = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        return btn
    }()
    
    private lazy var titleField: UITextField = makeField("Event Title", icon: "pencil")
    private lazy var venueField: UITextField = makeField("Venue / Location", icon: "mappin.circle.fill")
    private lazy var clubField: UITextField = makeField("Club Name", icon: "person.3.fill")
    private lazy var descriptionField: UITextField = makeField("Event Description", icon: "text.alignleft")
    
    private lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.minimumDate = Date()
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let tp = UIDatePicker()
        tp.datePickerMode = .time
        tp.preferredDatePickerStyle = .compact
        tp.translatesAutoresizingMaskIntoConstraints = false
        return tp
    }()
    
    private lazy var isPaidSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = Constants.Colors.primary
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(self, action: #selector(paidToggled), for: .valueChanged)
        return sw
    }()
    
    private lazy var priceField: UITextField = {
        let tf = makeField("Price (₹)", icon: "indianrupeesign.circle.fill")
        tf.keyboardType = .numberPad
        tf.isHidden = true
        return tf
    }()
    
    private lazy var publishButton: GradientButton = {
        let btn = GradientButton()
        btn.setTitle("Publish Event", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(publishTapped), for: .touchUpInside)
        return btn
    }()
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Event"
        view.backgroundColor = Constants.Colors.background
        navigationController?.navigationBar.prefersLargeTitles = false
        setupUI()
        setupKeyboardDismiss()
        setupVenueField()
        setupClubField()
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0
        timePicker.date = calendar.date(from: components) ?? Date()
        
        clubField.delegate = self
    }
    
    private func setupVenueField() {
        locationPicker.delegate = self
        locationPicker.dataSource = self
        locationPicker.tag = 1000 // Tag to identify location picker
        venueField.inputView = locationPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneBtn], animated: false)
        venueField.inputAccessoryView = toolbar
    }
    
    private func setupClubField() {
        clubPicker.delegate = self
        clubPicker.dataSource = self
        clubPicker.tag = 2000 // Tag to identify club picker
        clubField.inputView = clubPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneBtn], animated: false)
        clubField.inputAccessoryView = toolbar
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let dateRow = makeRowStack(label: "Date", rightView: datePicker)
        let timeRow = makeRowStack(label: "Time", rightView: timePicker)
        let paidRow = makeRowStack(label: "Paid Event", rightView: isPaidSwitch)
        
        let fields: [UIView] = [titleField, venueField, clubField, descriptionField]
        let fieldContainers = fields.map { wrapField($0) }
        
        priceFieldContainer = wrapField(priceField)
        priceFieldContainer?.isHidden = true
        priceField.keyboardType = .decimalPad
        priceField.isUserInteractionEnabled = true
        
        let mainStack = UIStackView(arrangedSubviews: fieldContainers + [priceFieldContainer!, dateRow, timeRow, paidRow])
        mainStack.axis = .vertical
        mainStack.spacing = 14
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        [imagePickerButton, mainStack, publishButton].forEach { contentView.addSubview($0) }
        
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
            
            imagePickerButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imagePickerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imagePickerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 160),
            
            mainStack.topAnchor.constraint(equalTo: imagePickerButton.bottomAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            publishButton.topAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: 24),
            publishButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            publishButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            publishButton.heightAnchor.constraint(equalToConstant: 56),
            publishButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func makeField(_ placeholder: String, icon: String) -> UITextField {
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
    
    private func wrapField(_ field: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 1.5
        container.layer.borderColor = Constants.Colors.divider.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        field.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(field)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            field.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            field.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            field.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }
    
    private func makeRowStack(label text: String, rightView: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 1.5
        container.layer.borderColor = Constants.Colors.divider.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = Constants.Fonts.medium(15)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(rightView)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            rightView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    @objc private func dismissPicker() { view.endEditing(true) }
    
    @objc private func pickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let edited = info[.editedImage] as? UIImage {
            selectedImage = edited
            imagePickerButton.setImage(edited, for: .normal)
            imagePickerButton.setTitle("", for: .normal)
            imagePickerButton.imageView?.contentMode = .scaleAspectFill
            imagePickerButton.clipsToBounds = true
        }
    }
    
    @objc private func paidToggled() {
        let isPaid = isPaidSwitch.isOn
        priceFieldContainer?.isHidden = !isPaid
        priceField.isHidden = !isPaid
        
        if isPaid {
            priceField.becomeFirstResponder()
        } else {
            priceField.text = ""
            view.endEditing(true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == clubField {
            if textField.text?.isEmpty ?? true || generalClubs.contains(textField.text ?? "") {
                clubField.inputView = clubPicker
            } else {
                clubField.inputView = nil
            }
            clubField.reloadInputViews()
        }
    }
    
    private func saveImageToDisk(image: UIImage, fileName: String) {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        try? data.write(to: fileURL)
    }
    
    @objc private func publishTapped() {
        guard let title = titleField.text, !title.isEmpty,
              let venue = venueField.text, !venue.isEmpty,
              let club = clubField.text, !club.isEmpty else {
            let alert = UIAlertController(title: "Missing Fields", message: "Please fill in title, venue, and club name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let priceText = priceField.text?.replacingOccurrences(of: "₹", with: "").trimmingCharacters(in: .whitespaces) ?? "0"
        let priceValue = isPaidSwitch.isOn ? (Double(priceText) ?? 0.0) : 0.0
        
        let date = datePicker.date
        let description = descriptionField.text ?? "Join us for this amazing event!"
        
        let uniqueImageName = "event_image_\(UUID().uuidString).jpg"
        
        if let imageToSave = selectedImage {
            saveImageToDisk(image: imageToSave, fileName: uniqueImageName)
        }
        
        _ = CoreDataManager.shared.saveEvent(
            title: title,
            venue: venue,
            date: date,
            about: description,
            imageName: uniqueImageName,
            isPaid: isPaidSwitch.isOn,
            price: isPaidSwitch.isOn ? priceValue : 0.0,
            latitude: selectedLatitude,
            longitude: selectedLongitude,
            clubName: club
        )
        
        CoreDataManager.shared.addNotification(
            title: "New Event Added!",
            body: "\(title) has been published. Check it out!",
            type: "event",
            eventID: nil
        )
        
        let alert = UIAlertController(title: "🎉 Published!", message: "\(title) is now live.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension AddEventViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1000 {
            // Location picker
            return coimbatoreLocations.count
        } else {
            // Club picker
            return generalClubs.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1000 {
            return coimbatoreLocations[row].name
        } else {
            return generalClubs[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1000 {
            // Location picker selected
            let location = coimbatoreLocations[row]
            venueField.text = location.name
            selectedLatitude = location.lat
            selectedLongitude = location.lon
        } else {
            // Club picker selected
            let selection = generalClubs[row]
            if selection == "Other (Type Name)" {
                clubField.text = ""
                clubField.inputView = nil
                clubField.reloadInputViews()
                clubField.becomeFirstResponder()
            } else {
                clubField.text = selection
                clubField.inputView = clubPicker
                view.endEditing(true)
            }
        }
    }
}
