//
//  AppDelegate.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 30.05.2023.
//

import CoreData
import SDWebImage
import SDWebImageSVGCoder
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: - persistent config
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StocksModel")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Не удалось загрузить хранилище Core Data: \(error)")
            }
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
        return container
    }()
    
    //MARK: - Initialize SVGCoder
    override init() {
        super.init()
            setUpDependencies()
        }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
}

//MARK: - Initialize SVGCoder
private extension AppDelegate {
    
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
