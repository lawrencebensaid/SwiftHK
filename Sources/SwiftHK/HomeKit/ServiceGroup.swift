//
//  ServiceGroup.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 25/12/2021.
//

import HomeKit

public class ServiceGroup: ObservableObject, Identifiable {
    
    /// HM adaptee
    let hmServiceGroup: HMServiceGroup?
    
    /// The unique identifier for the service group.
    public let id: UUID
    /// The name of the service group.
    public private(set) var name: String
    /// Array of the services in the service group.
    public let services: [Service]
    
    /// HM adaptor
    init(_ hmServiceGroup: HMServiceGroup) {
        self.hmServiceGroup = hmServiceGroup
        id = hmServiceGroup.uniqueIdentifier
        name = hmServiceGroup.name
        services = hmServiceGroup.services.map(Service.init)
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, services: [Service]) {
        self.id = id
        self.name = name ?? "Group \(String.random([.upper, .numbers], ofSize: 4))"
        self.services = services
        hmServiceGroup = nil
    }
    
    /// Updates the name of the service group.
    public func update(name: String) async throws {
        guard let group = hmServiceGroup else {
            self.name = name
            return
        }
        try await group.updateName(name)
    }
    
}
