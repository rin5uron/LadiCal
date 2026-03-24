import CoreData
import SwiftUI

struct DayEditorView: View {
    let date: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomItem.sortOrder, ascending: true)],
        animation: .default
    )
    private var customItems: FetchedResults<CustomItem>

    @State private var selectedItemIDs: Set<UUID> = []
    @State private var note = ""
    @State private var saveToList = false

    var body: some View {
        NavigationStack {
            Form {
                Section("日付") {
                    Text(date.formatted(.dateTime.year().month().day().weekday()))
                }

                Section("絵文字") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiItems, id: \.objectID) { item in
                                Button {
                                    toggleSelection(for: item)
                                } label: {
                                    Text(item.wrappedEmoji ?? "🙂")
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(isSelected(item) ? Color.primary.opacity(0.15) : Color.secondary.opacity(0.08))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("カスタム項目") {
                    ForEach(toggleItems, id: \.objectID) { item in
                        Toggle(item.wrappedName, isOn: binding(for: item))
                    }
                }

                Section("メモ") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                }

                Section("保存リスト") {
                    Toggle("このメモをリストにも保存する", isOn: $saveToList)
                }

                Section("画像") {
                    Label("画像選択は次の実装で追加", systemImage: "photo")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("日付編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                }
            }
            .onAppear {
                loadExistingRecord()
            }
        }
    }

    private var emojiItems: [CustomItem] {
        customItems.filter { $0.isEnabled && $0.wrappedType == .emoji }
    }

    private var toggleItems: [CustomItem] {
        customItems.filter { $0.isEnabled && $0.wrappedType == .toggle }
    }

    private func isSelected(_ item: CustomItem) -> Bool {
        guard let id = item.id else { return false }
        return selectedItemIDs.contains(id)
    }

    private func toggleSelection(for item: CustomItem) {
        guard let id = item.id else { return }

        if selectedItemIDs.contains(id) {
            selectedItemIDs.remove(id)
        } else {
            selectedItemIDs.insert(id)
        }
    }

    private func binding(for item: CustomItem) -> Binding<Bool> {
        Binding {
            isSelected(item)
        } set: { newValue in
            guard let id = item.id else { return }

            if newValue {
                selectedItemIDs.insert(id)
            } else {
                selectedItemIDs.remove(id)
            }
        }
    }

    private func loadExistingRecord() {
        guard let record = fetchRecord(for: date) else { return }

        note = record.note ?? ""
        saveToList = !(record.listItems as? Set<SavedListItem> ?? []).isEmpty
        selectedItemIDs = Set(record.customValueArray.compactMap(\.item?.id))
    }

    private func save() {
        let record = fetchRecord(for: date) ?? Record(context: viewContext)
        let now = Date()

        if record.id == nil {
            record.id = UUID()
            record.createdAt = now
            record.date = date.startOfDay()
        }

        record.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        record.updatedAt = now

        record.customValueArray.forEach(viewContext.delete)

        customItems.forEach { item in
            guard let itemID = item.id, selectedItemIDs.contains(itemID) else { return }

            let value = CustomValue(context: viewContext)
            value.id = UUID()
            value.boolValue = true
            value.createdAt = now
            value.updatedAt = now
            value.item = item
            value.record = record
        }

        syncListItem(for: record, at: now)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            assertionFailure("Failed to save record: \(error.localizedDescription)")
        }
    }

    private func syncListItem(for record: Record, at date: Date) {
        let existingItems = (record.listItems as? Set<SavedListItem> ?? [])

        if saveToList {
            let item = existingItems.first ?? SavedListItem(context: viewContext)
            item.id = item.id ?? UUID()
            item.record = record
            item.date = record.date
            item.note = record.note
            item.updatedAt = date
            item.createdAt = item.createdAt ?? date
        } else {
            existingItems.forEach(viewContext.delete)
        }
    }

    private func fetchRecord(for date: Date) -> Record? {
        let request: NSFetchRequest<Record> = Record.fetchRequest()
        let calendar = Calendar.current
        let start = date.startOfDay(using: calendar)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return nil
        }

        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)

        return try? viewContext.fetch(request).first
    }
}

struct DayEditorView_Previews: PreviewProvider {
    static var previews: some View {
        DayEditorView(date: .now)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
