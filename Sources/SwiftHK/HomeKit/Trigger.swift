//
//  Trigger.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 20/12/2021.
//

import HomeKit

public class Trigger: ObservableObject, Identifiable {
    
    /// HM adaptee
    private let hmTrigger: HMTrigger?
    
    /// A unique identifier for this trigger.
    public let id: UUID
    public private(set) var name: String
    public let isEnabled: Bool
    public let lastFireDate: Date?
    public let actionSets: [ActionSet]
    
    /// HM adaptor
    init(_ hmTrigger: HMTrigger) {
        self.hmTrigger = hmTrigger
        id = hmTrigger.uniqueIdentifier
        name = hmTrigger.name
        isEnabled = hmTrigger.isEnabled
        lastFireDate = hmTrigger.lastFireDate
        actionSets = hmTrigger.actionSets.map(ActionSet.init)
    }
    
    public func update(name: String) async throws {
        guard let trigger = hmTrigger else {
            self.name = name
            return
        }
        try await trigger.updateName(name)
    }
    
    public func enable(_ enable: Bool) async throws {
        guard let hmTrigger = hmTrigger else { return }
        try await hmTrigger.enable(enable)
    }
    
}
