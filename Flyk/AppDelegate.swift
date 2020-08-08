//
//  AppDelegate.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let defaults = UserDefaults.standard //THIS IS NSUSERDEFAULTS
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String //APP-VERSION
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        self.isFirstLaunch()
        
        return true
    }
    
    
    var currentUserAccount: NSManagedObject!
    
    
    func isFirstLaunch() {
//        if defaults.bool(forKey: "FirstLaunch") == true {
//            print("Second+")
//            return;
//        }else{
//            print("First")
//            //            defaults.set(true, forKey: "FirstLaunch")
//            //Send request to init new account
//            //Request cookie
//        }
        let context = persistentContainer.viewContext
        
        let getAccountRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
        getAccountRequest.returnsObjectsAsFaults = false
        do {
            let accountList: [NSManagedObject] = try context.fetch(getAccountRequest) as! [NSManagedObject]
            
            //IF ACCOUNT DNE THEN WE INSERT ONE
            if accountList.count == 0 {
                let accountEntity = NSEntityDescription.entity(forEntityName: "Accounts", in: context)
                let newAccount = NSManagedObject(entity: accountEntity!, insertInto: context)
                
                newAccount.setValue(false, forKey: "signed_in")
                newAccount.setValue("", forKey: "cookie_value")
                
                self.currentUserAccount = newAccount
                
                do {
                    try context.save()
                } catch {
                    print("Failed Saving First Account To Core Data")
                    return;
                }
            }else{
                self.currentUserAccount = accountList[0]
            }
        } catch let err {
            print("Failed fetching saved videos", err)
        }
    }
    
    func triggerSignInIfNoAccount(customMessgae: String?) -> Bool{
        // check if user has account
        // retrun true
        if self.currentUserAccount.value(forKey: "signed_in") as! Bool == false {
            let rootView = UIApplication.shared.windows.first?.rootViewController
            let signInNav = SignInNavController()
            signInNav.transitioningDelegate = signInNav
            signInNav.modalPresentationStyle = .custom
            signInNav.signInRootViewController.customMessage = customMessgae
            rootView?.present(signInNav, animated: true, completion: {})
            return false
        }
        return true
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
        FileManager.default.clearTmpDirectory()
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlykContainer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}


/* FILE MANAGER CLEAR TMP DIRECTORY METHOD */
extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
