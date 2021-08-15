//
//  Collection+Ex.swift
//  Otofuda-iOS
//
//  Created by にーの on 2021/07/14.
//  Copyright © 2021 nkmr-lab. All rights reserved.
//

import Foundation

public extension Collection {
    subscript(safe index: Index) -> Iterator.Element? {
        indices.contains(index) ? self[index] : nil
    }

    subscript(safe openBounds: Range<Index>) -> SubSequence {
        openBounds.clamped(to: startIndex ..< endIndex) == openBounds ? self[openBounds] : suffix(0)
    }

    subscript(safe closeBounds: ClosedRange<Index>) -> SubSequence {
        closeBounds.clamped(to: startIndex ... endIndex) == closeBounds ? self[closeBounds] : suffix(0)
    }
}
