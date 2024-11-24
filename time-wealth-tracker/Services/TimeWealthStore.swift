import Foundation
import SwiftUI

class TimeWealthStore: ObservableObject {
    @Published var currentBudget: TimeBudget
    @Published var timeEntries: [TimeEntry] = []
    @Published var customTags: [CustomTag] = []
    
    private let budgetKey = "time_budget"
    private let entriesKey = "time_entries"
    private let tagsKey = "custom_tags"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: budgetKey),
           let budget = try? JSONDecoder().decode(TimeBudget.self, from: data) {
            self.currentBudget = budget
        } else {
            self.currentBudget = TimeBudget()
        }
        
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let entries = try? JSONDecoder().decode([TimeEntry].self, from: data) {
            self.timeEntries = entries
        }
        
        if let data = UserDefaults.standard.data(forKey: tagsKey),
           let tags = try? JSONDecoder().decode([CustomTag].self, from: data) {
            self.customTags = tags
        }
    }
    
    func saveTimeEntry(_ entry: TimeEntry) {
        timeEntries.append(entry)
        updateBudget(with: entry)
        saveToStorage()
    }
    
    func updateBudget(with entry: TimeEntry) {
        currentBudget.spentMinutes += entry.amount
        if let index = currentBudget.categoryBudgets.firstIndex(where: { $0.category == entry.category }) {
            currentBudget.categoryBudgets[index].spentMinutes += entry.amount
        }
        saveToStorage()
    }
    
    func getEntriesForCategory(_ category: TimeCategory) -> [TimeEntry] {
        return timeEntries.filter { $0.category == category }
    }
    
    func getEntriesForCurrentMonth() -> [TimeEntry] {
        let calendar = Calendar.current
        let now = Date()
        return timeEntries.filter { entry in
            calendar.isDate(entry.startTime, equalTo: now, toGranularity: .month)
        }
    }
    
    // 标签管理方法
    func addCustomTag(_ tag: CustomTag) {
        customTags.append(tag)
        saveToStorage()
    }
    
    func updateCustomTag(_ tag: CustomTag) {
        if let index = customTags.firstIndex(where: { $0.id == tag.id }) {
            customTags[index] = tag
            
            // 更新所有使用此标签的条目
            for i in timeEntries.indices {
                if timeEntries[i].customTag == customTags[index].name {
                    timeEntries[i].customTag = tag.name
                }
            }
            saveToStorage()
        }
    }
    
    func deleteCustomTag(_ tag: CustomTag) {
        customTags.removeAll { $0.id == tag.id }
        
        // 移除所有使用此标签的条目中的标签
        for i in timeEntries.indices {
            if timeEntries[i].customTag == tag.name {
                timeEntries[i].customTag = nil
            }
        }
        saveToStorage()
    }
    
    private func saveToStorage() {
        if let data = try? JSONEncoder().encode(currentBudget) {
            UserDefaults.standard.set(data, forKey: budgetKey)
        }
        
        if let data = try? JSONEncoder().encode(timeEntries) {
            UserDefaults.standard.set(data, forKey: entriesKey)
        }
        
        if let data = try? JSONEncoder().encode(customTags) {
            UserDefaults.standard.set(data, forKey: tagsKey)
        }
    }
    
    func resetMonthlyBudget() {
        currentBudget = TimeBudget()
        saveToStorage()
    }
    
    func calculateTimeSpentToday() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return timeEntries
            .filter { calendar.isDate($0.startTime, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    func calculateTimeSpentThisMonth() -> Double {
        return getEntriesForCurrentMonth()
            .reduce(0) { $0 + $1.amount }
    }
}
