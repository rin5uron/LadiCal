import SwiftUI

struct ContentView: View {
    var body: some View {
        // いまの実装では、アプリ起動直後にカレンダー画面をそのまま出す。
        CalendarScreen()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
