# 30 天雙原生轉型計畫：從資深 Android 到 iOS (SwiftUI) / Mobile Tech Lead

> **背景設定**：7 年資深 Android 工程師（熟悉 XML / Compose / Coroutines / Flow / Clean Architecture）  
> **目標定位**：解鎖雙原生戰力，邁向 Mobile Tech Lead / Staff Engineer  
> **執行節奏**：每天 1~2 小時，為期 30 天  
> **最終交付**：完成一個現代架構、離線優先、高質感的展示級 iOS 專案《PulseTracker》

---

## 一、Android vs iOS 核心心智模型對照表

利用既有的 7 年經驗進行「概念映射」，是最高效的學習方式：

| 領域 | Android (既有技能) | iOS (Swift 5.9+ / iOS 17+) | 核心觀念備註 |
| :--- | :--- | :--- | :--- |
| **宣告式 UI** | Jetpack Compose (`@Composable`) | **SwiftUI** (`View` protocol) | 兩者皆為資料驅動與宣告式聲明，概念 80% 通用 |
| **狀態持有** | `remember { mutableStateOf() }` | `@State` / `@Binding` | 畫面內部狀態 vs 雙向子視圖傳遞（State Hoisting） |
| **ViewModel** | `ViewModel` + `StateFlow` | **`@Observable` class** | iOS 17+ 巨集，屬性變更自動精確觸發重繪 |
| **副作用 / 載入** | `LaunchedEffect(key)` | **`.task { }`** / `.onChange` | 支援生命週期自動取消與協同任務 |
| **資料模型** | `data class` | **`struct` + `Codable`** | Swift 強烈推薦優先使用 Value Type (`struct`) |
| **狀態模式** | `sealed interface / class` | **`enum with associated values`** | 搭配 `switch` 進行窮舉匹配，實作 MVI/UIState |
| **非同步機制** | Coroutines (`suspend fun`) | **Swift Concurrency (`async/await`)** | 結構化並行，避免回調地獄 |
| **主執行緒保護** | `Dispatchers.Main` | **`@MainActor`** | 編譯期靜態檢查主執行緒調度 |
| **資料流串流** | `Flow` / `SharedFlow` | **`AsyncStream` / Combine** | 響應式事件流 |
| **本地資料庫** | Room (`@Entity`, `@Dao`) | **SwiftData (`@Model`)** | iOS 17+ 原生宣告式 ORM，取代傳統 Core Data 樣板碼 |
| **依賴注入** | Hilt / Koin | **Protocol + Environment / Factory** | 依賴反轉與 Mock 測試設計 |

---

## 二、專案目標：《PulseTracker》Showcase

* **產品類型**：高質感資訊與資產追蹤 App（如即時加密貨幣/股票/GitHub Pulse）
* **技術亮點**：
  1. **UI 層**：純 SwiftUI 打造、支援 Dark Mode、動態字級、彈簧動畫與 `matchedGeometryEffect`
  2. **架構層**：Clean MVVM + `@Observable`，依賴注入設計，清晰的單向資料流
  3. **網路層**：原生 `URLSession` + `Codable` 泛型 API Client，具備 Loading / Error / Retry 狀態
  4. **快取層**：`SwiftData` 離線優先架構（Offline-First），網路與本地資料無縫同步
  5. **工程品質**：ViewModel 與 Repository 完整單元測試覆蓋、無記憶體洩漏保證（ARC 調優）

---

## 三、30 天詳細執行日程（每天 1~2 小時）

### 第一週：語法對齊與 SwiftUI 核心心智模型
> **本週重點**：利用 Kotlin / Compose 經驗快速攻克 Swift 語法，刻出首批 iOS 介面。

* **Day 1: Swift 與 Kotlin 語法映射**
  * `let` vs `var`（對照 `val` vs `var`）
  * Optional 解包：`if let`, `guard let`, `??`（對照 Kotlin 的 `?.` 與 `?:`）
* **Day 2: 結構體、協定與擴展（iOS 靈魂）**
  * `struct`（Value Type） vs `class`（Reference Type）底層差異
  * `protocol` & `extension`（對照 Kotlin `interface` 與擴充函式）
  * `enum with associated values` 實作 MVI/UIState
* **Day 3: SwiftUI 宣告式佈局**
  * `VStack`, `HStack`, `ZStack`, `Spacer`（對照 `Column`, `Row`, `Box`）
  * 修飾符（View Modifiers）原理與執行順序權重
* **Day 4: 狀態管理與元件抽取**
  * `@State` 與 `@Binding` 雙向綁定機制
  * 實作可重用的自訂元件（如：行情漲跌標籤、通用按鈕）
* **Day 5: 現代導航系統與列表渲染**
  * `NavigationStack` 與 `navigationDestination`（對照 Compose Navigation）
  * `List` 與 `LazyVStack` 的重繪機制與效能差異（對照 `LazyColumn`）
* **Day 6: 現代狀態持有者 `@Observable`**
  * 學習 iOS 17+ 最新的 `@Observable` 巨集（取代舊版 `ObservableObject` + `@Published`）
  * 建立第一個 iOS ViewModel，綁定畫面狀態
* **Day 7: 第一週里程碑審查**
  * **【交付成果】**：刻出《PulseTracker》首頁與詳情頁靜態 UI，支援假資料點擊跳轉與返回。

---

### 第二週：非同步、現代網路層與 Clean Architecture
> **本週重點**：用 Swift Concurrency 取代 Coroutines，串接真實 RESTful API。

* **Day 8: Swift Concurrency 基礎**
  * `async/await` 與 `Task`（對照 `suspend` 與 `CoroutineScope.launch`）
  * 結構化並行：`async let` 與 `TaskGroup` 併發請求
* **Day 9: 執行緒切換與 Actor 執行緒安全**
  * `@MainActor` 標記（對照 `Dispatchers.Main`）
  * `actor` 關鍵字原理：如何保證多執行緒安全存取（防止 Race Condition）
* **Day 10: 現代網路層架構（URLSession + Codable）**
  * 使用 `URLSession.shared.data(from:)` 實作非同步 API 請求
  * `Codable` 協定：自動 JSON 序列化與反序列化（對照 Moshi / Kotlinx.Serialization）
* **Day 11: 泛型 API Client 與錯誤處理封裝**
  * 封裝通用 `APIClient`，定義 `AppError`（網路超時、解析失敗、伺服器錯誤）
  * 建立統一的 Result / 狀態回傳機制
* **Day 12: 依賴注入（DI）與 Repository 模式**
  * 在 Swift 中實作輕量 DI（使用 Protocol + Environment 或 Factory 模式，對照 Hilt）
  * 串接公開 API（推薦 CoinGecko 或 GitHub Public API）
* **Day 13: 畫面非同步生命週期整合**
  * 使用 `.task { }` 修飾符進行進入畫面載入（對照 `LaunchedEffect`）
  * 實作下拉更新（`.refreshable`）與分頁載入（Pagination）
* **Day 14: 第二週里程碑審查**
  * **【交付成果】**：首頁完成真實動態資料載入，具備 Loading 骨架屏、錯誤重試按鈕與下拉刷新。

---

### 第三週：本機持久化、進階動態效果與系統整合
> **本週重點**：實現離線快取（SwiftData）與 iOS 特色精緻互動。

* **Day 15: SwiftData 核心觀念（iOS 17+）**
  * `@Model` 巨集定義資料實體（對照 Room `@Entity`）
  * `ModelContainer` 與 `ModelContext` 初始化與注入
* **Day 16: SwiftData CRUD 實戰**
  * `@Query` 在 View 中響應式讀取本地資料
  * 實作「我的追蹤清單 / 收藏夾」資料新增與刪除
* **Day 17: 打造離線優先（Offline-First）機制**
  * Repository 整合：網路成功時寫入 SwiftData 快取，斷網時無縫呈現本地歷史資料
* **Day 18: SwiftUI 進階動畫**
  * 彈簧動畫（Spring Animation）與轉場過渡
  * `matchedGeometryEffect`（對照 Compose Shared Element Transition）
* **Day 19: 本地搜尋與即時防抖（Debounce）**
  * 使用 `.searchable` 修飾符建立原生搜尋列
  * 實作關鍵字搜尋與即時過濾
* **Day 20: 系統特徵調校**
  * 支援 Dark Mode（自訂 Color Asset）
  * 支援 Dynamic Type（系統文字大小縮放不破版）與安全區域（Safe Area）邊界處理
* **Day 21: 第三週里程碑審查**
  * **【交付成果】**：功能完整的離線快取 + 收藏功能 + 順滑的轉場動畫。

---

### 第四週：測試、效能分析、封裝與面試武器庫
> **本週重點**：補齊單元測試、使用 Instruments 分析，包裝成頂尖履歷作品。

* **Day 22: 單元測試實戰（Swift Testing / XCTest）**
  * 撰寫 ViewModel 與 Repository 的單元測試
  * 建立 Mock API Client 驗證邊界與例外情況
* **Day 23: 記憶體與效能調校（對照 Android Profiler）**
  * 認識 ARC（自動引用計數）、強引用循環（Retain Cycle）
  * 掌握 `[weak self]` 與 Instruments (Leaks / Allocations) 偵測記憶體洩漏
* **Day 24: 專案架構重構與 Clean Code**
  * 檢視 Feature-based 模組化結構
  * 消除所有編譯 Warning，確保程式碼風格一致（SwiftLint 規範）
* **Day 25: 實機部署與 TestFlight 流程跑通**
  * 理解 Apple 開發者帳號、Provisioning Profile、Certificate 概念
  * 部署到實機 iPhone，或打包 Archive 產出可體驗的 App
* **Day 26: 打造殺手級 GitHub README**
  * 錄製流暢的 App 操作 GIF / 短片
  * 繪製架構圖（Clean Architecture + Data Flow）
* **Day 27: 撰寫「Android vs iOS」雙原生架構深度對比文件**
  * 總結 Compose vs SwiftUI、Coroutines vs Swift Concurrency、Room vs SwiftData 的設計哲學與踩坑心得
* **Day 28: 模擬 Tech Lead 面試問題準備**
  * 「身為 7 年 Android，你如何看待雙平台的架構一致性？」
  * 「如果團隊要導入 KMP vs 雙原生開發，你會如何評估權衡？」
* **Day 29: 專案最終檢查與驗收**
  * 全流程 Smoke Test：斷網模式、極限資料量、暗黑模式切換
* **Day 30: 結算展示與自信上線**
  * 整理好 GitHub 倉庫，正式更新 LinkedIn 與履歷上的「iOS / SwiftUI / Mobile Tech Lead」技能標籤

---

## 四、面試與履歷加分項（Tech Lead 視角）

1. **避免把自己當作初階 iOS 開發者**：
   * 你的定位是「**具備架構審查與技術選型能力的資深行動端專家**」，熟知雙平台的生命週期與執行緒陷阱。
2. **在專案 README 中展示「雙平台對比思維」**：
   * 在 GitHub 展示專案中加入專章：「*Android vs iOS Architecture Comparison*」，展示你對兩個平台架構底層邏輯的通透理解。
3. **善用 AI 加速工具**：
   * 開發時使用 AI 快速做語法轉譯，把時間留給理解 iOS 原生底層機制（ARC、Actor、RunLoop、SwiftData Context）。
