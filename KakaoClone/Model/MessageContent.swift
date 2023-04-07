import Foundation

public struct MessageContent: Content, Codable {
    let senderID: Int
    var contentType: ContentType
    var textContent: String?
    var imageContent: Data?
    var inputDate: Date = Date()
    
    init(senderID: Int, textContent: String) {
        self.senderID = senderID
        self.contentType = .text
        self.textContent = textContent
    }
    
    init(senderID: Int, imageContent: Data) {
        self.senderID = senderID
        self.contentType = .image
        self.imageContent = imageContent
    }
}

protocol Content: Codable {
    var senderID: Int { get }
    var inputDate: Date { get set }
}

enum ContentType: Codable {
    case text
    case image
}
