import Foundation

public struct Dialog: Codable {
    let opponent: User
    var messages: [MessageContent] = []
}
