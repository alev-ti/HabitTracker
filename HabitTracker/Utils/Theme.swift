import UIKit

final class Theme {
    
    // MARK: - Singleton
    static let shared = Theme()
    
    private init() {}

    // MARK: - Colors
    let backgroundColor = UIColor.systemBackground
    
    let textColor = UIColor { traits in
        traits.userInterfaceStyle == .light ? UIColor.black : UIColor.white
    }
    
    let buttonTitleColor = UIColor { traits in
        traits.userInterfaceStyle == .light ? UIColor.white : Color.lightBlack
    }
    
    let tableCellColor = UIColor { traits in
        traits.userInterfaceStyle == .light ? Color.lightGray : Color.darkGray
    }
}
