//
//  StackItemView.swift
//  Created by 0xNSHuman on 05/12/2017.

/*
The MIT License (MIT)
Copyright © 2017 0xNSHuman
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

import UIKit

/// View that is typically presented on top of the stack flow item's content, containing given title, as well as navigation buttons to control stack flow.

class StackItemViewHeader: UIView {
	// MARK: - Constants -
	
	static let defaultHeight: CGFloat = 44.0
	static let margin: CGFloat = 20.0
	
	// MARK: - Stack Item reference -
	
	private weak var stackItem: StackItemView?
	
	// MARK: - Subviews -
	
	let titleLabel = UILabel()
	
	var popButton: UIButton? = nil {
		didSet {
			oldValue?.removeFromSuperview()
			if let button = popButton { addSubview(button) }
			
			popButton?.addTarget(stackItem, action: #selector(StackItemView.popTapped), for: .touchUpInside)
			
			if let _ = popButton { applyAppearance() }
			resetConstraints()
		}
	}
	
	var pushButton: UIButton? = nil {
		didSet {
			oldValue?.removeFromSuperview()
			if let button = pushButton { addSubview(button) }
			
			pushButton?.addTarget(stackItem, action: #selector(StackItemView.pushTapped), for: .touchUpInside)
			
			if let _ = pushButton { applyAppearance() }
			resetConstraints()
		}
	}
	
	// MARK: - Appearance -
	
	override var frame: CGRect {
		didSet {
			super.frame = frame
		}
	}
	
	var appearance: StackItemAppearance.TopBar = StackItemAppearance.defaultPreset.topBarAppearance {
		didSet {
			applyAppearance()
		}
	}
	
	// MARK: - Initializers -
	
	convenience init(title: String) {
		self.init(frame: .zero, title: title)
	}
	
	required init(frame: CGRect, title: String) {
		super.init(frame: frame)
		
		addSubview(titleLabel)
		titleLabel.text = title
		setUp()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life cycle -
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		
		guard let stackItem = newSuperview as? StackItemView else {
			return
		}
		
		self.stackItem = stackItem
	}
	
	// MARK: - Setup -
	
	private func setUp() {
		titleLabel.textAlignment = .center
		resetConstraints()
	}
	
	private func applyAppearance() {
		backgroundColor = appearance.backgroundColor
		titleLabel.textColor = appearance.titleTextColor
		titleLabel.font = appearance.titleFont
		
		var buttonWidth: CGFloat = 0
		
		if let popTitle = appearance.popButtonIdentity.title {
			popButton?.setAttributedTitle(popTitle, for: .normal)
			
			buttonWidth = {
				return (popButton?.titleLabel?.sizeThatFits(CGSize(width: bounds.width, height: bounds.height)).width ?? 0) + (StackItemViewHeader.margin * 2)
			}()
		} else if let popImage = appearance.popButtonIdentity.icon {
			popButton?.setImage(popImage, for: .normal)
			
			buttonWidth = {
				let imageRatio = popImage.size.width / popImage.size.height
				return (bounds.height * imageRatio) + (StackItemViewHeader.margin * 2)
			}()
		}
		
		popButton?.frame = CGRect(origin: .zero, size: CGSize(width: buttonWidth, height: bounds.height))
		
		if let pushTitle = appearance.pushButtonIdentity.title {
			pushButton?.setAttributedTitle(pushTitle, for: .normal)
			
			buttonWidth = {
				return (pushButton?.titleLabel?.sizeThatFits(CGSize(width: bounds.width, height: bounds.height)).width ?? 0) + (StackItemViewHeader.margin * 2)
			}()
		} else if let pushImage = appearance.pushButtonIdentity.icon {
			pushButton?.setImage(pushImage, for: .normal)
			
			buttonWidth = {
				let imageRatio = pushImage.size.width / pushImage.size.height
				return (bounds.height * imageRatio) + (StackItemViewHeader.margin * 2)
			}()
		}
		
		pushButton?.frame = CGRect(origin: .zero, size: CGSize(width: buttonWidth, height: bounds.height))
	}
	
	private func resetConstraints() {
		translatesAutoresizingMaskIntoConstraints = false
		
		constraints.forEach {
			guard $0.firstAttribute != .height && $0.firstAttribute != .width else { return }
			
			$0.isActive = false
			removeConstraint($0)
		}
		
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		let longestButtonWidth = max(popButton?.bounds.width ?? 0.0, pushButton?.bounds.width ?? 0.0)
		
		var newConstraints = [
			NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: longestButtonWidth),
			NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -(longestButtonWidth)),
			NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		]
		
		if let popButton = popButton {
			popButton.translatesAutoresizingMaskIntoConstraints = false
			
			let buttonConstraints = [
				NSLayoutConstraint(item: popButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: popButton, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: popButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: popButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
			]
			
			newConstraints.append(contentsOf: buttonConstraints)
		}
		
		if let pushButton = pushButton {
			pushButton.translatesAutoresizingMaskIntoConstraints = false
			
			let buttonConstraints = [
				NSLayoutConstraint(item: pushButton, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: pushButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: pushButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: pushButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
			]
			
			newConstraints.append(contentsOf: buttonConstraints)
		}
		
		newConstraints.forEach { $0.isActive = true }
		
		setNeedsLayout()
		layoutIfNeeded()
	}
}

/// Internally used protocol for delivering events from particular items to containing stack flow view.

protocol StackItemViewDelegate {
	func stackItemRequestedPop(_ stackItemView: StackItemView)
	func stackItemRequestedPush(_ stackItemView: StackItemView)
}

/// Item view containing provided custom UI content along with wrapped up logic that enables pushing/popping this content into/out of stack flow view.

class StackItemView: UIView {
	// MARK: - Types -
	
	typealias TintView = UIView
	
	// MARK: - Subviews -
	
	private var headerView: StackItemViewHeader? = nil
	private var contentContainer = UIView()
	private(set) var contentView: UIView?
	
	var tintView = TintView()
	
	// MARK: - Other Properties -
	
	var delegate: StackItemViewDelegate? = nil
	
	// MARK: - Appearance -
	
	override var frame: CGRect {
		didSet {
			super.frame = frame
		}
	}
	
	var appearance: StackItemAppearance = StackItemAppearance.defaultPreset {
		didSet {
			applyAppearance()
		}
	}
	
	// MARK: Meta
	
	var isFirstInStack: Bool = true {
		didSet {
			if isFirstInStack {
				headerView?.popButton = nil
			} else {
				headerView?.popButton = UIButton(type: .custom)
			}
		}
	}
	
	// MARK: - Initializers -
	
	required init(contentView: UIView, title: String? = nil, customAppearance: StackItemAppearance? = nil) {
		super.init(frame: CGRect.init(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height + StackItemViewHeader.defaultHeight))
		
		if let appearance = customAppearance {
			self.appearance = appearance
		}
		
		if let title = title {
			self.headerView = StackItemViewHeader(title: title)
			self.headerView?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: StackItemViewHeader.defaultHeight)
			addSubview(headerView!)
			
			self.headerView?.pushButton = UIButton(type: .custom)
		}
		
		self.contentView = contentView
		contentContainer.addSubview(contentView)
		addSubview(contentContainer)
		
		addSubview(tintView)
		
		setUp()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	deinit {
		StackFlowNotification.forget(observer: self)
	}
	
	// MARK: - Life cycle -
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	// MARK: - Setup -
	
	private func setUp() {
		resetConstraints()
		applyAppearance()
		
		contentContainer.clipsToBounds = true
		
		tintView.isUserInteractionEnabled = false
		tintView.isHidden = true
		
		StackFlowNotification.observe(name: .itemPopped, by: self, selector: #selector(stackViewPoppedItem(notification:)))
		StackFlowNotification.observe(name: .itemPushed, by: self, selector: #selector(stackViewPushedItem(notification:)))
	}
	
	private func applyAppearance() {
		backgroundColor = appearance.backgroundColor
		headerView?.appearance = appearance.topBarAppearance
	}
	
	private func resetConstraints() {
		// Remove previous constraints
		
		constraints.forEach {
			$0.isActive = false
			removeConstraint($0)
		}
		
		// Self constraints
		
		let totalWidth = contentView?.bounds.width ?? 0.0
		let totalHeight = (headerView?.bounds.height ?? 0.0) + (contentView?.bounds.height ?? 0.0)
		
		let sizeConstraints = [
			NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: totalWidth),
			NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: totalHeight)
		]
		
		translatesAutoresizingMaskIntoConstraints = false
		sizeConstraints.forEach {
			$0.priority = .defaultHigh
			$0.isActive = true
		}
		
		// Header constraints
		
		if let header = headerView {
			let headerHeight = header.bounds.height
			
			let headerConstraints = [
				NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: header, attribute: .top, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: header, attribute: .leading, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: header, attribute: .trailing, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: header, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: headerHeight)
			]
			
			header.translatesAutoresizingMaskIntoConstraints = false
			headerConstraints.forEach { $0.isActive = true }
		}
		
		// Content constraints
		
		let containerConstraints = [
			NSLayoutConstraint(item: contentContainer, attribute: .top, relatedBy: .equal, toItem: headerView ?? self, attribute: headerView != nil ? .bottom : .top, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: contentContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: contentContainer, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: contentContainer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		]
		
		contentContainer.translatesAutoresizingMaskIntoConstraints = false
		containerConstraints.forEach { $0.isActive = true }
		
		let contentConstraints = [
			NSLayoutConstraint(item: contentContainer, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: contentContainer, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: contentContainer, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: contentContainer, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		]
		
		contentView?.translatesAutoresizingMaskIntoConstraints = false
		contentConstraints.forEach { $0.isActive = true }
		
		// Tint view
		
		let tintConstraints = [
			NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: tintView, attribute: .top, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: tintView, attribute: .leading, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: tintView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: tintView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		]
		
		tintView.translatesAutoresizingMaskIntoConstraints = false
		tintConstraints.forEach { $0.isActive = true }
		
		// Existing layout invalidation
		
		setNeedsLayout()
		layoutIfNeeded()
	}
	
	// MARK: - Stack events -
	
	@objc func stackViewPoppedItem(notification: Notification) {
		guard let stackNotification = try? StackFlowNotification(plainNotification: notification) else {
			return
		}
		
		guard stackNotification.stackFlowView.doesOwn(item: self) else {
			return
		}
		
		let isLastInStack = stackNotification.stackFlowView.lastItem == self
		
		headerView?.popButton = (!isFirstInStack && isLastInStack) ? UIButton(type: .custom) : nil
		headerView?.pushButton = isLastInStack ? UIButton(type: .custom) : nil
	}
	
	@objc func stackViewPushedItem(notification: Notification) {
		guard let stackNotification = try? StackFlowNotification(plainNotification: notification) else {
			return
		}
		
		guard stackNotification.stackFlowView.doesOwn(item: self) else {
			return
		}
		
		let isLastInStack = stackNotification.stackFlowView.lastItem == self
		
		headerView?.popButton = (!isFirstInStack && isLastInStack) ? UIButton(type: .custom) : nil
		headerView?.pushButton = isLastInStack ? UIButton(type: .custom) : nil
	}
	
	// MARK: - Control events -
	
	@objc func popTapped() {
		delegate?.stackItemRequestedPop(self)
	}
	
	@objc func pushTapped() {
		delegate?.stackItemRequestedPush(self)
	}
}
