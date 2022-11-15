//
//  ActionSet.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 20/12/2021.
//

import HomeKit

public class ActionSet: ObservableObject, Identifiable {
    
    public enum `Type`: String {
        case userDefined = "HMActionSetTypeUserDefined"
        case wakeUp = "HMActionSetTypeWakeUp"
        case departure = "HMActionSetTypeDeparture"
        case arrival = "HMActionSetTypeArrival"
        case sleep = "HMActionSetTypeSleep"
        
        public static let allValues: [`Type`] = [.userDefined, .wakeUp, .departure, .arrival, .sleep]
        
        public func description() -> String {
            switch self {
            case .wakeUp: return "Wake up"
            case .departure: return "Departure"
            case .arrival: return "Arrival"
            case .sleep: return "Sleep"
            default: return "User defined"
            }
        }
    }
    
    /// HM adaptee
    let hmActionSet: HMActionSet?
    
    private var _name: String = ""
    private var _type: `Type` = .userDefined
    private var _actions: Set<HMAction> = []
    
    public let id: UUID
    public var name: String { hmActionSet?.name ?? _name }
    public var type: `Type` { .init(rawValue: hmActionSet?.actionSetType ?? "") ?? _type }
    public var actions: Set<HMAction> { hmActionSet?.actions ?? _actions }
    
    /// HM adaptor
    init(_ hmActionSet: HMActionSet) {
        self.hmActionSet = hmActionSet
        id = hmActionSet.uniqueIdentifier
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, type: `Type` = .userDefined, actions: Set<HMAction> = []) {
        self.id = id
        _name = name ?? "Action set \(String.random([.upper, .numbers], ofSize: 4))"
        _type = type
        _actions = actions
        hmActionSet = nil
    }
    
    /// Updates the name of the action set.
    public func update(name: String) async throws {
        guard let scene = hmActionSet else {
            self._name = name
            return
        }
        try await scene.updateName(name)
    }
    
}
