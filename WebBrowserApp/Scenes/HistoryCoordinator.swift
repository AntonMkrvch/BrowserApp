//
//  HistoryCoordinator.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 7.05.23.
//

import UIKit
import RxSwift

enum HistoryListCoordinationResult {
    case page(URL)
    case cancel
}

class HistoryListCoordinator: BaseCoordinator<HistoryListCoordinationResult> {
    
    private let rootViewController: UIViewController
    private let context: AppContext
    
    init(rootViewController: UIViewController, context: AppContext) {
        self.rootViewController = rootViewController
        self.context = context
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = HistoryViewModel(with: context)
        let viewController = HistoryViewController.initFromStoryboard(name: "HistoryViewController")
        let navigationController = UINavigationController(rootViewController: viewController)
        
        viewController.viewModel = viewModel
        
        let cancel = viewModel.cancelled.map { _ in CoordinationResult.cancel }
        let language = viewModel.itemSelected.map { CoordinationResult.page($0.address) }
        
        rootViewController.present(navigationController, animated: true)
        
        return Observable.merge(cancel, language)
            .take(1)
            .do(onNext: { [weak self] _ in self?.rootViewController.dismiss(animated: true) })
        }
    
}
