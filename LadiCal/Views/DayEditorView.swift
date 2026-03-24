import SwiftUI

struct DayEditorView: View {
    let date: Date

    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmojis: Set<String> = ["🙂"]
    @State private var isPeriodEnabled = true
    @State private var isHeadacheEnabled = false
    @State private var note = ""

    private let emojiCandidates = ["🙂", "😵", "🌙", "💤", "🩸", "💊", "💧", "🥶", "🔥", "😌"]

    var body: some View {
        NavigationStack {
            Form {
                Section("日付") {
                    Text(date.formatted(.dateTime.year().month().day().weekday()))
                }

                Section("絵文字") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiCandidates, id: \.self) { emoji in
                                Button {
                                    if selectedEmojis.contains(emoji) {
                                        selectedEmojis.remove(emoji)
                                    } else {
                                        selectedEmojis.insert(emoji)
                                    }
                                } label: {
                                    Text(emoji)
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedEmojis.contains(emoji) ? Color.primary.opacity(0.15) : Color.secondary.opacity(0.08))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("カスタム項目") {
                    Toggle("項目1: 生理", isOn: $isPeriodEnabled)
                    Toggle("項目2: 頭痛", isOn: $isHeadacheEnabled)
                }

                Section("メモ") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
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
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DayEditorView_Previews: PreviewProvider {
    static var previews: some View {
        DayEditorView(date: .now)
    }
}
