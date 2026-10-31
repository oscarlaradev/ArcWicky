import Foundation
import GameController

public enum GamepadType: String, Sendable, CaseIterable {
    case dualSense = "PlayStation DualSense"
    case dualShock = "PlayStation DualShock 4"
    case xbox = "Xbox Wireless Controller"
    case switchPro = "Nintendo Switch Pro Controller"
    case switchJoyCon = "Nintendo Switch Joy-Con"
    case generic = "Game Controller"

    public var iconName: String {
        switch self {
        case .dualSense, .dualShock: return "playstation.logo"
        case .xbox: return "xbox.logo"
        case .switchPro, .switchJoyCon: return "gamecontroller.fill"
        case .generic: return "gamecontroller"
        }
    }
}

public struct ConnectedGamepad: Identifiable, Sendable, Equatable {
    public var id: String
    public var vendorName: String
    public var type: GamepadType
    public var batteryLevel: Float?
    public var hasHaptics: Bool

    public init(id: String, vendorName: String, type: GamepadType, batteryLevel: Float? = nil, hasHaptics: Bool = false) {
        self.id = id
        self.vendorName = vendorName
        self.type = type
        self.batteryLevel = batteryLevel
        self.hasHaptics = hasHaptics
    }
}

@MainActor
public final class GamepadManager: ObservableObject {
    public static let shared = GamepadManager()

    @Published public private(set) var connectedGamepads: [ConnectedGamepad] = []
    @Published public private(set) var primaryGamepad: ConnectedGamepad?

    private init() {
        setupObservers()
        refreshGamepads()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshGamepads()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshGamepads()
            }
        }
    }

    public func refreshGamepads() {
        let controllers = GCController.controllers()
        var gamepads: [ConnectedGamepad] = []

        for (index, controller) in controllers.enumerated() {
            let name = controller.vendorName ?? "Wireless Controller"
            let type = resolveType(from: name, controller: controller)
            let battery = controller.battery?.batteryLevel
            let hasHaptics = controller.haptics != nil

            gamepads.append(ConnectedGamepad(
                id: "\(index)-\(name)",
                vendorName: name,
                type: type,
                batteryLevel: battery,
                hasHaptics: hasHaptics
            ))
        }

        self.connectedGamepads = gamepads
        self.primaryGamepad = gamepads.first
    }

    private func resolveType(from name: String, controller: GCController) -> GamepadType {
        let lower = name.lowercased()
        if lower.contains("dualsense") || lower.contains("ps5") {
            return .dualSense
        } else if lower.contains("dualshock") || lower.contains("ps4") || lower.contains("sony") {
            return .dualShock
        } else if lower.contains("xbox") || lower.contains("microsoft") {
            return .xbox
        } else if lower.contains("switch pro") || lower.contains("pro controller") {
            return .switchPro
        } else if lower.contains("joy-con") || lower.contains("nintendo") {
            return .switchJoyCon
        }
        return .generic
    }
}
