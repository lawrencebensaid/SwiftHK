//
//  Home.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 27/08/2021.
//

import HomeKit

public class Home: NSObject, ObservableObject, Identifiable {
    
    static func == (lhs: Home, rhs: Home) -> Bool { lhs.id == rhs.id }
    static func == (lhs: Home?, rhs: Home) -> Bool { lhs?.id == rhs.id }
    static func == (lhs: Home, rhs: Home?) -> Bool { lhs.id == rhs?.id }
    
    /// HM adaptee
    let home: HMHome?
    
    private var _zones: [Zone] = []
    private var _rooms: [Room] = []
    private var _accessories: [Accessory] = []
    private var _scenes: [ActionSet] = []
    private var _triggers: [Trigger] = []
    
    public let id: UUID
    @Published public var name: String
    public var zones: [Zone] { home?.zones.map(Zone.init) ?? _zones }
    public var rooms: [Room] { home?.rooms.map(Room.init) ?? _rooms }
    public var scenes: [ActionSet] { home?.actionSets.map(ActionSet.init) ?? _scenes }
    public var triggers: [Trigger] { home?.triggers.map(Trigger.init) ?? _triggers }
    
    public var groups: [Group] {
        guard let services = home?.serviceGroups else { return [] }
        return services.map(Group.init)
    }
    
    public var homeHubState: HMHomeHubState { home?.homeHubState ?? .notAvailable }
    
    public override var description: String { "HPHome: \(name); \(id.uuidString)" }
    
    /// HM adaptor
    init(_ hmHome: HMHome) {
        home = hmHome
        id = hmHome.uniqueIdentifier
        name = hmHome.name
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String, zones: [Zone], rooms: [Room], scenes: [ActionSet] = [], triggers: [Trigger] = []) {
        home = nil
        self.id = id
        self.name = name
        _zones = zones
        _rooms = rooms
        _scenes = scenes
        _triggers = triggers
    }
    
    // MARK: - Resource selection
    
    public var accessories: [Accessory] {
        guard let accessories = home?.accessories else { return _accessories }
        return accessories.map(Accessory.init)
    }
    
    public func accessories(of categories: [Service.Category] = [], in room: Room? = nil) -> [Accessory] {
        guard var accessories = home?.accessories else { return [] }
        if categories.count > 0 {
            accessories = accessories.filter {
                let accessory = Accessory($0)
                guard let service = accessory.primaryService else { return false }
                return categories.contains(service.category)
            }
        }
        if let room = room {
            accessories = accessories.filter({ $0.room?.uniqueIdentifier == room.id })
        }
        return accessories.map(Accessory.init)
    }
    
    public var services: [Service] {
        guard let services = home?.servicesWithTypes(Service.Category.all.map({ $0.rawValue })) else { return [] }
        return services.map(Service.init)
    }
    
    public func services(of categories: [Service.Category], in room: Room? = nil) -> [Service] {
        guard var services = home?.servicesWithTypes(categories.map({ $0.rawValue })) else { return [] }
        if let room = room {
            services = services.filter({ $0.accessory?.room?.uniqueIdentifier == room.id })
        }
        return services.map(Service.init)
    }
    
    
    // MARK: - Resource functions
    
    public func update(name: String) async throws {
        guard home != nil else { // In case the object is a dummy
            self.name = name
            return
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            home?.updateName(name) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    self.name = name
                    continuation.resume()
                }
            }
        }
    }
    
    public func addZone(withName zoneName: String, completionHandler completion: @escaping (Zone?, Error?) -> Void) {
        home?.addZone(withName: zoneName) { completion($0 != nil ? Zone($0!) : nil, $1) }
    }
    
    public func removeZone(_ zone: Zone, completionHandler completion: @escaping (Error?) -> Void) {
        guard let zone = zone.zone else { completion(SHKError()); return }
        home?.removeZone(zone, completionHandler: completion)
    }
    
    public func addRoom(withName roomName: String, completionHandler completion: @escaping (Room?, Error?) -> Void) {
        home?.addRoom(withName: roomName) { completion($0 != nil ? Room($0!) : nil, $1) }
    }
    
    public func removeRoom(_ room: Room, completionHandler completion: @escaping (Error?) -> Void) {
        guard let room = room.room else { completion(SHKError()); return }
        home?.removeRoom(room, completionHandler: completion)
    }
    
    public func executeActionSet(_ actionSet: ActionSet, completionHandler completion: @escaping (Error?) -> Void) {
        guard let actionSet = actionSet.scene else { completion(SHKError()); return }
        home?.executeActionSet(actionSet, completionHandler: completion)
    }
    
}
