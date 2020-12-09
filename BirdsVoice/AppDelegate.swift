//
//  AppDelegate.swift
//  BirdsVoice
//
//  Created by Zaini on 02/12/2020.
//

import UIKit
import CoreData
import AVFoundation
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        IQKeyboardManager.shared.enable = true
        AVAudioSession().requestRecordPermission() { [unowned self] _ in}
        return true
    }

    lazy var persistant : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Birds")
        container.loadPersistentStores { (storeData, error) in
            if let error = error{
                fatalError("no data found")
            }
        }
        return container
    }()


}

