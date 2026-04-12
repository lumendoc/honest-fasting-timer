import Foundation
import SwiftData

@Model
class CompletedFast {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var targetDuration: TimeInterval
    var actualDuration: TimeInterval
    var presetName: String
    var wasCompletedNaturally: Bool
    var createdAt: Date
    
    init(
        startDate: Date,
        endDate: Date,
        targetDuration: TimeInterval,
        presetName: String,
        wasCompletedNaturally: Bool
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.targetDuration = targetDuration
        self.actualDuration = endDate.timeIntervalSince(startDate)
        self.presetName = presetName
        self.wasCompletedNaturally = wasCompletedNaturally
        self.createdAt = Date()
    }
    
    var formattedDuration: String {
        let hours = Int(actualDuration) / 3600
        let minutes = (Int(actualDuration) % 3600) / 60
        if minutes > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(hours)h"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
}
