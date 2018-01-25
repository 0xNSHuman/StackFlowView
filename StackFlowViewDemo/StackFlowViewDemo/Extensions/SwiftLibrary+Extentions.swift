//
//  SwiftLibrary+Extentions.swift
//  Created by Vladislav Averin
//

import Foundation

private extension String {
	var urlEscaped: String {
		return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
	}
	
	var utf8Encoded: Data {
		return self.data(using: .utf8)!
	}
}

extension Dictionary {
	static func += (left: inout Dictionary, right: Dictionary) {
		// Swift 4 way
		
		left.merge(right) { (_, new) in new }
		return;
		
		// Swift 3 way
		
		for (key, value) in right {
			left[key] = value
		}
	}
}

extension Sequence where Iterator.Element: Hashable {
	func unique() -> [Iterator.Element] {
		var seen: Set<Iterator.Element> = []
		return filter {
			if seen.contains($0) {
				return false
			} else {
				seen.insert($0)
				return true
			}
		}
	}
}

// TODO: Not sure about overflow

extension Int {
	static postfix func ++ (_ value: inout Int) {
		value = value < Int.max ? value + 1 : Int.max
	}
	
	static postfix func -- (_ value: inout Int) {
		value = value > Int.min ? value - 1 : Int.min
	}
}

extension UInt {
	static postfix func ++ (_ value: inout UInt) {
		value = value < UInt.max ? value + 1 : UInt.max
	}
	
	static postfix func -- (_ value: inout UInt) {
		value = value > UInt.min ? value - 1 : UInt.min
	}
}
