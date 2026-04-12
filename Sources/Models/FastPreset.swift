import Foundation

enum FastPreset: String, CaseIterable, Identifiable {
    case sixteenEight = "16:8"
    case eighteenSix = "18:6"
    case twentyFour = "20:4"
    case omad = "OMAD"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .sixteenEight: return "16:8 Intermittent"
        case .eighteenSix: return "18:6 Intermittent"
        case .twentyFour: return "20:4 Warrior"
        case .omad: return "OMAD (One Meal)"
        case .custom: return "Custom"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .sixteenEight: return 16 * 60 * 60
        case .eighteenSix: return 18 * 60 * 60
        case .twentyFour: return 20 * 60 * 60
        case .omad: return 23 * 60 * 60
        case .custom: return 16 * 60 * 60
        }
    }
    
    var description: String {
        switch self {
        case .sixteenEight: return "Fast 16 hours, eat 8 hours"
        case .eighteenSix: return "Fast 18 hours, eat 6 hours"
        case .twentyFour: return "Fast 20 hours, eat 4 hours"
        case .omad: return "Fast 23 hours, one meal"
        case .custom: return "Set your own duration"
        }
    }
}
