# 週期一 (Day 1 ~ Day 5)：語言心智映射與 SwiftUI 佈局基石

> **週期目標**：解鎖 Swift 語法心智模型，完成宣告式佈局（Compose ➔ SwiftUI）概念置換，搭建出具備「雙分類入口選擇」與「通用卡片網格清單 + 詳情跳轉」的現代 iOS 導航骨架。  
> **最終交付目標**：為 30 天最終專案（對標雙分類、遠端 API、分頁加載、本機 DB 快取架構）打下穩固的 UI 與導航基礎。  
> **建議學習時間**：每天 1~2 小時

---

## Day 1: Swift 與 Kotlin 基礎語法映射與空安全（Optionals）

### 1. 核心觀念深入解析（7 年 Android 視角的語意對照）

身為資深 Android 工程師，你已經熟悉 Kotlin 的型別推導與空安全機制。學習 Swift 時，最關鍵的是理解兩者在編譯期檢查與解包作用域上的設計哲學差異。

#### (1) 常數與變數
* **Kotlin**：`val`（唯讀變數）、`var`（可變變數）。
* **Swift**：`let`（唯讀常數）、`var`（可變變數）。
* **編譯器哲學**：Swift 編譯器對未修改的 `var` 非常敏感，若變數後續未發生變更，Xcode 會強制跳出 Warning 建議改為 `let`。在 Swift 實務中，**預設一律先宣告為 `let`，直到確定需要改變時才改為 `var`**。

#### (2) 空安全心智模型（Optionals）
Swift 的 `Optional` 在底層是一個帶泛型的列舉：
```swift
enum Optional<Wrapped> {
    case none
    case some(Wrapped)
}
```

在 Kotlin 中，你習慣依賴 Smart Cast（例如 `if (str != null) str.length`）或 Scope Function `str?.let { ... }`。  
而在 Swift 中，解包有明確的作用域邊界與工程規範：

##### ① `guard let`（Swift 最推崇的「提早退出 Early Exit」哲學）
這是 Swift 最具特色的語言特性之一。當前置條件不成立時，強制在 `else` 區塊內離開目前作用域（`return`、`throw` 或 `break`）。**通過驗證後的變數，在整個函式後續的所有程式碼中直接保證為「非空型別」，不需巢狀縮排**：

```swift
func displayUserProfile(id: Int?, username: String?) {
    // 同時解包多個可空值，並能直接串接布林條件驗證！
    guard let id = id, id > 0,
          let username = username, !username.trimmingCharacters(in: .whitespaces).isEmpty else {
        print("❌ 驗證失敗：無效的使用者 ID 或名稱")
        return
    }
    
    // 從這裡開始，id 是 Int，username 是 String（非 Optional）
    print("✅ 使用者 [\(id)]: \(username)")
}
```

##### ② `if let`（局部作用域解包）
對應 Kotlin 的 `obj?.let { value -> ... }`。解包後的變數只在 `if` 區塊的大括號內有效：
```swift
let email: String? = "user@example.com"

if let validEmail = email {
    sendNotification(to: validEmail) // 僅在此區塊內 validEmail 為 String
}
```

##### ③ 空合併運算子 `??`（對標 Kotlin Elvis 運算子 `?:`）
```swift
let nickname: String? = nil
let username: String? = "Alex"
// 若 nickname 為 nil 則看 username，皆為 nil 則給預設值
let displayName = nickname ?? username ?? "訪客"
```

##### ④ 可選鏈（Optional Chaining `?.`）
與 Kotlin 一致，若中間鏈結任一節點為 `nil`，整個表達式立即短路返回 `nil`：
```swift
let streetName = user?.address?.street?.name
```

> ⚠️ **Android 工程師常見踩坑點**：
> 1. **強制解包 `!`（對標 Kotlin `!!`）**：例如 `user!.name`。若值為 `nil`，執行期直接崩潰（Fatal Error）。除極少數架構初始化場景外，嚴格禁止在業務代碼中使用。
> 2. **字串插值（String Interpolation）**：Kotlin 使用 `"$id ${user.name}"`；Swift 使用 `"\(id) \(user.name)"`，反斜線括號內可放置任意運算式。

---

### 2. 今日實作練習題（直接在 VS Code 或 [SwiftFiddle](https://swiftfiddle.com/) 練習）

以下提供完整的通用工程練習題目與測試案例。你可以將下方代碼複製到你的練習環境，完成其中的 4 個任務：

```swift
import Foundation

// MARK: - 模擬情境：解析後端回傳的使用者個人資料（所有欄位皆可能為 nil）
struct RawUserResponse {
    let id: Int?
    let username: String?
    let email: String?
    let roles: [String]?
    let bio: String?
}

// MARK: - 請完成此資料解析函式
func processUserProfile(response: RawUserResponse) {
    // 【任務 1：使用 guard let 做嚴格前置驗證（Early Exit）】
    // 規則：id 必須非空且 > 0；username 必須非空且去除空白後不為空字串。
    // 條件若不符，印出 "❌ 驗證失敗：無效的使用者 ID 或名稱" 並直接 return。
    
    
    // 【任務 2：使用 ?? 空合併運算子取得主角色】
    // 規則：取 roles 的第一個元素，若 roles 為 nil 或為空陣列，預設角色為 "Guest"。
    
    
    // 【任務 3：使用 if let 或空合併處理可選資訊】
    // 規則：email 若有值則使用，若為 nil 則顯示 "未提供 Email"；
    //       bio 若有值則使用，若為 nil 則顯示 "尚未填寫個人簡介"。
    
    
    // 【任務 4：使用字串插值 \( ) 印出格式化名片】
    // 預期輸出格式：
    // ✅ 使用者 [101] Alex (角色: Admin)
    //    Email: alex@example.com
    //    簡介: Senior Mobile Engineer
}

// MARK: - 測試案例驗證
print("--- 測試 1：正常完整資料 ---")
let validUser = RawUserResponse(
    id: 101,
    username: "Alex",
    email: "alex@example.com",
    roles: ["Admin", "Developer"],
    bio: "Senior Mobile Engineer"
)
processUserProfile(response: validUser)

print("\n--- 測試 2：邊界缺漏欄位資料 ---")
let partialUser = RawUserResponse(
    id: 102,
    username: "Sam",
    email: nil,
    roles: nil,
    bio: nil
)
processUserProfile(response: partialUser)

print("\n--- 測試 3：無效異常資料 ---")
let invalidUser = RawUserResponse(
    id: -1,
    username: "   ",
    email: nil,
    roles: nil,
    bio: nil
)
processUserProfile(response: invalidUser)
```

#### 預期執行結果對照：
```text
--- 測試 1：正常完整資料 ---
✅ 使用者 [101] Alex (角色: Admin)
   Email: alex@example.com
   簡介: Senior Mobile Engineer

--- 測試 2：邊界缺漏欄位資料 ---
✅ 使用者 [102] Sam (角色: Guest)
   Email: 未提供 Email
   簡介: 尚未填寫個人簡介

--- 測試 3：無效異常資料 ---
❌ 驗證失敗：無效的使用者 ID 或名稱
```

---

### 3. 當日交付成果與檢驗指標
* [ ] 熟練運用 `guard let` 與 `if let` 的使用邊界，體會提早退出（Early Exit）的代碼清晰度。
* [ ] 理解 `??` 在陣列可空元素（`roles?.first ?? "Guest"`）上的連續解包技巧。
* [ ] 正確使用 `\()` 進行字串插值與格式化輸出。

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
