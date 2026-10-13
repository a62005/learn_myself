# 週期四 (Day 16 ~ Day 20)：離線持久化與進階互動體驗

> **週期目標**：深入 SwiftData 響應式資料操作，實現 Offline-First（離線優先）快取機制（先本機快取、無資料再網路拉取入庫），整合卡片共享元素展開動畫（`matchedGeometryEffect`）、防抖即時搜尋與深淺色無障礙適配。  
> **最終交付目標**：達成斷網零白屏、秒開流暢瀏覽、具備本機資料庫持久化的商用級體驗。  
> **建議學習時間**：每天 1~2 小時

---

## Day 16: SwiftData 寫入與響應式查詢（對照 Room Dao 操作）

### 1. 核心觀念深入解析（Android vs iOS 對照）

#### (1) `@Query`：一行代碼搞定響應式資料庫監聽
* 在 Android 中，若要實現資料庫變更自動通知 UI，必須在 Room DAO 回傳 `Flow<List<Entity>>`，並在 ViewModel 轉為 StateFlow，再於 Compose 中 collect。
* 在 SwiftUI 中，**`@Query` 巨集直接由系統代管資料流**：
  ```swift
  struct ItemListView: View {
      // 依據 id 升序排列，資料庫有變更時 View 自動觸發差分重繪！
      @Query(sort: \ItemEntity.id, order: .forward) 
      private var localItems: [ItemEntity]
      
      @Environment(\.modelContext) private var modelContext // 取得操作環境
      
      var body: some View {
          List {
              ForEach(localItems) { item in
                  Text(item.name)
              }
              .onDelete(perform: deleteItems) // 原生滑動刪除
          }
      }
      
      private func deleteItems(offsets: IndexSet) {
          for index in offsets {
              modelContext.delete(localItems[index])
          }
      }
  }
  ```

#### (2) 資料庫寫入（Insert）與去重檢查
```swift
func saveItem(entity: ItemEntity) {
    // SwiftData @Attribute(.unique) 會自動依據指定唯一鍵進行去重更新
    modelContext.insert(entity)
    try? modelContext.save()
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 在 View 層或 Repository 注入 `@Environment(\.modelContext)`。
2. 實作單一資料實體的寫入與刪除邏輯。
3. 測試將 API 拉取到的資料實體寫入 SwiftData，並在重啟 App 後透過 `@Query` 正確讀出。

---

### 3. 當日交付成果與檢驗指標
* [ ] 掌握 SwiftData 的 `@Query` 響應式查詢與 Context 交易寫入。
* [ ] 達成資料本機持久化儲存。

---

## Day 17: 打造 Offline-First 離線優先快取（SSOT 架構）

### 1. 核心觀念深入解析

身為 7 年資深工程師，**Offline-First（離線優先）架構**是拉開與初階開發者差距的關鍵：

```mermaid
flowchart TD
    Start["開啟 App / 進入清單"] --> CheckDB{"檢查本機 SwiftData 是否已有資料？"}
    CheckDB -->|有快取資料| FastRender["立即渲染本地資料 (0 毫秒白屏)"]
    CheckDB -->|本機為空 (首次啟動)| FetchAPI["發起網路請求拉取第 1 頁清單"]
    FastRender --> BackgroundCheck["背景檢查是否需載入最新資料"]
    FetchAPI --> FetchDetails["併發抓取每筆項目的詳細規格"]
    FetchDetails --> InsertDB["批次寫入 SwiftData ModelContext"]
    InsertDB --> AutoSync["@Query 自動感知寫入，列表無縫更新！"]
```

#### 資料同步與驅動最佳實踐
* `ItemRepository` 負責整合邏輯：在呼叫 API 成功後，批次更新本機快取；若 API 拋出連線失敗異常，不噴錯誤頁面，而是降級使用本地快取。

---

### 2. 每日實作任務（1~2 小時）

1. 擴充 `ItemRepository`：新增 `getLocalItems()` 與 `cacheItems(_ items: [ItemModel])`。
2. 離線壓力測試：
   * 正常連網打開 App 抓取資料。
   * 將電腦網路關閉（模擬完全斷網）。
   * 殺掉 App 程序重新啟動。
   * 驗證 App 是否依然能秒開顯示快取資料，並在頂部展示「離線模式」提示條。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成具備真實商用價值的 Single Source of Truth (SSOT) 離線架構。
* [ ] 徹底杜絕斷網即白屏的糟糕體驗。

---

## Day 18: SwiftUI 進階動畫（MatchedGeometryEffect 展開轉場）

### 1. 核心觀念深入解析（Android vs iOS 對照）

#### (1) Compose Shared Transition vs SwiftUI `matchedGeometryEffect`
* 在 Android 中，要實現列表項目展開至詳情頁的共享元素動畫，在舊版 XML 或早期的 Compose 相當繁瑣。
* 在 SwiftUI 中，`matchedGeometryEffect` 的優雅度達到了極致：
  ```swift
  struct ContainerView: View {
      @Namespace private var animationNamespace // 建立命名空間
      @State private var selectedItem: ItemModel?
      
      var body: some View {
          ZStack {
              if let item = selectedItem {
                  // 展開的詳情卡片
                  DetailCardView(item: item, namespace: animationNamespace)
                      .matchedGeometryEffect(id: item.id, in: animationNamespace)
              } else {
                  // 列表網格
                  GridListView(namespace: animationNamespace) { item in
                      withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                          selectedItem = item
                      }
                  }
              }
          }
      }
  }
  ```

#### (2) 彈簧動畫（Spring Animation）的物理感
iOS 的動畫預設推崇物理彈簧效果（Spring），比傳統的 EaseInOut 更有質感：
* `response`：彈簧週期（決定速度）。
* `dampingFraction`：阻尼係數（0.7~0.8 為 Apple 官方經典手感）。

---

### 2. 每日實作任務（1~2 小時）

1. 在列表卡片與詳情頁之間，使用 `@Namespace` 與 `matchedGeometryEffect` 綁定圖片與卡片容器。
2. 實現點擊列表項目時，該卡片直接原地無縫放大為詳情頁頂部看板的過渡效果。
3. 調試 Spring 物理參數，達到平滑回彈視覺感受。

---

### 3. 當日交付成果與檢驗指標
* [ ] 實現媲美 Apple 原生 App（如 App Store 今日推薦）的平滑展開動畫。
* [ ] 掌握 `@Namespace` 與彈簧物理參數的調試。

---

## Day 19: 本地搜尋與防抖（Debounce）機制

### 1. 核心觀念深入解析

#### (1) 原生 `.searchable` 修飾符
SwiftUI 提供了與系統 NavigationBar 完美整合的搜尋介面：
```swift
NavigationStack {
    List(filteredItems) { ... }
        .searchable(text: $viewModel.searchText, prompt: "搜尋名稱或編號")
}
```

#### (2) 防抖（Debounce）心智模型對比
* 在 Android 中：你使用 `searchQueryFlow.debounce(300).collectLatest { ... }`。
* 在 Swift Concurrency 中：利用 `Task.sleep` 與任務取消（Task Cancellation）：
  ```swift
  @Observable
  @MainActor
  class SearchViewModel {
      var searchText: String = "" {
          didSet { triggerDebouncedSearch() }
      }
      
      private var searchTask: Task<Void, Never>?
      
      private func triggerDebouncedSearch() {
          searchTask?.cancel() // 取消前一次未完成的等待
          searchTask = Task {
              try? await Task.sleep(nanoseconds: 300_000_000) // 等待 300ms
              guard !Task.isCancelled else { return }
              await performFilter(query: searchText)
          }
      }
  }
  ```

---

### 2. 每日實作任務（1~2 小時）

1. 在 ViewModel 中加入 `searchText` 與搜尋防抖邏輯。
2. 在畫面串接 `.searchable`。
3. 實作即時過濾：當使用者鍵入關鍵字時，列表在 300ms 內平滑過濾並呈現匹配項目；清空時立即恢復全量列表。

---

### 3. 當日交付成果與檢驗指標
* [ ] 成功整合系統原生搜尋列與自訂防抖邏輯。
* [ ] 避免頻繁輸入造成介面卡頓或無效運算。

---

## Day 20: 系統外觀與邊界適配（Dark Mode & Dynamic Type）

### 1. 核心觀念深入解析

資深工程師的專業度體現在**對極限情況與無障礙（Accessibility）的考究**：

#### (1) 語意色彩（Semantic Colors）
永遠不要寫死 `Color.white` 或 `Color.black`：
* 背景使用 `Color(.systemBackground)` / `Color(.secondarySystemBackground)`。
* 文字使用 `Color.primary`（自動適配深淺色） / `Color.secondary`。

#### (2) Dynamic Type（大字體無障礙支援）
* Apple 使用者非常在意系統字體縮放。
* 使用語意字型：`.font(.headline)`、`.font(.subheadline)`，系統會在使用者放大字級時自動縮放。
* 避免給容器寫死絕對高度（例如 `frame(height: 44)`），改用 `.frame(minHeight: 44)`。

---

### 2. 每日實作任務（1~2 小時）

1. 檢查整個 App 的色彩定義，全面改用 Semantic Colors 與自訂 Color Assets。
2. 在模擬器開啟 **Accessibility Inspector**，將字體縮放到 200%，排查排版完整度。
3. 切換深色與淺色模式，驗證對比度與視覺層次。

---

### 3. 當日交付成果與檢驗指標（週期四里程碑）
* [ ] **【里程碑產出】** 一款在深淺模式、極端大字級下皆表現完美的工業級 App。
* [ ] 完成從網路層、離線資料庫到高階視覺與無障礙的全部產品功能開發。
