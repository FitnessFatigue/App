//
//  Realm.swift
//  Intervals
//
//  Created by Matthew Roche on 10/10/2021.
//

import Foundation
import RealmSwift

// Handles set up of Realm configuration, and production of Realm instances that can be shared accross threads
struct RealmController {
    
    // Set up realm configuration with versioning
    func setUp() {
        let configuration = Realm.Configuration(
            schemaVersion: 8,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration
    }
    
    // Create standardised Realm instance which can be used accross threads
    func returnContainerisedRealm() throws -> Realm {
        do {
            let realmFileUrl = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.matthewroche.intervals")?
                .appendingPathComponent("default.realm")
            var realmConfig = Realm.Configuration.defaultConfiguration
            realmConfig.fileURL = realmFileUrl
            let realm = try Realm(configuration: realmConfig)
            return realm
        } catch {
            print(error)
            throw RealmError.UnableToAccessSharedRealm
        }
    }
    
    enum RealmError: Error {
        case UnableToAccessSharedRealm
    }
    
}
