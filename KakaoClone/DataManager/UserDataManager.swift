import Foundation

public class UserDataManager {
    public var users: [User] = [man, woman, otherPeople]
    
    public func getUser(_ id: Int) -> User {
        guard let user = users.first(where: {$0.id == id}) else { return User(id: 0, userName: "nil") }
        return user
    }
}
