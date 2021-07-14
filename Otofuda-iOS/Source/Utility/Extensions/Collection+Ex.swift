//
//  Collection+Ex.swift
//  Otofuda-iOS
//
//  Created by にーの on 2021/07/14.
//  Copyright © 2021 nkmr-lab. All rights reserved.
//

import Foundation

extension Collection {
    public subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }

    public subscript (safe openBounds: Range<Index>) -> SubSequence {
        return openBounds.clamped(to: self.startIndex..<self.endIndex) == openBounds ? self[openBounds] : self.suffix(0)
    }

    public subscript (safe closeBounds: ClosedRange<Index>) -> SubSequence {
        return closeBounds.clamped(to: self.startIndex...self.endIndex) == closeBounds ? self[closeBounds] : self.suffix(0)
    }
}
