import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // .xcdatamodeld を使わず、コード上で Core Data モデルを組み立てている。
        container = NSPersistentContainer(name: "LadiCal", managedObjectModel: Self.makeModel())

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved Core Data error: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        do {
            // 初回起動時に、最低限の絵文字項目とトグル項目を自動投入する。
            try DefaultCustomItemsSeeder.seedIfNeeded(context: container.viewContext)
        } catch {
            assertionFailure("Failed to seed default items: \(error.localizedDescription)")
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Record = 1日分の記録本体
        let record = NSEntityDescription()
        record.name = "Record"
        record.managedObjectClassName = NSStringFromClass(Record.self)

        // CustomItem = 「生理」「頭痛」「🙂」のような入力項目の定義
        let customItem = NSEntityDescription()
        customItem.name = "CustomItem"
        customItem.managedObjectClassName = NSStringFromClass(CustomItem.self)

        // CustomValue = その日のその項目が選ばれた、という保存結果
        let customValue = NSEntityDescription()
        customValue.name = "CustomValue"
        customValue.managedObjectClassName = NSStringFromClass(CustomValue.self)

        // SavedListItem = 一覧に残したいメモだけ別保存する箱
        let savedListItem = NSEntityDescription()
        savedListItem.name = "SavedListItem"
        savedListItem.managedObjectClassName = NSStringFromClass(SavedListItem.self)

        record.properties = [
            attribute(name: "id", type: .UUIDAttributeType),
            attribute(name: "date", type: .dateAttributeType),
            attribute(name: "note", type: .stringAttributeType, optional: true),
            attribute(name: "imagePath", type: .stringAttributeType, optional: true),
            attribute(name: "createdAt", type: .dateAttributeType),
            attribute(name: "updatedAt", type: .dateAttributeType)
        ]

        customItem.properties = [
            attribute(name: "id", type: .UUIDAttributeType),
            attribute(name: "name", type: .stringAttributeType),
            attribute(name: "type", type: .stringAttributeType),
            attribute(name: "emoji", type: .stringAttributeType, optional: true),
            attribute(name: "isEnabled", type: .booleanAttributeType, optional: false, defaultValue: true),
            attribute(name: "sortOrder", type: .integer16AttributeType, optional: false, defaultValue: 0),
            attribute(name: "iconImagePath", type: .stringAttributeType, optional: true),
            attribute(name: "createdAt", type: .dateAttributeType),
            attribute(name: "updatedAt", type: .dateAttributeType)
        ]

        customValue.properties = [
            attribute(name: "id", type: .UUIDAttributeType),
            attribute(name: "boolValue", type: .booleanAttributeType, optional: false, defaultValue: true),
            attribute(name: "createdAt", type: .dateAttributeType),
            attribute(name: "updatedAt", type: .dateAttributeType)
        ]

        savedListItem.properties = [
            attribute(name: "id", type: .UUIDAttributeType),
            attribute(name: "date", type: .dateAttributeType),
            attribute(name: "note", type: .stringAttributeType, optional: true),
            attribute(name: "urlString", type: .stringAttributeType, optional: true),
            attribute(name: "createdAt", type: .dateAttributeType),
            attribute(name: "updatedAt", type: .dateAttributeType)
        ]

        let recordToCustomValues = relationship(name: "customValues", destination: customValue, minCount: 0, maxCount: 0, deleteRule: .cascadeDeleteRule, optional: true, toMany: true)
        let customValueToRecord = relationship(name: "record", destination: record, minCount: 0, maxCount: 1, deleteRule: .nullifyDeleteRule, optional: true, toMany: false)
        recordToCustomValues.inverseRelationship = customValueToRecord
        customValueToRecord.inverseRelationship = recordToCustomValues

        let itemToCustomValues = relationship(name: "customValues", destination: customValue, minCount: 0, maxCount: 0, deleteRule: .cascadeDeleteRule, optional: true, toMany: true)
        let customValueToItem = relationship(name: "item", destination: customItem, minCount: 0, maxCount: 1, deleteRule: .nullifyDeleteRule, optional: true, toMany: false)
        itemToCustomValues.inverseRelationship = customValueToItem
        customValueToItem.inverseRelationship = itemToCustomValues

        let recordToListItems = relationship(name: "listItems", destination: savedListItem, minCount: 0, maxCount: 0, deleteRule: .cascadeDeleteRule, optional: true, toMany: true)
        let listItemToRecord = relationship(name: "record", destination: record, minCount: 0, maxCount: 1, deleteRule: .nullifyDeleteRule, optional: true, toMany: false)
        recordToListItems.inverseRelationship = listItemToRecord
        listItemToRecord.inverseRelationship = recordToListItems

        record.properties.append(contentsOf: [recordToCustomValues, recordToListItems])
        customItem.properties.append(itemToCustomValues)
        customValue.properties.append(contentsOf: [customValueToItem, customValueToRecord])
        savedListItem.properties.append(listItemToRecord)

        model.entities = [record, customItem, customValue, savedListItem]
        return model
    }

    private static func attribute(
        name: String,
        type: NSAttributeType,
        optional: Bool = false,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        attribute.defaultValue = defaultValue
        return attribute
    }

    private static func relationship(
        name: String,
        destination: NSEntityDescription,
        minCount: Int,
        maxCount: Int,
        deleteRule: NSDeleteRule,
        optional: Bool,
        toMany: Bool
    ) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = name
        relationship.destinationEntity = destination
        relationship.minCount = minCount
        relationship.maxCount = maxCount
        relationship.deleteRule = deleteRule
        relationship.isOptional = optional
        return relationship
    }
}
