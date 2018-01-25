//
//  StackFlow.swift
//  Created by Vladislav Averin on 11/12/2017.

/*
The MIT License (MIT)
Copyright © 2017 Vladislav Averin
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import UIKit

// MARK: - Stack item appearance -

/// Appearance description, typically assigned to newly pushed stack flow item when you want to customize its look.

public struct StackItemAppearance {
	static var defaultPreset: StackItemAppearance {
		let popButtonTitle = NSAttributedString(string: "prev", attributes: [.foregroundColor : UIColor.blue])
		let pushButtonTitle = NSAttributedString(string: "next", attributes: [.foregroundColor : UIColor.blue])
		
		let topBarAppearance = StackItemAppearance.TopBar(backgroundColor: .white, titleFont: UIFont.systemFont(ofSize: UIFont.systemFontSize), titleTextColor: .darkGray, popButtonIdentity: TopBar.Button(title: popButtonTitle), pushButtonIdentity: TopBar.Button(title: pushButtonTitle))
		
		return StackItemAppearance(backgroundColor: .clear, topBarAppearance: topBarAppearance)
	}
	
	/// Appearance description for stack flow item's top (navigation) bar.
	
	public struct TopBar {
		public struct Button {
			let icon: UIImage?
			let title: NSAttributedString?
			
			public init(icon: UIImage) {
				self.icon = icon
				self.title = nil
			}
			
			public init(title: NSAttributedString) {
				self.title = title
				self.icon = nil
			}
		}
		
		let backgroundColor: UIColor
		let titleFont: UIFont
		let titleTextColor: UIColor
		let popButtonIdentity: Button
		let pushButtonIdentity: Button
		
		public init(backgroundColor: UIColor, titleFont: UIFont, titleTextColor: UIColor, popButtonIdentity: Button, pushButtonIdentity: Button) {
			
			self.backgroundColor = backgroundColor
			self.titleFont = titleFont
			self.titleTextColor = titleTextColor
			self.popButtonIdentity = popButtonIdentity
			self.pushButtonIdentity = pushButtonIdentity
		}
	}
	
	let backgroundColor: UIColor
	let topBarAppearance: TopBar
	
	public init(backgroundColor: UIColor, topBarAppearance: TopBar? = nil) {
		self.backgroundColor = backgroundColor
		self.topBarAppearance = topBarAppearance ?? StackItemAppearance.defaultPreset.topBarAppearance
	}
}

// MARK: - Internal notifications -

/// Internally used events wrapper. Intended for inter-module use only, at least with its current implementation.

struct StackFlowNotification {
	// MARK: - Errors -
	
	enum StackFlowNotificationError: Error {
		case parsingFailed
	}
	
	// MARK: - Notification names -
	
	enum Name: String {
		case itemPushed = "stackFlowViewItemPushed"
		case itemPopped = "stackFlowViewItemPopped"
	}
	
	// MARK: - Stored values -
	
	private let obj: Notification
	let name: Name
	let stackFlowView: StackFlowView
	
	// MARK: - Initializers -
	
	private init(name: Name, stackView: StackFlowView) {
		self.name = name
		self.stackFlowView = stackView
		self.obj = Notification(name: Notification.Name(rawValue: name.rawValue), object: stackView, userInfo: nil)
	}
	
	init(plainNotification: Notification) throws {
		guard let name = Name(rawValue: plainNotification.name.rawValue), let stackView = plainNotification.object as? StackFlowView else {
			throw StackFlowNotificationError.parsingFailed
		}
		
		self.name = name
		self.stackFlowView = stackView
		self.obj = plainNotification
	}
	
	// MARK: - Post -
	
	static func post(name: Name,  stackView: StackFlowView) {
		let notification = StackFlowNotification(name: name, stackView: stackView)
		NotificationCenter.default.post(notification.obj)
	}
	
	// MARK: - Subscribe -
	
	static func observe(name: Name, by observer: Any, selector: Selector) {
		NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name(rawValue: name.rawValue), object: nil)
	}
	
	static func forget(observer: Any) {
		NotificationCenter.default.removeObserver(observer)
	}
}
