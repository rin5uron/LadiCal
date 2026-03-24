import CoreData
import Foundation

extension CustomItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomItem> {
        NSFetchRequest<CustomItem>(entityName: "CustomItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var emoji: String?
    @NSManaged public var iconImagePath: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isEnabled: Bool
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: Int16
    @NSManaged public var type: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var customValues: NSSet?
}
