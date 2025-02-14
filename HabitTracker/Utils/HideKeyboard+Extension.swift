import UIKit

extension UIViewController {
    func hideKeyboardWhenTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc private func hide() {
        view.endEditing(true)
    }
}
