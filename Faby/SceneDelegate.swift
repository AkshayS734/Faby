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
        
        // Check for existing session and determine the initial view controller
        Task {
            // Try to restore session if one exists
            let sessionRestored = await UserSessionManager.shared.restoreSession()
            
            await MainActor.run {
                // Determine the initial view controller based on session state
                let initialViewController: UIViewController
                
                // Check if onboarding has been completed
                let onboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
                
                if !onboardingComplete {
                    // If onboarding not completed, show walkthrough first
                    initialViewController = WalkthroughViewController()
                } else if sessionRestored {
                    // If session restored, get the appropriate view controller based on signup stage
                    initialViewController = UserSessionManager.shared.getAppropriateViewController()
                    print("DEBUG: Restored session with stage: \(UserSessionManager.shared.currentSignupStage.rawValue)")
                } else {
                    // Default to walkthrough if no session or onboarding not complete
                    initialViewController = WalkthroughViewController()
                }
                
                // Set the root view controller and make window visible
                window.rootViewController = initialViewController
                self.window = window
                window.makeKeyAndVisible()
            }
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

