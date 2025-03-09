import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitize = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitize.hasPrefix("#") {
            hexSanitize.removeFirst()
        }

        guard hexSanitize.count == 6 else { return nil }

        var RGB: UInt64 = 0
        Scanner(string: hexSanitize).scanHexInt64(&RGB)

        let red = CGFloat((RGB >> 16) & 0xFF) / 255.0
        let green = CGFloat((RGB >> 8) & 0xFF) / 255.0
        let blue = CGFloat(RGB & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var hexString: String {
        let components = self.cgColor.components ?? [0, 0, 0, 1]
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        let rgb = (Int)(red * 255.0) << 16 | (Int)(green * 255.0) << 8 | (Int)(blue * 255.0)
        
        return String(format: "#%06X%0", rgb)
    }
}

