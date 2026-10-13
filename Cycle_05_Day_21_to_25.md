# 週期五 (Day 21 ~ Day 25)：測試、底層效能與工程化治理（工業級品管）

> **專案標竿**：對標 [PokemonXDigimonBook](https://github.com/a62005/PokemonXDigimonBook) 的多模組化結構（`app`、`lib_network`、`lib_database`）與單元測試。  
> **週期目標**：為雙圖鑑專案補齊單元測試（驗證分頁與離線快取邏輯）、排查大量圖片滑動下的記憶體佔用（Instruments Leaks / Allocations）、導入 SwiftLint 並完成實機 iPhone 部署。  
> **建議學習時間**：每天 1~2 小時

---

## Day 21: 模組整潔與架構收斂

### 1. 核心觀念深入解析

對照你的 Android 原版多模組結構：
* `app` ➔ 畫面與 MVI 控制
* `lib_network` ➔ 網路層與 DTO
* `lib_database` ➔ Room 實體與 Dao
在 iOS 專案中，我們梳理成清晰的邊界規範：
```text
PokemonXDigimonBook-iOS/
├── App/                            // App 入口與 ModelContainer 配置
├── Core/
│   ├── Network/                    // APIClient, DTOs, Endpoints
│   ├── Database/                   // SwiftData Entities (PokemonEntity, DigimonEntity)
│   ├── Repositories/               // 雙 Repository 實作與 Protocol
│   └── Utils/                      // ColorUtils, ImageCache
├── Components/                     // MonsterCard, StatItemView, ShimmerView
└── Features/
    ├── Home/                       // HomeScreen
    ├── MonsterList/                // MonsterListScreen (Pokemon/Digimon 複用)
    └── MonsterDetail/              // PokemonDetailScreen, DigimonDetailScreen
```

---

### 2. 每日實作任務（1~2 小時）

1. 檢查檔案歸類，消除跨模組的非法依賴。
2. 提取常數：將 Base URL（`https://pokeapi.co/api/v2/`、`https://digi-api.com/api/v1/`）與分頁大小（`PAGE_SIZE = 30`）統一收攏至 `AppConfig.swift`。
3. 確保專案能夠乾淨編譯（Clean Build）無報錯。

---

### 3. 當日交付成果與檢驗指標
* [ ] 專案結構清晰，職責劃分嚴格對標 Android 企業級多模組架構。

---

## Day 22: 單元測試實戰（驗證分頁、Mock 網路與 DB 快取）

### 1. 核心觀念深入解析（Swift Testing / XCTest）

對照原版 Android 的測試，我們在 iOS 撰寫兩個核心測試案例：
1. **分頁載入測試**：測試當呼叫 `.loadMore` 時，`offset` 是否由 0 遞增為 30，且新抓取的怪獸能被追加進列表。
2. **離線快取優先測試**：測試當 Mock 網路斷線時，Repository 是否能正確退回本地 SwiftData 資料。

```swift
import Testing
@testable import PokemonXDigimonBook_iOS

struct PokemonRepositoryTests {
    @Test("測試當本地有快取時，優先回傳本地怪獸清單")
    func testOfflineCacheReturn() async throws {
        // Arrange
        let mockAPI = MockPokemonAPI()
        let repo = PokemonRepository(apiClient: mockAPI)
        
        // Act
        let monsters = try await repo.fetchLocalMonsters()
        
        // Assert
        #expect(!monsters.isEmpty)
    }
    
    @Test("測試分頁載入邏輯累加正確")
    func testPaginationOffset() async {
        let viewModel = await PokemonViewModel(repository: MockPokemonRepository())
        await viewModel.onIntent(.loadInitial)
        await viewModel.onIntent(.loadMore)
        
        #expect(viewModel.currentCount == 60)
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 新增 Unit Test Target，撰寫 `PokemonViewModelTests.swift` 與 `DigimonViewModelTests.swift`。
2. 撰寫至少 6 個涵蓋分頁、錯誤回退與去重檢查的單元測試。
3. 按下 `Cmd + U`，確認測試綠燈全數通過。

---

### 3. 當日交付成果與檢驗指標
* [ ] 產出健全的單元測試套件，具備商用級代碼可靠度。

---

## Day 23: 記憶體調校與 Instruments Leaks 實戰

### 1. 核心觀念深入解析（大量怪獸圖片的效能守護）

雙圖鑑 App 有數百張怪獸高解析度圖片與大量動態列表，這是最容易觸發 OOM（Out Of Memory）或記憶體洩漏的場景：
* **ARC 閉包弱引用**：在非同步任務或回調中存取 ViewModel，務必加上 `[weak self]`。
* **圖片解碼快取控制**：確保 `MonsterImageCache` 設定了最大記憶體限制（`countLimit` 與 `totalCostLimit`），避免圖片擠爆 RAM。
* **Instruments Leaks**：檢查反覆進出寶可夢與數碼寶貝詳情頁是否有未釋放的 View 或 ViewModel。

---

### 2. 每日實作任務（1~2 小時）

1. 使用 `Cmd + I` 啟動 **Xcode Instruments ➔ Leaks**。
2. 在模擬器中進行壓力操作：快速滑動 100 隻怪獸、快速連續點進點出詳情頁 20 次。
3. 觀察 Leaks 與 Allocations 時間軸，確認記憶體維持在安全水準（< 150MB），且無紅色洩漏報警。

---

### 3. 當日交付成果與檢驗指標
* [ ] 通過 Instruments 效能與記憶體壓力測試。
* [ ] 掌握 iOS 原生 Profiler 的深度調校能力。

---

## Day 24: 專案工程化規範與 SwiftLint

### 1. 核心觀念深入解析

在 Tech Lead 視角下，團隊代碼規範必須具備自動化防禦：
* 導入 **SwiftLint**。
* 規範強制解包（`force_unwrapping`）、函式長度（`function_body_length`）、命名慣例。

---

### 2. 每日實作任務（1~2 小時）

1. 透過 SPM 導入 SwiftLint Build Tool Plugin。
2. 配置 `.swiftlint.yml`。
3. 執行編譯，修復所有 Warning，達成 **0 Warning, 0 Error**。

---

### 3. 當日交付成果與檢驗指標
* [ ] 專案代碼風格標準化，完全符合 Apple 官方 API Design Guidelines。

---

## Day 25: 簽名憑證、實機部署與 TestFlight 打包

### 1. 核心觀念深入解析

* 實機運行是檢驗真實觸控、轉場動畫幀率（ProMotion 120Hz）與離線快取的唯一真理。
* 搞懂 Apple 簽名三部曲：Certificate ➔ App ID ➔ Provisioning Profile。

---

### 2. 每日實作任務（1~2 小時）

1. 連接實機 iPhone，在 Xcode 選擇個人開發者 Team 進行自動簽名。
2. 將《PokemonXDigimonBook (iOS)》安裝至實機 iPhone。
3. 實際在手機上開啟離線模式，把玩流暢的怪獸展開動畫與雙世界切換！

---

### 3. 當日交付成果與檢驗指標（週期五里程碑）
* [ ] **【里程碑產出】** 一款在實機 iPhone 上順暢運行、具備單元測試防護且通過記憶體檢驗的完整 App！
