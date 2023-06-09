//
//  AppDelegate.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 30.05.2023.
//

import SDWebImage
import SDWebImageSVGCoder
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    override init() {
        super.init()
            setUpDependencies() // Initialize SVGCoder
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

// Initialize SVGCoder
private extension AppDelegate {
    
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
