//
//  Extensions.swift
//  DogApp
//
//  Created by Wilfred Anorma on 25/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import Foundation
import UIKit

final class Utilities {
    private init() {}
    static func getTextLabelWidth(with text:String, using font:UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return boundingBox.width
    }
}

extension UILabel {
    var width: CGFloat {
        guard let text = self.text else { return 0 }
        return Utilities.getTextLabelWidth(with: text, using: self.font)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
