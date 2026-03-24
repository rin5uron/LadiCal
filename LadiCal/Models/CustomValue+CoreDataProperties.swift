import CoreData
import Foundation

extension CustomValue {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomValue> {
        NSFetchRequest<CustomValue>(entityName: "CustomValue")
    }

    @NSManaged public var boolValue: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var item: CustomItem?
    @NSManaged public var record: Record?
}
