import Foundation
import UIKit

public struct User: Identifiable, Codable {
    public let id: Int
    var userName: String
    var profileImageURL: String = "gpt" //person.circle
}
