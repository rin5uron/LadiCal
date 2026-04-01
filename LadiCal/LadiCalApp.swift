import SwiftUI

@main
struct LadiCalApp: App {
    // Core Data の入口。ここで作った保存コンテナを全画面に渡す。
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // 最初に表示する画面は ContentView。
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
