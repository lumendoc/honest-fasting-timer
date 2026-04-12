import Foundation

enum AppConfig {
    static let appName = "Honest Fasting Timer"
    static let bundleId = "com.lumen.honestfastingtimer"
    static let privacyPolicyURL = URL(string: "https://lumendoc.net/privacy")!
    static let supportURL = URL(string: "mailto:support@lumendoc.net")!

    // One-time purchase (not subscription)
    static let unlockProductId = "com.lumen.honestfastingtimer.unlock"
    
    // Price display string
    static let unlockPrice = "$4.99"
    
    // App Group for widget sharing
    static let appGroupId = "group.com.lumen.honestfastingtimer"
}

enum AppSecrets {
    static func value(for key: String, env: [String: String] = ProcessInfo.processInfo.environment) -> String? {
        if let value = env[key]?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
            return value
        }

        guard let envLocalURL = findDotEnvLocal() else { return nil }
        guard let contents = try? String(contentsOf: envLocalURL, encoding: .utf8) else { return nil }

        for rawLine in contents.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }

            let parts = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { continue }
            guard String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines) == key else { continue }

            return String(parts[1]).trimmingCharacters(in: CharacterSet(charactersIn: " \t\n\r\"'"))
        }

        return nil
    }

    private static func findDotEnvLocal(fileManager: FileManager = .default) -> URL? {
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let candidates = [
            currentDirectory.appendingPathComponent(".env.local"),
            currentDirectory.deletingLastPathComponent().appendingPathComponent(".env.local"),
            URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true).appendingPathComponent(".env.local")
        ]

        return candidates.first { fileManager.fileExists(atPath: $0.path) }
    }
}
