import Foundation

struct ActiveFast: Codable {
    let startDate: Date
    let endDate: Date
    let presetName: String
    let presetDuration: TimeInterval
    
    var remainingTime: TimeInterval {
        max(0, endDate.timeIntervalSinceNow)
    }
    
    var progress: Double {
        let elapsed = Date().timeIntervalSince(startDate)
        return min(1.0, max(0.0, elapsed / presetDuration))
    }
    
    var isComplete: Bool {
        remainingTime <= 0
    }
    
    var formattedRemainingTime: String {
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startDate)
    }
    
    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
