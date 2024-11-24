import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: TimeWealthStore
    @State private var selectedFilter: TimeCategory?
    
    var body: some View {
        NavigationView {
            VStack {
                filterSection
                
                List {
                    ForEach(groupedEntries.keys.sorted().reversed(), id: \.self) { date in
                        Section(header: Text(formatDate(date))) {
                            ForEach(groupedEntries[date] ?? []) { entry in
                                TimeEntryRow(entry: entry)
                            }
                        }
                    }
                }
            }
            .navigationTitle("历史记录")
        }
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                FilterChip(
                    title: "全部",
                    isSelected: selectedFilter == nil,
                    action: { selectedFilter = nil }
                )
                
                ForEach(TimeCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedFilter == category,
                        action: { selectedFilter = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var filteredEntries: [TimeEntry] {
        if let filter = selectedFilter {
            return store.timeEntries.filter { $0.category == filter }
        }
        return store.timeEntries
    }
    
    private var groupedEntries: [Date: [TimeEntry]] {
        Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.startTime)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

struct TimeEntryRow: View {
    let entry: TimeEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.category.icon)
                    .foregroundColor(Color(entry.category.color))
                Text(entry.category.rawValue)
                    .font(.headline)
                Spacer()
                Text("\(Int(entry.amount)) 分钟")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(formatTime(entry.startTime))
                Text("-")
                Text(formatTime(entry.endTime ?? entry.startTime))
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}
