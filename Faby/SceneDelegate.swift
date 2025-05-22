//
//  SceneDelegate.swift
//  Faby
//
//  Created by Batch - 1 on 13/01/25.
//

import UIKit
import Supabase
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create a new UIWindow using the windowScene constructor
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Display a loading view initially while we check authentication
        let loadingVC = UIViewController()
        loadingVC.view.backgroundColor = .systemBackground
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingVC.view.center
        activityIndicator.startAnimating()
        loadingVC.view.addSubview(activityIndicator)
        window.rootViewController = loadingVC
        window.makeKeyAndVisible()
        
        // Check authentication state asynchronously
        Task {
            // Attempt to restore session from persistent storage
            await AuthManager.shared.restoreSession()
            
            // Check if user is logged in after session restore attempt
            await MainActor.run {
                // Decide which screen to show based on authentication state
                if AuthManager.shared.isUserLoggedIn {
                    print("✅ SceneDelegate: User is logged in, showing main app")
                    // User is logged in, go to main app
                    setupMainAppUI(window: window)
                } else {
                    print("👋 SceneDelegate: User is not logged in, showing walkthrough")
                    // User is not logged in, show walkthrough
                    let walkthrough = WalkthroughViewController()
                    UIView.transition(with: window, 
                                      duration: 0.3, 
                                      options: .transitionCrossDissolve, 
                                      animations: { window.rootViewController = walkthrough },
                                      completion: nil)
                }
            }
        }
    }
    
    // Helper method to set up the main app UI
    func setupMainAppUI(window: UIWindow) {
        // Load the Main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Load the tab bar controller from the storyboard
        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            window.rootViewController = mainTabBarController
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    let tabBarController = UITabBarController()

   


}

