//
//  Zone.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 27/08/2021.
//

import HomeKit

public class Zone: NSObject, ObservableObject, Identifiable {
    
    static func == (lhs: Zone, rhs: Zone) -> Bool { lhs.id == rhs.id }
    static func == (lhs: Zone?, rhs: Zone) -> Bool { lhs?.id == rhs.id }
    static func == (lhs: Zone, rhs: Zone?) -> Bool { lhs.id == rhs?.id }
    
    /// HM adaptee
    let hmZone: HMZone?
    
    public let id: UUID
    public private(set) var name: String
    public private(set) var rooms: [Room]
    
    /// HM adaptor
    init(_ hmZone: HMZone) {
        self.hmZone = hmZone
        id = hmZone.uniqueIdentifier
        name = hmZone.name
        rooms = hmZone.rooms.map({ Room($0) })
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, rooms: [Room]) {
        hmZone = nil
        self.id = id
        self.name = name ?? "Zone \(String.random([.upper, .numbers], ofSize: 4))"
        self.rooms = rooms
    }
    
    // MARK: - Resource functions
    
    /// Updates the name of the zone.
    public func update(name: String) async throws {
        guard let hmZone = hmZone else {
            self.name = name
            return
        }
        try await hmZone.updateName(name)
    }
    
    /// Adds a room to the zone.
    public func add(room: Room) async throws {
        guard let hmZone = hmZone else { return }
        guard let hmRoom = room.hmRoom else { return }
        try await hmZone.addRoom(hmRoom)
        rooms.append(room)
    }
    
    /// Removes a room from the zone.
    public func remove(room: Room) async throws {
        guard let hmZone = hmZone else { return }
        guard let hmRoom = room.hmRoom else { return }
        try await hmZone.removeRoom(hmRoom)
        rooms.removeAll(where: { $0 == hmRoom })
    }
    
}
