import Foundation
import UIKit

extension UITextView {
    func numberOfLine() -> Int {
        guard let lineHeight = self.font?.lineHeight else { return 0 }
        return Int(self.contentSize.height / lineHeight)
    }
}
