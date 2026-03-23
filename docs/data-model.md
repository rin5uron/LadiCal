# LadiCal データモデル

## 1. このドキュメントの目的

このドキュメントは、LadiCal で「何をどう保存するか」を初心者向けに整理したもの。

ここでいうデータモデルは、アプリの中にある情報の箱分けルールのこと。

例:

- 1日分の記録はどこに入れるか
- 絵文字や ON / OFF 項目はどこに入れるか
- 画像はどこに入れるか

## 2. 現時点の前提

現時点では、以下の方針で進める。

- 1日につき記録は 1 個
- メモは 1 日に 1 つ
- 画像は 1 日に 0 枚または 1 枚
- 絵文字と ON / OFF 項目は、同じ `CustomItem` の仲間として扱う
- 絵文字は「最初からある一覧から選ぶ」が基本
- 将来はユーザーが絵文字カテゴリや項目を追加できるようにする

## 3. 情報の箱

初期設計では、主に次の 3 つの箱を使う。

### 3.1 Record

`Record` は「1日分の記録」を入れる箱。

例:

- 2026-03-23 の記録
- メモ
- 画像 1 枚

### 3.2 CustomItem

`CustomItem` は「選べる項目の定義」を入れる箱。

例:

- 生理
- 頭痛
- 手荒れ
- 😵
- 🙂 

つまり、絵文字も ON / OFF 項目も、どちらも `CustomItem` の一種とする。

違いは、項目の種類だけ。

- `toggle`: ON / OFF で記録する項目
- `emoji`: 絵文字として選ぶ項目

### 3.3 CustomValue

`CustomValue` は「その日、その項目がどうだったか」を入れる箱。

例:

- 2026-03-23 の「生理」 = ON
- 2026-03-23 の「頭痛」 = OFF
- 2026-03-23 の「😵」 = 選択済み

## 4. 3つの箱の関係

イメージはこう。

```text
Record
- 2026-03-23
- note = "少しつらい"
- imagePath = "..."

CustomItem
- 生理      type=toggle
- 頭痛      type=toggle
- 😵        type=emoji
- 🙂        type=emoji

CustomValue
- 2026-03-23 x 生理 = true
- 2026-03-23 x 頭痛 = false
- 2026-03-23 x 😵 = true
- 2026-03-23 x 🙂 = false
```

実際の保存では、`CustomValue` は ON のものだけ保存する。

## 5. MVP のシンプルな考え方

MVP では、まず次のように考える。

- `Record` は 1 日に 1 件だけ
- `Record` の中にはメモ 1 つと画像 1 枚だけ持つ
- 絵文字もトグルも、選択肢そのものは `CustomItem`
- その日の選択結果は `CustomValue`

これで、

- カレンダーに表示する
- 日付ごとに編集する
- CSV に出す
- 後で項目を増やす

がやりやすくなる。

## 6. 現時点のエンティティ案

### 6.1 Record

持つものの案:

- `id`
- `date`
- `note`
- `imagePath`
- `createdAt`
- `updatedAt`

補足:

- `imagePath` は、画像ファイルそのものではなく「画像の保存場所」を持つ想定
- 画像がない日は `nil` にする
- 画像は写真ライブラリから選べるが、保存時にはアプリ専用のローカル領域へコピーする

### 6.2 CustomItem

持つものの案:

- `id`
- `name`
- `type`
- `emoji`
- `isEnabled`
- `sortOrder`
- `iconImagePath`
- `createdAt`
- `updatedAt`

補足:

- `type` は `toggle` または `emoji`
- `emoji` は絵文字項目のときだけ使う
- `iconImagePath` は、将来「各項目に画像を設定したい」案に備えた候補

### 6.3 CustomValue

持つものの案:

- `id`
- `recordId`
- `itemId`
- `boolValue`
- `createdAt`
- `updatedAt`

補足:

- MVP では ON のものだけ保存する
- 絵文字は「選んだものだけ保存する」
- トグルは「ON のものだけ保存する」
- 保存されていない項目は OFF とみなす

### 6.4 SavedListItem

`SavedListItem` は「一覧に残したいメモだけを保存する箱」。

`Record` の内容をそのまま自動で一覧化するのではなく、ユーザーが保存したいものだけを別で持つ。

持つものの案:

- `id`
- `recordId`
- `date`
- `note`
- `url`
- `createdAt`
- `updatedAt`

補足:

- 元の `Record` との関連を持つ
- 一覧に残したいメモだけ保存する
- 一覧の見出しは、まず日付を使う
- 将来、一覧専用タイトルやタグを足しやすい

## 7. 確定した運用ルール

- `Record` は 1 日に 1 件
- メモは 1 日に 1 つ
- 画像は 1 日に 0 枚または 1 枚
- 絵文字と ON / OFF 項目はどちらも `CustomItem`
- `CustomValue` は ON のものだけ保存する
- リスト機能は `SavedListItem` を別に持つ
- リスト一覧の見出しは日付を使う
- 無効化した `CustomItem` は新規入力では非表示にする
- 無効化した `CustomItem` でも、過去データには表示する
- 画像は写真ライブラリから選択し、アプリ専用ローカル領域へコピー保存する

## 8. Core Data にするときの考え方

初心者向けに言うと、Core Data では次のような対応になる。

- `Record` = 日付ごとの本体データ
- `CustomItem` = 設定で管理する項目マスター
- `CustomValue` = その日の選択結果
- `SavedListItem` = 一覧に残したいメモ

関連のイメージ:

- `Record` 1件 に対して `CustomValue` は複数ぶら下がる
- `CustomItem` 1件 は複数日の `CustomValue` から参照される
- `SavedListItem` は `Record` を参照する

## 9. まだ未確定のこと

次の点は、対話で決める必要がある。

- 画像をアプリ内でどういうフォルダ構成にするか

## 10. 将来の拡張

あとで必要になったら、次を追加できる。

- 複数メモ
- 画像 3 枚まで
- 数値項目
- 絵文字カテゴリ
- 周期管理や妊娠モード専用データ
