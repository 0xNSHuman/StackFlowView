//
//  StackFlowView.swift
//  Created by Vladislav Averin on 05/12/2017.

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

import UIKit

/// Protocol used by Stack Flow View consumers to control the flow itself.

public protocol StackFlowDelegate {
	func stackFlowViewDidRequestPop(_ stackView: StackFlowView, numberOfItems: Int)
	func stackFlowViewDidRequestPush(_ stackView: StackFlowView)
	
	func stackFlowViewWillPop(_ stackView: StackFlowView)
	func stackFlowViewDidPop(_ stackView: StackFlowView)
	
	func stackFlowView(_ stackView: StackFlowView, willPush view: UIView)
	func stackFlowView(_ stackView: StackFlowView, didPush view: UIView)
}

/// View that enables visual stack behaviour for subviews it contains. It can be used to stack up any custom UI elements in strict predefined order, or just randomly, in any of the four directions: up, down, left, right. There are a lot of customization options that make a number of different common UI patterns to be set up.

open class StackFlowView: UIView, StackItemViewDelegate {
	// MARK: - Types -
	
	typealias StackSeparatorView = UIView
	
	public enum Direction {
		case up, down, left, right
		
		public var isVertical: Bool { return self == .up || self == .down }
	}
	
	public enum SeparationStyle {
		case none
		case line(thikness: CGFloat, color: UIColor)
		case padding(size: CGFloat)
	}
	
	public enum FadingStyle {
		case none
		case tint(color: UIColor, preLastAlpha: CGFloat, alphaDecrement: CGFloat?)
		case gradientMask(effectDistance: CGFloat)
		indirect case combined(styles: [FadingStyle])
	}
	
	public struct NavigationOptions: OptionSet {
		public let rawValue: Int
		
		public static let swipe = NavigationOptions(rawValue: 1 << 1)
		public static let tap = NavigationOptions(rawValue: 1 << 2)
		
		public static let none: [NavigationOptions] = []
		public static let all: [NavigationOptions] = [.swipe, .tap]
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
	
	// MARK: - Delegate -
	
	public var delegate: StackFlowDelegate? = nil
	
	// MARK: - Subviews -
	
	private let contentContainer = UIView()
	private var items: [StackItemView] = []
	private var separators: [StackItemView : StackSeparatorView] = [:]
	
	var lastItem: StackItemView? {
		return items.last
	}
	
	// MARK: - Public accessors -
	
	public var numberOfItems: Int {
		return items.count
	}
	
	public var lastItemContent: UIView? {
		return lastItem?.contentView
	}
	
	/// This property is calculated considering only part of stack flow view that stays inside safe area of its superview. It's highly recommended to always use this property for newly pushed item side definition, to avoid broken layout caused by dynamically shrinked safe area.
	
	public var safeSize: CGSize {
		let width = contentContainer.bounds.width
		let height = contentContainer.bounds.height
		
		let size = CGSize(width: width, height: height)
		return size
	}
	
	// MARK: - Appearance -
	
	open override var frame: CGRect {
		didSet {
			super.frame = frame
		}
	}
	
	/// Whether or not stack flow view should stretch/shrink its items' width (for vertical stacks) or height (for horizontal stacks) to fill the area perpendicular to stack's direction. For example: should it make vertical stack items wider after rotatin from portrait to landscape orientation.
	
	public var isAutoresizingItems: Bool = true
	
	/// Whether or not stack flow view should do its best to stay inside superview's safe area. For example: adjust content to avoid being covered by status bar, navigation bar, iPhone X notch, etc.
	
	public var isSeekingSafeArea: Bool = true {
		didSet {
			resetContainerConstraints()
			layoutIfNeeded()
		}
	}
	
	/// Head of stack is the last item pushed. Depending on the direction of stack growth, this property adds padding on top, bottom, left or right side of the stack, right next to its head item.
	
	public var headPadding: CGFloat = 0.0 {
		didSet {
			resetContainerConstraints()
			layoutIfNeeded()
		}
	}
	
	/// The direction stack pushes its items to. For example: .down direction will always keep the last item sticked to the bottom of stack flow view, and all previous elements will be shifted upper side.
	
	public var growthDirection: Direction = .down {
		didSet {
			resetChildrenLayoutConstraints()
			layoutIfNeeded()
		}
	}
	
	/// The way stack items are separated visually.
	
	public var separationStyle: SeparationStyle = .line(thikness: 1.0, color: .white) {
		didSet {
			resetChildrenLayoutConstraints()
			layoutIfNeeded()
		}
	}
	
	/// The way stack item fades out previously pushed elements, focusing on the latest one. Multiple options can be combined and used simultaneously, or none of them, resulting in fade-out functionality turned off.
	
	public var fadingStyle: FadingStyle = .combined(styles: [.tint(color: .black, preLastAlpha: 0.9, alphaDecrement: nil), .gradientMask(effectDistance: 500)]) {
		didSet {
			resetFadingSettings()
		}
	}
	
	/// Active built-in navigation options. For example: swipe up or down controls flow of vertical stack, or tapping any of the inactive items pops the stack until it becomes active.
	
	public var userNavigationOptions: NavigationOptions = [.swipe, .tap]
	
	/// Duration of pop/push transitions
	
	public var transitionDuration: Double = 0.25
	
	// MARK: - Meta resolvers -
	
	func doesOwn(item: StackItemView) -> Bool {
		return (items.index(of: item) ?? nil) != nil
	}
	
	private var separationSizeAndColor: (CGFloat, UIColor) {
		switch separationStyle {
		case .padding(let size):
			return (size, .clear)
			
		case .line(let thikness, let color):
			return (thikness, color)
			
		case .none:
			return (0, .clear)
		}
	}
	
	// MARK: - Initializers -
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setUp()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life cycle -
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		resetFadingSettings()
		resetChildrenLayoutConstraints()
		
		layoutIfNeeded()
	}
	
	// MARK: - Setup -
	
	private func setUp() {
		backgroundColor = .clear
		contentContainer.backgroundColor = .clear
		contentContainer.frame = bounds
		
		contentContainer.translatesAutoresizingMaskIntoConstraints = false
		contentContainer.clipsToBounds = true
		
		addSubview(contentContainer)
		
		resetContainerConstraints()
		layoutIfNeeded()
		
		// Add navigation gestures
		
		let swipeGestures = [
			UISwipeGestureRecognizer(target: self, action: #selector(swipeOccured(_:))),
			UISwipeGestureRecognizer(target: self, action: #selector(swipeOccured(_:))),
			UISwipeGestureRecognizer(target: self, action: #selector(swipeOccured(_:))),
			UISwipeGestureRecognizer(target: self, action: #selector(swipeOccured(_:)))
		]
		
		swipeGestures.forEach {
			let directions: [UISwipeGestureRecognizerDirection] = [.up, .down, .left, .right]
			$0.direction = directions[swipeGestures.index(of: $0)!]
			contentContainer.addGestureRecognizer($0)
		}
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOccured(_:)))
		contentContainer.addGestureRecognizer(tapGesture)
	}
	
	// MARK: - Items lifecycle -
	
	/// Pushes given view with custom content to stack. Optionally, navigation bar can be presented once title is provided. Also, said navigation bar's appearance can be customized.
	
	/// - parameter view: The view with custom content to push
	/// - parameter title: Optional title to display along with navigation nar
	/// - parameter customAppearance: Optional customization of the presented navigation bar
	
	public func push(_ view: UIView, title: String? = nil, customAppearance: StackItemAppearance? = nil) {
		let stackItemView = StackItemView(contentView: view, title: title, customAppearance: customAppearance)
		stackItemView.delegate = self
		
		delegate?.stackFlowView(self, willPush: view)
		
		items.append(stackItemView)
		
		prepareAndPush(stackItemView)
		
		delegate?.stackFlowView(self, didPush: view)
	}
	
	/// Pops given number of items out of stack flow view.
	
	/// - parameter numberOfItems: Number of items to pop
	
	public func pop(_ numberOfItems: Int = 1) {
		for _ in 0 ..< numberOfItems {
			if let lastChild = items.last {
				delegate?.stackFlowViewWillPop(self)
				
				items.removeLast()
				
				popAndCleanUp(lastChild)
				
				delegate?.stackFlowViewDidPop(self)
			}
		}
	}
	
	/// Pops all the items out of stack flow view.
	
	public func clean() {
		pop(items.count)
	}
	
	// MARK: - StackItemViewDelegate -
	
	func stackItemRequestedPop(_ stackItemView: StackItemView) {
		delegate?.stackFlowViewDidRequestPop(self, numberOfItems: 1)
	}
	
	func stackItemRequestedPush(_ stackItemView: StackItemView) {
		delegate?.stackFlowViewDidRequestPush(self)
	}
	
	// MARK: - Transitions -
	
	private func popAndCleanUp(_ item: StackItemView) {
		UIView.animate(withDuration: transitionDuration * 0.5, animations: {
			item.alpha = 0.0
			self.separators[item]?.alpha = 0.0
		}) { (_) in
			item.removeFromSuperview()
			
			self.separators[item]?.removeFromSuperview()
			self.separators.removeValue(forKey: item)
			
			self.resetChildrenLayoutConstraints()
			
			UIView.animate(withDuration: self.transitionDuration * 0.5) {
				self.resetFadingSettings()
				self.layoutIfNeeded()
			}
			
			StackFlowNotification.post(name: .itemPopped, stackView: self)
		}
	}
	
	private func prepareAndPush(_ item: StackItemView) {
		removeChildrenLayoutConstraints()
		
		var separator: StackSeparatorView? = nil
		
		// TODO: Revisit this `isFirstInStack` property thing, I'm not fully satisfied with this approach (@vladaverin24)
		
		if items.first == item {
			item.isFirstInStack = true
		} else {
			item.isFirstInStack = false
			
			separator = StackSeparatorView()
			separator?.backgroundColor = separationSizeAndColor.1
			
			separators[item] = separator
		}
		
		// Initial position to kick transition from
		
		switch growthDirection {
		case .up:
			item.center = CGPoint(x: contentContainer.bounds.width / 2, y: -(item.bounds.height / 2))
		case .down:
			separator?.frame = CGRect(x: 0, y: contentContainer.bounds.height + (separator?.bounds.height ?? 0.0) / 2, width: contentContainer.bounds.width, height: separationSizeAndColor.0)
			
			if let separator = separator {
				item.center = CGPoint(x: contentContainer.bounds.width / 2, y: separator.center.y + separationSizeAndColor.0)
			} else {
				item.center = CGPoint(x: contentContainer.bounds.width / 2, y: contentContainer.bounds.height + item.bounds.height / 2)
			}
			
		case .left:
			item.center = CGPoint(x: -(item.bounds.width / 2), y: contentContainer.bounds.height / 2)
		case .right:
			item.center = CGPoint(x: contentContainer.bounds.width + item.bounds.width / 2, y: contentContainer.bounds.height / 2)
		}
		
		if let separator = separator {
			contentContainer.addSubview(separator)
		}
		
		contentContainer.addSubview(item)
		applyChildrenLayoutConstraints()
		
		UIView.animate(withDuration: transitionDuration) {
			self.resetFadingSettings()
			self.layoutIfNeeded()
		}
		
		StackFlowNotification.post(name: .itemPushed, stackView: self)
	}
	
	// MARK: - Items fading -
	
	private func resetFadingSettings() {
		guard let lastItem = items.last else { return }
		
		// Lock up all the elements but the last in stack
		
		items.forEach { $0.isUserInteractionEnabled = false }
		lastItem.isUserInteractionEnabled = true
		
		// Clean up previous isolation setup
		
		lastItem.tintView.isHidden = true
		lastItem.alpha = 1.0
		
		let tintResetAction: () -> () = {
			for i in 0 ..< self.items.count - 1 {
				self.items[i].tintView.isHidden = true
				self.items[i].alpha = 1.0
			}
		}
		
		let gradientResetAction: () -> () = {
			self.contentContainer.layer.mask = nil
		}
		
		if case .gradientMask(_) = fadingStyle {
			tintResetAction()
		} else if case .tint(_, _, _) = fadingStyle {
			gradientResetAction()
		} else if case .combined(let styles) = fadingStyle {
			if !styles.contains(where: { (style) -> Bool in
				if case .tint(_, _, _) = style {
					return true
				} else {
					return false
				}
			}) {
				tintResetAction()
			}
			
			if !styles.contains(where: { (style) -> Bool in
				if case .gradientMask(_) = style {
					return true
				} else {
					return false
				}
			}) {
				gradientResetAction()
			}
		} else if case .none = fadingStyle {
			tintResetAction()
			gradientResetAction()
		}
		
		// Apply new isolation
		
		func applyStyle(_ style: FadingStyle) {
			switch style {
			case .gradientMask(let effectDistance):
				let itemDistance = (growthDirection.isVertical ? lastItem.bounds.height : lastItem.bounds.width)
				let containerDistance = growthDirection.isVertical ? contentContainer.bounds.height : contentContainer.bounds.width
				
				let relativeItemEnd = itemDistance / containerDistance
				let relativeEffectEnd = relativeItemEnd + (effectDistance / containerDistance)
				
				let gradientLayer = CAGradientLayer()
				gradientLayer.frame = contentContainer.bounds
				gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
				gradientLayer.locations = [relativeItemEnd as NSNumber, relativeEffectEnd as NSNumber, 1.0]
				
				switch growthDirection {
				case .up:
					gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
					gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
					
				case .down:
					gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
					gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
					
				case .left:
					gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
					gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
					
				case .right:
					gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
					gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
				}
				
				contentContainer.layer.mask = gradientLayer
				
			case .tint(let color, let alpha, let alphaDecrement):
				// The decision to use stored subview instead of sublayer here is made because CALayer lacks ability to be autolayouted on iOS
			
				for i in 0 ..< items.count - 1 {
					let item = items[i]
					let tintView = item.tintView
					tintView.backgroundColor = color
					
					var itemAlpha: CGFloat
					if let decrement = alphaDecrement {
						itemAlpha = alpha - decrement * CGFloat(items.count - i - 1)
						itemAlpha = itemAlpha > 0.0 ? itemAlpha : 0.0
					} else {
						itemAlpha = alpha
					}
					
					item.alpha = itemAlpha
				}
				
			case .combined(let styles):
				for style in styles {
					applyStyle(style)
				}
				
				break
				
			case .none:
				break
			}
		}
		
		applyStyle(fadingStyle)
	}
	
	// MARK: - Layout -
	
	private func resetContainerConstraints() {
		constraints.forEach {
			// Only relationships with superview!
			
			guard ($0.firstItem as? UIView == contentContainer) || ($0.secondItem  as? UIView == contentContainer) else { return }
			
			$0.isActive = false
		}
		
		contentContainer.removeConstraints(contentContainer.constraints)
		
		var containerConstraints: [NSLayoutConstraint]
		
		// Here we're trying to consider any potential safe area insets. Although, I believe it's responsibility on developer using this view to position it properly, that's still nice to be backed by this little nice feature.
		
		if isSeekingSafeArea, #available(iOS 11, *) {
			let guide = safeAreaLayoutGuide
			
			containerConstraints = [
				contentContainer.topAnchor.constraint(equalTo: guide.topAnchor, constant: growthDirection == .up ? headPadding : 0.0),
				contentContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: growthDirection == .down ? -headPadding : 0.0),
				contentContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: growthDirection == .left ? headPadding : 0.0),
				contentContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: growthDirection == .right ? -headPadding : 0.0)
			]
		} else {
			containerConstraints = [
				NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: contentContainer, attribute: .top, multiplier: 1.0, constant: growthDirection == .up ? headPadding : 0.0),
				NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: contentContainer, attribute: .bottom, multiplier: 1.0, constant: growthDirection == .down ? headPadding : 0.0),
				NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: contentContainer, attribute: .leading, multiplier: 1.0, constant: growthDirection == .left ? headPadding : 0.0),
				NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: contentContainer, attribute: .trailing, multiplier: 1.0, constant: growthDirection == .right ? headPadding : 0.0)
			]
		}
		
		containerConstraints.forEach { $0.isActive = true }
		layoutIfNeeded()
	}
	
	private func resetChildrenLayoutConstraints() {
		removeChildrenLayoutConstraints()
		applyChildrenLayoutConstraints()
	}
	
	private func removeChildrenLayoutConstraints() {
		contentContainer.constraints.forEach {
			if $0.firstItem is StackItemView || $0.secondItem is StackItemView {
				$0.isActive = false
				contentContainer.removeConstraint($0)
			}
		}
	}
	
	private func applyChildrenLayoutConstraints() {
		items.forEach {
			let childConstraints = layout(for: $0)
			childConstraints.forEach { $0.isActive = true }
		}
	}
	
	private func layout(for child: StackItemView) -> [NSLayoutConstraint] {
		child.translatesAutoresizingMaskIntoConstraints = false
		
		// Get info about items relative position and separation between them
		
		let isFirstChild = child == items.first
		let isLastChild = child == items.last
		
		let prevChild: StackItemView?
		let separator: StackSeparatorView?
		let padding: CGFloat?
		
		if !isFirstChild {
			prevChild = items[items.index(of: child)! - 1]
			separator = separators[child]!
			
			separator?.translatesAutoresizingMaskIntoConstraints = false
			
			switch separationStyle {
			case .padding(let height):
				padding = height
				separator?.backgroundColor = .clear
				
			case .line(let width, let color):
				padding = width
				separator?.backgroundColor = color
				
			case .none:
				padding = 0
				separator?.backgroundColor = .clear
			}
		} else {
			prevChild = nil
			separator = nil
			padding = nil
		}
		
		// Set up necessary constraints
		
		var constraints: [NSLayoutConstraint] = []
		
		if growthDirection.isVertical {
			constraints = [
				// Center child content
				
				NSLayoutConstraint(item: child, attribute: .centerX, relatedBy: .equal, toItem: contentContainer, attribute: .centerX, multiplier: 1.0, constant: 0.0),
			] + (!isFirstChild ? [
				// Stick separator to container bounds
				
				NSLayoutConstraint(item: separator!, attribute: .leading, relatedBy: .equal, toItem: contentContainer, attribute: .leading, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: separator!, attribute: .trailing, relatedBy: .equal, toItem: contentContainer, attribute: .trailing, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: separator!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: padding!)
			] : [])
		} else {
			constraints = [
				// Center child content
				
				NSLayoutConstraint(item: child, attribute: .centerY, relatedBy: .equal, toItem: contentContainer, attribute: .centerY, multiplier: 1.0, constant: 0.0)
			] + (!isFirstChild ? [
				// Stick separator to container bounds
				
				NSLayoutConstraint(item: separator!, attribute: .top, relatedBy: .equal, toItem: contentContainer, attribute: .top, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: separator!, attribute: .bottom, relatedBy: .equal, toItem: contentContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0),
				NSLayoutConstraint(item: separator!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: padding!)
			] : [])
		}
		
		if isAutoresizingItems {
			let autoResizeAttribute: NSLayoutAttribute = growthDirection.isVertical ? .width : .height
			constraints.append(NSLayoutConstraint(item: child, attribute: autoResizeAttribute, relatedBy: .equal, toItem: contentContainer, attribute: autoResizeAttribute, multiplier: 1.0, constant: 0.0))
		}
		
		// Constraints depending on stack growth direction
		
		var relAttrConstBuffer: (UIView, NSLayoutAttribute, CGFloat)
		
		switch growthDirection {
		case .up:
			if isLastChild {
				relAttrConstBuffer = (contentContainer, .top, 0.0)
				let topC = NSLayoutConstraint(item: child, attribute: .top, relatedBy: .equal, toItem: relAttrConstBuffer.0, attribute: relAttrConstBuffer.1, multiplier: 1.0, constant: relAttrConstBuffer.2)
				
				constraints.append(topC)
			}
			
			if !isFirstChild {
				let separatorConstraints = [
					NSLayoutConstraint(item: separator!, attribute: .bottom, relatedBy: .equal, toItem: prevChild, attribute: .top, multiplier: 1.0, constant: 0.0),
					NSLayoutConstraint(item: separator!, attribute: .top, relatedBy: .equal, toItem: child, attribute: .bottom, multiplier: 1.0, constant: 0.0)
				]
				
				constraints.append(contentsOf: separatorConstraints)
			}
			
		case .down:
			if isLastChild {
				relAttrConstBuffer = (contentContainer, .bottom, 0.0)
				let bottomC = NSLayoutConstraint(item: child, attribute: .bottom, relatedBy: .equal, toItem: relAttrConstBuffer.0, attribute: relAttrConstBuffer.1, multiplier: 1.0, constant: relAttrConstBuffer.2)
				
				constraints.append(bottomC)
			}
			
			if !isFirstChild {
				let separatorConstraints = [
					NSLayoutConstraint(item: separator!, attribute: .top, relatedBy: .equal, toItem: prevChild, attribute: .bottom, multiplier: 1.0, constant: 0.0),
					NSLayoutConstraint(item: separator!, attribute: .bottom, relatedBy: .equal, toItem: child, attribute: .top, multiplier: 1.0, constant: 0.0)
				]
				
				constraints.append(contentsOf: separatorConstraints)
			}
			
		case .left:
			if isLastChild {
				relAttrConstBuffer = (contentContainer, .leading, 0.0)
				let leadingC = NSLayoutConstraint(item: child, attribute: .leading, relatedBy: .equal, toItem: relAttrConstBuffer.0, attribute: relAttrConstBuffer.1, multiplier: 1.0, constant: relAttrConstBuffer.2)
				
				constraints.append(leadingC)
			}
			
			if !isFirstChild {
				let separatorConstraints = [
					NSLayoutConstraint(item: separator!, attribute: .leading, relatedBy: .equal, toItem: child, attribute: .trailing, multiplier: 1.0, constant: 0.0),
					NSLayoutConstraint(item: separator!, attribute: .trailing, relatedBy: .equal, toItem: prevChild, attribute: .leading, multiplier: 1.0, constant: 0.0)
				]
				
				constraints.append(contentsOf: separatorConstraints)
			}
			
		case .right:
			if isLastChild {
				relAttrConstBuffer = (contentContainer, .trailing, 0.0)
				let trailingC = NSLayoutConstraint(item: child, attribute: .trailing, relatedBy: .equal, toItem: relAttrConstBuffer.0, attribute: relAttrConstBuffer.1, multiplier: 1.0, constant: relAttrConstBuffer.2)
				
				constraints.append(trailingC)
			}
			
			if !isFirstChild {
				let separatorConstraints = [
					NSLayoutConstraint(item: separator!, attribute: .leading, relatedBy: .equal, toItem: prevChild, attribute: .trailing, multiplier: 1.0, constant: 0.0),
					NSLayoutConstraint(item: separator!, attribute: .trailing, relatedBy: .equal, toItem: child, attribute: .leading, multiplier: 1.0, constant: 0.0)
				]
				
				constraints.append(contentsOf: separatorConstraints)
			}
		}
		
		return constraints
	}
	
	// MARK: - Navigation controls -
	
	@objc func swipeOccured(_ swipe: UISwipeGestureRecognizer) {
		guard userNavigationOptions.contains(.swipe) else { return }
		
		switch swipe.direction {
		case .up:
			if growthDirection == .down {
				delegate?.stackFlowViewDidRequestPush(self)
			} else if growthDirection == .up {
				delegate?.stackFlowViewDidRequestPop(self, numberOfItems: 1)
			}
			
		case .down:
			if growthDirection == .down {
				delegate?.stackFlowViewDidRequestPop(self, numberOfItems: 1)
			} else if growthDirection == .up {
				delegate?.stackFlowViewDidRequestPush(self)
			}
			
		case .left:
			if growthDirection == .left {
				delegate?.stackFlowViewDidRequestPop(self, numberOfItems: 1)
			} else if growthDirection == .right {
				delegate?.stackFlowViewDidRequestPush(self)
			}
			
		case .right:
			if growthDirection == .left {
				delegate?.stackFlowViewDidRequestPush(self)
			} else if growthDirection == .right {
				delegate?.stackFlowViewDidRequestPop(self, numberOfItems: 1)
			}
			
		default:
			break
		}
	}
	
	@objc func tapOccured(_ swipe: UITapGestureRecognizer) {
		guard userNavigationOptions.contains(.tap) else { return }
		
		let tapPoint = swipe.location(in: contentContainer)
		
		if let tappedItem = itemAtLocation(tapPoint), let itemIndex = items.index(of: tappedItem) {
			delegate?.stackFlowViewDidRequestPop(self, numberOfItems: (items.count - 1) - itemIndex)
		}
	}
	
	// MARK: - Resolvers -
	
	/// Location of stack item in stack view container coordinates
	
	private func itemAtLocation(_ point: CGPoint) -> StackItemView? {
		var item: StackItemView? = nil
		
		items.forEach {
			if $0.frame.contains(point) {
				item = $0
			}
		}
		
		return item
	}
}
