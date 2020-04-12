// Douglas Hill, March 2020

import UIKit

extension UIImage {
    /// Creates an images with a system name or falls back to a placeholder on older versions.
    static func createWithSystemName(_ name: String, font: UIFont) -> UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(font: font))
        } else {
            let bounds = CGRect(x: 0, y: 0, width: font.pointSize, height: font.pointSize)
            return UIGraphicsImageRenderer(bounds: bounds).image { context in
                let thickness: CGFloat = 1
                let path = UIBezierPath(ovalIn: bounds.insetBy(dx: 0.5 * thickness, dy: 0.5 * thickness))
                path.lineWidth = thickness
                path.stroke()
            }.withRenderingMode(.alwaysTemplate)
        }
    }
}

extension UIColor {
    class var systemBackground_: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    class var secondarySystemBackground_: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemBackground
        } else {
            return .init(white: 0.95, alpha: 1)
        }
    }

    class var label_: UIColor {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }
}
