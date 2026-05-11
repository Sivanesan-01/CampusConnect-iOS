//
//  ClubFormationViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit

class ClubFormationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let categories = ["Technology", "Cultural", "Sports", "Business", "Photography", "Music", "Arts"]
    private var selectedCategory = "Technology"
    
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
    
    private lazy var clubImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = Constants.Colors.primary.withAlphaComponent(0.08)
        btn.layer.cornerRadius = 60
        btn.layer.borderWidth = 3
        btn.layer.borderColor = Constants.Colors.primary.withAlphaComponent(0.3).cgColor
        btn.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        btn.tintColor = Constants.Colors.primary
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(pickClubImage), for: .touchUpInside)
        return btn
    }()
    
    private lazy var clubNameField = makeField("Club Name", icon: "person.3.fill")
    private lazy var descriptionView: UITextView = {
        let tv = UITextView()
        tv.font = Constants.Fonts.regular(15)
        tv.textColor = Constants.Colors.textPrimary
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 14
        tv.layer.borderWidth = 1.5
        tv.layer.borderColor = Constants.Colors.divider.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var categoryLabel: UILabel = {
        let l = UILabel()
        l.text = "Category"
        l.font = Constants.Fonts.semiBold(16)
        l.textColor = Constants.Colors.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var createButton: GradientButton = {
        let btn = GradientButton()
        btn.setTitle("Create Club", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Start a Club"
        view.backgroundColor = Constants.Colors.background
        setupUI()
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let descLabel = makeLabel("About Your Club")
        let wrapped = wrapField(clubNameField)
        
        [clubImageButton, wrapped, descLabel, descriptionView,
         categoryLabel, categoryCollectionView, createButton].forEach { contentView.addSubview($0) }
        
        
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
            
            clubImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            clubImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            clubImageButton.widthAnchor.constraint(equalToConstant: 120),
            clubImageButton.heightAnchor.constraint(equalToConstant: 120),
            
            wrapped.topAnchor.constraint(equalTo: clubImageButton.bottomAnchor, constant: 24),
            wrapped.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            wrapped.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descLabel.topAnchor.constraint(equalTo: wrapped.bottomAnchor, constant: 20),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            descriptionView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
            descriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionView.heightAnchor.constraint(equalToConstant: 100),
            
            categoryLabel.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            categoryCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            categoryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 44),
            
            createButton.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 30),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = Constants.Fonts.semiBold(16)
        l.textColor = Constants.Colors.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
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
    
    private func wrapField(_ field: UITextField) -> UIView {
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
    
    @objc private func pickClubImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            clubImageButton.setImage(image, for: .normal)
            clubImageButton.imageView?.contentMode = .scaleAspectFill
            clubImageButton.clipsToBounds = true
        }
    }
    
    @objc private func createTapped() {
        guard let name = clubNameField.text, !name.isEmpty else {
            let alert = UIAlertController(title: "Missing", message: "Please enter a club name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 1. Save the Club (Existing code)
        _ = CoreDataManager.shared.saveClub(
            name: name,
            description: descriptionView.text ?? "",
            category: selectedCategory,
            imageName: "club_\(UUID().uuidString)"
        )
        
        // 2. NEW: Use your existing helper to add the notification
        CoreDataManager.shared.addNotification(
            title: "🎊 New Club: \(name)",
            body: "Your club has been successfully created in the \(selectedCategory) category.",
            type: "club",
            eventID: nil
        )
        
        // 3. Show Success Alert (Existing code)
        let alert = UIAlertController(title: "🎊 Club Created!", message: "\(name) has been created successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }


}

extension ClubFormationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { categories.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        cell.configure(title: categories[indexPath.item], isSelected: categories[indexPath.item] == selectedCategory)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = categories[indexPath.item]
        let width = text.size(withAttributes: [.font: Constants.Fonts.medium(14)]).width + 32
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        collectionView.reloadData()
    }
}
