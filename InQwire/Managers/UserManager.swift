import Foundation

private let kUserIdKey = "userId"

struct UserManager {
    
    /// Id of the current user
    static var currentUserId: String {
        return UserDefaults.standard.value(forKey: kUserIdKey) as? String ?? self.generateUserId()
    }
    
    private static func generateUserId() -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyz"
        let length = UInt32(3)
        var userId = ""
        for _ in 0 ..< length {
            var nextChar = letters.character(at: Int(arc4random_uniform(length)))
            userId += NSString(characters: &nextChar, length: 1) as String
        }
        
        userId += String(Int(arc4random_uniform(100)))
        UserDefaults.standard.set(userId, forKey: kUserIdKey)
        return userId
    }
}
