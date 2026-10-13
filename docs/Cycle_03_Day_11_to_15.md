# 週期三 (Day 11 ~ Day 15)：Clean MVVM 與 API 實戰

> **週期目標**：封裝企業級通用網路層，實作輕量依賴注入（Protocol-based DI），無縫銜接畫面非同步生命週期（`.task` 與下拉更新），實作分頁滾動載入機制，並建置 iOS 17+ SwiftData 持久化資料庫。  
> **最終交付目標**：打通 View ➔ ViewModel ➔ Repository ➔ Remote API / SwiftData DB 的完整 Clean 架構鏈條。  
> **建議學習時間**：每天 1~2 小時

---

## Day 11: 泛型 API Client 封裝與強型別錯誤處理

### 1. 核心觀念深入解析（Android vs iOS 對照）

在 Android 中，你使用 Retrofit + OkHttp Interceptor 封裝網路。在 iOS 中，運用 Swift 強大的泛型與協定，打造出一個不需要註解處理器（KAPT/KSP）的通用 API Client：

#### (1) 定義 Endpoint 規格協定
```swift
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
}
```

#### (2) 強型別錯誤列舉
```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(statusCode: Int, message: String)
    case decodingError(Error)
    case noInternet
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "無效的伺服器地址"
        case .serverError(let code, let msg): return "伺服器錯誤 (\(code)): \(msg)"
        case .decodingError: return "資料解析失敗"
        case .noInternet: return "請確認網路連線"
        }
    }
}
```

#### (3) 泛型 Request 實作
```swift
actor APIClient {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // 1. 組裝 URL 與 Query 參數
        // 2. URLSession.shared.data(for:) 請求
        // 3. 檢查 HTTP 狀態碼 (200...299)
        // 4. JSONDecoder 解碼並回傳強型別物件 T
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Core/Network/Endpoint.swift` 與 `Core/Network/NetworkError.swift`。
2. 實作 `Core/Network/APIClient.swift`，包含狀態碼過濾與超時處理。
3. 測試邊界狀況：輸入無效網址或斷網，驗證能精準拋出 `NetworkError`。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成一個不依賴第三方框架的純 Swift 泛型 `APIClient`。
* [ ] 錯誤能被轉譯為可讀的 `NetworkError`。

---

## Day 12: 依賴注入（DI）與 Repository 模式

### 1. 核心觀念深入解析

#### (1) Android Hilt/Koin vs iOS Protocol DI
* 在 Android 中，你習慣使用 Hilt 進行依賴注入。
* 在 iOS 中，資深架構師更傾向於使用 **Protocol-based Constructor Injection**，清晰、易於追蹤且編譯極快：

```swift
// 1. 定義抽象協定
protocol ItemRepositoryProtocol: Sendable {
    func fetchList(page: Int, pageSize: Int) async throws -> [ItemModel]
    func fetchDetail(id: Int) async throws -> ItemDetailModel
}

// 2. 生產環境實作
class ItemRepository: ItemRepositoryProtocol {
    private let apiClient: APIClient
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchList(page: Int, pageSize: Int) async throws -> [ItemModel] {
        // 呼叫 APIClient 並透過 Mapper 轉成領域層模型
    }
}

// 3. 測試用 Mock 實作
class MockItemRepository: ItemRepositoryProtocol {
    var stubbedList: [ItemModel] = []
    func fetchList(page: Int, pageSize: Int) async throws -> [ItemModel] { stubbedList }
}
```

#### (2) ViewModel 注入
```swift
@Observable
@MainActor
class ItemListViewModel {
    private let repository: ItemRepositoryProtocol
    
    // 預設參數注入：既支援 Production 又支援單元測試與 Preview 傳入 Mock
    init(repository: ItemRepositoryProtocol = ItemRepository()) {
        self.repository = repository
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `ItemRepositoryProtocol.swift` 與實作類別。
2. 將 DTO 轉 Domain Model 的 Mapper 方法封裝進 Repository。
3. 改寫 ViewModel，讓其完全依賴抽象協定。
4. 建立 `MockItemRepository`，在 Xcode `#Preview` 中傳入假資料驗證畫面渲染。

---

### 3. 當日交付成果與檢驗指標
* [ ] 達成領域層（Domain）與網路層（Data）的乾淨分離（DIP 原則）。
* [ ] Preview 能夠在不連網的情況下秒級加載 Mock 畫面。

---

## Day 13: 畫面生命週期與分頁載入（Pagination 算法）

### 1. 核心觀念深入解析（Android vs iOS 對照）

#### (1) `.task { }` vs `LaunchedEffect`
* 在 Compose 中，你習慣寫 `LaunchedEffect(Unit) { viewModel.fetchData() }`。
* 在 SwiftUI 中，使用 `.task { }` 修飾符：
  ```swift
  .task {
      await viewModel.loadInitialData()
  }
  ```
* **生命週期保護**：當使用者離開當前 View 時，SwiftUI 會**自動取消此 `.task`**，避免無謂頻寬與背景記憶體浪費。

#### (2) 分頁滾動載入更多（Pagination）
在雙欄網格或列表滑動時，當使用者接近底部時自動加載下一頁：
```swift
LazyVGrid(columns: columns, spacing: 16) {
    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
        ItemCard(item: item)
            .onAppear {
                // 當滑動到剩餘倒數 6 筆，且不在加載中時，觸發載入更多
                if index >= items.count - 6 && !viewModel.isLoadingMore && viewModel.hasMore {
                    viewModel.onAction(.loadMore)
                }
            }
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 在 ViewModel 實作分頁狀態（`currentPage`、`isLoadingMore`、`hasMore`）。
2. 在網格列表加上底部載入指示器（`ProgressView()`）。
3. 串接 `.refreshable` 下拉更新，實作重新從第一頁拉取的重置邏輯。

---

### 3. 當日交付成果與檢驗指標
* [ ] 熟練掌控 View 的非同步生命週期取消機制。
* [ ] 實作絲滑的分頁滾動加載與下拉刷新。

---

## Day 14: 動態資料 UI 完整串聯與錯誤重試

### 1. 核心觀念深入解析

資深工程師的 App 具備健全的狀態防禦體系：
* **骨架屏（Shimmer）**：使用 SwiftUI `.redacted(reason: .placeholder)`，一行代碼即可將既有的 View 變成優雅的載入佔位骨架屏！
* **錯誤重試卡片（ErrorView）**：包含警告圖標、錯誤描述與 `Button("重試")`。

```swift
var body: some View {
    switch viewModel.state {
    case .idle, .loading:
        ShimmerLoadingGrid()
    case .success(let items):
        MainGridView(items: items)
    case .error(let message):
        ErrorRetryView(message: message) {
            viewModel.onAction(.retry)
        }
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Components/ErrorRetryView.swift`。
2. 建立 `Components/ShimmerLoadingView.swift`，利用 `.redacted` 實現骨架屏。
3. 測試開關網路（模擬斷網），確認重試機制運作無誤。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成防禦式 UI 狀態處理，徹底消除白屏與無提示異常。
* [ ] 列表動態資料流串聯全面完工。

---

## Day 15: SwiftData 核心架構（iOS 17+ 現代 ORM）

### 1. 核心觀念深入解析（Android Room vs SwiftData）

#### (1) 宣告式實體
* **Android Room**：你需要定義 `@Entity`、`@Dao`（寫 SQL 或方法標記）、`@Database`，並手動維護 Migration。
* **SwiftData (iOS 17+)**：Apple 的最新架構，完全拋棄傳統 Core Data 冗長的 XML 與樣板代碼：
  ```swift
  import SwiftData

  @Model
  class ItemEntity {
      @Attribute(.unique) var id: Int
      var name: String
      var imageUrl: String
      var category: String
      var score: Int
      var desc: String?
      var updatedAt: Date
      
      init(id: Int, name: String, imageUrl: String, category: String, score: Int, desc: String? = nil, updatedAt: Date = Date()) {
          self.id = id
          self.name = name
          self.imageUrl = imageUrl
          self.category = category
          self.score = score
          self.desc = desc
          self.updatedAt = updatedAt
      }
  }
  ```

#### (2) 注入與上下文容器
在 App 入口注入資料庫容器（對應 Room Database 初始化）：
```swift
@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            AppNavigation()
        }
        .modelContainer(for: ItemEntity.self) // 注入 ModelContainer
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Core/Database/Entities/ItemEntity.swift`。
2. 在 App 入口配置 `.modelContainer(for: ItemEntity.self)`。
3. 撰寫一個輕量資料庫輔助方法，練習進行實體建立與存儲。

---

### 3. 當日交付成果與檢驗指標（週期三里程碑）
* [ ] 成功配置 SwiftData 運行環境，無編譯錯誤。
* [ ] **【里程碑產出】** 專案完整打通 Clean MVVM（View ➔ ViewModel ➔ Repository ➔ APIClient）並具備資料庫擴展能力。
