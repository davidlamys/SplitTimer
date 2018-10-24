//
//  UIViewController+Extension.swift
//  SplitTimer
//
//  Created by David Lam on 22/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import UIKit

extension UIViewController {
    static func make<T>(viewController: T.Type) -> T where T: UIViewController {
        let viewControllerName = String(describing: viewController)
        let storyboard = UIStoryboard(name: viewControllerName, bundle: Bundle(for: viewController))

        guard let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerName) as? T else {
            fatalError("Unable to create ViewController: \(viewControllerName) from storyboard: \(storyboard)")
        }
        return viewController
    }
}
