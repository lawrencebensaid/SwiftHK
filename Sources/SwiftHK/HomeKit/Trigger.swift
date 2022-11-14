//
//  Trigger.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 20/12/2021.
//

import HomeKit

public class Trigger: ObservableObject, Identifiable {
    
    /// HM adaptee
    private let trigger: HMTrigger?
    
    public let id: UUID
    public let name: String
    public let isEnabled: Bool
    public let lastFireDate: Date?
    public let actionSets: [ActionSet]
    
    /// HM adaptor
    init(_ hmTrigger: HMTrigger) {
        trigger = hmTrigger
        id = hmTrigger.uniqueIdentifier
        name = hmTrigger.name
        isEnabled = hmTrigger.isEnabled
        lastFireDate = hmTrigger.lastFireDate
        actionSets = hmTrigger.actionSets.map(ActionSet.init)
    }
    
    public func updateName(_ name: String, completionHandler completion: @escaping (Error?) -> Void) {
        trigger?.updateName(name, completionHandler: completion)
    }
    
    public func enable(_ enable: Bool, completionHandler: @escaping (Error?) -> Void) {
        trigger?.enable(enable, completionHandler: completionHandler)
    }
    
    public static func find(_ query: String, in triggers: [Trigger]) -> [Trigger] {
        if query == "" { return triggers }
        return triggers.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
    }
    
}
