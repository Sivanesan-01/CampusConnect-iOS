//
//  MapViewController.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    private lazy var mapView: MKMapView = {
        let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }()
    
    private lazy var legendCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "📍 Your Enrolled Event Locations"
        label.font = Constants.Fonts.semiBold(14)
        label.textColor = Constants.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        v.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: v.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -12)
        ])
        return v
    }()
    
    private lazy var directionCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let fromLabel = UILabel()
        fromLabel.text = "From:"
        fromLabel.font = Constants.Fonts.medium(13)
        fromLabel.textColor = Constants.Colors.textSecondary
        
        let fromField = UITextField()
        fromField.text = "SKCET"
        fromField.font = Constants.Fonts.regular(13)
        fromField.textColor = Constants.Colors.textPrimary
        fromField.borderStyle = .none
        fromField.isUserInteractionEnabled = false
        fromField.tag = 100
        
        let toLabel = UILabel()
        toLabel.text = "To:"
        toLabel.font = Constants.Fonts.medium(13)
        toLabel.textColor = Constants.Colors.textSecondary
        
        let toField = UITextField()
        toField.placeholder = "Select event"
        toField.font = Constants.Fonts.regular(13)
        toField.textColor = Constants.Colors.textPrimary
        toField.borderStyle = .none
        toField.tag = 101
        
        let dirBtn = UIButton(type: .system)
        dirBtn.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.circle.fill"), for: .normal)
        dirBtn.tintColor = Constants.Colors.primary
        dirBtn.addTarget(self, action: #selector(getDirectionsTapped), for: .touchUpInside)
        
        stack.addArrangedSubview(fromLabel)
        stack.addArrangedSubview(fromField)
        stack.addArrangedSubview(toLabel)
        stack.addArrangedSubview(toField)
        stack.addArrangedSubview(dirBtn)
        
        v.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: v.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -12),
            fromField.widthAnchor.constraint(equalToConstant: 80),
            toField.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        return v
    }()
    
    private lazy var topBackgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = .white  // ← Changed back to white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private var enrolledEvents: [EventEntity] = []
    private var eventPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        title = "Event Map"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupUI()
        setupHeaderGradient()
        setupEventPicker()
        configureMapView()
        loadEnrolledEventAnnotations()
        // Delayed initialization for iOS 18 simulator fix
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.centerOnCollege()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEnrolledEventAnnotations()
    }
    
    // MARK: - Background Gradient Setup
    private var headerGradientLayer: CAGradientLayer?

    private func setupHeaderGradient() {
        // First, ensure topBackgroundView has a white background
        topBackgroundView.backgroundColor = .white
        
        let gradient = CAGradientLayer()
        
        // Using the same gradient colors from HomeViewController
        gradient.colors = [
            Constants.Colors.gradientStart.withAlphaComponent(0.08).cgColor,
            Constants.Colors.gradientEnd.withAlphaComponent(0.08).cgColor
        ]
        
        // Diagonal gradient
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        // Add gradient ON TOP of the white background
        topBackgroundView.layer.addSublayer(gradient)
        self.headerGradientLayer = gradient
    }

    // Override to update gradient frame when layout changes
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer?.frame = topBackgroundView.bounds
    }
    
    // CRITICAL METHOD: Configure map view properties
    private func configureMapView() {
        mapView.delegate = self
        
        // Force light mode for map
        if #available(iOS 13.0, *) {
            mapView.overrideUserInterfaceStyle = .light
        }
        
        // CRITICAL: Set map type and properties in specific order
        mapView.mapType = .standard
        mapView.showsUserLocation = false
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        
        // iOS 18 Simulator specific fix
        #if targetEnvironment(simulator)
        if #available(iOS 18.0, *) {
            // Force map to re-render by cycling map types
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.mapView.mapType = .hybrid
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.mapView.mapType = .standard
                }
            }
        }
        #endif
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(topBackgroundView)     // ← Add this
        view.addSubview(legendCard)
        view.addSubview(directionCard)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // White background behind cards
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBackgroundView.bottomAnchor.constraint(equalTo: directionCard.bottomAnchor, constant: 8),
            
            legendCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            legendCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            legendCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            directionCard.topAnchor.constraint(equalTo: legendCard.bottomAnchor, constant: 12),
            directionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            directionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupEventPicker() {
        eventPicker.delegate = self
        eventPicker.dataSource = self
        
        if let toField = directionCard.viewWithTag(101) as? UITextField {
            toField.inputView = eventPicker
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
            toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneBtn], animated: false)
            toField.inputAccessoryView = toolbar
        }
    }
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    private func centerOnCollege() {
        let coordinate = CLLocationCoordinate2D(latitude: 11.0168, longitude: 76.9558)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: true)
    }
    
    private func loadEnrolledEventAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        let participations = CoreDataManager.shared.fetchParticipations()
        let participatedIDs = participations.compactMap { $0.eventID }
        
        let allEvents = CoreDataManager.shared.fetchAllEvents()
        enrolledEvents = allEvents.filter { event in
            guard let id = event.id else { return false }
            return participatedIDs.contains(id)
        }
        
        for event in enrolledEvents {
            let annotation = EventAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
            annotation.title = event.title
            annotation.subtitle = event.venue
            annotation.event = event
            mapView.addAnnotation(annotation)
        }
        
        if enrolledEvents.isEmpty {
            showEmptyState()
        }
    }
    
    private func showEmptyState() {
        let alert = UIAlertController(title: "No Enrolled Events", message: "Register for events to see them on the map!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is EventAnnotation else { return nil }
        
        let identifier = "EventPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            view?.annotation = annotation
        }
        
        view?.markerTintColor = Constants.Colors.primary
        view?.glyphImage = UIImage(systemName: "calendar.badge.plus")
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? EventAnnotation,
              let event = annotation.event else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { return }
        detailVC.event = event
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func getDirectionsTapped() {
        guard let toField = directionCard.viewWithTag(101) as? UITextField,
              let eventTitle = toField.text, !eventTitle.isEmpty,
              let selectedEvent = enrolledEvents.first(where: { $0.title == eventTitle }) else {
            let alert = UIAlertController(title: "Select Event", message: "Please select an event destination", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        mapView.removeOverlays(mapView.overlays)
        
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 11.0168, longitude: 76.9558))
        let destPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selectedEvent.latitude, longitude: selectedEvent.longitude))
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let route = response?.routes.first else {
                let alert = UIAlertController(title: "Route Not Found", message: "Unable to calculate route", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
                return
            }
            
            self?.mapView.addOverlay(route.polyline)
            self?.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 50, bottom: 80, right: 50), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = Constants.Colors.primary
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enrolledEvents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return enrolledEvents[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let toField = directionCard.viewWithTag(101) as? UITextField {
            toField.text = enrolledEvents[row].title
        }
    }
}

class EventAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = .init()
    var title: String?
    var subtitle: String?
    var event: EventEntity?
}
