//
//  DemoItemView.swift
//  StackFlowViewDemo
//
//  Created by 0xNSHuman on 19/01/2018.
//  Copyright © 2018 0xNSHuman. All rights reserved.
//

import UIKit

class DemoItemView: UIView {
	// MARK: - Constants -
	
	static let minimumAllowedWidth: CGFloat = 300 //(appDelegate?.window?.bounds.width ?? 0) / 2 //380.0
	static let maximumAllowedWidth: CGFloat = minimumAllowedWidth + 1
	
	static let minimumAllowedHeight: CGFloat = 97.0
	static let maximumAllowedHeight: CGFloat = minimumAllowedHeight + 1
	
	// MARK: - Outlets -
	
	@IBOutlet weak var identityLabel: UILabel!
	@IBOutlet var navigationLabels: [UILabel]!
	
	// MARK: - Properties -
	
	var popHandler: (() -> ())? = nil
	var pushHandler: (() -> ())? = nil
	
	// MARK: - Life cycle -
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setUp()
	}
	
	// MARK: - Setup -
	
	private func setUp() {
		// Set bg color
		
		backgroundColor = Utils.randomPastelColor()
		
		// Attach gestures
		
		addGestureRecognizer({
			let tapGesture = UITapGestureRecognizer()
			tapGesture.delegate = self
			tapGesture.addTarget(self, action: #selector(tapOccured(_:)))
			return tapGesture
		}())
		
		addGestureRecognizer({
			let doubleTapGesture = UITapGestureRecognizer()
			doubleTapGesture.delegate = self
			doubleTapGesture.numberOfTapsRequired = 2
			doubleTapGesture.addTarget(self, action: #selector(doubleTapOccured(_:)))
			return doubleTapGesture
		}())
	}
	
	// MARK: - Tap events -
	
	@objc private func tapOccured(_ gesture: UITapGestureRecognizer) {
		pushHandler?()
	}
	
	@objc private func doubleTapOccured(_ gesture: UITapGestureRecognizer) {
		popHandler?()
	}
}

// MARK: - Touch Delegate -

extension DemoItemView: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		guard (gestureRecognizer as? UITapGestureRecognizer)?.numberOfTapsRequired == 1,
		(otherGestureRecognizer as? UITapGestureRecognizer)?.numberOfTapsRequired == 2 else  {
			return false
		}
		
		return true
	}
}

// MARK: - Triggers -

extension DemoItemView {
	func becameActive() {
		navigationLabels.forEach { $0.isHidden = false }
	}
	
	func becameInactive() {
		navigationLabels.forEach { $0.isHidden = true }
	}
}

// MARK: - Producer for StackFlowView -

extension DemoItemView {
	static func stackItem(bounds: CGRect) -> DemoItemView {
		let itemView = Bundle.main.typeFromNib(DemoItemView.self)! // Force unwrap is 100% safe here
		itemView.frame = bounds
		return itemView
	}
	
	static func bounds(for stackFlowView: StackFlowView) -> CGRect {
		// Note this `safeSize` property of StackFlowView. You should use it to get info about its available content area, not blocked by any views outside of safe area
		
		let safeStackFlowViewWidth = stackFlowView.safeSize.width
		let safeStackFlowViewHeight = stackFlowView.safeSize.height
		
		if stackFlowView.growthDirection.isVertical {
			let height = (CGFloat(arc4random()).truncatingRemainder(dividingBy: (maximumAllowedHeight - minimumAllowedHeight))) + minimumAllowedHeight
			
			return CGRect(x: 0, y: 0, width: safeStackFlowViewWidth, height: {
					return min(height, safeStackFlowViewHeight)
				}()
			)
		} else {
			let width = (CGFloat(arc4random()).truncatingRemainder(dividingBy: (maximumAllowedWidth - minimumAllowedWidth))) + minimumAllowedWidth
			
			return CGRect(x: 0, y: 0, width: {
					return min(width, safeStackFlowViewWidth)
				}(), height: safeStackFlowViewHeight
			)
		}
	}
}
