# HomeKit for Swift (SwiftHK)

HomeKit for Swift is a package which allows you to interact with HomeKit in a modern way.

```swift
let home = Manager().home

// Print power status of all services
for service in home.services {
    let isOn = try await service.fetch(.powerState)
    print("\(service.name) is \(isOn == true ? "ON" : "OFF")")
}

// Switch everything off
for service in home.services {
    try await service.fetch(.powerState)
}
```

***NOTE: This project is a WORK IN PROGRESS. It is unfinished subject to change!*** 