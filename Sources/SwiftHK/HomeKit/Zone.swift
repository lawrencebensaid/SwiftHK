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
    let zone: HMZone?
    
    public let id: UUID
    public private(set) var name: String
    public private(set) var rooms: [Room]
    
    /// HM adaptor
    init(_ hmZone: HMZone) {
        zone = hmZone
        id = hmZone.uniqueIdentifier
        name = hmZone.name
        rooms = hmZone.rooms.map({ Room($0) })
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, rooms: [Room]) {
        zone = nil
        self.id = id
        self.name = name ?? "Zone \(String.random([.upper, .numbers], ofSize: 4))"
        self.rooms = rooms
    }
    
    // MARK: - Resource functions
    
    public func updateName(_ name: String, completionHandler completion: @escaping (Error?) -> Void) {
        zone?.updateName(name) {
            if $0 == nil {
                self.name = name
            }
#if DEBUG
            if let error = $0 { print(error.localizedDescription) }
#endif
            completion($0)
        }
    }
    
    public func addRoom(_ room: Room, completionHandler completion: @escaping (Error?) -> Void) {
        guard let hmRoom = room.room else { completion(SHKError()); return }
        zone?.addRoom(hmRoom) {
            if $0 == nil {
                self.rooms.append(room)
            }
#if DEBUG
            if let error = $0 { print(error.localizedDescription) }
#endif
            completion($0)
        }
    }
    
    public func removeRoom(_ room: Room, completionHandler completion: @escaping (Error?) -> Void) {
        guard let hmRoom = room.room else { completion(SHKError()); return }
        zone?.removeRoom(hmRoom) {
            if $0 == nil {
                self.rooms.removeAll(where: { $0 == room })
            }
#if DEBUG
            if let error = $0 { print(error.localizedDescription) }
#endif
            completion($0)
        }
    }
    
    // MARK: Helpers
    
    public enum SortingMode: Int {
        case name = 0
        case roomCount = 1
    }
    
    public func sort(_ zone: Zone, by sortingMode: SortingMode = .name, order: ComparisonResult = .orderedAscending) -> Bool {
        switch(sortingMode) {
        case .name: return name.localizedCaseInsensitiveCompare(zone.name) == order
        case .roomCount:
            let c1 = rooms.count
            let c2 = zone.rooms.count
            return order == .orderedAscending ? c1 > c2 : c1 < c2
        }
    }
    
    public static func find(_ query: String, in zones: [Zone]) -> [Zone] {
        if query == "" { return zones }
        return zones.filter {
            $0.name.lowercased().contains(query.lowercased()) ||
            Room.find(query, in: $0.rooms).count > 0
        }
    }
    
}
