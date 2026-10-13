# 週期一 (Day 1 ~ Day 5)：語言心智映射與 SwiftUI 佈局基石

> **週期目標**：解鎖 Swift 語法心智模型，完成宣告式佈局（Compose ➔ SwiftUI）概念置換，搭建出具備「雙分類入口選擇」與「通用卡片網格清單 + 詳情跳轉」的現代 iOS 導航骨架。  
> **最終交付目標**：為 30 天最終專案（對標雙分類、遠端 API、分頁加載、本機 DB 快取架構）打下穩固的 UI 與導航基礎。  
> **建議學習時間**：每天 1~2 小時

---

## Day 1: Swift 與 Kotlin 基礎語法映射與空安全（Optionals）

### 1. 核心觀念深入解析（Android vs iOS 對照）

身為 7 年 Android 資深工程師，在轉換到 Swift 時，首要任務是掌握型別推導與空安全機制的語意差異：

#### (1) 常數與變數
* Kotlin：`val`（唯讀）、`var`（可變）。
* Swift：`let`（唯讀）、`var`（可變）。
* **關鍵規則**：Swift 編譯器會嚴格檢查未曾被修改的變數，強制建議宣告為 `let`。在 Swift 工程中，預設一律先用 `let`。

#### (2) 空安全心智模型（Optionals）
Swift 的 `Optional` 本質是列舉 `enum Optional<Wrapped> { case none, case some(Wrapped) }`。
對比 Kotlin 習慣的 `?.`、`?:` 與 `let`，Swift 最關鍵的核心是「提早退出（Early Exit）」：

```swift
// 1. guard let：提早返回（Early Exit，Swift 最推崇的工程規範）
func processUserProfile(id: Int?, username: String?) {
    // 條件若不滿足，必須在 else 中 return 或 throw
    guard let id = id, id > 0,
          let username = username, !username.isEmpty else {
        print("❌ 驗證失敗：無效的使用者資料")
        return
    }
    
    // 通過驗證後，id 與 username 在後續作用域中直接作為非空型別使用
    print("✅ 使用者 [\(id)]: \(username)")
}

// 2. if let：局部作用域安全解包（對照 Kotlin 的 ?.let { }）
if let email = user.email {
    sendNotification(to: email)
}

// 3. 空合併運算子（對標 Kotlin Elvis 運算子 ?:）
let displayName = user.nickname ?? user.username ?? "訪客"
```

> ⚠️ **踩坑提醒**：
> * 切忌在生產代碼濫用強制解包 `!`（對標 Kotlin `!!`），為 nil 時會觸發 Fatal Error。
> * Swift 字串插值語法為 `"ID: \(id)"`，而非 Kotlin 的 `"$id"` 或 `"${user.id}"`。

---

### 2. 每日實作任務（1~2 小時）

1. 在 VS Code 中建立並開啟 `Day01_Syntax.swift`。
2. 實作通用資料解析函式 `parseResponseData`：
   * 定義包含可空欄位（`id: Int?`, `name: String?`, `tags: [String]?`, `bio: String?`）的資料結構。
   * 使用 `guard let` 組合驗證（ID 大於 0 且名稱非空）。
   * 使用 `??` 取得預設標籤與預設簡介。
3. 在 [SwiftFiddle](https://swiftfiddle.com/) 或本地環境驗證輸出結果。

---

### 3. 當日交付成果與檢驗指標
* [ ] 熟練掌握 `guard let` 與 `if let` 的使用邊界。
* [ ] 能自如處理可空型別的多層解包與字串插值格式化。

---

## Day 2: 結構體、協定與列舉（Swift 架構基石與 POP）

### 1. 核心觀念深入解析

這是掌握現代 iOS 架構最重要的**第一道分水嶺**：

#### (1) Struct（值型別） vs Class（參考型別）
* 在 Android 中，除了 Primitive Types 外，資料模型與多數元件皆為 Reference Type（存在 Heap）。
* 在 Swift 中，**Model 與 UI View 90% 都是 `struct`**：
  * `struct` 存放在 Stack，賦值時採用 Copy-on-Write（CoW），天然具備**執行緒安全（Thread-safe）**、無共享狀態、無記憶體洩漏風險的特質。

#### (2) Protocol 與 POP（面向協定編程）
* 對應 Kotlin 的 `interface`。但 Swift 的 Protocol 可以搭配 `extension` 提供**預設實作**：
  ```swift
  protocol IdentifiableItem {
      var id: Int { get }
      var title: String { get }
      func formattedHeader() -> String
  }

  extension IdentifiableItem {
      func formattedHeader() -> String {
          return "#\(id) \(title.capitalized)"
      }
  }
  ```

#### (3) Enum with Associated Values 實作 MVI/UIState
對標 Android 的 `sealed interface UIState`，Swift 使用帶關聯數值的列舉：
```swift
enum UIState<T> {
    case idle
    case loading
    case success(data: T)
    case error(message: String)
}

// 使用 Pattern Matching 窮舉
func render(state: UIState<[Item]>) {
    switch state {
    case .idle: break
    case .loading: showLoading()
    case .success(let items): showList(items)
    case .error(let msg): showError(msg)
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 定義通用的實體協定（如 `DisplayableItem`），包含 `id`、`name`、`imageUrl` 等屬性。
2. 建立具體遵從該協定的 `struct`，並利用 `extension` 擴充標籤格式化方法。
3. 實作通用 `UIState` 列舉，撰寫 `switch` 狀態分流邏輯。

---

### 3. 當日交付成果與檢驗指標
* [ ] 理解為什麼 SwiftUI 選擇以 `struct` + `protocol` 作為核心架構。
* [ ] 完成專案通用的 Entity Protocol 與 `UIState` 模式設計。

---

## Day 3: SwiftUI 宣告式佈局（Compose 像素級映射）

### 1. 核心觀念深入解析

你已經具備 Jetpack Compose 實戰經驗，兩者的渲染引擎心智模型皆為 `UI = f(State)`：

| Jetpack Compose | SwiftUI | 佈局行為說明 |
| :--- | :--- | :--- |
| `Column(modifier = ...)` | `VStack(spacing: ...)` | 垂直線性排列 |
| `Row(modifier = ...)` | `HStack(spacing: ...)` | 水平線性排列 |
| `Box(contentAlignment = ...)` | `ZStack(alignment: ...)` | 重疊層次排列（後寫的在最上層） |
| `Spacer(Modifier.weight(1f))` | `Spacer()` | 彈簧佔位符，撐滿剩餘空間 |
| `Text("Title")` | `Text("Title")` | 文字渲染 |
| `AsyncImage(model = ...)` | `AsyncImage(url: ...)` | 非同步圖片載入 |

#### 修飾符（Modifiers）的執行順序機制
SwiftUI 的修飾符本質是「包裝（Wrapping）」，順序極為關鍵：
```swift
Text("Label")
    .padding(8)
    .background(Color.blue) // 背景色會覆蓋包含 padding 的整個區域

Text("Label")
    .background(Color.blue) // 背景色僅貼緊文字本體
    .padding(8)
```

---

### 2. 每日實作任務（1~2 小時）

1. 實作「雙分類入口首頁」（`HomeScreen`）：
   * 垂直上下分割為兩個區塊，各自具備滿版點擊區域與大圖/文字展示。
   * 中間加上分隔線。
2. 實作清單單列/單格元件（`ItemCardView`）：
   * 包含圖片、編號標籤、標題、屬性/分類 Tag。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成美觀、結構清晰的 `HomeScreen` 與 `ItemCardView`。
* [ ] 熟練運用 `VStack`、`HStack`、`ZStack` 與修飾符鏈結。

---

## Day 4: 狀態驅動 UI（@State、@Binding 與 State Hoisting）

### 1. 核心觀念深入解析

#### (1) `@State`：私有狀態持有
* 對應 Compose 的 `var count by remember { mutableStateOf(0) }`。
* 管理 View 內部的私有狀態。當值改變時，SwiftUI 自動觸發差分重繪。
* **最佳實踐**：永遠宣告為 `private`，確保狀態只由宣告它的 View 直接擁有。

#### (2) `@Binding`：雙向狀態綁定（狀態提升 State Hoisting）
* 對應 Compose 中傳入 `value: T` 與 `onValueChange: (T) -> Unit`。
* 子視圖以 `@Binding var value: T` 接收，父層傳入時加上前綴符號 `$`（例如 `$selectedCategory`），傳遞狀態引用：

```swift
struct CategorySegmentedControl: View {
    let categories: [String]
    @Binding var selectedCategory: String // 接收外部狀態綁定

    var body: some View {
        HStack {
            ForEach(categories, id: \.self) { cat in
                Button(cat) {
                    selectedCategory = cat // 直接修改，父視圖同步刷新
                }
            }
        }
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 實作一個通用的「分類切換標籤列」（`CategoryPicker.swift`）。
2. 加入選取狀態的視覺反饋（選中底色與彈簧切換動畫）。
3. 父層透過 `@State` 持有當前選取項，子層以 `@Binding` 綁定並驗證雙向同步。

---

### 3. 當日交付成果與檢驗指標
* [ ] 深刻理解 `$` 符號（Projected Value）在 SwiftUI 中的綁定語意。
* [ ] 產出具備雙向狀態同步的通用選擇器元件。

---

## Day 5: 現代導航系統與網格列表（NavigationStack & LazyVGrid）

### 1. 核心觀念深入解析

#### (1) `NavigationStack` (iOS 16+)
* 現代 iOS 架構全面採用 `NavigationStack` 與型別安全路由（Type-safe Routing）：
  ```swift
  enum Route: Hashable {
      case list(category: String)
      case detail(id: Int, title: String)
  }

  NavigationStack(path: $navigationPath) {
      HomeScreen(...)
          .navigationDestination(for: Route.self) { route in
              switch route {
              case .list(let cat):
                  ItemListView(category: cat)
              case .detail(let id, let title):
                  ItemDetailView(id: id, title: title)
              }
          }
  }
  ```

#### (2) `LazyVGrid`：雙欄網格渲染
* 對應 Compose 的 `LazyVerticalGrid(columns = GridCells.Fixed(2))`。
* SwiftUI 使用 `LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())])` 實現高效延遲載入網格。

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Navigation/AppRoute.swift` 定義全域型別安全路由。
2. 實作雙欄網格列表頁面 `ItemGridScreen.swift`，使用假資料進行網格排版。
3. 跑通完整跳轉路徑：`HomeScreen` ➔ 點選分類 ➔ 進入雙欄網格清單 ➔ 點擊卡片跳轉至詳情頁。

---

### 3. 當日交付成果與檢驗指標（週期一里程碑）
* [ ] **【里程碑產出】** 建立起雙分類入口、雙欄網格與詳情頁的完整靜態跳轉架構。
* [ ] 熟悉 SwiftUI 現代導航與宣告式網格排版。
