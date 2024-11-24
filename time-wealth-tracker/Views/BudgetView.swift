import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var store: TimeWealthStore
    @State private var showingAddBudget = false
    @State private var selectedCategory: TimeCategory = .work
    @State private var allocatedMinutes: String = ""
    
    var body: some View {
        NavigationView {
            List {
                monthlyOverviewSection
                categoryBudgetsSection
            }
            .navigationTitle("时间预算")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                addBudgetSheet
            }
        }
    }
    
    private var monthlyOverviewSection: some View {
        Section(header: Text("月度概览")) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("总预算")
                    Spacer()
                    Text("\(Int(store.currentBudget.totalMinutes)) 分钟")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("已分配")
                    Spacer()
                    Text("\(Int(totalAllocatedMinutes)) 分钟")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("未分配")
                    Spacer()
                    Text("\(Int(remainingUnallocatedMinutes)) 分钟")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var categoryBudgetsSection: some View {
        Section(header: Text("类别预算")) {
            ForEach(store.currentBudget.categoryBudgets) { budget in
                CategoryBudgetRow(budget: budget)
            }
            .onDelete(perform: deleteCategoryBudget)
        }
    }
    
    private var addBudgetSheet: some View {
        NavigationView {
            Form {
                Picker("类别", selection: $selectedCategory) {
                    ForEach(TimeCategory.allCases, id: \.self) { category in
                        if !store.currentBudget.categoryBudgets.contains(where: { $0.category == category }) {
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                TextField("分配时间（分钟）", text: $allocatedMinutes)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("添加预算")
            .navigationBarItems(
                leading: Button("取消") {
                    showingAddBudget = false
                },
                trailing: Button("保存") {
                    saveBudget()
                }
            )
        }
    }
    
    private func saveBudget() {
        guard let minutes = Double(allocatedMinutes),
              minutes > 0,
              minutes <= remainingUnallocatedMinutes else { return }
        
        let newBudget = CategoryBudget(
            category: selectedCategory,
            allocatedMinutes: minutes
        )
        
        store.currentBudget.categoryBudgets.append(newBudget)
        showingAddBudget = false
        allocatedMinutes = ""
    }
    
    private func deleteCategoryBudget(at offsets: IndexSet) {
        store.currentBudget.categoryBudgets.remove(atOffsets: offsets)
    }
    
    private var totalAllocatedMinutes: Double {
        store.currentBudget.categoryBudgets.reduce(0) { $0 + $1.allocatedMinutes }
    }
    
    private var remainingUnallocatedMinutes: Double {
        store.currentBudget.totalMinutes - totalAllocatedMinutes
    }
}

struct CategoryBudgetRow: View {
    let budget: CategoryBudget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: budget.category.icon)
                Text(budget.category.rawValue)
                Spacer()
                Text("\(Int(budget.allocatedMinutes)) 分钟")
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: budget.spentMinutes, total: budget.allocatedMinutes)
                .tint(Color(budget.category.color))
            
            HStack {
                Text("已用: \(Int(budget.spentMinutes)) 分钟")
                Spacer()
                Text("剩余: \(Int(budget.remainingMinutes)) 分钟")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
