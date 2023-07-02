import UIKit

class CustomScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UITableViewCell {
            return false
        }
        return true
    }
}
