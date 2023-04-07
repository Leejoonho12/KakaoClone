import Foundation
import UIKit

enum Constraint {
    static let BOTTOM_VIEW_INIT_HEIGHT = 42
    static let BOTTOM_VIEW_HEIGHT_PER_ROW = 22
    static let TEXT_VIEW_TOP_INSET = 10
    static let FIXED_SEARCH_BAR_HEIGHT = 44
}

enum TextViewInset {
    static let initial = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
    static let increasing = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let maxHeight = UIEdgeInsets(top: 10, left: 10, bottom: 5, right: 10)
}

enum ImageQuality {
    static let low = 250
    static let normal = 500
    static let high = 1000
}
