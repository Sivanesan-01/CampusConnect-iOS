import UIKit
import FirebaseCore
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        CoreDataManager.shared.seedSampleDataIfNeeded()
        setupAppearance()
        return true
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = Constants.Colors.primary
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: Constants.Colors.textPrimary,
            .font: Constants.Fonts.semiBold(17)
        ]
        UITabBar.appearance().tintColor = Constants.Colors.primary
        UITabBar.appearance().unselectedItemTintColor = Constants.Colors.textLight
    }
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.CoreData.modelName)
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData error: \(error)") }
        }
        return container
    }()
}
