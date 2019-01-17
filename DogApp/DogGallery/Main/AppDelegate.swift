//
//  AppDelegate.swift
//  DogApp
//
//  Created by Wilfred Anorma on 25/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let presenter = DogGalleryPresenter()
        let networkManager = DogGalleryNetworkLayer()
        let interactor = DogGalleryInteractor(presenter:presenter, networkManager: networkManager)
        
        let viewController = DogGalleryViewController(interactor: interactor)
        presenter.view = viewController
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationViewController
        
        return true
    }
}
