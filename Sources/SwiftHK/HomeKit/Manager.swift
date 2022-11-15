//
//  HomeManager.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 25/08/2021.
//

import HomeKit

public class Manager: NSObject, ObservableObject {
    
    /// HM adaptee
    var hmManager: HMHomeManager
    
    private var listeners: [UUID: [Characteristic.Category: [((Service, Any?) -> ())]]] = [:]
    private var updateHomes: [((HMHome) -> ())] = []
    
    public var homes: [Home] { hmManager.homes.map(Home.init) }
    public private(set) var primaryHome: Home?
    
    @Published public var home: Home?
    
    public override init() {
        self.hmManager = HMHomeManager()
        super.init()
        hmManager.delegate = self
    }
    
    // MARK: - Resource functions
    
    /// Adds a new home to this home manager.
    public func addHome(named name: String) async throws -> HMHome? {
        try await hmManager.addHome(named: name)
    }
    
    /// Removes a home from this home manager.
    public func remove(home: Home) async throws {
        guard let hmHome = home.hmHome else { throw SHKError() }
        try await hmManager.removeHome(hmHome)
    }
    
    /// Updates the primary home of this home manager.
    public func update(primary home: Home) async throws {
        guard let hmHome = home.hmHome else { throw SHKError() }
        try await hmManager.updatePrimaryHome(hmHome)
    }
    
    // MARK: - Update events
    
    public func onUpdateHomes(perform: @escaping ((HMHome) -> ())) {
        updateHomes.append(perform)
    }
    
    public func onUpdate(_ category: Characteristic.Category, for type: [Service.Category] = Service.Category.all, perform: @escaping ((Service, Any?) -> ())) {
        onUpdate([category], for: type, perform: perform)
    }
    
    public func onUpdate(_ categories: [Characteristic.Category], for type: [Service.Category] = Service.Category.all, perform: @escaping ((Service, Any?) -> ())) {
        if let home = home?.hmHome {
            onUpdate(home: home, categories: categories, type: type, perform: perform)
        } else {
            onUpdateHomes {
                self.onUpdate(home: $0, categories: categories, type: type, perform: perform)
            }
        }
    }
    
    private func onUpdate(home: HMHome, categories: [Characteristic.Category], type: [Service.Category], perform: @escaping ((Service, Any?) -> ())) {
        let services = home.servicesWithTypes(type.map({ $0.rawValue }))
        for service in services ?? [] {
            for category in categories {
                onUpdate(category, for: Service(service), perform: perform)
            }
        }
    }
    
    public func onUpdate(_ category: Characteristic.Category, for service: Service, perform: @escaping ((Service, Any?) -> ())) {
        if home != nil {
            onUpdate(category: category, for: service, perform: perform)
        } else {
            onUpdateHomes { home in
                self.onUpdate(category: category, for: service, perform: perform)
            }
        }
    }
    
    private func onUpdate(category: Characteristic.Category, for service: Service, perform: @escaping ((Service, Any?) -> ())) {
        for characteristic in service.characteristics {
            if characteristic.characteristicType != category.rawValue {
                continue
            }
            if !characteristic.properties.contains(HMCharacteristicPropertySupportsEventNotification) {
                continue
            }
            if listeners[service.id] == nil {
                listeners[service.id] = [:]
            }
            if listeners[service.id]?[category] == nil {
                listeners[service.id]?[category] = []
            }
            listeners[service.id]?[category]?.append(perform)
            service.hmService?.accessory?.delegate = self
            characteristic.enableNotification(true) { error in
                if let error = error {
                    print("Failed to enable notifications for \(characteristic): \(error.localizedDescription)")
                    return
                }
            }
            return
        }
    }
    
}

extension Manager: HMHomeManagerDelegate {
    
    public func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        print("UPDATE: homeManager/didUpdate")
    }
    
    public func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        print("UPDATE: homeManager/didAdd")
    }
    
    public func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        print("UPDATE: homeManager/didRemove")
    }
    
    public func homeManager(_ manager: HMHomeManager, didReceiveAddAccessoryRequest request: HMAddAccessoryRequest) {
        print("UPDATE: homeManager/didReceiveAddAccessoryRequest")
    }
    
    public func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("UPDATE: homeManagerDidUpdateHomes")
        if let home = manager.primaryHome {
            primaryHome = Home(home)
            home.delegate = self
            if self.home == nil {
                self.home = Home(home)
            }
            for listener in updateHomes {
                listener(home)
            }
        }
    }
    
    public func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        print("UPDATE: homeManagerDidUpdatePrimaryHome")
        guard let home = manager.primaryHome else { return }
        primaryHome = Home(home)
    }
    
}

extension Manager: HMHomeDelegate {
    
    public func homeDidUpdateName(_ home: HMHome) {
        print("UPDATE: homeDidUpdateName")
    }
    
    public func home(_ home: HMHome, didAdd room: HMRoom, to zone: HMZone) {
        print("UPDATE: home/didAdd room to zone")
    }
    
    public func home(_ home: HMHome, didEncounterError error: Error, for accessory: HMAccessory) {
        print("UPDATE: home/didEncounterError")
    }
    
}

extension Manager: HMAccessoryDelegate {
    
    public func accessory(_ accessory: HMAccessory, service context: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        let category = Characteristic.Category(rawValue: characteristic.characteristicType)
        //        let description = HPCharacteristic.Category(rawValue: characteristic.characteristicType)?.description() ?? "?\(characteristic.characteristicType)!"
        //        let value = characteristic.value != nil ? "\(characteristic.value!)" : "nil"
        //        print("\(service.name) \(description) \(value)")
        if let category = category {
            for listener in listeners[context.uniqueIdentifier]?[category] ?? [] {
                listener(Service(context), characteristic.value)
            }
        }
    }
    
}

/// SwiftHK internal error
class SHKError: Error { }
