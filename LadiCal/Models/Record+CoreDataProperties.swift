import CoreData
import Foundation

extension Record {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var imagePath: String?
    @NSManaged public var note: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var customValues: NSSet?
    @NSManaged public var listItems: NSSet?
}
