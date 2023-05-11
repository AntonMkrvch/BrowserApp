//
//  AppCoordinator.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 7.05.23.
//

import UIKit
import RxSwift

enum AppCoordinatorResult {
    case browser
}

class AppCoordinator: BaseCoordinator<BrowserCoordinationResult> {

    private let window: UIWindow
    private let context: AppContext

    init(window: UIWindow, context: AppContext) {
        self.window = window
        self.context = context
    }

    override func start() -> Observable<BrowserCoordinationResult> {
        let browserCoordinator = BrowserCoordinator(window: window, context: context)
        return coordinate(to: browserCoordinator)
    }
}
