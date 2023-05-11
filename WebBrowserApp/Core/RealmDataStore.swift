//
//  RealmDataStore.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 11.05.23.
//

import Foundation
import RealmSwift

protocol StorageService {
    func save(request: BrowserRequestModel)
    func getHistory() -> [BrowserRequestModel]
}

class ReaalmDataStore: StorageService {
    
    let realm = try! Realm()

    func save(request: BrowserRequestModel) {
        let newModel = BrowserRequest(url: request.address, date: request.date)
        try! realm.write {
            realm.add(newModel)
        }
    }
    
    func getHistory() -> [BrowserRequestModel] {
        let history = realm.objects(BrowserRequest.self)
        return history.map { BrowserRequestModel(address: $0.address, date: $0.date) }
    }
    
    
}

class BrowserRequest: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var address: URL!
    @Persisted var date: Date
    
    convenience init(url: URL, date: Date) {
        self.init()
        self.address = url
        self.date = date
    }
    
    
}

extension URL: FailableCustomPersistable {
    public typealias PersistedType = String
    public init?(persistedValue: String) { self.init(string: persistedValue) }
    public var persistableValue: String { self.absoluteString }
}
