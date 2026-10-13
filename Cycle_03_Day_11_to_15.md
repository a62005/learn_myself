# 週期三 (Day 11 ~ Day 15)：Clean MVVM 與 API 實戰（雙圖鑑動態串接）

> **專案標竿**：對標 [PokemonXDigimonBook](https://github.com/a62005/PokemonXDigimonBook) 的 `HttpClientImp.kt`、`PokemonRepository.kt` 與 `DigimonRepository.kt`。  
> **週期目標**：封裝通用 API Client，實作分頁滾動載入（Pagination），建立 Pokemon 與 Digimon 雙 Repository，並搭建 iOS 17+ SwiftData 怪獸資料庫實體。  
> **建議學習時間**：每天 1~2 小時

---

## Day 11: 泛型 API Client 封裝（對照 HttpClientImp 與 ApiResponseData）

### 1. 核心觀念深入解析（Android vs iOS 對照）

在你的 Android `lib_network` 中，封裝了 `HttpClientImp` 與 `ApiResponseData<T>`：
```kotlin
// Android 原版
data class ApiResponseData<T>(
    val data: T? = null,
    val hasError: Boolean = false,
    val error: ApiFailedResponse? = null
)
```

在 Swift 中，我們利用原生的 `Result<T, AppError>` 或強型別錯誤列舉，封裝出一個無第三方庫依賴的現代網路客戶端：

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(code: Int, message: String)
    case decodingFailed(Error)
    case connectionError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "無效的 API 網址"
        case .serverError(let code, let msg): return "伺服器錯誤 (\(code)): \(msg)"
        case .decodingFailed: return "怪獸資料解析失敗"
        case .connectionError: return "網路連線異常，請檢查網路"
        }
    }
}

actor APIClient {
    func request<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw NetworkError.connectionError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(code: -1, message: "非 HTTP 回應")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(code: httpResponse.statusCode, message: "HTTP 狀態碼異常")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Core/Network/APIClient.swift` 與 `Core/Network/NetworkError.swift`。
2. 建立 `PokemonAPI.swift` 與 `DigimonAPI.swift` 服務層，各自提供分頁與詳情拉取方法。
3. 測試邊界狀況：給予錯誤網址或模擬斷網，確認錯誤能被精確捕捉。

---

### 3. 當日交付成果與檢驗指標
* [ ] 產出乾淨、執行緒安全的通用 `APIClient`。
* [ ] 雙端 API 服務層封裝完成。

---

## Day 12: 雙 Repository 設計（Protocol DI 實戰）

### 1. 核心觀念深入解析

對照你的 Android 原版：
* `PokemonRepository`：負責協調 `PokemonDao` 與 `PokemonNetworkManager`。
* `DigimonRepository`：負責協調 `DigimonDao` 與 `DigimonNetworkManager`。
* 在 Android 中你透過 Koin 模組（`DatabaseModule`、`NetworkModule`）注入。
* 在 iOS 中，我們定義抽象協定（Protocol），並透過建構子注入：

```swift
protocol PokemonRepositoryProtocol: Sendable {
    func fetchPokemonList(offset: Int, limit: Int) async throws -> [SimplePokemonItem]
    func fetchPokemonDetail(name: String) async throws -> PokemonDetailItem
}

protocol DigimonRepositoryProtocol: Sendable {
    func fetchDigimonList(page: Int, pageSize: Int) async throws -> [SimpleDigimonItem]
    func fetchDigimonDetail(name: String) async throws -> DigimonDetailItem
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `PokemonRepositoryProtocol.swift` 與 `DigimonRepositoryProtocol.swift`。
2. 實作生產環境的 `PokemonRepository` 與 `DigimonRepository`。
3. 建立 `MockPokemonRepository`（回傳皮卡丘、小火龍等靜態 Mock 資料），注入至 Preview 中進行畫面秒級渲染。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成業務邏輯與網路層的解耦（DIP 原則）。
* [ ] 雙 Repository 架構建置完成。

---

## Day 13: 列表分頁載入更多（對照 snapshotFlow remainingItems 邏輯）

### 1. 核心觀念深入解析（Pagination 算法映射）

在你的 Android `MonsterListScreen.kt` 中，你寫了一段非常優雅的無限滾動監聽：
```kotlin
// Android 原版：監聽最後可見項，當剩餘項目 <= 8 時自動載入更多
snapshotFlow {
    val totalItems = layoutInfo.totalItemsCount
    val lastVisibleItem = layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
    totalItems > 0 && (totalItems - lastVisibleItem - 1) <= 8
}
```

在 SwiftUI 中，最原生的分頁機制是利用 `.onAppear` 修飾符：
當倒數第 5 個或最後一個 Item 在螢幕上露出（Appear）時，觸發載入更多：

```swift
LazyVGrid(columns: columns, spacing: 16) {
    ForEach(Array(monsters.enumerated()), id: \.element.id) { index, monster in
        MonsterCard(monster: monster) { ... }
            .onAppear {
                // 當滑動到接近末尾且不在載入中時，觸發 loadMore
                if index >= monsters.count - 6 && !viewModel.isLoadingMore && viewModel.hasMore {
                    viewModel.onIntent(.loadMore)
                }
            }
    }
}
```

* 頁面首次進入載入：在 `MonsterListScreen` 掛載 `.task { viewModel.onIntent(.loadInitial) }`。

---

### 2. 每日實作任務（1~2 小時）

1. 在 `PokemonViewModel` 與 `DigimonViewModel` 實作分頁狀態（`offset`、`page`、`isLoadingMore`、`hasMore`）。
2. 在網格列表加上底部載入菊花圖示（`ProgressView()`，對照 Android 的 `CircularProgressIndicator`）。
3. 在模擬器測試連續下滑，驗證能否順暢載入第 2 頁、第 3 頁（每頁 30 筆）。

---

### 3. 當日交付成果與檢驗指標
* [ ] 實現順滑無卡頓的分頁載入更多（Pagination）。
* [ ] 成功避免重複發起同一頁載入的防抖保護。

---

## Day 14: 動態資料 UI 完整串聯與 ErrorHandler

### 1. 核心觀念深入解析

對照你的 Android `ErrorHandler.kt`：
* Android 使用 Snackbar 或 Toast 提示網路異常，並在重試時重新觸發 Intent。
* 在 SwiftUI 中，我們可以用彈出式 Alert 或頂部橫條 Banner 實現：
```swift
.alert("網路連線錯誤", isPresented: $viewModel.showErrorAlert) {
    Button("重新嘗試") { viewModel.onIntent(.retry) }
    Button("取消", role: .cancel) { }
} message: {
    Text(viewModel.errorMessage)
}
```
* **下拉更新**：加上 `.refreshable { await viewModel.refresh() }`，讓玩家可以下拉重新從第 0 筆開始抓取。

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Components/ErrorHandlerView.swift`。
2. 整合 `PokemonScreen` 與 `DigimonScreen`，支援真實 API 資料顯示、下拉刷新與異常重試。
3. 實作載入中的骨架屏（Shimmer）效果。

---

### 3. 當日交付成果與檢驗指標
* [ ] 雙怪獸清單正式由真實 API 資料驅動。
* [ ] 具備健全的異常捕獲與重試回退機制。

---

## Day 15: SwiftData 核心架構（打造 PokemonEntity 與 DigimonEntity）

### 1. 核心觀念深入解析（Room vs SwiftData 實體映射）

對照你的 Android `PokemonEntity.kt` 與 `DigimonEntity.kt`：
* Android Room：`@Entity`, `@PrimaryKey`, `@Embedded val stat: Stat`
* iOS 17+ SwiftData：`@Model`

```swift
import SwiftData
import Foundation

// 寶可夢實體（對照 Room PokemonEntity）
@Model
class PokemonEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var imageUrl: String
    var height: Int
    var weight: Int
    var types: [String]
    var desc: String?
    
    // 能力值（扁平化儲存或巢狀物件）
    var hp: Int
    var attack: Int
    var defense: Int
    var speed: Int
    var exp: Int
    
    var heightInM: Double { Double(height) / 10.0 }
    var weightInKg: Double { Double(weight) / 10.0 }

    init(id: Int, name: String, imageUrl: String, height: Int, weight: Int, types: [String], hp: Int, attack: Int, defense: Int, speed: Int, exp: Int, desc: String? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.height = height
        self.weight = weight
        self.types = types
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.speed = speed
        self.exp = exp
        self.desc = desc
    }
}

// 數碼寶貝實體（對照 Room DigimonEntity）
@Model
class DigimonEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var imageUrl: String
    var types: [String]?
    var desc: String?

    init(id: Int, name: String, imageUrl: String, types: [String]? = nil, desc: String? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.types = types
        self.desc = desc
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Core/Database/Entities/PokemonEntity.swift` 與 `DigimonEntity.swift`。
2. 在 App 入口注入雙實體的 ModelContainer：
   ```swift
   .modelContainer(for: [PokemonEntity.self, DigimonEntity.self])
   ```
3. 驗證專案編譯無任何報錯。

---

### 3. 當日交付成果與檢驗指標（週期三里程碑）
* [ ] 成功在 iOS 上建立與原版 Android 欄位完全相符的資料庫實體。
* [ ] **【里程碑產出】** 雙圖鑑具備真實網路資料載入、分頁與本機資料庫運算環境。
