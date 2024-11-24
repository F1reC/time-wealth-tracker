import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: TimeWealthStore
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedCategory: TimeCategory = .work
    @State private var selectedTag: CustomTag?
    @State private var note: String = ""
    @State private var showingTagManagement = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("时间")) {
                    DatePicker("开始时间", selection: $startDate)
                    DatePicker("结束时间", selection: $endDate)
                }
                
                Section(header: Text("分类")) {
                    Picker("类别", selection: $selectedCategory) {
                        ForEach(TimeCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    if !store.customTags.isEmpty {
                        Picker("标签", selection: $selectedTag) {
                            Text("无标签").tag(nil as CustomTag?)
                            ForEach(store.customTags) { tag in
                                HStack {
                                    Image(systemName: tag.icon)
                                        .foregroundColor(Color(tag.color))
                                    Text(tag.name)
                                }
                                .tag(tag as CustomTag?)
                            }
                        }
                    }
                    
                    Button("管理标签") {
                        showingTagManagement = true
                    }
                }
                
                Section(header: Text("备注")) {
                    TextField("添加备注", text: $note)
                }
            }
            .navigationTitle("手动记录")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEntry()
                    }
                }
            }
            .sheet(isPresented: $showingTagManagement) {
                TagManagementView()
            }
        }
    }
    
    private func saveEntry() {
        let amount = endDate.timeIntervalSince(startDate) / 60.0 // Convert to minutes
        let entry = TimeEntry(
            startTime: startDate,
            endTime: endDate,
            category: selectedCategory,
            customTag: selectedTag?.name,
            note: note,
            amount: amount
        )
        store.saveTimeEntry(entry)
        dismiss()
    }
}

struct ManualEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ManualEntryView()
            .environmentObject(TimeWealthStore())
    }
}
