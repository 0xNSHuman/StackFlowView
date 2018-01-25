//
//  Foundation+Extensions.swift
//  Created by Vladislav Averin
//

import Foundation

extension Date {
	static func unixDate(from string: String) -> Date? {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		
		if let date = formatter.date(from: string) {
			return date
		} else {
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
			return formatter.date(from: string)
		}
	}
	
	func unixDateString() -> String? {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		formatter.timeZone = TimeZone(identifier: "UTC")
		
		return formatter.string(from: self)
	}
	
	func stringRepresentation(format: String) -> String? {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.string(from: self)
	}
}

extension Bundle {
	func typeFromNib<T>(_ type: T.Type) -> T? {
		return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T
	}
}
