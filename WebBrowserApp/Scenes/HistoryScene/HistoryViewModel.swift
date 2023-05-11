//
//  HistoryViewModel.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 8.05.23.
//

import Foundation
import RxSwift

protocol HistoryViewModelInputsType {
    
    func viewDidLoad()
    
    var cancel: AnyObserver<Void> { get }
    
    var selectItem: AnyObserver<BrowserRequestModel> { get }
    
    var search: AnyObserver<String?> { get }
}

protocol HistoryViewModelOutputsType {
    
    var cancelled: Observable<Void> { get }
    
    var itemSelected: Observable<BrowserRequestModel> { get }
    
    var historyItems: [BrowserRequestModel] { get }
    
    var reloadItems: Observable<Void> { get }
}


class HistoryViewModel: HistoryViewModelInputsType, HistoryViewModelOutputsType {
    
    // MARK: - Private properies
    
    private let context: AppContext
    private let disposeBag = DisposeBag()
    
    private var _historyData = BehaviorSubject<[BrowserRequestModel]>(value: [])
    private var _selectedItem = PublishSubject<BrowserRequestModel>()
    private var _searchString = BehaviorSubject<String?>(value: nil)
    private var _cancell = PublishSubject<Void>()
    private var _reloadData = PublishSubject<Void>()
    
    
    // MARK: - Initializers
    
    init(with context: AppContext) {
        self.context = context
        self.setupBindings()
        self.fetchHistory()
    }
    
    // MARK: - Input
    
    var cancel: AnyObserver<Void> { _cancell.asObserver() }
    
    var selectItem: AnyObserver<BrowserRequestModel> { _selectedItem.asObserver() }
    
    var search: AnyObserver<String?> { _searchString.asObserver() }
    
    func viewDidLoad() {
        
    }
    
    // MARK: - Output
    
    var cancelled: Observable<Void> { _cancell.asObservable() }
    
    var itemSelected: Observable<BrowserRequestModel> { _selectedItem.asObservable() }
    
    var historyItems: [BrowserRequestModel] = []
    
    var reloadItems: Observable<Void> { _reloadData.asObservable() }
    
    // MARK: Private funcs
    
    private var itemsToShow: Observable<[BrowserRequestModel]> {
        Observable.combineLatest(_historyData.asObservable(), _searchString.asObservable())
            .map { historyData, searchString in
                let orderedData = historyData.sorted { $0.date < $1.date}
                if let searchString, !searchString.isEmpty {
                    return orderedData.filter { $0.address.absoluteString.contains(searchString) }
                } else {
                    return orderedData
                }
            }
    }
    
    private func setupBindings() {
        itemsToShow.subscribe(onNext: { [weak self] items in
            self?.historyItems = items
            self?._reloadData.onNext(Void())
        })
        .disposed(by: disposeBag)
    }
    
    private func fetchHistory() {
        context.container.historyRepository.getBrowseHistory()
            .subscribe(onNext: { [weak self] in self?._historyData.on(.next($0))})
            .disposed(by: disposeBag)
    }
    
    
}


