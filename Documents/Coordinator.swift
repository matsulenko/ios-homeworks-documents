//
//  Coordinator.swift
//  Documents
//
//  Created by Matsulenko on 06.09.2023.
//

import Foundation
import KeychainSwift
import UIKit

final class Coordinator {
    
    lazy var mrootViewController: UIViewController = UINavigationController()
    
    func start() -> UIViewController {
        mrootViewController = LoginViewController()
        
        return mrootViewController
    }
    
    func openFileManager() {
        
        self.view.window!.rootViewController = UINavigationController(rootViewController: FileManagerViewController(coordinator: self))
    }
}
