import UIKit

enum PageModel {
    case bluePage
    case redPage

    var image: UIImage {
        switch self {
        case .bluePage:
            return UIImage(named: "onboarding_blue") ?? UIImage()
        case .redPage:
            return UIImage(named: "onboarding_red") ?? UIImage()
        }
    }

    var text: String {
        switch self {
        case .bluePage:
            return "Отслеживайте только то, что хотите"
        case .redPage:
            return "Даже если это не литры воды и йога"
        }
    }
}

