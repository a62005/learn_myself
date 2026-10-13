# 週期六 (Day 26 ~ Day 30)：作品包裝與 Tech Lead 總結（雙原生護城河）

> **專案標竿**：以 [PokemonXDigimonBook (Android)](https://github.com/a62005/PokemonXDigimonBook) 與《PokemonXDigimonBook (iOS)》形成**「雙原生對照」代表作**。  
> **週期目標**：跳脫「初階 iOS 學習者」標籤，以「7 年資深雙原生架構師 / Tech Lead」視角包裝專案，產出具備雙平台架構對比的 GitHub Showcase、撰寫高階架構手冊、演練跨端決策面試題，並更新履歷上線。  
> **建議學習時間**：每天 1~2 小時

---

## Day 26: 打造展示級 GitHub Repository（雙平台對照展示）

### 1. 核心觀念深入解析

在技術主管與獵頭眼裡，**能將同一個成熟產品用 Android 與 iOS 雙原生現代架構分別完美實現的工程師**，是極度稀缺的 Mobile Tech Lead 人選：

#### 殺手級 README 結構標準
1. **Header 與雙端展示**：
   * 標題：《PokemonXDigimonBook - Dual Native Showcase (Android & iOS)》
   * 放置左右對照的 GIF 動圖：左邊 Android Compose 版，右邊 iOS SwiftUI 版，展現兩端在 UI、動畫、分頁與離線體驗上的高度一致性！
2. **Key Highlights（技術亮點）**：
   * 原生 PokeAPI 與 DigimonAPI 支援
   * 雙端 Offline-First 離線優先架構（Room vs SwiftData）
   * MVI / UDF 單向資料流架構設計
   * 完整單元測試與 0 Memory Leak 保證
3. **系統架構圖**：清晰標註雙端的模組對應關係（`lib_network` ➔ `Core/Network`、`lib_database` ➔ `Core/Database`）。

---

### 2. 每日實作任務（1~2 小時）

1. 錄製 iOS 版的操作短片（雙入口點擊、雙欄網格分頁滑動、卡片展開動畫、斷網離線展示）。
2. 製作成高畫質 GIF 動圖，與既有 Android 專案對比。
3. 編寫專業的雙語 `README.md`，並放上專案架構圖。

---

### 3. 當日交付成果與檢驗指標
* [ ] 產出令人震撼的雙平台開源專案主頁。

---

## Day 27: 撰寫「Android vs iOS 雙原生圖鑑架構深度對比手冊」

### 1. 核心觀念深入解析（你的核彈級面試武器）

這份文件記錄你將原本 Android 專案移植到 iOS 過程中的架構思考，也是你在面試時證明自己具備架構審查能力的決定性文件：

#### 手冊核心四大主題（真實對比）
1. **宣告式 UI 與動畫**：
   * Compose `LazyVerticalGrid` + `SharedTransitionScope` vs SwiftUI `LazyVGrid` + `matchedGeometryEffect` 的實現差異與手感調校。
2. **非同步與網路層治理**：
   * Retrofit + Kotlin Coroutines (`withContext(ioDispatcher)`) vs 原生 `URLSession` + Swift Concurrency (`async/await` + `@MainActor`) 的執行緒模型差異。
3. **本地快取與資料庫**：
   * Room DAO 流程（`observeSimplePokemonList()`, 寫入檢查）vs SwiftData 現代 ORM（`@Model`, `@Query`, ModelContext）的 API 設計哲學。
4. **記憶體與生命週期**：
   * Android GC 與 Activity/Lifecycle vs iOS ARC 引用計數與 View Identity 的排查經驗。

---

### 2. 每日實作任務（1~2 小時）

1. 在專案中新增文件 `ARCHITECTURE_COMPARISON.md`。
2. 整理這 27 天以來的真實踩坑心得，結合具體的 Kotlin vs Swift 代碼片段完整成文。
3. 在 README 頂部附上這篇對比手冊的連結。

---

### 3. 當日交付成果與檢驗指標
* [ ] 產出極具深度與說服力的 `ARCHITECTURE_COMPARISON.md`。

---

## Day 28: Mobile Tech Lead 面試問題攻防準備

### 1. 核心觀念深入解析

準備好應對高階主管對「雙原生經驗」的深度拷問：

#### 核心攻防題與回答策略
* **問題 1：「既然你同時掌握了 Android 與 iOS 原生，為什麼很多公司依然想用 Flutter 或 KMP？你會如何建議？」**
  * *答題策略*：從團隊組織架構、商業交付速度、業務複雜度切入。說明「對於高度依賴系統生態（如 Widget、實體動態、即時圖形運算）的核心產品，雙原生具備無可替代的極致體驗與首發優勢；而 KMP 適合共享通用的資料處理與演算法，兩者可以互補」。
* **問題 2：「在維護大型怪獸圖鑑這類資料密集型 App 時，雙平台的記憶體治理策略有何不同？」**
  * *答題策略*：對比 Android 的 Bitmap 記憶體配置（Glide/Coil 記憶體快取與 GC 回收）與 iOS 的 ARC（`[weak self]`、NSCache、Instruments Leaks 偵測），展現深厚底層掌控力。

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `TECH_LEAD_INTERVIEW_PREP.md`。
2. 針對上述問題寫下結構化回答大綱（STAR 原則）。
3. 進行口頭模擬演練。

---

### 3. 當日交付成果與檢驗指標
* [ ] 具備在技術面試中引導節奏、以 Tech Lead 高度對談的能力。

---

## Day 29: 全流程極限測試（Smoke Test & Edge Cases）

### 1. 核心觀念深入解析

在向外界公開展示之前，進行最後的工業級品質防禦驗證：
* **斷網與弱網切換**：驗證從連線到斷線再到重連，SwiftData 能否穩健兜底。
* **分頁邊界**：驗證當滑動到 API 最末頁（如 Digimon 抓滿）時，`hasMore` 能否正確終止分頁請求，不無限迴圈。
* **超長怪獸名稱**：驗證部分超長數碼寶貝名稱在卡片中是否正常省略或換行，不發生破版。
* **深淺色與旋轉螢幕**：全面測試。

---

### 2. 每日實作任務（1~2 小時）

1. 逐一完成上述邊界壓力測試，修復最後的細節問題。
2. 執行全套單元測試確保全綠。
3. 提交 Git 紀錄，打上 Release Tag：`git tag -a v1.0.0 -m "Release PokemonXDigimonBook iOS v1.0.0"`。

---

### 3. 當日交付成果與檢驗指標
* [ ] 專案達到 0 Crash、0 Warning、發布等級的完美品質。

---

## Day 30: 結算成果與職涯升級上線

### 1. 核心觀念深入解析

恭喜你！歷經 30 天的高強度刻意練習，你已經成功完成了一次漂亮的跨平台技術躍遷。你不再只是「資深 Android 工程師」，而是**「能一人主導雙平台原生架構、對雙端底層了然於胸的 Mobile Tech Lead」**！

#### 履歷與個人品牌更新範例
* **職稱定位**：**Senior Mobile Engineer / Mobile Tech Lead (Android & iOS)**
* **經歷亮點**：
  > *「擁有 7 年資深 Android 經驗，熟練 Jetpack Compose、Kotlin 協程與模組化架構；同時具備現代 iOS 雙原生交付實戰能力（iOS 17+ SwiftUI、Swift Concurrency、SwiftData）。獨立打造《PokemonXDigimonBook》雙原生雙版本，成功實踐 Offline-First 離線架構、自定義分頁與流暢共享元素轉場動畫，具備跨平台架構決策與深度效能調校經驗。」*
* **作品附錄**：
  * Android 原版專案：`https://github.com/a62005/PokemonXDigimonBook`
  * iOS 雙原生專案：你的新倉庫連結
  * 雙原生架構深度對比手冊：`ARCHITECTURE_COMPARISON.md`

---

### 2. 每日實作任務（1~2 小時）

1. 將 iOS 專案推送到個人 GitHub。
2. 更新 LinkedIn 與 104/CakeResume 上的經歷與技能標籤。
3. 慶祝這 30 天的實力質變！

---

### 3. 當日交付成果與檢驗指標（最終里程碑）
* [ ] **【最終里程碑】** 成功交付展示級《PokemonXDigimonBook (iOS)》雙原生專案。
* [ ] 徹底破除被 AI 取代的焦慮，建立起堅實的雙原生技術護城河！
