import CoreData
import Foundation

enum DefaultCustomItemsSeeder {
    static func seedIfNeeded(context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<CustomItem> = CustomItem.fetchRequest()
        request.fetchLimit = 1

        if try context.count(for: request) > 0 {
            return
        }

        let now = Date()

        let defaults: [(String, CustomItemType, String?, Int16)] = [
            ("生理", .toggle, nil, 0),
            ("頭痛", .toggle, nil, 1),
            ("眠気", .toggle, nil, 2),
            ("落ち込み", .emoji, "🙂", 10),
            ("つらい", .emoji, "😵", 11),
            ("よく眠れた", .emoji, "💤", 12),
            ("夜", .emoji, "🌙", 13),
            ("薬", .emoji, "💊", 14)
        ]

        defaults.forEach { item in
            let customItem = CustomItem(context: context)
            customItem.id = UUID()
            customItem.name = item.0
            customItem.type = item.1.rawValue
            customItem.emoji = item.2
            customItem.isEnabled = true
            customItem.sortOrder = item.3
            customItem.createdAt = now
            customItem.updatedAt = now
        }

        try context.save()
    }
}
