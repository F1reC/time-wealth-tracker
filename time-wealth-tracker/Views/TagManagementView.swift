import SwiftUI

struct TagManagementView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: TimeWealthStore
    @State private var showingAddTag = false
    @State private var editingTag: CustomTag?
    @State private var newTagName = ""
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "tag.fill"
    
    private let colors = ["blue", "red", "green", "purple", "orange", "pink", "teal", "gray"]
    private let icons = ["tag.fill", "star.fill", "heart.fill", "circle.fill", "square.fill", "flag.fill"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.customTags) { tag in
                    HStack {
                        Image(systemName: tag.icon)
                            .foregroundColor(Color(tag.color))
                        Text(tag.name)
                        Spacer()
                        Button(action: {
                            editingTag = tag
                            newTagName = tag.name
                            selectedColor = tag.color
                            selectedIcon = tag.icon
                            showingAddTag = true
                        }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .onDelete(perform: deleteTag)
            }
            .navigationTitle("标签管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        newTagName = ""
                        selectedColor = "blue"
                        selectedIcon = "tag.fill"
                        editingTag = nil
                        showingAddTag = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddTag) {
                NavigationView {
                    Form {
                        TextField("标签名称", text: $newTagName)
                        
                        Section(header: Text("颜色")) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 10) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(Color(color))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                        }
                        
                        Section(header: Text("图标")) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 10) {
                                ForEach(icons, id: \.self) { icon in
                                    Image(systemName: icon)
                                        .foregroundColor(selectedIcon == icon ? .accentColor : .primary)
                                        .font(.title2)
                                        .onTapGesture {
                                            selectedIcon = icon
                                        }
                                }
                            }
                        }
                    }
                    .navigationTitle(editingTag == nil ? "新建标签" : "编辑标签")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") {
                                showingAddTag = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("保存") {
                                saveTag()
                                showingAddTag = false
                            }
                            .disabled(newTagName.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteTag(at offsets: IndexSet) {
        for index in offsets {
            store.deleteCustomTag(store.customTags[index])
        }
    }
    
    private func saveTag() {
        let tag = CustomTag(
            id: editingTag?.id ?? UUID(),
            name: newTagName,
            color: selectedColor,
            icon: selectedIcon
        )
        
        if editingTag != nil {
            store.updateCustomTag(tag)
        } else {
            store.addCustomTag(tag)
        }
    }
}

struct TagManagementView_Previews: PreviewProvider {
    static var previews: some View {
        TagManagementView()
            .environmentObject(TimeWealthStore())
    }
}
