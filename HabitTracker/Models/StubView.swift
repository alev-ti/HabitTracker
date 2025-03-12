import UIKit

struct StubView {
    let imageView: UIImageView
    let label: UILabel

    func setVisibility(isVisible: Bool) {
        imageView.isHidden = !isVisible
        label.isHidden = !isVisible
    }
}

