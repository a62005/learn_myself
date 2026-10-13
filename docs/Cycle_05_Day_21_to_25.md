# 週期五 (Day 21 ~ Day 25)：測試、底層效能與工程化治理

> **週期目標**：為專案注入工業級品質——補齊單元測試（Swift Testing / XCTest）、掌握 iOS 記憶體管理機制（ARC vs GC）、使用 Xcode Instruments 進行效能與洩漏檢測，並跑通實機簽名與打包流程。  
> **最終交付目標**：達成單元測試全綠燈、0 記憶體洩漏、0 編譯警告並在實機 iPhone 順暢運行。  
> **建議學習時間**：每天 1~2 小時

---

## Day 21: 模組整合與程式碼整潔（Clean Code）

### 1. 核心觀念深入解析

在進行工程化測試前，需要對先前的程式碼進行全盤檢視與架構收斂：

#### (1) 架構依賴邊界審查
* **View 層**：絕對不允許出現任何資料庫操作、URL 拼裝或商務計算。View 只做資料呈現與轉發事件給 ViewModel。
* **ViewModel 層**：只依賴 Repository 抽象介面（Protocol），自身不持有具體的網路實作。
* **Domain Entity**：保持純淨，不依賴任何外部框架。

#### (2) 消除魔術數字與硬編碼字串
* 建立 `Core/Constants/AppConstants.swift`，集中管理分頁筆數、API Base URL 等設定。
* 提取通用色彩與間距至 `DesignSystem`。

---

### 2. 每日實作任務（1~2 小時）

1. 全局搜尋專案中的字串與數值，將其重構至常數設定檔。
2. 檢查所有 View 檔案行數：若有單一 View 超過 150 行，拆解為獨立的子視圖元件（Subviews）。
3. 確保專案能夠在 Xcode 乾淨編譯（Clean Build）無任何報錯。

---

### 3. 當日交付成果與檢驗指標
* [ ] 程式碼結構整潔，邊界清晰。
* [ ] 無冗餘註解與死代碼。

---

## Day 22: 單元測試實戰（Swift Testing / XCTest）

### 1. 核心觀念深入解析（Android vs iOS 對照）

#### (1) JUnit / Mockk vs Swift Testing
* Android 你習慣用 JUnit 5 + Mockk：
  ```kotlin
  @Test
  fun `when fetch success then state is Success`() = runTest { ... }
  ```
* iOS 最新標準是 **Swift Testing**（iOS 18+ / Swift 6 原生支援）或經典的 **XCTest**。
* **Swift Testing 實戰範例**：
  ```swift
  import Testing
  @testable import MainProject

  struct ItemViewModelTests {
      @Test("測試當 Repository 回傳成功時，ViewModel 狀態轉變為 Success")
      func testLoadDataSuccess() async {
          // Arrange
          let mockRepo = MockItemRepository()
          mockRepo.stubbedItems = [
              ItemModel(id: 1, name: "Sample Item")
          ]
          let viewModel = await ItemViewModel(repository: mockRepo)
          
          // Act
          await viewModel.onAction(.loadInitial)
          
          // Assert
          if case .success(let items) = viewModel.state {
              #expect(items.count == 1)
              #expect(items.first?.name == "Sample Item")
          } else {
              Issue.record("預期狀態應為 Success")
          }
      }
      
      @Test("測試網路異常時，ViewModel 狀態能正確捕捉錯誤訊息")
      func testLoadDataFailure() async {
          let mockRepo = MockItemRepository()
          mockRepo.shouldThrowError = true
          let viewModel = await ItemViewModel(repository: mockRepo)
          
          await viewModel.onAction(.loadInitial)
          
          if case .error = viewModel.state {
              #expect(true)
          } else {
              Issue.record("預期狀態應為 Error")
          }
      }
  }
  ```

---

### 2. 每日實作任務（1~2 小時）

1. 在 Xcode 專案中新增 Unit Test Target。
2. 為 ViewModel 與 Repository 撰寫至少 5 個測試案例（分頁累加、錯誤處理、快取回退）。
3. 執行快捷鍵 `Cmd + U`，確認所有測試全數通過（Green）。

---

### 3. 當日交付成果與檢驗指標
* [ ] 產出具備商用標準的單元測試套件。
* [ ] 理解非同步測試在 Swift Concurrency 下的驗證機制。

---

## Day 23: 記憶體管理與效能調校（ARC vs GC）

### 1. 核心觀念深入解析（資深工程師的核心壁壘）

#### (1) Android JVM/ART (GC) vs iOS (ARC)
* **Android 的 GC**：物件即便存在雙向引用，只要 Root 物件不可達，Garbage Collector 在合適時機就會回收。
* **iOS 的 ARC（自動引用計數）**：
  * 物件在堆積中的生命週期**完全由計數決定**。當 Reference Count 歸零時，記憶體**立刻釋放**（確定性銷毀 `deinit`）。
  * **強引用循環（Retain Cycle）致命陷阱**：
    若物件 A 強持有物件 B，物件 B 同時也強持有物件 A，計數永遠不會歸零 ➔ **永久性記憶體洩漏（Memory Leak）**！

#### (2) 閉包逃逸與 `[weak self]`
在閉包（Closure）或非同步 Task 內部存取 `self` 時，必須謹慎使用弱引用：
```swift
class DataWatcher {
    var onUpdate: (() -> Void)?
    
    func setup() {
        // 使用 [weak self] 打破 Retain Cycle
        self.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.refreshData()
        }
    }
}
```

#### (3) Instruments 工具實戰（對比 Android Profiler）
* **Leaks**：即時標紅閃爍顯示記憶體循環洩漏點。
* **Allocations**：追蹤記憶體配置峰值與物件計數堆疊。

---

### 2. 每日實作任務（1~2 小時）

1. 打開 Xcode 菜單 ➔ **Product ➔ Profile**（快捷鍵 `Cmd + I`）。
2. 選擇 **Leaks** 模板啟動。
3. 在 App 中進行壓力操作：反覆點擊進入詳情頁、返回列表 20 次，進行拉取刷新與搜尋。
4. 觀察 Leaks 時間軸是否有任何紅色叉叉（Leak 報警），並檢查 Memory Graph 確認無任何未銷毀的 ViewModel 物件。

---

### 3. 當日交付成果與檢驗指標
* [ ] 深刻掌握 ARC、`weak` 與 `unowned` 的運作原理。
* [ ] 透過 Instruments 完成專案全面檢測，達成 0 Memory Leak。

---

## Day 24: 專案工程化規範與 SwiftLint

### 1. 核心觀念深入解析

在團隊協作或 Tech Lead 視角下，**程式碼規範與模組化依賴管理**是專案可維護性的基石：

#### (1) Swift Package Manager (SPM)
* 對照 Android 的 Gradle 依賴管理，現代 iOS 全面採用 Apple 原生內建的 SPM。
* 原生整合於 Xcode、直接以原始碼編譯、快取極快。

#### (2) 導入 SwiftLint（程式碼靜態分析）
* 統一團隊程式碼風格（強制空格、命名長度、禁止強制解包等）。
* 透過 Build Tool Plugin 自動在編譯期標註 Warning 與 Error。

---

### 2. 每日實作任務（1~2 小時）

1. 在 Xcode 專案中透過 SPM 導入 **SwiftLint**。
2. 在專案根目錄建立 `.swiftlint.yml` 設定檔。
3. 執行編譯，修復專案中出現的所有 Lint Warning，達到 **0 Warning, 0 Error** 的工業級規範。

---

### 3. 當日交付成果與檢驗指標
* [ ] 專案具備自動化程式碼風格檢查機制。
* [ ] 程式碼庫整潔一致，符合 Apple 官方 API Design Guidelines。

---

## Day 25: 簽名憑證、實機部署與 TestFlight 打包

### 1. 核心觀念深入解析

搞懂 iOS 代碼簽名體系三部曲：
1. **Certificate（憑證）**：證明你是合法的 Apple 開發者。
2. **App ID (Bundle Identifier)**：證明這款 App 的全域唯一身分。
3. **Provisioning Profile（描述檔）**：結合憑證、App ID 與實機 UDID 的正式授權書。

---

### 2. 每日實作任務（1~2 小時）

1. 登入 Apple ID（免費個人帳號即可進行實機部署）。
2. 連接實機 iPhone，在 Xcode 選擇自己的手機作為 Target 進行自動簽名。
3. 將 App 安裝至實機 iPhone 運行，體驗實機手勢與 120Hz 流暢度！

---

### 3. 當日交付成果與檢驗指標（週期五里程碑）
* [ ] 搞懂 Certificate、Provisioning Profile 與 App ID 的核心關係。
* [ ] **【里程碑產出】** 專案通過單元測試、通過 Instruments 效能檢驗，並成功運行在實機硬體上！
