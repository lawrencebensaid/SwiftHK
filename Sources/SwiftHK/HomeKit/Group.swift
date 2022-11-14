//
//  Group.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 25/12/2021.
//

import HomeKit

public class Group: ObservableObject, Identifiable {
    
    /// HM adaptee
    let group: HMServiceGroup?
    
    public let id: UUID
    public let name: String
    public let services: [Service]
    
    /// HM adaptor
    init(_ hmServiceGroup: HMServiceGroup) {
        group = hmServiceGroup
        id = hmServiceGroup.uniqueIdentifier
        name = hmServiceGroup.name
        services = hmServiceGroup.services.map(Service.init)
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, services: [Service]) {
        self.id = id
        self.name = name ?? "Group \(String.random([.upper, .numbers], ofSize: 4))"
        self.services = services
        group = nil
    }
    
    // MARK: Helpers
    
    public static func find(_ query: String, in groups: [Group]) -> [Group] {
        if query == "" { return groups }
        return groups.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
    }
    
}
