import UIKit

final class Theme {
    
    let backgroundColor = UIColor.systemBackground
    
    let textColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    let buttonTitleColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.white
        } else {
            return Color.lightBlack
        }
    }
    
    let tableCellColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return Color.lightGray
        } else {
            return Color.darkGray
        }
    }
}

