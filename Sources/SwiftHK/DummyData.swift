//
//  DummyData.swift
//  SwiftUI Previews & Unit testing data
//
//  Created by Lawrence Bensaid on 11/15/22.
//

import Foundation

extension Accessory {
    
    public static func preview(_ index: Int) -> Accessory { previews[index] }
    
    public static var preview: Accessory { preview(Int.random(in: 0..<previews.count)) }
    
    private static let previews = [
        Accessory(category: .lightbulb, services: [.preview(0)]),
        Accessory(category: .lightbulb, services: [.preview(1)]),
        Accessory(category: .lightbulb, services: [.preview(2)]),
        Accessory(category: .lightbulb, services: [.preview(3)]),
        Accessory(category: .outlet, services: [.preview(4)]),
        Accessory(category: .outlet, services: [.preview(5)]),
        Accessory(category: .switch, services: [.preview(6)]),
        Accessory(category: .switch, services: [.preview(7)]),
        Accessory(category: .sensor, services: [.preview(8)]),
        Accessory(category: .sensor, services: [.preview(9)]),
        Accessory(category: .sensor, services: [.preview(10)]),
        Accessory(category: .sensor, services: [.preview(11)]),
        Accessory(category: .securitySystem, services: [.preview(12)]),
        Accessory(category: .securitySystem, services: [.preview(13)]),
        Accessory(category: .securitySystem, services: [.preview(14)]),
        Accessory(category: .securitySystem, services: [.preview(15)])
    ]
    
}

extension ActionSet {
    
    public static func preview(_ index: Int) -> ActionSet { previews[index] }
    
    public static var preview: ActionSet { preview(Int.random(in: 0..<previews.count)) }
    
    private static let previews = [
        ActionSet()
    ]
    
}

extension Group {
    
    public static func preview(_ index: Int) -> Group { previews[index] }
    
    public static var preview: Group { preview(Int.random(in: 0..<previews.count)) }
    
    private static let previews = [
        Group(services: [.preview(0)])
    ]
    
}

extension Home {
    
    public static let preview = Home(name: "Demo Home", zones: [.preview(0), .preview(1)], rooms: [.preview(0), .preview(1), .preview(2), .preview(3), .preview(4)])
    
}

extension Room {
    
    public static func preview(_ index: Int) -> Room { previews[index] }
    
    public static var preview: Room { preview(Int.random(in: 0..<previews.count)) }
    
    private static let previews = [
        Room(name: "Kitchen", accessories: [.preview(0), .preview(1), .preview(2), .preview(5)]),
        Room(name: "Hallway", accessories: [.preview(0)]),
        Room(name: "Office", accessories: [.preview(0)]),
        Room(name: "Patio", accessories: [.preview(0)]),
        Room(name: "Porch", accessories: [.preview(0)]),
        Room(name: "Bathroom", accessories: [.preview(0)]),
        Room(name: "Workshop", accessories: [.preview(0)])
    ]
    
}

extension Service {
    
    public static func preview(_ index: Int) -> Service { previews[index] }
    
    public static var preview: Service { preview(Int.random(in: 0..<previews.count)) }
    
    private static let previews = [
        Service(category: .lightbulb, [.powerState: 0]),
        Service(category: .lightbulb, [.powerState: 1]),
        Service(category: .lightbulb, [.powerState: 0]),
        Service(category: .lightbulb, [.powerState: 1]),
        Service(category: .outlet, [.powerState: 0]),
        Service(category: .outlet, [.powerState: 1]),
        Service(category: .switch, [.powerState: 0]),
        Service(category: .switch, [.powerState: 1]),
        Service(category: .contactSensor, [.contactState: 0]),
        Service(category: .contactSensor, [.contactState: 1]),
        Service(category: .motionSensor, [.motionDetected: 0]),
        Service(category: .motionSensor, [.motionDetected: 1]),
        Service(category: .securitySystem, [.currentSecuritySystemState: 3]),
        Service(category: .securitySystem, [.currentSecuritySystemState: 1]),
        Service(category: .securitySystem, [.currentSecuritySystemState: 2]),
        Service(category: .securitySystem, [.currentSecuritySystemState: 4])
    ]
    
}

extension Zone {
    
    public static func preview(_ index: Int) -> Zone { previews[index] }
    
    public static var preview: Zone { preview(Int.random(in: 0..<previews.count)) }
    
    private static let previews = [
        Zone(name: "Ground floor", rooms: [.preview(0), .preview(1), .preview(2)]),
        Zone(name: "Outside", rooms: [.preview(3), .preview(4)]),
        Zone(name: "First floor", rooms: [.preview(5)]),
        Zone(name: "Garage", rooms: [.preview(6)]),
        Zone(name: "Second floor", rooms: []),
        Zone(name: "Basement", rooms: [])
    ]
    
}
