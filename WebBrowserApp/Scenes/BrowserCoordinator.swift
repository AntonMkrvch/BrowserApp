//
//  BrowserCoordinator.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 6.05.23.
//


import UIKit
import RxSwift

enum BrowserCoordinationResult {
    case page(String)
    case history
}

class BrowserCoordinator: BaseCoordinator<BrowserCoordinationResult> {

    private let window: UIWindow
    private let context: AppContext

    init(window: UIWindow, context: AppContext) {
        self.window = window
        self.context = context
    }

    override func start() -> Observable<BrowserCoordinationResult> {
        let viewModel = BrowserViewModel(with: context)
        let viewController = BrowserViewController.initFromStoryboard(name: "BrowserViewController")
        let navigationController = UINavigationController(rootViewController: viewController)

        viewController.viewModel = viewModel

        viewModel.showHistory
            .flatMap { [weak self] in self!.showHistory(on: navigationController).compactMap { $0 } }
            .bind(to: viewModel.openPageFromHistory)
            .disposed(by: disposeBag)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return Observable.never()
    }

    private func showHistory(on rootViewController: UIViewController) -> Observable<URL?> {
        let historyListCoordinator = HistoryListCoordinator(rootViewController: rootViewController, context: context)
        return coordinate(to: historyListCoordinator)
            .map { result in
                switch result {
                case .page(let url):
                    return url
                case .cancel:
                    return nil
                }
            }
    }
}
