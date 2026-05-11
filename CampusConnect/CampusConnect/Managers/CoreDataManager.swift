//
//  CoreDataManager.swift
//  CampusConnect
//
//  Created by Sivanesan Sivakumar on 08/05/26.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func save() {
        if context.hasChanges {
            do { try context.save() }
            catch { print("CoreData save error: \(error)") }
        }
    }
    
    // MARK: - Events
    func saveEvent(title: String, venue: String, date: Date, about: String,
                   imageName: String, isPaid: Bool, price: Double, latitude: Double,
                   longitude: Double, clubName: String) -> EventEntity {
        let event = EventEntity(context: context)
        event.id = UUID()
        event.title = title
        event.venue = venue
        event.date = date
        event.about = about
        event.imageName = imageName
        event.isPaid = isPaid
        event.price = price
        event.latitude = latitude
        event.longitude = longitude
        event.clubName = clubName
        event.participantCount = 0
        event.createdAt = Date()
        save()
        return event
    }
    
    func fetchAllEvents() -> [EventEntity] {
        let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sort]
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchEvents(for category: String) -> [EventEntity] {
        let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        request.predicate = NSPredicate(format: "clubName == %@", category)
        return (try? context.fetch(request)) ?? []
    }
    
    func deleteEvent(_ event: EventEntity) {
        context.delete(event)
        save()
    }
    
    // MARK: - Favorites
    func addFavorite(eventID: UUID) {
        if !isFavorite(eventID: eventID) {
            let fav = FavoriteEntity(context: context)
            fav.eventID = eventID
            fav.savedAt = Date()
            save()
        }
    }
    
    func removeFavorite(eventID: UUID) {
        let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@", eventID as CVarArg)
        if let fav = try? context.fetch(request).first {
            context.delete(fav)
            save()
        }
    }
    
    func isFavorite(eventID: UUID) -> Bool {
        let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@", eventID as CVarArg)
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    func fetchFavoriteEvents() -> [EventEntity] {
        let favRequest: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        let favs = (try? context.fetch(favRequest)) ?? []
        let ids = favs.compactMap { $0.eventID }
        let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Participation
    func addParticipation(eventID: UUID, eventTitle: String, date: Date) {
        // 1. BLOCK double entry
        guard !hasAlreadyParticipated(eventID: eventID) else {
            print("User already joined")
            return
        }
        
        // 2. Create the record
        let participation = ParticipationEntity(context: context)
        participation.eventID = eventID
        participation.eventTitle = eventTitle
        participation.participatedAt = date
        save()
        
        // 3. Increment the count on the actual Event
        let req: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", eventID as CVarArg)
        
        if let event = try? context.fetch(req).first {
            event.participantCount += 1
            save()
        }
    }
    
    
    func fetchParticipations() -> [ParticipationEntity] {
        let request: NSFetchRequest<ParticipationEntity> = ParticipationEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "participatedAt", ascending: false)
        request.sortDescriptors = [sort]
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Clubs
    func saveClub(name: String, description: String, category: String, imageName: String) -> ClubEntity {
        let club = ClubEntity(context: context)
        club.id = UUID()
        club.name = name
        club.clubDescription = description
        club.category = category
        club.imageName = imageName
        club.createdAt = Date()
        save()
        return club
    }
    
    func fetchAllClubs() -> [ClubEntity] {
        let request: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Club Membership Tracking
    func getJoinedClubs() -> [String] {
        var clubNames = Set<String>()
        
        // 1. Get clubs the user created
        let createdClubs = fetchAllClubs().compactMap { $0.name }
        clubNames.formUnion(createdClubs)
        
        // 2. Get clubs from events the user registered for
        let participations = fetchParticipations()
        let participationEventIDs = participations.compactMap { $0.eventID }
        
        let eventRequest: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        eventRequest.predicate = NSPredicate(format: "id IN %@", participationEventIDs)
        
        if let registeredEvents = try? context.fetch(eventRequest) {
            let clubsFromEvents = registeredEvents.compactMap { $0.clubName }
            clubNames.formUnion(clubsFromEvents)
        }
        
        // 3. Remove empty strings and return sorted array
        return Array(clubNames).filter { !$0.isEmpty }.sorted()
    }
    
    func fetchEvents(forClubName clubName: String) -> [EventEntity] {
        let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        request.predicate = NSPredicate(format: "clubName == %@", clubName)
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Notifications
    func addNotification(title: String, body: String, type: String, eventID: UUID?) {
        let notification = NotificationEntity(context: context)
        notification.id = UUID()
        notification.title = title
        notification.body = body
        notification.type = type
        notification.eventID = eventID
        notification.createdAt = Date()
        notification.isRead = false
        save()
    }
    
    func fetchNotifications() -> [NotificationEntity] {
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sort]
        return (try? context.fetch(request)) ?? []
    }
    
    func markNotificationRead(_ notification: NotificationEntity) {
        notification.isRead = true
        save()
    }
    
    // MARK: - User Profile
    func saveUserProfile(name: String, email: String, phone: String, department: String,
                         college: String, year: String, skills: String, profileImageName: String? = nil) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        let existing = (try? context.fetch(request))?.first
        let user = existing ?? UserEntity(context: context)
        
        user.name = name
        user.email = email
        user.phone = phone
        user.department = department
        user.college = college
        user.year = year
        user.skills = skills
        
        if let imageName = profileImageName {
            user.profileImageName = imageName
        }
        
        save()
    }
    
    func fetchUserProfile() -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        return (try? context.fetch(request))?.first
    }
    
    // MARK: - Seed Sample Data
    func seedSampleDataIfNeeded() {
        let existing = fetchAllEvents()
        guard existing.isEmpty else { return }
        
        // Using actual Coimbatore locations matching the location picker
        let sampleEvents: [(String, String, String, Bool, Double, String, Double, Double, String)] = [
            ("Tech Symposium 2025", "SKCE&T Campus", "Join us for a day of innovation and tech talks.", false, 0, "TechClub", 10.9394, 76.9540, "Tech"),
            ("Cultural Fiesta", "Fun Republic Mall", "A vibrant celebration of arts and culture.", true, 50, "CulturalClub", 11.0261, 77.0030, "Cultural"),
            ("Hackathon 24H", "Codissia Trade Fair Complex", "Build, innovate and win exciting prizes.", true, 100, "TechClub", 11.0346, 77.0268, "Hack"),
            ("Photography Workshop", "VOC Park", "Learn the art of photography from experts.", true, 150, "PhotoClub", 11.0032, 76.9680, "Photo"),
            ("Entrepreneurship Summit", "Brookefields Mall", "Connect with startup founders and investors.", false, 0, "BizClub", 11.0084, 76.9598, "Summit"),
            ("Sports Day 2025", "Nehru Stadium", "Annual inter-department sports competition.", false, 0, "SportsClub", 11.0019, 76.9667, "Sports")
        ]
        
        let calendar = Calendar.current
        for (i, sample) in sampleEvents.enumerated() {
            let date = calendar.date(byAdding: .day, value: i + 3, to: Date()) ?? Date()
            _ = saveEvent(
                title: sample.0,
                venue: sample.1,
                date: date,
                about: sample.2,
                imageName: sample.8,  // Using the actual image name from assets
                isPaid: sample.3,
                price: sample.4,
                latitude: sample.6,   // Real latitude from location picker
                longitude: sample.7,  // Real longitude from location picker
                clubName: sample.5
            )
        }
        
        addNotification(title: "New Event Added!", body: "Tech Symposium 2025 is now live. Register now!", type: "event", eventID: nil)
        addNotification(title: "Hackathon Reminder", body: "Hackathon starts in 2 days. Prepare your team!", type: "reminder", eventID: nil)
        addNotification(title: "Club Update", body: "TechClub has posted new updates.", type: "club", eventID: nil)
    }
    
    func hasAlreadyParticipated(eventID: UUID) -> Bool {
        let request: NSFetchRequest<ParticipationEntity> = ParticipationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@", eventID as CVarArg)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
}
