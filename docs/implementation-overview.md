# LadiCal 実装の見方

このファイルは、Swift や SwiftUI にまだ慣れていない状態でも、このリポジトリがどう動いているかを追えるようにするための補助仕様である。

## 1. 何の言語で書いているか

LadiCal は以下の組み合わせで実装している。

- `Swift`
  - Apple プラットフォーム向けのプログラミング言語
- `SwiftUI`
  - iPhone アプリの画面を作るための UI フレームワーク
- `Core Data`
  - アプリ内データをローカル保存するための仕組み

React や React Native ではない。

## 2. このアプリが動く流れ

起動から画面表示までの流れは、かなり単純である。

1. `LadiCalApp.swift`
   - アプリの入口
   - Core Data の保存コンテナを作る
   - 最初に `ContentView` を表示する
2. `ContentView.swift`
   - 現在は中継だけを担当する
   - `CalendarScreen` を呼び出す
3. `CalendarScreen.swift`
   - メインの月カレンダー画面
   - 保存済みの記録を読み込む
   - 日付選択と編集画面への遷移を担当する
4. `DayEditorView.swift`
   - 1日分の記録を編集する画面
   - 絵文字、トグル、メモ、リスト保存フラグを編集して保存する

## 3. SwiftUI の見方

SwiftUI では、画面を `View` という単位で書く。

例:

```swift
struct ContentView: View {
    var body: some View {
        CalendarScreen()
    }
}
```

この意味は、

- `ContentView` という画面部品を作る
- 中身は `CalendarScreen` を表示する

というだけである。

HTML や React の JSX に少し近いが、Apple 純正の書き方になっている。

## 4. よく出る書き方

### `@State`

画面の中で一時的に持つ値。

例:

```swift
@State private var selectedDate = Date()
```

これは「今選ばれている日付」を画面の中で保持している。

### `@FetchRequest`

Core Data から保存済みデータを読み込む書き方。

例:

```swift
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Record.date, ascending: true)],
    animation: .default
)
private var records: FetchedResults<Record>
```

これは「保存されている `Record` を日付順で持ってくる」という意味。

### `.sheet`

別画面を下から出す書き方。

例:

```swift
.sheet(isPresented: $isShowingEditor) {
    DayEditorView(date: selectedDate)
}
```

これは「編集画面をモーダルで開く」という意味。

## 5. Core Data の役割

LadiCal では、1日ごとの記録を Core Data に保存する。

現在の基本構造は以下の通り。

- `Record`
  - 1日分の本体データ
  - 日付、メモ、画像パスを持つ
- `CustomItem`
  - 項目定義
  - 例: 生理, 頭痛, 🙂
- `CustomValue`
  - その日のその項目が選ばれた、という保存結果
- `SavedListItem`
  - 一覧に残したいメモだけを別保存する

つまり、

- `CustomItem` = 項目の名前帳
- `Record` = 1日分の記録本体
- `CustomValue` = その日に選ばれた項目

という関係で見ればよい。

## 6. このリポジトリで最初に読む順番

初心者向けのおすすめ順はこれ。

1. `LadiCal/LadiCalApp.swift`
2. `LadiCal/ContentView.swift`
3. `LadiCal/Views/CalendarScreen.swift`
4. `LadiCal/Views/DayDetailCardView.swift`
5. `LadiCal/Views/DayEditorView.swift`
6. `LadiCal/Persistence/PersistenceController.swift`
7. `docs/data-model.md`

## 7. ファイルと役割の対応

- `LadiCal/LadiCalApp.swift`
  - アプリ全体の起点
- `LadiCal/ContentView.swift`
  - 最初の表示先
- `LadiCal/Views/CalendarScreen.swift`
  - カレンダー画面
- `LadiCal/Views/DayDetailCardView.swift`
  - カレンダー下部の詳細カード
- `LadiCal/Views/DayEditorView.swift`
  - 日付編集画面
- `LadiCal/Persistence/PersistenceController.swift`
  - 保存基盤
- `LadiCal/Models/`
  - 保存データの型
- `LadiCal/Support/`
  - 補助ロジック

## 8. 今の画面が白く見えるときに見る場所

白画面は、単に白ベース UI に見えている場合と、実行時エラーで止まっている場合がある。

確認場所は以下。

1. Xcode 上部のエラー表示
2. 左側の Issue Navigator
3. 下部のデバッグログ
4. 実行先が `iPhone Simulator` になっているか

もし実行時エラーなら、原因はログに出る。画面だけでは判断できないので、その文言を確認する必要がある。

## 9. どこまで勉強すればいいか

最初から Swift を深く学び切る必要はない。

まず理解すべき範囲はこれで十分。

- `struct`
- `var`
- `View`
- `@State`
- `@Environment`
- `@FetchRequest`
- `NavigationStack`
- `sheet`

目標は、「自分でゼロから全部書く」ことではなく、「今あるコードを読んで、少し直せる」状態にすること。
