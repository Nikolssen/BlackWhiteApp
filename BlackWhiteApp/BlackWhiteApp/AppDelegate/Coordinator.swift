//
//  Coordinator.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/15/24.
//
import UIKit

final class Coordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func activate() {
        let rootViewController = tabBarController
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    private var tabBarController: UITabBarController? {
        let controller = UITabBarController()
        controller.viewControllers = [photoEffectController, settingsController]
        return controller
    }
    
    private var photoEffectController: UIViewController {
        let controller = UINavigationController(rootViewController: PhotoEffect.ViewController())
        controller.tabBarItem.image = UIImage(systemName: "photo")
        return controller
    }
    
    private var settingsController: UIViewController {
        let controller = UINavigationController(rootViewController: Settings.ViewController())
        controller.tabBarItem.image = UIImage(systemName: "gearshape")
        return controller
    }
}
