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
            return NSLocalizedString("page_model.onboarding_blue", comment: "onboarding blue page text")
        case .redPage:
            return NSLocalizedString("page_model.onboarding_red", comment: "onboarding red page text")
        }
    }
}

