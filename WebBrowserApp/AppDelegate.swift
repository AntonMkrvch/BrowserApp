//
//  AppDelegate.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 5.05.23.
//

import UIKit

import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    private var appCoordinator: AppCoordinator!
    private let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let _window = UIWindow()
        
        window = _window
        
        let services = ServiceContainerImpl()
        let repos = ContainerImpl(services: services)
        let context = AppContextImpl(container: repos)
        
        appCoordinator = AppCoordinator(window: _window, context: context)
        appCoordinator.start()
            .subscribe()
            .disposed(by: disposeBag)
        
        return true
    }
    
    


}

