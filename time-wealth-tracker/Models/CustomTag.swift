import Foundation

struct CustomTag: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var color: String
    var icon: String
    
    init(id: UUID = UUID(), name: String, color: String = "blue", icon: String = "tag.fill") {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
    }
}
