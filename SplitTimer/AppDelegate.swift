//
//  AppDelegate.swift
//  SplitTimer
//
//  Created by David Lam on 21/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import SwiftUI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        addSwiftUIView()
        return true
    }

    func addSwiftUIView() {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
        let view = SwiftUISplitTimer()
        let timerViewController = UIHostingController(rootView: view)
        timerViewController.tabBarItem = UITabBarItem(title: "SwiftUI", image: nil, selectedImage: nil)
        tabBarController.viewControllers?.append(timerViewController)
    }

}
