//
//  Accessory.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 25/08/2021.
//

import HomeKit

public class Accessory: ObservableObject, Identifiable {
    
    /// HM adaptee
    private let accessory: HMAccessory?
    
    private let services_: [Service]
    
    public let localId: UUID
    public let name: String
    public let room: HMRoom?
    public let category: Category
    public let isReachable: Bool
    public let firmwareVersion: String?
    public let isBlocked: Bool
    public let isBridged: Bool
    public let manufacturer: String?
    public let model: String?
    
    public var services: [Service] {
        guard let services = accessory?.services else { return services_ }
        return services.map(Service.init)
    }
    
    public var primaryService: Service? {
        return services.filter({ $0.isPrimaryService }).first
    }
    
    /// HM adaptor
    init(_ hmAccessory: HMAccessory) {
        accessory = hmAccessory
        localId = hmAccessory.uniqueIdentifier
        name = hmAccessory.name
        room = hmAccessory.room
        category = Category(rawValue: hmAccessory.category.categoryType) ?? .other
        isReachable = hmAccessory.isReachable
        services_ = hmAccessory.services.map(Service.init)
        firmwareVersion = hmAccessory.firmwareVersion
        isBlocked = hmAccessory.isBlocked
        isBridged = hmAccessory.isBridged
        manufacturer = hmAccessory.manufacturer
        model = hmAccessory.model
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, category: Category = .other, isReachable: Bool = true, services: [Service] = [], isBlocked: Bool = false, isBridged: Bool = false) {
        accessory = nil
        self.localId = id
        self.name = name ?? "\(category.description()) \(String.random([.upper, .numbers], ofSize: 4))"
        room = nil
        self.category = category
        self.isReachable = isReachable
        self.services_ = services
        firmwareVersion = nil
        self.isBlocked = isBlocked
        self.isBridged = isBridged
        manufacturer = nil
        model = nil
    }
    
    // MARK: - Resource functions
    
    public func updateName(_ name: String, completionHandler completion: @escaping (Error?) -> Void) {
        accessory?.updateName(name, completionHandler: completion)
    }
    
    // MARK: Helpers
    
    public static func find(_ query: String, in accessories: [Accessory]) -> [Accessory] {
        if query == "" { return accessories }
        return accessories.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
    }
    
    // MARK: - Category
    
    public enum Category: String {
        case other = "0FBA259B-05AC-46F2-875F-204ABB6D9FE7"
        case securitySystem = "14D8FE28-2998-49E3-AC95-E3969BE2957C"
        case bridge = "61102194-9993-48BF-A1EF-6C7DC50F0C01"
        case door = "DD4DE411-8F01-44EE-866A-1F96144DC1B6"
        case doorLock = "C25D5FCE-52EC-4599-A815-1192C5F08C7F"
        case fan = "151CB559-0DF9-40AA-8A67-12AF06C4449D"
        case garageDoorOpener = "604B6E52-2C87-4596-B4C9-D15077C0C07F"
        case ipCamera = "C9EE63DB-2FF7-4514-826A-2FC2F0D4C9F0"
        case lightbulb = "57D56F4D-3302-41F7-AB34-5365AA180E81"
        case outlet = "730F40D4-6D0E-4903-B09E-520A08AFB78C"
        case programmableSwitch = "3F9B944B-B8DF-4570-BAF5-CD31A8B321A7"
        case rangeExtender = "8E33483E-2102-4BFE-9295-0A187D114188"
        case sensor = "772AFB8E-8D2F-455E-90E5-9852E6C4DD31"
        case `switch` = "2F4C3164-8DE4-4A4F-93BA-DD1D5068DF0B"
        case thermostat = "79668DCF-89FB-450D-94B5-AEE70B7B09F1"
        case videoDoorbell = "957A52E0-BE03-490C-8305-7B20C1CC17BA"
        case window = "1C501511-408E-4C1E-816B-3FC011FFD5B1"
        case windowCovering = "2FB9EE1F-1C21-4D0B-9383-9B65F64DBF0E"
        case airPurifier = "5510B997-D711-4636-870F-82BB61092B15"
        case airHeater = "BF7036FD-93CF-49B5-954F-CD2B760D11DA"
        case airConditioner = "18DDD63A-27F9-4341-B59B-759D3D114586"
        case airHumidifier = "3FEB9075-C9AF-4629-ADBC-A853259C645A"
        case airDehumidifier = "1E15B639-DC98-41D4-A394-2E4A1D54AA3A"
        case sprinkler = "94D3FBD5-0A74-4EE4-BE1A-C97E82ADFA33"
        case faucet = "43CE6F7E-F7E8-44B4-80CE-5786F6E6CD47"
        case showerHead = "39D2A5B4-F9A6-43F6-90E7-0019F0C0E99F"
        
        public func description() -> String {
            switch self {
            case .other: return "Other"
            case .securitySystem: return "Security System"
            case .bridge: return "Bridge"
            case .door: return "Door"
            case .doorLock: return "Door Lock"
            case .fan: return "Fan"
            case .garageDoorOpener: return "Garage Door Opener"
            case .ipCamera: return "IP Camera"
            case .lightbulb: return "Lightbulb"
            case .outlet: return "Outlet"
            case .programmableSwitch: return "Programmable Switch"
            case .rangeExtender: return "Range Extender"
            case .sensor: return "Sensor"
            case .switch: return "Switch"
            case .thermostat: return "Thermostat"
            case .videoDoorbell: return "Video Doorbell"
            case .window: return "Window"
            case .windowCovering: return "Window Covering"
            case .airPurifier: return "Air Purifier"
            case .airHeater: return "Air Heater"
            case .airConditioner: return "Air Conditioner"
            case .airHumidifier: return "Air Humidifier"
            case .airDehumidifier: return "Air Dehumidifier"
            case .sprinkler: return "Sprinkler"
            case .faucet: return "Faucet"
            case .showerHead: return "Shower Head"
            }
        }
        
    }
    
}
