# 週期一 (Day 1 ~ Day 5)：語言心智映射與 SwiftUI 佈局基石（雙圖鑑骨架）

> **專案標竿**：以 Android 專案 [PokemonXDigimonBook](https://github.com/a62005/PokemonXDigimonBook) 為對標，打造 iOS 雙原生版本《PokemonXDigimonBook (iOS)》。  
> **週期目標**：解鎖 Swift 語法心智模型，完成宣告式佈局（Compose ➔ SwiftUI）概念置換，搭建出「首頁雙入口選擇」與「怪獸網格清單 + 詳情」的靜態導航骨架。  
> **建議學習時間**：每天 1~2 小時

---

## Day 1: Swift 與 Kotlin 基礎語法映射與空安全（Optionals）

### 1. 核心觀念深入解析（Android vs iOS 對照）

你的 Android 專案中有大量處理怪獸屬性（`types: List<String>?`）、可空描述（`description: String?`）的邏輯。在 Kotlin 中你習慣用 `?.`、`?:` 與 `let`，在 Swift 中需要掌握其獨有的解包語意：

#### (1) 常數與變數
* Kotlin：`val id: Int`、`var isFavorite: Boolean`。
* Swift：`let id: Int`、`var isFavorite: Bool`。Swift 編譯器會嚴格檢查未修改變數，強制建議改為 `let`。

#### (2) 空安全心智模型（Optionals）
Swift 的 `Optional` 本質是列舉 `enum Optional<Wrapped> { case none, case some(Wrapped) }`：

```swift
// 1. guard let：提早返回（Early Exit，處理怪獸可空欄位最推薦）
func getMainType(types: [String]?) -> String {
    guard let firstType = types?.first, !firstType.isEmpty else {
        return "Normal" // 預設屬性
    }
    return firstType.capitalized
}

// 2. if let：局部作用域安全解包（對照 Kotlin 的 ?.let { }）
if let description = digimon.description {
    renderDescriptionText(description)
}

// 3. 空合併運算子（對應 Kotlin 的 ?:）
let displayName = pokemon.name ?? "未知寶可夢"
```

> ⚠️ **Android 工程師常見踩坑點**：
> * 切忌在生產環境濫用強制解包 `!`（對應 Kotlin `!!`）。
> * Swift 字串插值為 `"No.\(id) \(name)"`，而非 Kotlin 的 `"No.$id ${name}"`。

---

### 2. 每日實作任務（1~2 小時）

1. **開啟 Xcode Playground**：建立名為 `Day01_SyntaxMapping`。
2. **實作怪獸資料模型原型**：
   * 建立包含可空欄位（如 `description: String?`, `types: [String]?`）的資料結構。
   * 撰寫一個函式解析該資料，使用 `guard let` 做多條件驗證。
   * 實作預設圖片網址與預設屬性的空合併處理（使用 `??`）。
3. **對比筆記**：對照你原本 Android 專案中的 `PokemonEntity` 與 `DigimonEntity`，在 Playground 中寫下欄位型別映射對照。

---

### 3. 當日交付成果與檢驗指標
* [ ] 熟練運用 `guard let` 與 `if let` 處理怪獸資料的可空屬性。
* [ ] 能不假思索地在 Swift 中完成 Optional 解包與字串格式化。

---

## Day 2: 結構體、協定與列舉（怪獸通用 Bean 抽象設計）

### 1. 核心觀念深入解析

在你的 Android 專案中，定義了 `ISimpleBean` 與 `IDetailBean` 來讓 Pokemon 與 Digimon 共享通用介面與 Card 元件：

```kotlin
// Android 原版
interface ISimpleBean {
    val id: Int
    val name: String
    val imageUrl: String
    fun getMainType(): String?
}
```

在 Swift 中，我們使用 **面向協定編程（POP, Protocol-Oriented Programming）** 與 **值型別（Struct）** 完美復刻：

#### (1) Struct（值型別）取代 Class
* 你的怪獸 Model 在 iOS 中**全部宣告為 `struct`**！
* 存放於 Stack、複製即寫（Copy-on-Write）、天生執行緒安全且無 GC 負擔。

#### (2) Protocol 與預設實作（Extension）
```swift
protocol SimpleMonster: Identifiable {
    var id: Int { get }
    var name: String { get }
    var imageUrl: String { get }
    var types: [String]? { get }
    func getMainType() -> String?
}

// 利用 extension 提供預設實作
extension SimpleMonster {
    func getMainType() -> String? {
        return types?.first
    }
}
```

#### (3) Enum with Associated Values 實作 MVI/UIState
對應你專案中的 `BaseListUiState<T>` 與 `BaseUiState<T>`：
```swift
enum ListUIState<T> {
    case idle
    case loading
    case success(items: [T], hasMore: Bool)
    case error(message: String)
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 Swift 版的 `SimplePokemonItem` 與 `SimpleDigimonItem` 結構體。
2. 讓兩者遵循 `SimpleMonster` 協定，透過 `extension` 實作主屬性色彩判定。
3. 實作 `ListUIState` 列舉，練習用 `switch` 搭配 Pattern Matching 模擬成功/失敗分流。

---

### 3. 當日交付成果與檢驗指標
* [ ] 完成《PokemonXDigimonBook》的 Protocol 與 Model 架構草案。
* [ ] 掌握 Swift Protocol 的預設實作機制。

---

## Day 3: SwiftUI 宣告式佈局（刻出 HomeScreen 雙入口）

### 1. 核心觀念深入解析

對照你的 Android `HomeScreen.kt`：
* Android 是用 `Column`，裡面放兩個 `Box(modifier = Modifier.weight(1f))`，中間用黑線 `Spacer` 隔開，分別點擊進入 Pokemon 或 Digimon。
* 在 SwiftUI 中，像素級映射如下：

```swift
// SwiftUI 對標 HomeScreen
struct HomeScreen: View {
    var onPokemonClick: () -> Void
    var onDigimonClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 上半部：Pokemon
            Button(action: onPokemonClick) {
                Image("logo_pokemon")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
            
            // 分隔黑線
            Rectangle()
                .fill(Color.black)
                .frame(height: 4)
            
            // 下半部：Digimon
            Button(action: onDigimonClick) {
                Image("logo_digimon")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 在 Xcode 建立新專案 `PokemonXDigimonBook-iOS`。
2. 將 Android 專案 `mipmap-xxhdpi` 中的 `logo_pokemon.webp` 與 `logo_digimon.webp` 匯入 Xcode `Assets.xcassets`。
3. 實作 `Views/HomeScreen.swift`，達到上下對半分割、點擊高亮反饋與黑線分隔。

---

### 3. 當日交付成果與檢驗指標
* [ ] 成功在模擬器中呈現與原版 Android 視覺 1:1 一致的 `HomeScreen`。
* [ ] 掌握 `VStack`、`Rectangle` 與圖片縮放修飾符（`resizable`, `scaledToFit`）。

---

## Day 4: 怪獸卡片元件與屬性顏色系統（MonsterCard）

### 1. 核心觀念深入解析

對照你的 Android `MonsterCard.kt` 與 `ColorUtils.kt`：
* Android 根據 `types.first()` 決定卡片背景色（如 Fire ➔ 紅、Water ➔ 藍、Grass ➔ 綠）。
* 列表中展示：怪獸編號（如 `#001`）、英文名稱、主屬性 Tag、非同步圖片。

#### SwiftUI MonsterCard 實作範例
```swift
struct MonsterCard: View {
    let id: Int
    let name: String
    let imageUrl: String
    let mainType: String?
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(format: "#%03d", id))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(name.capitalized)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let type = mainType {
                        Text(type.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding()
                
                // 圖片
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .padding(8)
            }
            .frame(height: 120)
            .background(ColorUtils.colorForType(mainType))
            .cornerRadius(16)
            .shadow(radius: 4)
        }
        .buttonStyle(.plain)
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Core/Utils/ColorUtils.swift`，為火、水、草、電等 18 種屬性配置專屬顏色。
2. 實作 `Components/MonsterCard.swift`。
3. 在 Preview 中傳入幾筆測試資料，確認卡片在不同屬性下的視覺呈現。

---

### 3. 當日交付成果與檢驗指標
* [ ] 產出可高度復用、支援 Pokemon 與 Digimon 的 `MonsterCard.swift`。
* [ ] 完成怪獸屬性顏色映射系統。

---

## Day 5: 雙欄網格列表與導航系統（NavigationStack）

### 1. 核心觀念深入解析

對照你的 Android `MonsterListScreen.kt`：
* Android 使用 `LazyVerticalGrid(columns = GridCells.Fixed(2))`。
* SwiftUI 對標使用 `LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())])`。
* 導航架構：從 `HomeScreen` 點擊進入 `PokemonScreen` 或 `DigimonScreen`，點擊卡片再進入 `DetailScreen`。

```swift
enum AppRoute: Hashable {
    case pokemonList
    case digimonList
    case pokemonDetail(id: Int, name: String)
    case digimonDetail(name: String)
}

struct AppNavigation: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeScreen(
                onPokemonClick: { path.append(AppRoute.pokemonList) },
                onDigimonClick: { path.append(AppRoute.digimonList) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .pokemonList:
                    PokemonScreen(onItemClick: { id, name in
                        path.append(AppRoute.pokemonDetail(id: id, name: name))
                    })
                case .digimonList:
                    DigimonScreen(onItemClick: { name in
                        path.append(AppRoute.digimonDetail(name: name))
                    })
                case .pokemonDetail(let id, let name):
                    PokemonDetailScreen(id: id, name: name)
                case .digimonDetail(let name):
                    DigimonDetailScreen(name: name)
                }
            }
        }
    }
}
```

---

### 2. 每日實作任務（1~2 小時）

1. 建立 `Navigation/AppRoute.swift` 與 `AppNavigation.swift`。
2. 建立包含假資料的雙欄網格列表頁 `MonsterListScreen.swift`。
3. 跑通完整跳轉路徑：`HomeScreen` ➔ `PokemonScreen`（雙欄網格）➔ `DetailScreen`。

---

### 3. 當日交付成果與檢驗指標（週期一里程碑）
* [ ] **【里程碑產出】** 成功重現與原版 Android 相同的雙世界入口與雙欄網格頁面跳轉骨架。
* [ ] 熟悉 SwiftUI 現代 `NavigationStack` 與 `NavigationPath` 的型別安全路由。
