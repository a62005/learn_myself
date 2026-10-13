# 週期六 (Day 26 ~ Day 30)：作品包裝與 Tech Lead 總結

> **週期目標**：跳脫「初階 iOS 學習者」標籤，以「7 年資深雙原生架構師 / Tech Lead」視角包裝專案，產出殺手級 GitHub 開源專案、撰寫雙平台深度架構手冊、演練跨端決策高階面試題，並更新履歷上線。  
> **最終交付目標**：以具備「雙分類、遠端 API、分頁加載、網格卡片、詳情跳轉、本機 DB 離線快取」的完整 App 為核心作品，建立難以被取代的雙原生技術護城河。  
> **建議學習時間**：每天 1~2 小時

---

## Day 26: 打造展示級 GitHub Repository

### 1. 核心觀念深入解析

在技術主管與獵頭眼裡，一份普通的小練習通常無人問津；但一份**具備清晰產品展示、完整架構圖與工業級工程標準的 Showcase**，會直接讓你的面試邀請率翻倍：

#### 殺手級 README 結構標準
1. **Header 與產品展示**：
   * 標題：《Dual-Native Showcase App (Android & iOS)》
   * 放置清晰的操作 GIF 動圖：展現雙分類切換、分頁滾動載入、卡片展開動畫、離線斷網秒開。
2. **Key Highlights（技術亮點）**：
   * Pure SwiftUI (iOS 17+) & `@Observable` Observation 框架
   * Swift Concurrency (`async/await`, `actor`, `@MainActor`)
   * SwiftData 驅動的 **Offline-First 離線優先架構**
   * Protocol-based Clean Architecture & 完整單元測試
3. **系統架構圖**：展示 View ➔ ViewModel ➔ Repository ➔ Remote/Local Data 的數據流向。
4. **技術棧對照表**：列出專案如何映射現代 Android 實踐。

---

### 2. 每日實作任務（1~2 小時）

1. 錄製一段 30 秒流暢的操作短片（包含下拉刷新、搜尋、離線快取切換、卡片展開動畫）。
2. 轉換為高畫質、輕量化的 GIF 動圖。
3. 使用 Mermaid 或繪圖工具繪製專案架構圖。
4. 編寫結構完整的繁中與英文雙語 `README.md`。

---

### 3. 當日交付成果與檢驗指標
* [ ] 產出令人驚艷的專案展示首頁 `README.md`。
* [ ] 包含動態操作預覽與架構視覺化圖表。

---

## Day 27: 撰寫「Android vs iOS」雙原生架構深度對比手冊

### 1. 核心觀念深入解析（你的核彈級面試武器）

這份文件是你在面試時最強大的議價籌碼。它證明了你不是「改寫 iOS」，而是具備**站在高維度審視行動端作業系統架構與設計哲學**的 Tech Lead：

#### 核心探討四大主題
1. **宣告式 UI 渲染機制對比**：
   * Compose 的 Recomposition 邊界（Composer、Slot Table、RecomposeScope） vs SwiftUI 的 View 差分計算（View Graph、AttributeGraph、Structural Identity）。
2. **非同步與並發模型對比**：
   * Kotlin Coroutines（基於 Continuation 的協程與調度器 Dispatchers） vs Swift Concurrency（基於 Cooperative Thread Pool、Task 與 Actor 隔離域）。
3. **本地快取與資料庫機制**：
   * Room DAO 流程（Flow 響應式查詢、手動維護 Migration） vs SwiftData 現代 ORM（`@Model`、`@Query`、自動 Schema 演進）的設計哲學。
4. **記憶體管理與穩定性治理**：
   * JVM/ART 世代 GC（垃圾回收機制、STW、記憶體碎片） vs Apple ARC（編譯期自動引用計數、Retain Cycle、`[weak self]` 最佳實踐）。

---

### 2. 每日實作任務（1~2 小時）

1. 在專案中新增文件 `ARCHITECTURE_COMPARISON.md`。
2. 結合這 27 天以來的實戰體會，分段落撰寫上述四大主題，並輔以具體的 Kotlin vs Swift 代碼片段。
3. 在 README 中高亮推薦閱讀此份文件。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成高含金量的 `ARCHITECTURE_COMPARISON.md`。
* [ ] 確立自己在雙原生技術體系中的高階架構認知。

---

## Day 28: Mobile Tech Lead 面試問題攻防準備

### 1. 核心觀念深入解析

當你帶著 7 年 Android 經驗並展現精湛的 iOS 交付能力時，面試官不會問你初階的語法題，而是會聚焦在**架構選型、團隊治理與跨端決策**：

#### 高頻攻防題大綱與回答策略

* **問題 1：「新專案啟動時，你如何在 Native、Flutter 與 KMP（Kotlin Multiplatform）之間做技術決策？」**
  * *答題維度*：評估業務生命週期、效能敏感度（如相機/音訊/繪圖/實體感測）、團隊技能分佈與維護成本。說明 KMP 適合「共享商業邏輯與演算法，保留原生 UI」；雙原生適合「對使用者體驗、首發系統特性、底層效能要求極高的一線核心產品」。
* **問題 2：「身為雙端架構師，你如何確保雙平台團隊在架構與 API 串接上的一致性？」**
  * *答題維度*：統一的 API Specification（OpenAPI/Swagger）、通用的 MVI/Clean 架構理念、跨平台規格會議與跨端 Code Review 機制。
* **問題 3：「如果在線上出現偶發性 Crash 或卡頓，雙平台的排查思維有何異同？」**
  * *答題維度*：對比 Android Perfetto/Systrace/Tombstone 與 iOS Instruments/MetricKit/dSYM 符號化解析，展現深厚的底層嗅覺。

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `TECH_LEAD_INTERVIEW_PREP.md`。
2. 針對上述 3 個核心問題與另外 2 個你過往曾遇過的真實踩坑情境，寫下結構化回答大綱（STAR 原則）。
3. 進行一次 15 分鐘的口語自我模擬演練。

---

### 3. 當日交付成果與檢驗指標
* [ ] 建立具備高度說服力的 Tech Lead 問答框架。
* [ ] 能夠自如切換 Android 與 iOS 的專業術語。

---

## Day 29: 全流程極限測試（Smoke Test & Edge Cases）

### 1. 核心觀念深入解析

在向外界公開展示之前，進行最後的工業級品質防禦驗證：
* **斷網與弱網切換**：驗證從連線到斷線再到重連，SwiftData 能否穩健兜底。
* **分頁邊界**：驗證當滑動到 API 最末頁時，`hasMore` 能否正確終止分頁請求，不無限迴圈。
* **超長文字排版**：驗證超長標題在卡片中是否正常省略或換行，不發生破版。
* **深淺色模式熱切換**。
* **系統無障礙字體 200% 縮放**。

---

### 2. 每日實作任務（1~2 小時）

1. 在模擬器逐一執行上述極限邊界測試。
2. 檢查是否有任何微小的 Layout Glitch，迅速調整 Modifier。
3. 執行最終版單元測試確保全數通過。
4. 在 Git 提交乾淨的 Commit 紀錄，並打上版本標籤 `git tag -a v1.0.0 -m "Release v1.0.0"`。

---

### 3. 當日交付成果與檢驗指標
* [ ] 專案達到零崩潰、無破版、無警告的發布水準。
* [ ] 產出乾淨的 Git 歷史紀錄與 Release Tag。

---

## Day 30: 結算成果與職涯升級上線

### 1. 核心觀念深入解析

恭喜你！歷經 30 天的高強度刻意練習，你已經成功完成了一次漂亮的跨平台技術躍遷。你不再只是單一平台的工程師，而是**「能一人主導雙平台原生架構、對雙端底層了然於胸的 Mobile Tech Lead」**！

#### 履歷與個人品牌更新範例
* **職稱升級**：
  * 從原本的 `Senior Android Engineer`
  * 升級為 **`Senior Mobile Engineer / Mobile Tech Lead (Android & iOS)`**
* **重點經歷撰寫範例**：
  > *「具備 7 年 Android 資深架構實務，精通 Jetpack Compose 與 Kotlin 協程體系；同時具備現代 iOS (iOS 17+ SwiftUI、Swift Concurrency、SwiftData) 完整產品交付能力。曾獨立設計並交付高可用性 Offline-First 架構，具備跨平台架構選型、效能調校與大型專案模組化治理經驗。」*
* **作品附錄**：
  * 附上 GitHub Showcase 專案倉庫連結。
  * 附上《雙原生架構深度對比手冊》專欄連結。

---

### 2. 每日實作任務（1~2 小時）

1. 將專案公開發布至個人 GitHub。
2. 更新 LinkedIn 與求職平台上的「工作經歷」與「技能標籤（Skills）」，加入 Swift、SwiftUI、SwiftData、iOS Architecture。
3. 慶祝這 30 天的實力質變！

---

### 3. 當日交付成果與檢驗指標（最終里程碑）
* [ ] **【最終里程碑】** 完整交付展示級 iOS 專案 + 深度架構手冊。
* [ ] 徹底破除被 AI 取代的焦慮，建立起堅實的雙原生技術護城河！
