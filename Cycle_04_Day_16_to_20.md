# 週期四 (Day 16 ~ Day 20)：離線持久化與進階互動體驗（寫入 DB 與離線秒開）

> **專案標竿**：對標 [PokemonXDigimonBook](https://github.com/a62005/PokemonXDigimonBook) 的 `lib_database`、`PokemonDao.kt`、`DigimonDao.kt` 與 Compose 共享元素動畫。  
> **週期目標**：實現怪獸資料寫入 SwiftData、重現原版 Android「先讀 DB 快取、無資料再網路拉取入庫」的離線優先（Offline-First）機制，並以 SwiftUI 復刻 SharedTransition 卡片展開動畫。  
> **建議學習時間**：每天 1~2 小時

---

## Day 16: SwiftData 寫入與響應式查詢（對照 Room Dao 操作）

### 1. 核心觀念深入解析（Android vs iOS 對照）

在你的 Android 專案中，你定義了 `PokemonDao` 與 `DigimonDao`：
```kotlin
// Android 原版
@Dao
interface PokemonDao : BaseDao<PokemonEntity> {
    @Query("SELECT * FROM PokemonEntity")
    fun observeSimplePokemonList(): Flow<List<SimplePokemonBean>>
    
    @Query("SELECT * FROM PokemonEntity WHERE name = :name")
    suspend fun getPokemonByName(name: String): PokemonEntity?
}
```

在 SwiftUI 中，**`@Query` 巨集直接由系統代管資料庫監聽**：
```swift
struct PokemonListView: View {
    // 依據 id 升序排列，資料庫有變更時 View 自動觸發差分重繪！
    @Query(sort: \PokemonEntity.id, order: .forward) 
    private var localPokemons: [PokemonEntity]
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        // 直接使用 localPokemons 渲染
    }
}
```

#### 資料庫寫入（Insert）與去重檢查
```swift
// 對應 dao.insert(entity)
func savePokemon(entity: PokemonEntity) {
    // SwiftData @Attribute(.unique) 會自動依據 id 去重更新
    modelContext.insert(entity)
    try? modelContext.save()
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 在 View 層或 Repository 注入 `@Environment(\.modelContext)`。
2. 實作單一怪獸資料的寫入與刪除邏輯。
3. 測試將 API 拉取到的怪獸實體寫入 SwiftData，並在重啟 App 後透過 `@Query` 正確讀出。

---

### 3. 當日交付成果與檢驗指標
* [ ] 掌握 SwiftData 的 `@Query` 響應式查詢與 Context 交易寫入。
* [ ] 達成怪獸資料本機持久化儲存。

---

## Day 17: 打造 Offline-First 離線優先快取（完全對齊 Android Repository 邏輯）

### 1. 核心觀念深入解析（原版流程還原）

在你的 Android `PokemonRepository.kt` 中，核心流程如下：
```kotlin
// Android 原版流程：
val localSize = pokemonDao.getSize()
if (localSize == 0) {
    loadMorePokemon(0) // 1. 若本機為空，發起網路載入
}
// 2. 網路載入列表後，針對每筆資料拉取 Detail
// 3. 組裝出 PokemonEntity 並寫入 pokemonDao.insert(entity)
// 4. UI 透過 observePokemonList() 永遠只讀取 DB！
```

在 iOS 中，我們將這套 **Single Source of Truth (SSOT)** 架構完整移植：

```mermaid
flowchart TD
    Start["開啟 App / 進入怪獸列表"] --> CheckDB{"檢查本機 SwiftData 是否已有資料？"}
    CheckDB -->|有資料| FastRender["立即渲染本地怪獸 (0 毫秒載入)"]
    CheckDB -->|無資料 (首次啟動)| FetchAPI["發起網路請求拉取第 1 頁清單"]
    FastRender --> BackgroundCheck["背景檢查是否需載入更多"]
    FetchAPI --> FetchDetails["併發抓取每隻怪獸的詳細數值 (Stats/Types)"]
    FetchDetails --> InsertDB["批次寫入 SwiftData ModelContext"]
    InsertDB --> AutoSync["@Query 自動感知寫入，列表無縫更新！"]
```

---

### 2. 每日實作任務（1~2 小時）

1. 重構 `PokemonRepository` 與 `DigimonRepository`：
   * 增加本地資料庫查詢方法。
   * 將 API 獲取的怪獸詳細資訊批次轉換為 `PokemonEntity` / `DigimonEntity` 並入庫。
2. 離線壓力測試：
   * 進入 App 載入前 30 隻寶可夢與數碼寶貝。
   * 開啟電腦飛航模式（完全斷網）。
   * 殺掉 App 程序重新開啟，驗證是否能**秒開且正常瀏覽已下載怪獸的卡片與數值條**。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成與原版 Android 專案一模一樣的 SSOT 離線資料流架構。
* [ ] 達到斷網零白屏、體驗絲滑流暢的商用級水準。

---

## Day 18: SwiftUI 進階動畫（復刻 SharedTransition 怪獸展開動畫）

### 1. 核心觀念深入解析（Android vs iOS 對照）

在你的 Android `MonsterListScreen.kt` 中，使用了：
```kotlin
// Android 原版 Compose Shared Element Transition
@OptIn(ExperimentalSharedTransitionApi::class)
MonsterListScreen(
    sharedTransitionScope = sharedTransitionScope,
    animatedContentScope = animatedContentScope, ...
)
```

在 SwiftUI 中，使用 **`matchedGeometryEffect`** 復刻卡片展開動畫更加優雅直觀：

```swift
struct MonsterContainerView: View {
    @Namespace private var animationNamespace
    @State private var selectedMonster: SimpleMonster?

    var body: some View {
        ZStack {
            if let monster = selectedMonster {
                // 展開後的詳情頁
                MonsterDetailView(monster: monster, namespace: animationNamespace) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedMonster = nil
                    }
                }
            } else {
                // 列表頁
                MonsterGrid(namespace: animationNamespace) { monster in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedMonster = monster
                    }
                }
            }
        }
    }
}
```
* 在卡片與詳情頁頂部的圖片上，分別掛上 `.matchedGeometryEffect(id: "img_\(monster.id)", in: animationNamespace)`，點擊時怪獸大圖會原汁原味地從卡片放大至詳情頁！

---

### 2. 每日實作任務（1~2 小時）

1. 為列表卡片與詳情頁設定 `@Namespace`。
2. 將怪獸圖片與卡片背景色掛載 `matchedGeometryEffect`。
3. 調試 Spring 動畫參數（`dampingFraction: 0.75`），重現 Compose 的流暢轉場手感。

---

### 3. 當日交付成果與檢驗指標
* [ ] 實現完美的怪獸卡片展開與收合動畫。
* [ ] 掌握 SwiftUI 共享命名空間的物理彈簧過渡機制。

---

## Day 19: 本地搜尋與即時防抖（Debounce）

### 1. 核心觀念深入解析

在圖鑑 App 中，快速搜尋是核心體驗：
* 支援依據「怪獸編號（如 25）」或「怪獸名稱（如 pikachu / agumon）」即時搜尋。
* 利用 Swift Concurrency 的 `Task` 取消機制實現 300ms 防抖，避免使用者每打一個英文字元就重新計算過濾。

```swift
func filterMonsters(query: String) {
    searchTask?.cancel()
    searchTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }
        
        if query.isEmpty {
            self.filteredList = self.allList
        } else {
            self.filteredList = self.allList.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                String($0.id).contains(query)
            }
        }
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 在 `PokemonScreen` 與 `DigimonScreen` 掛載 `.searchable(text: $viewModel.searchQuery)`。
2. 實作依據名稱與編號的多維度防抖過濾。
3. 驗證清空搜尋欄時能秒級還原原本的分頁列表。

---

### 3. 當日交付成果與檢驗指標
* [ ] 整合系統原生搜尋列與自訂防抖邏輯。
* [ ] 搜尋反應極速且無多餘計算開銷。

---

## Day 20: 系統外觀適配（屬性色 Dark Mode & Dynamic Type）

### 1. 核心觀念深入解析

* **屬性色對比度**：火、水、草、超能力、毒等顏色在深色模式（Dark Mode）下必須具備高可讀性。
* **動態字級（Dynamic Type）**：能力值標籤（HP, ATK, DEF）與怪獸名稱在系統大字體無障礙模式下，不得出現文字重疊破版。
* **安全區域（Safe Area）**：雙入口首頁的上下分割在 iPhone 瀏海屏與靈動島下的正確避讓。

---

### 2. 每日實作任務（1~2 小時）

1. 檢查 `ColorUtils.swift` 中所有怪獸屬性顏色在 Dark Mode 下的表現。
2. 在模擬器開啟 Accessibility 縮放字體至 200%，排查詳情頁能力值條的佈局自適應。
3. 支援橫向螢幕或 iPad 佈局適配。

---

### 3. 當日交付成果與檢驗指標（週期四里程碑）
* [ ] **【里程碑產出】** 一款在離線快取、資料庫持久化、展開動畫與無障礙上皆達到發布標準的雙圖鑑 App。
* [ ] 全面達成與 Android 原版專案在功能與資料庫層面的 1:1 復刻！
