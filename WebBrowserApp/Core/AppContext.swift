//
//  AppContext.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 8.05.23.
//

import Foundation
import RxSwift

protocol AppContext {
    var container: RepositoryContainer { get }
}

protocol ServiceContainer {
    var dataStorageService: StorageService { get }
}

protocol RepositoryContainer {
    var historyRepository: BrowseHistoryRepository { get }
}


class AppContextImpl: AppContext {
    let container: RepositoryContainer
    
    init(container: RepositoryContainer) {
        self.container = container
    }
}

class ContainerImpl: RepositoryContainer {
    
    var historyRepository: BrowseHistoryRepository
    
    private let services: ServiceContainer
    
    init(services: ServiceContainer) {
        self.services = services
        self.historyRepository = BrowserHistoryRepositoryImpl(storageService: services.dataStorageService)
    }
}


class ServiceContainerImpl: ServiceContainer {
    let dataStorageService: StorageService
    
    init() {
        self.dataStorageService = ReaalmDataStore()
    }
}
