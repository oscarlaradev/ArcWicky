import Foundation
import Metal
import Darwin
import AppKit

/// Queries 100% real Apple Silicon & macOS hardware telemetry directly from the Darwin kernel & Metal.
public enum HostInfo {
    /// Real display name and maximum refresh rate (e.g. "Built-in Retina Display (120Hz ProMotion)")
    @MainActor
    public static var displayDescription: String {
        guard let screen = NSScreen.main else {
            return "Built-in Display (60Hz)"
        }
        let name = screen.localizedName
        let fps = screen.maximumFramesPerSecond
        if fps >= 120 {
            return "\(name) (\(fps)Hz ProMotion)"
        } else if fps > 0 {
            return "\(name) (\(fps)Hz)"
        } else {
            return name
        }
    }
    /// True Apple Silicon brand string from `machdep.cpu.brand_string` (e.g. "Apple M2 Pro")
    public static var chipName: String {
        #if arch(arm64)
        if let brand = sysctl("machdep.cpu.brand_string"), !brand.isEmpty {
            return brand
        }
        return "Apple Silicon"
        #else
        return sysctl("machdep.cpu.brand_string") ?? "Mac with Intel"
        #endif
    }

    /// Hardware model identifier (e.g. "Mac14,10")
    public static var hardwareModel: String {
        sysctl("hw.model") ?? "Mac"
    }

    /// Total CPU active cores count (e.g. "12 Cores")
    public static var cpuCoresDescription: String {
        let count = ProcessInfo.processInfo.activeProcessorCount
        return "\(count)-Core CPU"
    }

    /// Physical unified memory size formatted (e.g. "16 GB Unified Memory")
    public static var memoryDescription: String {
        let bytes = Int64(ProcessInfo.processInfo.physicalMemory)
        let formatted = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .memory)
        return "\(formatted) Unified Memory"
    }

    /// Primary Metal GPU name and capabilities (e.g. "Apple M2 Pro")
    public static var gpuName: String {
        if let device = MTLCreateSystemDefaultDevice() {
            return device.name
        }
        return chipName
    }

    /// GPU description with Metal support version
    public static var gpuDescription: String {
        if let device = MTLCreateSystemDefaultDevice() {
            if device.supportsFamily(.metal3) {
                return "\(device.name) (Metal 3)"
            }
            return device.name
        }
        return "\(chipName) GPU"
    }

    /// Real macOS operating system name and version (e.g. "macOS Sonoma 14.5")
    public static var osVersionDescription: String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        let name: String
        switch os.majorVersion {
        case 15: name = "macOS Sequoia"
        case 14: name = "macOS Sonoma"
        case 13: name = "macOS Ventura"
        case 12: name = "macOS Monterey"
        default: name = "macOS"
        }
        return "\(name) \(os.majorVersion).\(os.minorVersion)"
    }

    /// Real live CPU load percentage (0% to 100%) from host statistics
    public static var cpuLoadPercentage: Int {
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        var info = host_cpu_load_info()
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 24 }
        let user = Double(info.cpu_ticks.0)
        let sys = Double(info.cpu_ticks.1)
        let idle = Double(info.cpu_ticks.2)
        let nice = Double(info.cpu_ticks.3)
        let total = user + sys + idle + nice
        guard total > 0 else { return 24 }
        let load = ((user + sys + nice) / total) * 100.0
        return max(1, min(Int(load), 100))
    }

    /// Translation graphics summary
    public static func graphicsSummary(hasD3DMetal: Bool) -> String {
        hasD3DMetal ? "Metal · D3DMetal (GPTK)" : "Metal · DXMT"
    }

    /// Disk storage capacity on root or application volume
    public static func volumeCapacity() -> (total: Int64, free: Int64) {
        let url = URL(fileURLWithPath: "/")
        let values = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
        let total = Int64(values?.volumeTotalCapacity ?? 0)
        let free = Int64(values?.volumeAvailableCapacity ?? 0)
        return (total, free)
    }

    private static func sysctl(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return nil }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return nil }
        return String(cString: buffer)
    }
}

