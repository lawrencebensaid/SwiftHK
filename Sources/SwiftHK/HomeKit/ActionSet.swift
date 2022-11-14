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
    let scene: HMActionSet?
    
    private var _name: String = ""
    private var _type: `Type` = .userDefined
    private var _actions: Set<HMAction> = []
    
    public let id: UUID
    public var name: String { scene?.name ?? _name }
    public var type: `Type` { .init(rawValue: scene?.actionSetType ?? "") ?? _type }
    public var actions: Set<HMAction> { scene?.actions ?? _actions }
    
    /// HM adaptor
    init(_ hmActionSet: HMActionSet) {
        id = hmActionSet.uniqueIdentifier
        scene = hmActionSet
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, type: `Type` = .userDefined, actions: Set<HMAction> = []) {
        self.id = id
        _name = name ?? "Action set \(String.random([.upper, .numbers], ofSize: 4))"
        _type = type
        _actions = actions
        scene = nil
    }
    
    public func updateName(_ name: String, completionHandler completion: @escaping (Error?) -> Void) {
        scene?.updateName(name, completionHandler: completion)
    }
    
    // MARK: - Helpers
    
    public enum SortingMode: Int {
        case name = 0
        case type = 1
    }
    
    public func sort(_ actionSet: ActionSet, by sortingMode: SortingMode = .name, order: ComparisonResult = .orderedAscending) -> Bool {
        switch(sortingMode) {
        case .name: return name.localizedCaseInsensitiveCompare(actionSet.name) == order
        case .type:
            let i1 = `Type`.allValues.firstIndex(of: type) ?? 0
            let i2 = `Type`.allValues.firstIndex(of: actionSet.type) ?? 0
            return order == .orderedAscending ? i1 > i2 : i1 < i2
        }
    }
    
    public static func find(_ query: String, in actionsets: [ActionSet]) -> [ActionSet] {
        if query == "" { return actionsets }
        return actionsets.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
    }
    
}
