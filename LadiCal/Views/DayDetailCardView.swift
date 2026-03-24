import SwiftUI

struct DayDetailCardView: View {
    let date: Date
    let emojis: [String]
    let note: String
    let hasImage: Bool
    let onEditTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date.formatted(.dateTime.year().month().day().weekday()))
                        .font(.headline)

                    Text(emojis.joined(separator: " "))
                        .font(.title2)
                }

                Spacer()

                Button("編集", action: onEditTapped)
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
            }

            Text(note)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if hasImage {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.12))
                    .frame(height: 120)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                            Text("画像サムネイル")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondary.opacity(0.08))
        )
    }
}

struct DayDetailCardView_Previews: PreviewProvider {
    static var previews: some View {
        DayDetailCardView(
            date: .now,
            emojis: ["🙂", "🌙"],
            note: "選択日の詳細をここに表示します。",
            hasImage: true,
            onEditTapped: {}
        )
        .padding()
    }
}
