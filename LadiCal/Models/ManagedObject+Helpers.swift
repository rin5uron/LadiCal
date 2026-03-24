import Foundation

extension CustomItem {
    var wrappedName: String { name ?? "項目" }
    var wrappedType: CustomItemType { CustomItemType(rawValue: type ?? "") ?? .toggle }
    var wrappedEmoji: String? { emoji }

    var customValueArray: [CustomValue] {
        let values = customValues as? Set<CustomValue> ?? []
        return values.sorted {
            ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
        }
    }
}

extension Record {
    var customValueArray: [CustomValue] {
        let values = customValues as? Set<CustomValue> ?? []
        return values.sorted {
            ($0.item?.sortOrder ?? 0) < ($1.item?.sortOrder ?? 0)
        }
    }

    var emojiValues: [CustomValue] {
        customValueArray.filter { $0.item?.wrappedType == .emoji }
    }

    var toggleValues: [CustomValue] {
        customValueArray.filter { $0.item?.wrappedType == .toggle }
    }
}
