import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var store: TimeWealthStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    todayOverview
                    monthlyProgress
                    categoryBreakdown
                }
                .padding()
            }
            .navigationTitle("时间财富概览")
        }
    }
    
    private var todayOverview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今日概览")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("已使用")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(Int(store.calculateTimeSpentToday())) 分钟")
                        .font(.title)
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("剩余")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(1440 - Int(store.calculateTimeSpentToday())) 分钟")
                        .font(.title)
                        .bold()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private var monthlyProgress: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("月度进度")
                .font(.headline)
            
            let spent = store.calculateTimeSpentThisMonth()
            let total = store.currentBudget.totalMinutes
            let percentage = (spent / total) * 100
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("\(Int(percentage))%")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Text("\(Int(spent))/\(Int(total)) 分钟")
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: spent, total: total)
                    .tint(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("类别分布")
                .font(.headline)
            
            let entries = store.getEntriesForCurrentMonth()
            let categorySums = Dictionary(grouping: entries, by: { $0.category })
                .mapValues { entries in
                    entries.reduce(0) { $0 + $1.amount }
                }
            
            Chart {
                ForEach(TimeCategory.allCases, id: \.self) { category in
                    BarMark(
                        x: .value("Category", category.rawValue),
                        y: .value("Minutes", categorySums[category] ?? 0)
                    )
                    .foregroundStyle(by: .value("Category", category.rawValue))
                }
            }
            .frame(height: 200)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
