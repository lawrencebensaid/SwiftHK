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
    let room: HMRoom?
    
    private var _accessories: [Accessory] = []
    
    public let id: UUID
    public private(set) var name: String
    
    // HM adaptor
    init(_ hmRoom: HMRoom) {
        room = hmRoom
        id = hmRoom.uniqueIdentifier
        name = hmRoom.name
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, accessories: [Accessory] = []) {
        room = nil
        self.id = id
        self.name = name ?? "Room \(String.random([.upper, .numbers], ofSize: 4))"
        _accessories = accessories
    }
    
    // MARK: - Resource selection
    
    public var accessories: [Accessory] { room?.accessories.map(Accessory.init) ?? _accessories }
    
    public func zones(_ context: Home) -> [Zone] {
        return context.zones.filter({ $0.rooms.contains(where: { $0.id == id }) })
    }
    
    // MARK: - Resource functions
    
    public func updateName(_ name: String, completionHandler completion: @escaping (Error?) -> Void) {
        room?.updateName(name) {
            if $0 == nil {
                self.name = name
            }
#if DEBUG
            if let error = $0 { print(error.localizedDescription) }
#endif
            completion($0)
        }
    }
    
    public func addZone(_ zone: Zone, completionHandler completion: @escaping (Error?) -> Void) {
        guard let hmZone = zone.zone, let hmRoom = room else { completion(SHKError()); return }
        hmZone.addRoom(hmRoom) {
#if DEBUG
            if let error = $0 { print(error.localizedDescription) }
#endif
            completion($0)
        }
    }
    
    public func removeZone(_ zone: Zone, completionHandler completion: @escaping (Error?) -> Void) {
        guard let hmZone = zone.zone, let hmRoom = room else { completion(SHKError()); return }
        hmZone.removeRoom(hmRoom) {
#if DEBUG
            if let error = $0 { print(error.localizedDescription) }
#endif
            completion($0)
        }
    }
    
    // MARK: Helpers
    
    public enum SortingMode: Int {
        case name = 0
        case accessoryCount = 1
    }
    
    public func sort(_ room: Room, by sortingMode: SortingMode = .name, order: ComparisonResult = .orderedAscending) -> Bool {
        switch(sortingMode) {
        case .name: return name.localizedCaseInsensitiveCompare(room.name) == order
        case .accessoryCount:
            let c1 = accessories.count
            let c2 = room.accessories.count
            return order == .orderedAscending ? c1 > c2 : c1 < c2
        }
    }
    
    public static func find(_ query: String, in rooms: [Room]) -> [Room] {
        if query == "" { return rooms }
        return rooms.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
    }
    
}
