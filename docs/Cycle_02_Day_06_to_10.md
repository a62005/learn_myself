# 週期二 (Day 6 ~ Day 10)：現代狀態管理與非同步並發

> **週期目標**：將專案狀態持有模式升級至 iOS 17+ `@Observable` 巨集，深入詳情頁數值儀表板與標籤排版，掌握 Swift Concurrency（非同步並發與 Actor 執行緒安全），並建立起原生 HTTP 網路連線與 JSON 自動反序列化架構。  
> **最終交付目標**：打通現代非同步通信管道，為雙分類遠端 API 的動態抓取與快取做好準備。  
> **建議學習時間**：每天 1~2 小時

---

## Day 6: 現代狀態持有者 `@Observable`（對比 BaseViewModel 與 StateFlow）

### 1. 核心觀念深入解析（Android vs iOS 對照）

在 Android 中，你習慣使用 ViewModel + StateFlow 的 MVI / MVVM 模式：
```kotlin
// Android 原版
abstract class BaseViewModel<I : BaseIntent, S : BaseUiState> : ViewModel() {
    private val _uiState = MutableStateFlow<S>(initialState)
    val uiState: StateFlow<S> = _uiState.asStateFlow()
}
```

在 iOS 17+ 中，Apple 推出了最新的 **`@Observable` 巨集**，其追蹤粒度精確到單一屬性，不需要再手動寫 `MutableStateFlow` 或舊版的 `@Published`：

```swift
import SwiftUI
import Observation

@Observable
@MainActor // 標記在主執行緒執行
class ItemListViewModel {
    var state: ListUIState<ItemModel> = .idle
    var isLoadingMore: Bool = false
    var hasMore: Bool = true
    
    // 依據 Intent / Action 驅動狀態流轉
    func onAction(_ action: ListAction) {
        switch action {
        case .loadInitial:
            loadFirstPage()
        case .loadMore:
            loadNextPage()
        case .retry:
            loadFirstPage()
        }
    }
    
    private func loadFirstPage() {
        state = .loading
        // 非同步拉取資料
    }
}
```

* **在 View 中使用**：
  ```swift
  struct ItemListView: View {
      @State private var viewModel = ItemListViewModel()
      
      var body: some View {
          // 直接讀取 viewModel.state，系統自動感知並精確重繪
      }
  }
  ```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `MVI/ListAction.swift` 與通用狀態列舉。
2. 建立 `ViewModels/ItemListViewModel.swift`，使用 `@Observable` 管理列表、加載中與分頁標記。
3. 撰寫模擬資料的狀態轉移方法（`.idle` ➔ `.loading` ➔ `.success`）。
4. 在 View 端透過 `@State private var viewModel` 綁定，驗證狀態變更時的自動響應。

---

### 3. 當日交付成果與檢驗指標
* [ ] 掌握 `@Observable` 的微粒度追蹤優勢與 `@MainActor` 保護。
* [ ] 完成 ViewModel 與 View 的單向資料流綁定。

---

## Day 7: 詳情頁 UI 深入實作（數值儀表板與規格標籤）

### 1. 核心觀念深入解析

在詳情頁中，常見的資訊架構包含：頂部封面大圖、分類標籤、規格網格（如尺寸、數值指標）、以及動態數值進度條（Progress Bar）。

#### SwiftUI 動態數值進度條實作
```swift
struct MetricBarView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let tintColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .leading)
            
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 36, alignment: .trailing)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    Capsule()
                        .fill(tintColor)
                        .frame(width: geometry.size.width * CGFloat(min(value, maxValue)) / CGFloat(maxValue))
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Components/MetricBarView.swift`。
2. 實作通用詳情頁面 `DetailScreen.swift`：
   * 包含大圖縮放展示、標題與屬性標籤。
   * 使用 `LazyVGrid` 排版核心參數網格。
   * 加入多組 `MetricBarView` 顯示各項評分/數值條。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成高完成度、具備層次感的標準詳情頁 UI。
* [ ] 掌握 `GeometryReader` 計算相對寬度的技巧。

---

## Day 8: Swift Concurrency 基礎（async / await & Task）

### 1. 核心觀念深入解析（Android vs iOS 對照）

你對 Kotlin Coroutines 的非同步機制非常熟悉，Swift Concurrency 在語義上幾乎完美對標：

| Kotlin Coroutines | Swift Concurrency | 概念說明 |
| :--- | :--- | :--- |
| `suspend fun fetchData(): List<T>` | `func fetchData() async throws -> [T]` | 暫停點標記（非阻塞等待） |
| `val result = fetchData()` | `let result = try await fetchData()` | 呼叫掛起函式 |
| `CoroutineScope.launch { }` | `Task { }` | 從同步環境開啟非同步作用域 |
| `coroutineScope { async { } }` | `async let first = ...` | 平行發起子任務（結構化並發） |
| `job.cancel()` | `task.cancel()` | 協同取消機制 |

#### 結構化並行實戰範例：
```swift
// 同時發起兩個非同步請求並等待兩者都完成（對應 Kotlin async + awaitAll）
func loadDashboardData() async throws -> DashboardData {
    async let firstFeed = fetchCategoryA()
    async let secondFeed = fetchCategoryB()
    
    // 平行執行，在此處等待兩者結果合併
    let (dataA, dataB) = try await (firstFeed, secondFeed)
    return DashboardData(feedA: dataA, feedB: dataB)
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 撰寫模擬延遲的非同步方法：`func simulateFetch() async throws -> [Item]`。
2. 實作 `async let` 平行發起多個任務並統計總耗時，印證並發執行效能。
3. 練習在 `Task` 內檢查取消標記：`try Task.checkCancellation()`。

---

### 3. 當日交付成果與檢驗指標
* [ ] 熟練運用 `async`、`await`、`throws`、`try` 語法組合。
* [ ] 理解結構化並發的生命週期與異常傳播途徑。

---

## Day 9: 執行緒調度與安全（@MainActor 與 Actor）

### 1. 核心觀念深入解析

#### (1) `@MainActor`：主執行緒的守護者
* 在 Android 中，若在背景執行緒更新 UI 會拋出 `CalledFromWrongThreadException`。
* 在 Swift 中，將 ViewModel 或 UI 類別標記為 `@MainActor`，編譯期將自動強制所有狀態變更都在 Main Thread 執行，徹底免除多執行緒切換錯誤。

#### (2) `actor` 模型實作通用快取
* Android 中處理多執行緒競爭（Race Condition）通常需要用 Lock、Mutex 或 Atomic 物件。
* Swift 引入了 **Actor 模型**：同一時刻只允許一個執行緒存取其內部的 Mutable State，天然免除鎖與競爭：
  ```swift
  actor MemoryCache<Key: Hashable, Value> {
      private var storage: [Key: Value] = [:]
      
      func save(value: Value, for key: Key) {
          storage[key] = value
      }
      
      func get(for key: Key) -> Value? {
          return storage[key]
      }
  }
  
  // 在外部存取 actor 的方法時，必須加上 await！
  let cachedItem = await cache.get(for: "item_01")
  ```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Core/Services/MemoryCache.swift`，實作通用的鍵值快取 Actor。
2. 為所有 ViewModel 加上 `@MainActor` 標記，確認編譯期無任何 Concurrency Warning。

---

### 3. 當日交付成果與檢驗指標
* [ ] 掌握 Actor 隔離機制與多執行緒安全概念。
* [ ] 產出執行緒安全的 Actor 快取模組。

---

## Day 10: 原生網路層基礎（URLSession + Codable）

### 1. 核心觀念深入解析

在 Android 你使用 Retrofit + Moshi / Gson。現代 iOS 開發中，**原生工具已經足夠強大，不需要第三方 HTTP 庫**：

#### (1) `URLSession.shared.data(from:)`
```swift
let url = URL(string: "https://api.example.com/v1/items?page=1")!
let (data, response) = try await URLSession.shared.data(from: url)

// 檢查 HTTP 狀態碼
guard let httpResponse = response as? HTTPURLResponse, 
      (200...299).contains(httpResponse.statusCode) else {
    throw URLError(.badServerResponse)
}
```

#### (2) `Codable` 序列化對照
```swift
// 對應 Kotlinx.Serialization 的 @Serializable
struct ItemResponseDTO: Decodable {
    let id: Int
    let name: String
    let imageUrl: String
    let createdAt: String?

    // 對應 Kotlin 的 @SerialName
    enum CodingKeys: String, CodingKey {
        case id, name
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Core/Network/DTOs/ItemResponseDTO.swift`。
2. 撰寫一個標準網路拉取函式：
   * 發起 `URLSession` 請求。
   * 使用 `JSONDecoder()` 反序列化回 DTO 陣列。
   * 撰寫 Mapper 方法：將 DTO 轉換為領域層模型 `ItemModel`。
3. 測試呼叫真實公開 API，在 Console 印出解析後的資料。

---

### 3. 當日交付成果與檢驗指標（週期二里程碑）
* [ ] 成功取得外部真實 API 資料並完成反序列化。
* [ ] **【里程碑產出】** 專案具備完整 Swift Concurrency、線程安全快取與原生 HTTP 解析能力。
