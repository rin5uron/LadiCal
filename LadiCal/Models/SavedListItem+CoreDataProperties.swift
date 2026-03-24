import CoreData
import Foundation

extension SavedListItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedListItem> {
        NSFetchRequest<SavedListItem>(entityName: "SavedListItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var note: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var urlString: String?
    @NSManaged public var record: Record?
}
