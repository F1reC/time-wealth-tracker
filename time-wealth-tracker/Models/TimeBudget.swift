import Foundation

struct TimeBudget: Identifiable, Codable {
    var id: UUID
    var month: Date // 预算月份
    var totalMinutes: Double // 本月总分钟数
    var spentMinutes: Double // 已使用分钟数
    var categoryBudgets: [CategoryBudget] // 各类别预算
    
    init(id: UUID = UUID(), month: Date = Date()) {
        self.id = id
        self.month = month
        self.totalMinutes = Self.calculateTotalMinutesInMonth(month)
        self.spentMinutes = 0
        self.categoryBudgets = []
    }
    
    static func calculateTotalMinutesInMonth(_ date: Date) -> Double {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        return Double(range.count * 24 * 60)
    }
}

struct CategoryBudget: Identifiable, Codable {
    var id: UUID
    var category: TimeCategory
    var allocatedMinutes: Double
    var spentMinutes: Double
    
    var remainingMinutes: Double {
        allocatedMinutes - spentMinutes
    }
    
    var percentageUsed: Double {
        guard allocatedMinutes > 0 else { return 0 }
        return (spentMinutes / allocatedMinutes) * 100
    }
    
    init(id: UUID = UUID(), category: TimeCategory, allocatedMinutes: Double, spentMinutes: Double = 0) {
        self.id = id
        self.category = category
        self.allocatedMinutes = allocatedMinutes
        self.spentMinutes = spentMinutes
    }
}
