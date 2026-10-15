import Foundation

// MARK: - 模擬情境：解析後端回傳的使用者資料（所有欄位皆可能為 nil）
struct RawUserResponse {
    let id: Int?
    let username: String?
    let email: String?
    let roles: [String]?
    let bio: String?
}

// MARK: - 實作練習函式
func processUserProfile(response: RawUserResponse) {
    // 【任務 1：使用 guard let 做驗證（Early Exit）】
    // 規則：id 必須非空且 > 0，username 必須非空且去除空白後不為空（!username.trimmingCharacters(in: .whitespaces).isEmpty）
    // 條件若不滿足，印出 "❌ 驗證失敗：無效的使用者 ID 或名稱" 並提早 return。
    
    
    // 【任務 2：使用 ?? 空合併運算子（Elvis 運算子）】
    // 規則：primaryRole 取 roles 的第一個元素，若 roles 為 nil 或空陣列，預設為 "Guest"
    
    
    // 【任務 3：使用 if let 或空合併處理可空欄位】
    // 規則：處理 email 與 bio，若 bio 為 nil 則顯示 "尚未填寫個人簡介"
    let newBio = response.bio ??
    
    // 【任務 4：使用字串插值 \( ) 印出格式化結果】
    // 預期輸出格式範例：
    // ✅ 使用者 [101] Alex (角色: Admin)
    //    Email: alex@example.com
    //    簡介: Senior Mobile Engineer
    
}

// MARK: - 測試案例
print("--- 測試 1：正常資料 ---")
let validUser = RawUserResponse(
    id: 101,
    username: "Alex",
    email: "alex@example.com",
    roles: ["Admin", "Developer"],
    bio: "Senior Mobile Engineer"
)
processUserProfile(response: validUser)

print("\n--- 測試 2：邊界/缺少欄位資料 ---")
let partialUser = RawUserResponse(
    id: 102,
    username: "Sam",
    email: nil,
    roles: nil,
    bio: nil
)
processUserProfile(response: partialUser)

print("\n--- 測試 3：無效資料 ---")
let invalidUser = RawUserResponse(
    id: -1,
    username: "",
    email: nil,
    roles: nil,
    bio: nil
)
processUserProfile(response: invalidUser)
