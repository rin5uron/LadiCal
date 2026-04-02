import CoreData
import SwiftUI

struct CalendarScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    // 保存済み Record を日付順で読み込む。画面はこの結果をそのまま描画する。
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.date, ascending: true)],
        animation: .default
    )
    private var records: FetchedResults<Record>

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()
    @State private var isShowingEditor = false

    private let calendar = Calendar.current
    private let weekSymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                headerBar

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 18) {
                            ForEach(visibleMonths, id: \.self) { month in
                                monthSection(for: month)
                                    .id(month.startOfMonth(using: calendar))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(height: 360)
                    .onAppear {
                        proxy.scrollTo(displayedMonth.startOfMonth(using: calendar), anchor: .top)
                    }
                    .onChange(of: displayedMonth) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(displayedMonth.startOfMonth(using: calendar), anchor: .top)
                        }
                    }
                }

                DayDetailCardView(
                    date: selectedDate,
                    emojis: selectedRecord?.calendarEmojis ?? [],
                    note: selectedRecord?.note ?? "この日の記録はまだありません。",
                    hasImage: selectedRecord?.imagePath != nil,
                    onEditTapped: { isShowingEditor = true }
                )
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .sheet(isPresented: $isShowingEditor) {
                // 選択中の日付を編集するシート。
                DayEditorView(date: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private var selectedRecord: Record? {
        // カレンダーで選ばれている日の記録を探す。
        record(for: selectedDate)
    }

    private var visibleMonths: [Date] {
        (-12...12).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: Date().startOfMonth(using: calendar))
        }
    }

    private var headerBar: some View {
        HStack {
            Text(displayedMonth.formatted(.dateTime.year().month(.wide)))
                .font(.title2.weight(.semibold))
            Spacer()

            DatePicker("", selection: displayedDateBinding, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
    }

    private var displayedDateBinding: Binding<Date> {
        Binding {
            selectedDate
        } set: { newDate in
            selectedDate = newDate
            displayedMonth = newDate.startOfMonth(using: calendar)
        }
    }

    private func weekdayHeader() -> some View {
        HStack {
            ForEach(weekSymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func monthSection(for month: Date) -> some View {
        let days = makeDaysForMonth(month)

        return VStack(spacing: 10) {
            HStack {
                Text(month.formatted(.dateTime.year().month(.wide)))
                    .font(.headline)
                Spacer()
            }

            weekdayHeader()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(days) { day in
                    if let date = day.date {
                        dayCell(for: date)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.clear)
                            .frame(height: 64)
                    }
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let record = record(for: date)
        let dayEmojis = record?.calendarEmojis ?? []
        let hasNote = !(record?.note ?? "").isEmpty
        let hasPeriod = record?.hasPeriod ?? false

        return Button {
            if isSelected {
                isShowingEditor = true
            } else {
                selectedDate = date
                displayedMonth = date.startOfMonth(using: calendar)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.caption.weight(.semibold))
                    Spacer()

                    if hasNote {
                        Circle()
                            .fill(.red)
                            .frame(width: 6, height: 6)
                    }
                }

                Text(dayEmojis.prefix(2).joined(separator: " "))
                    .font(.caption2)
                    .lineLimit(1)
                    .frame(minHeight: 14, alignment: .topLeading)

                Spacer()

                Capsule()
                    .fill(hasPeriod ? .red : .clear)
                    .frame(height: 3)
            }
            .padding(8)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primary.opacity(0.12) : Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isToday ? Color.primary : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func makeDaysForMonth(_ date: Date) -> [CalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: date),
            let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let lastDay = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end),
            let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastDay)
        else {
            return []
        }

        var days: [CalendarDay] = []
        var cursor = firstWeek.start

        while cursor < lastWeek.end {
            let isCurrentMonth = calendar.isDate(cursor, equalTo: date, toGranularity: .month)
            days.append(CalendarDay(date: isCurrentMonth ? cursor : nil))
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }

        return days
    }

    private func record(for date: Date) -> Record? {
        let start = date.startOfDay(using: calendar)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return nil
        }

        // 1日1レコード前提なので、同じ日のものを1件探せば足りる。
        return records.first {
            guard let recordDate = $0.date else { return false }
            return recordDate >= start && recordDate < end
        }
    }
}

private struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
}

struct CalendarScreen_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScreen()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
