//
//  Service.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 25/08/2021.
//

import HomeKit

public class Service: NSObject, HMAccessoryDelegate, ObservableObject, Identifiable {
    
    /// HM adaptee
    let hmService: HMService?
    
    /// A unique identifier for the service.
    public let id: UUID
    /// Name for the service.
    ///
    /// Returns the service's name that is associated with HomeKit. The initial value is the value of the name characteristic of the service, if it has one.
    public var name: String {
        guard let name = hmService?.name else { return name_ }
        return name
    }
    private var name_: String!
    
    /// The type of the service, e.g. `lightbulb`.
    public var category: Category {
        guard let type = hmService?.serviceType else { return category_ }
        return Category(rawValue: type)!
    }
    private let category_: Category!
    
    /// Accessory that provides this service.
    public var accessory: Accessory? {
        guard let accessory = hmService?.accessory else { return accessory_ }
        return Accessory(accessory)
    }
    private let accessory_: Accessory?
    
    /// Indicates if this service is the primary service.
    ///
    /// Applications should use this property to show the primary service on the accessory.
    public var isPrimaryService: Bool {
        guard let isPrimaryService = hmService?.isPrimaryService else { return isPrimaryService_ }
        return isPrimaryService
    }
    private let isPrimaryService_: Bool!
    
    /// Array of Characteristic objects that represents all the characteristics provided by the service.
    public var characteristics: [HMCharacteristic]
    
    private var listeners: [HMCharacteristic: ((Any?) -> ())] = [:]
    
    /// HM adaptor
    init(_ hmService: HMService) {
        self.hmService = hmService
        id = hmService.uniqueIdentifier
        characteristics = hmService.characteristics
        name_ = nil
        category_ = nil
        accessory_ = nil
        isPrimaryService_ = nil
    }
    
    /// Intended for SwiftUI preview purposes only!
    init(id: UUID = UUID(), name: String? = nil, category: Category, _ overrides: [Characteristic.Category: Any] = [:]) {
        hmService = nil
        self.id = id
        name_ = name ?? "\(category.description()) \(String.random([.upper, .numbers], ofSize: 4))"
        category_ = category
        accessory_ = nil
        characteristics = []
        isPrimaryService_ = true
    }
    
    
    /// This method is used to change the name of the service.
    ///
    /// The new name is stored in HomeKit and not on the accessory.
    ///
    /// - Parameter name: New name for the service.
    ///
    /// - Throws: `NSError` which provides more information on the status of the request
    public func update(name: String) async throws {
        guard let service = hmService else {
            self.name_ = name
            return
        }
        try await service.updateName(name)
    }
    
    /// Reads the value of the characteristic. The updated value can be read from the 'value' property of the characteristic.
    ///
    /// - Throws: `NSError` which provides more information on the status of the request
    public func fetch(_ characteristic: Characteristic.Category) async throws -> Any? {
        let matches = characteristics.filter({ $0.characteristicType == characteristic.rawValue })
        try await matches.first?.readValue()
        return matches.first?.value
    }
    
    /// The value of the characteristic.
    ///
    /// The value is a cached value that may have been updated as a result of prior interaction with the accessory.
    public func value(of characteristic: Characteristic.Category) -> Any? {
        let matches = characteristics.filter({ $0.characteristicType == characteristic.rawValue })
        return matches.first?.value
    }
    
    
    /// Enables notifications or indications for the value of a specified characteristic.
    ///
    /// - Parameter category What characteristic to listen for.
    ///
    /// - Throws: `NSError` which provides more information on the status of the request
    public func onUpdate(_ category: Characteristic.Category, update: @escaping ((Any?) -> ())) {
        debugPrint("Subscribe \(name) \(category.description())")
        hmService?.accessory?.delegate = self
        for characteristic in characteristics {
            if characteristic.characteristicType == category.rawValue {
                characteristic.enableNotification(true) { error in
                    if error != nil {
                        print("Error: \(error!)")
                        return
                    }
                }
                listeners[characteristic] = update
            }
        }
    }
    
    /// Modifies the value of the characteristic.
    ///
    /// The value being written is validated against the metadata, format and permissions. The value written may be bounded by metadata for characteristics with int and float format. If validation fails, the error provided to the completion handler indicates the type of failure.
    ///
    /// - Throws: `NSError`
    public func update(_ category: Characteristic.Category, to newValue: Int) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            for char in characteristics {
                if char.characteristicType == category.rawValue {
                    char.writeValue(newValue) { error in
                        print(newValue)
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
                    break
                }
            }
        }
    }
    
    public func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        let characteristicDescription = Characteristic.Category(rawValue: characteristic.characteristicType)?.description() ?? characteristic.characteristicType
        #if DEBUG
        print("\(service.name) \(characteristicDescription) > \(String(describing: characteristic.value))")
        #endif
        listeners[characteristic]?(characteristic.value)
    }
    
    // MARK: - Category
    
    public enum Category: String {
        case `switch` = "00000049-0000-1000-8000-0026BB765291"
        case thermostat = "0000004A-0000-1000-8000-0026BB765291"
        case outlet = "00000047-0000-1000-8000-0026BB765291"
        case lockManagement = "00000044-0000-1000-8000-0026BB765291"
        case airQualitySensor = "0000008D-0000-1000-8000-0026BB765291"
        case carbonDioxideSensor = "00000097-0000-1000-8000-0026BB765291"
        case carbonMonoxideSensor = "0000007F-0000-1000-8000-0026BB765291"
        case contactSensor = "00000080-0000-1000-8000-0026BB765291"
        case door = "00000081-0000-1000-8000-0026BB765291"
        case humiditySensor = "00000082-0000-1000-8000-0026BB765291"
        case leakSensor = "00000083-0000-1000-8000-0026BB765291"
        case lightSensor = "00000084-0000-1000-8000-0026BB765291"
        case motionSensor = "00000085-0000-1000-8000-0026BB765291"
        case occupancySensor = "00000086-0000-1000-8000-0026BB765291"
        case securitySystem = "0000007E-0000-1000-8000-0026BB765291"
        case statefulProgrammableSwitch = "00000088-0000-1000-8000-0026BB765291"
        case statelessProgrammableSwitch = "00000089-0000-1000-8000-0026BB765291"
        case smokeSensor = "00000087-0000-1000-8000-0026BB765291"
        case temperatureSensor = "0000008A-0000-1000-8000-0026BB765291"
        case window = "0000008B-0000-1000-8000-0026BB765291"
        case windowCovering = "0000008C-0000-1000-8000-0026BB765291"
        case cameraRTPStreamManagement = "00000110-0000-1000-8000-0026BB765291"
        case cameraControl = "00000111-0000-1000-8000-0026BB765291"
        case microphone = "00000112-0000-1000-8000-0026BB765291"
        case speaker = "00000113-0000-1000-8000-0026BB765291"
        case airPurifier = "000000BB-0000-1000-8000-0026BB765291"
        case filterMaintenance = "000000BA-0000-1000-8000-0026BB765291"
        case slats = "000000B9-0000-1000-8000-0026BB765291"
        case label = "000000CC-0000-1000-8000-0026BB765291"
        case irrigationSystem = "000000CF-0000-1000-8000-0026BB765291"
        case valve = "000000D0-0000-1000-8000-0026BB765291"
        case faucet = "000000D7-0000-1000-8000-0026BB765291"
        case accessoryInformation = "0000003E-0000-1000-8000-0026BB765291"
        case fan = "00000040-0000-1000-8000-0026BB765291"
        case garageDoorOpener = "00000041-0000-1000-8000-0026BB765291"
        case lightbulb = "00000043-0000-1000-8000-0026BB765291"
        case lockMechanism = "00000045-0000-1000-8000-0026BB765291"
        case battery = "00000096-0000-1000-8000-0026BB765291"
        case ventilationFan = "000000B7-0000-1000-8000-0026BB765291"
        case heaterCooler = "000000BC-0000-1000-8000-0026BB765291"
        case humidifierDehumidifier = "000000BD-0000-1000-8000-0026BB765291"
        case doorbell = "00000121-0000-1000-8000-0026BB765291"
        case accessoryRuntimeInformation = "00000239-0000-1000-8000-0026BB765291"
        case threadTransport = "00000701-0000-1000-8000-0026BB765291"
        
        case eve = "E863F007-079E-48FF-8F27-9C2605A29F52"
        
        public static var all: [Category] {
            return [.`switch`, .thermostat, .outlet, .lockManagement, .airQualitySensor, .carbonDioxideSensor, .carbonMonoxideSensor, .contactSensor, .door, .humiditySensor, .leakSensor, .lightSensor, .motionSensor, .occupancySensor, .securitySystem, .statefulProgrammableSwitch, .statelessProgrammableSwitch, .smokeSensor, .temperatureSensor, .window, .windowCovering, .cameraRTPStreamManagement, .cameraControl, .microphone, .speaker, .airPurifier, .filterMaintenance, .slats, .label, .irrigationSystem, .valve, .faucet, .accessoryInformation, .fan, .garageDoorOpener, .lightbulb, .lockMechanism, .battery, .ventilationFan, .heaterCooler, .humidifierDehumidifier, .doorbell, .accessoryRuntimeInformation, .threadTransport, .eve]
        }
        public func description() -> String {
            switch self {
            case .switch: return "Switch"
            case .thermostat: return "Thermostat"
            case .outlet: return "Outlet"
            case .lockManagement: return "Lock Management"
            case .airQualitySensor: return "Air Quality Sensor"
            case .carbonDioxideSensor: return "Carbon Dioxide Sensor"
            case .carbonMonoxideSensor: return "Carbon Monoxide Sensor"
            case .contactSensor: return "Contact Sensor"
            case .door: return "Door"
            case .humiditySensor: return "Humidity Sensor"
            case .leakSensor: return "Leak Sensor"
            case .lightSensor: return "Light Sensor"
            case .motionSensor: return "Motion Sensor"
            case .occupancySensor: return "Occupancy Sensor"
            case .securitySystem: return "Security System"
            case .statefulProgrammableSwitch: return "Stateful Programmable Switch"
            case .statelessProgrammableSwitch: return "Stateless Programmable Switch"
            case .smokeSensor: return "Smoke Sensor"
            case .temperatureSensor: return "Temperature Sensor"
            case .window: return "Window"
            case .windowCovering: return "Window Covering"
            case .cameraRTPStreamManagement: return "Camera RTP Stream Management"
            case .cameraControl: return "Camera Control"
            case .microphone: return "Microphone"
            case .speaker: return "Speaker"
            case .airPurifier: return "Air Purifier"
            case .filterMaintenance: return "Filter Maintenance"
            case .slats: return "Slats"
            case .label: return "Label"
            case .irrigationSystem: return "Irrigation System"
            case .valve: return "Valve"
            case .faucet: return "Faucet"
            case .accessoryInformation: return "Accessory Information"
            case .fan: return "Fan"
            case .garageDoorOpener: return "Garage Door Opener"
            case .lightbulb: return "Lightbulb"
            case .lockMechanism: return "Lock Mechanism"
            case .battery: return "Battery"
            case .ventilationFan: return "Ventilation Fan"
            case .heaterCooler: return "Heater-Cooler"
            case .humidifierDehumidifier: return "Humidifier-Dehumidifier"
            case .doorbell: return "Doorbell"
            case .accessoryRuntimeInformation: return "Accessory Runtime Information"
            case .threadTransport: return "Thread Transport"
            case .eve: return "Eve"
            }
        }
    }
    
}
