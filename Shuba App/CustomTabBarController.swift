//
//  MainNavigationController.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 20/05/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit
import Firebase

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup our custom view controllers
        let mapsController = MapsController()
        let recentNavController = UINavigationController(rootViewController: mapsController)
        recentNavController.tabBarItem.title = "Maps"
        recentNavController.tabBarItem.image = UIImage(named: "maps3")
        
        let nearByController = NearByStopsController()
        let nearbyNavController = UINavigationController(rootViewController: nearByController)
        nearbyNavController.tabBarItem.title = "Nearby-Stops"
        nearbyNavController.tabBarItem.image = UIImage(named: "nearbystops")
        
        let crowdController = CrowdController(collectionViewLayout:UICollectionViewFlowLayout())
        let nextNavController = UINavigationController(rootViewController: crowdController)
        nextNavController.tabBarItem.title = "Crowd"
        nextNavController.tabBarItem.image = UIImage(named: "chats")
        
        let accountsController = AccountViewController()
        let accountNavController = UINavigationController(rootViewController: accountsController)
        accountNavController.tabBarItem.title = "Account"
        accountNavController.tabBarItem.image = UIImage(named: "account")
       
        
        let settingController = SettingController()
        let settingNavController = UINavigationController(rootViewController: settingController)
        settingNavController.tabBarItem.title = "Settings"
        settingNavController.tabBarItem.image = UIImage(named: "settings")
        
        let signOutController = SignOutController()
        let signOutNavController = UINavigationController(rootViewController: signOutController)
        signOutNavController.tabBarItem.title = "SignOut"
        signOutNavController.tabBarItem.image = UIImage(named: "signout")
  
        viewControllers = [recentNavController, nearbyNavController, nextNavController, accountNavController, settingNavController, signOutNavController]
       
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}
