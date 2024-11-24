import Foundation

struct TimeEntry: Identifiable, Codable {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var category: TimeCategory
    var customTag: String?
    var note: String
    var amount: Double // 以分钟为单位的时间花费
    
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, category: TimeCategory, customTag: String? = nil, note: String = "", amount: Double = 0) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.customTag = customTag
        self.note = note
        self.amount = amount
    }
}

enum TimeCategory: String, Codable, CaseIterable {
    case work = "工作"
    case study = "学习"
    case exercise = "运动"
    case entertainment = "娱乐"
    case rest = "休息"
    case social = "社交"
    case custom = "自定义"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .exercise: return "figure.run"
        case .entertainment: return "tv.fill"
        case .rest: return "bed.double.fill"
        case .social: return "person.2.fill"
        case .custom: return "tag.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .work: return "blue"
        case .study: return "green"
        case .exercise: return "orange"
        case .entertainment: return "purple"
        case .rest: return "gray"
        case .social: return "pink"
        case .custom: return "teal"
        case .other: return "brown"
        }
    }
}
