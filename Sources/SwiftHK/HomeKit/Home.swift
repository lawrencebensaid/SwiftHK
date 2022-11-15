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
    let hmHome: HMHome?
    
    private var _zones: [Zone] = []
    private var _rooms: [Room] = []
    private var _accessories: [Accessory] = []
    private var _scenes: [ActionSet] = []
    private var _triggers: [Trigger] = []
    
    public let id: UUID
    @Published public var name: String
    public var zones: [Zone] { hmHome?.zones.map(Zone.init) ?? _zones }
    public var rooms: [Room] { hmHome?.rooms.map(Room.init) ?? _rooms }
    public var scenes: [ActionSet] { hmHome?.actionSets.map(ActionSet.init) ?? _scenes }
    public var triggers: [Trigger] { hmHome?.triggers.map(Trigger.init) ?? _triggers }
    
    public var groups: [ServiceGroup] {
        guard let services = hmHome?.serviceGroups else { return [] }
        return services.map(ServiceGroup.init)
    }
    
    public var homeHubState: HMHomeHubState { hmHome?.homeHubState ?? .notAvailable }
    
    public override var description: String { "HPHome: \(name); \(id.uuidString)" }
    
    /// HM adaptor
    init(_ hmHome: HMHome) {
        self.hmHome = hmHome
        id = hmHome.uniqueIdentifier
        name = hmHome.name
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String, zones: [Zone], rooms: [Room], scenes: [ActionSet] = [], triggers: [Trigger] = []) {
        hmHome = nil
        self.id = id
        self.name = name
        _zones = zones
        _rooms = rooms
        _scenes = scenes
        _triggers = triggers
    }
    
    // MARK: - Resource selection
    
    public var accessories: [Accessory] {
        guard let accessories = hmHome?.accessories else { return _accessories }
        return accessories.map(Accessory.init)
    }
    
    public func accessories(of categories: [Service.Category] = [], in room: Room? = nil) -> [Accessory] {
        guard var accessories = hmHome?.accessories else { return [] }
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
        guard let services = hmHome?.servicesWithTypes(Service.Category.all.map({ $0.rawValue })) else { return [] }
        return services.map(Service.init)
    }
    
    public func services(of categories: [Service.Category], in room: Room? = nil) -> [Service] {
        guard var services = hmHome?.servicesWithTypes(categories.map({ $0.rawValue })) else { return [] }
        if let room = room {
            services = services.filter({ $0.accessory?.room?.uniqueIdentifier == room.id })
        }
        return services.map(Service.init)
    }
    
    
    // MARK: - Resource functions
    
    /// Updates the name of the home.
    public func update(name: String) async throws {
        guard let hmHome = hmHome else {
            self.name = name
            return
        }
        try await hmHome.updateName(name)
    }
    
    /// Adds a new zone to the home.
    public func addZone(named name: String) async throws -> Zone {
        guard let hmHome = hmHome else {
            return Zone(name: name, rooms: [])
        }
        let hmZone = try await hmHome.addZone(named: name)
        return Zone(hmZone)
    }
    
    /// Removes a zone from the home.
    public func remove(zone: Zone) async throws {
        guard let hmHome = hmHome else { return }
        guard let hmZone = zone.hmZone else { return }
        try await hmHome.removeZone(hmZone)
    }
    
    /// Creates a new room with the specified name.
    public func addRoom(named name: String) async throws -> Room {
        guard let hmHome = hmHome else {
            return Room(name: name)
        }
        let hmRoom = try await hmHome.addRoom(named: name)
        return Room(hmRoom)
    }
    
    /// Removes a room from the home.
    public func remove(room: Room) async throws {
        guard let hmHome = hmHome else { return }
        guard let hmRoom = room.hmRoom else { throw SHKError() }
        try await hmHome.removeRoom(hmRoom)
    }
    
    /// Executes all the actions in a specified action set.
    public func execute(actionSet: ActionSet) async throws {
        guard let hmHome = hmHome else { return }
        guard let hmActionSet = actionSet.hmActionSet else { return }
        try await hmHome.executeActionSet(hmActionSet)
    }
    
}
