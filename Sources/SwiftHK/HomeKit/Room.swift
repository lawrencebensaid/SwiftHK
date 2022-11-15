//
//  Room.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 26/08/2021.
//

import HomeKit

public class Room: NSObject, ObservableObject, Identifiable {
    
    static func == (lhs: Room, rhs: Room) -> Bool { lhs.id == rhs.id }
    static func == (lhs: Room?, rhs: Room) -> Bool { lhs?.id == rhs.id }
    static func == (lhs: Room, rhs: Room?) -> Bool { lhs.id == rhs?.id }
    
    /// HM adaptee
    let hmRoom: HMRoom?
    
    private var _accessories: [Accessory] = []
    
    public let id: UUID
    public private(set) var name: String
    
    // HM adaptor
    init(_ hmRoom: HMRoom) {
        self.hmRoom = hmRoom
        id = hmRoom.uniqueIdentifier
        name = hmRoom.name
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, accessories: [Accessory] = []) {
        hmRoom = nil
        self.id = id
        self.name = name ?? "Room \(String.random([.upper, .numbers], ofSize: 4))"
        _accessories = accessories
    }
    
    // MARK: - Resource selection
    
    public var accessories: [Accessory] { hmRoom?.accessories.map(Accessory.init) ?? _accessories }
    
    public func zones(_ context: Home) -> [Zone] {
        return context.zones.filter({ $0.rooms.contains(where: { $0.id == id }) })
    }
    
    // MARK: - Resource functions
    
    /// Updates the name of the room.
    public func update(name: String) async throws {
        guard let hmRoom = hmRoom else {
            self.name = name
            return
        }
        try await hmRoom.updateName(name)
    }
    
    /// Adds a room to the zone.
    public func add(zone: Zone) async throws {
        guard let hmZone = zone.hmZone, let hmRoom = hmRoom else { return }
        try await hmZone.addRoom(hmRoom)
    }
    
    /// Removes a room from the zone.
    public func remove(zone: Zone) async throws {
        guard let hmZone = zone.hmZone, let hmRoom = hmRoom else { return }
        try await hmZone.removeRoom(hmRoom)
    }
    
}
