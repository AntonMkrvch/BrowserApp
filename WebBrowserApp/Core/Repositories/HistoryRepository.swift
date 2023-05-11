//
//  HistoryRepository.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 11.05.23.
//

import Foundation
import RxSwift

protocol BrowseHistoryRepository {
    func getBrowseHistory() -> Observable<[BrowserRequestModel]>
    func save(request: BrowserRequestModel)
}

class BrowserHistoryRepositoryImpl: BrowseHistoryRepository {
    
    
    let storageService: StorageService
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func getBrowseHistory() -> RxSwift.Observable<[BrowserRequestModel]> {
        let his = storageService.getHistory()
        return Observable.just(his)
    }
    
    func save(request: BrowserRequestModel) {
        storageService.save(request: request)
    }
    
    
}
