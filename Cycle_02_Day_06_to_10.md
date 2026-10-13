# 週期二 (Day 6 ~ Day 10)：現代狀態管理與非同步並發（API 連線準備）

> **專案標竿**：對標 [PokemonXDigimonBook](https://github.com/a62005/PokemonXDigimonBook) 的 `lib_network` 與 ViewModel 設計。  
> **週期目標**：使用 iOS 17+ `@Observable` 升級怪獸清單 ViewModel，實作怪獸屬性數值條 UI，掌握 Swift Concurrency 並實作 PokeAPI 與 DigimonAPI 的原生網路解析層。  
> **建議學習時間**：每天 1~2 小時

---

## Day 6: 現代狀態持有者 `@Observable`（對照 BaseViewModel 與 UiState）

### 1. 核心觀念深入解析（Android vs iOS 對照）

在你的 Android 專案中，你定義了：
```kotlin
// Android 原版
abstract class BaseViewModel<T : BaseIntent, S : BaseUiState> : ViewModel() {
    private val _uiState = MutableStateFlow<S>(initialState)
    val uiState: StateFlow<S> = _uiState.asStateFlow()
}

class PokemonViewModel(...) : BaseViewModel<PokemonIntent, PokemonUiState>()
```

在 iOS 17+ 中，你可以用 `@Observable` 與 Swift 列舉達到同樣的單向資料流（UDF），甚至省去手動寫 `StateFlow` 的樣板碼：

```swift
@Observable
@MainActor
class PokemonViewModel {
    var state: ListUIState<SimplePokemonItem> = .idle
    var isLoadingMore: Bool = false
    var hasMore: Bool = true
    private var currentOffset: Int = 0
    
    func onIntent(_ intent: PokemonIntent) {
        switch intent {
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
        // 載入資料
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `MVI/PokemonIntent.swift` 與 `MVI/DigimonIntent.swift`。
2. 建立 `ViewModels/PokemonViewModel.swift` 與 `ViewModels/DigimonViewModel.swift`。
3. 在 ViewModel 中宣告相應的 `@Observable` 屬性，並先以假資料跑通 `loadInitial` 與 `loadMore` 的狀態變更。
4. 在 View 端透過 `@State private var viewModel = PokemonViewModel()` 綁定。

---

### 3. 當日交付成果與檢驗指標
* [ ] 達成與原版 Android 一致的 Intent-driven / UDF 架構思維。
* [ ] 熟練運用 `@Observable` 微粒度響應機制。

---

## Day 7: 詳情頁 UI 搭建（Stat 數值條與屬性標籤）

### 1. 核心觀念深入解析

對照你的 Android `StatItem.kt` 與 `PokemonDetailScreen.kt`：
* 詳情頁展示：
  1. 頂部大圖（利用官方的高解析度官方插畫）。
  2. 屬性標籤清單（`types: List<String>`）。
  3. 體型資訊（身高：`heightInM`、體重：`weightInKg`）。
  4. 基礎能力值條（HP, Attack, Defense, Speed, Exp）：展示數值與長條進度條（Progress Bar）。
* Digimon 詳情頁展示：屬性清單與英文敘述段落（`description`）。

#### SwiftUI 數值進度條實作範例
```swift
struct StatItemView: View {
    let statName: String
    let value: Int
    let maxValue: Int = 255
    let tintColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(statName.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
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

1. 建立 `Components/StatItemView.swift`。
2. 實作 `Views/PokemonDetailScreen.swift`，包含能力值儀表板與體型網格。
3. 實作 `Views/DigimonDetailScreen.swift`，包含屬性標籤與捲動英文描述卡片。

---

### 3. 當日交付成果與檢驗指標
* [ ] 詳情頁視覺完成度達到原版 Android 水準。
* [ ] 掌握 `GeometryReader` 計算相對進度條寬度的技巧。

---

## Day 8: Swift Concurrency 基礎（async / await & Task）

### 1. 核心觀念深入解析（Android vs iOS 對照）

你的 Android 專案在 Repository 使用 Kotlin 協程發起請求：
```kotlin
// Android 原版：PokemonRepository
suspend fun loadMorePokemon(offset: Int): ApiResponseData<Unit> = withContext(ioDispatcher) { ... }
```
在 Swift 中，非同步機制完美對標：
* `suspend fun` ➔ `async throws`
* `CoroutineScope.launch` ➔ `Task { }`
* `async { }` + `await()` ➔ `async let`

#### 結構化並行在雙圖鑑中的應用
當點擊首頁時，若想同時預先載入 Pokemon 與 Digimon 的總筆數（`maxCount`），可以利用 `async let` 平行拉取：
```swift
func prefetchCounts() async throws -> (pokemonCount: Int, digimonCount: Int) {
    async let pCount = fetchPokemonCount()
    async let dCount = fetchDigimonCount()
    return try await (pCount, dCount) // 平行發起，在此同時等待
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 在 Playground 練習使用 `async let` 與 `TaskGroup`。
2. 練習非同步任務的取消機制（`Task.checkCancellation()`）。
3. 熟悉 `Task.sleep(nanoseconds:)`，模擬網路延遲與超時測試。

---

### 3. 當日交付成果與檢驗指標
* [ ] 熟練運用 Swift Concurrency 基本語法。
* [ ] 理解非同步上下文與錯誤傳遞鏈條。

---

## Day 9: 執行緒安全與圖片快取 Actor

### 1. 核心觀念深入解析

#### (1) `@MainActor` 全域隔離
* 標記在 ViewModel 與 View 上的所有方法與狀態變更，自動由編譯器保證在主執行緒執行，杜絕 Android 的 `CalledFromWrongThreadException`。

#### (2) `actor` 模型實作圖片/資料快取
在顯示大量寶可夢與數碼寶貝清單時，我們需要一個執行緒安全的記憶體快取：
```swift
actor MonsterImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
```
* **好處**：Actor 天生免除多執行緒 Race Condition，不需像 Java/Kotlin 一樣手動寫 Synchronized 或 Mutex。

---

### 2. 每日實作任務（1~2 小時）

1. 在專案中新建 `Core/Services/MonsterImageCache.swift`。
2. 實作 Actor 記憶體快取。
3. 為 `PokemonViewModel` 與 `DigimonViewModel` 全面標記 `@MainActor`。

---

### 3. 當日交付成果與檢驗指標
* [ ] 掌握 Actor 隔離域與執行緒安全特性。
* [ ] 產出乾淨的記憶體快取 Actor 模組。

---

## Day 10: 原生網路層（對接真實 PokeAPI 與 DigimonAPI）

### 1. 核心觀念深入解析（API 格式對齊）

完全對照你的 Android `PokemonApi.kt` 與 `DigimonApi.kt`：

#### (1) 基礎端點設定（Base URL）
* **Pokemon API**：`https://pokeapi.co/api/v2/`
  * 列表：`GET pokemon?offset=0&limit=30`
  * 詳情：`GET pokemon/{id}` 或 `GET pokemon/{name}`
  * 官方大圖：`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png`
* **Digimon API**：`https://digi-api.com/api/v1/`
  * 列表：`GET digimon?pageSize=30&page=0`
  * 詳情：`GET digimon/{name}`

#### (2) Swift `Codable` DTO 定義
```swift
// Pokemon 列表 DTO
struct PokemonListResponseDTO: Decodable {
    let count: Int
    let results: [PokemonResultDTO]
}

struct PokemonResultDTO: Decodable {
    let name: String
    let url: String // 形如 "https://pokeapi.co/api/v2/pokemon/1/"
}

// Digimon 列表 DTO
struct DigimonListResponseDTO: Decodable {
    let content: [DigimonContentDTO]
    let pageable: DigimonPageableDTO
}

struct DigimonContentDTO: Decodable {
    let id: Int
    let name: String
    let image: String
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 在 `Core/Network/DTOs` 下建立 `PokemonDTO.swift` 與 `DigimonDTO.swift`。
2. 撰寫解析函式，使用 `URLSession.shared.data(from: url)` 分別打通 PokeAPI 與 DigimonAPI 的列表請求。
3. 撰寫輔助邏輯：從 PokeAPI 的 `url` 中萃取怪獸 `id`，拼出官方大圖 URL。
4. 在 Console 印出成功抓到的前 30 筆真實資料。

---

### 3. 當日交付成果與檢驗指標（週期二里程碑）
* [ ] 成功取得外部真實 PokeAPI 與 DigimonAPI 資料。
* [ ] **【里程碑產出】** 專案正式具備雙圖鑑真實 API 的非同步拉取與解析能力。
