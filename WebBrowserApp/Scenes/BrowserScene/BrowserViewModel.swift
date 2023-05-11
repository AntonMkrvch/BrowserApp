//
//  BrowserViewModel.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 7.05.23.
//

import Foundation
import RxSwift

protocol BrowserViewModelInputsType {

    func viewDidLoad()
    
    var openHistory: AnyObserver<Void> { get }
    
    var manualRequestAddress: AnyObserver<String> { get }
    
    var reload: AnyObserver<Void> { get }
    
    var pageLoaded: AnyObserver<URL> { get }
    
}

protocol BrowserViewModelOutputsType {
    
    var showHistory: Observable<Void> { get }
    
    var urlValue: Observable<URL> { get }
}


class BrowserViewModel: BrowserViewModelInputsType, BrowserViewModelOutputsType {
    
    // MARK: - Private properies
    
    private let context: AppContext
    private let disposeBag = DisposeBag()
    
    private let _openHistory = PublishSubject<Void>()
    private let _reload = PublishSubject<Void>()
    private let _pageLoaded = PublishSubject<URL>()
    private let _openHistoryPage = PublishSubject<URL>()
    private let _currentPage = BehaviorSubject<String>(value: "")
    
    private let _showHistory = PublishSubject<Void>()
    private let _link = BehaviorSubject<URL?>(value: nil)
    
    // MARK: - Initializers
    
    init(with context: AppContext) {
        self.context = context
        self.setupBindings()
    }
    
    // MARK: - Input

    func viewDidLoad() { }
    var openHistory: AnyObserver<Void> { _openHistory.asObserver() }
    var reload: AnyObserver<Void> { _reload.asObserver() }
    var pageLoaded: AnyObserver<URL> { _pageLoaded.asObserver() }
    var manualRequestAddress: AnyObserver<String> { _currentPage.asObserver() }
    var openPageFromHistory: AnyObserver<URL> { _openHistoryPage.asObserver() }
    
    // MARK: - Output
    
    var showHistory: Observable<Void> { _openHistory.asObservable() }
    
    var urlValue: Observable<URL> {
        let manuallyEntered = _currentPage
            .asObservable()
            .map { [weak self] in
                self?.toURL(text: $0)
            }
            .compactMap { $0 }
        
        return Observable.merge(manuallyEntered, _openHistoryPage)
    }
    
    //MARK: Private funcs
    
    private func setupBindings() {
        _pageLoaded.subscribe(onNext: { [weak self] url in
            guard let self else { return }
            self.context.container.historyRepository
                .save(request: BrowserRequestModel(address: url,
                                                   date: Date()))
        })
        .disposed(by: disposeBag)

    }
    
    private func toURL(text: String) -> URL? {
        if text.isEmpty { return nil }
        if text.canOpenUrl() {
            return URL(string: text)
        }
        let allowedCharacters = NSCharacterSet.urlFragmentAllowed
        guard let encodedSearchString = text.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        let queryString = "https://www.google.com/search?q=\(encodedSearchString)"
        if let queryURL = URL(string: queryString) { return  queryURL } else { return nil }
    }
    
}

extension String {
    func canOpenUrl() -> Bool {
        guard let url = URL(string: self), UIApplication.shared.canOpenURL(url) else { return false }
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: self)
    }
}
