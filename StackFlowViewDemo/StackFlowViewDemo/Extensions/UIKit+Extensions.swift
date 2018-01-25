//
//  UIKit+Extensions.swift
//  Created by Vladislav Averin
//

import Foundation
import UIKit

// MARK: UIImage

public extension UIImage {
	public func applying(tintColor color: UIColor) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		let context: CGContext = UIGraphicsGetCurrentContext()!
		context.translateBy(x: 0, y: self.size.height)
		context.scaleBy(x: 1.0, y: -1.0)
		context.setBlendMode(CGBlendMode.normal)
		let rect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		context.clip(to: rect, mask: self.cgImage!)
		color.setFill()
		context.fill(rect);
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
		UIGraphicsEndImageContext();
		return newImage;
	}
}

public extension UIView {
	// Shadow
	
	func dropShadow(scale: Bool = true, offset: CGFloat = 1.0) {
		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 0.5
		self.layer.shadowOffset = CGSize(width: 0, height: offset)
		self.layer.shadowRadius = 1
		
		self.layer.shadowPath = (layer.mask as? CAShapeLayer)?.path ?? UIBezierPath(rect: self.bounds).cgPath
	}
	
	// Mask
	
	enum GeometryMaskType {
		case circle
	}
	
	typealias MaskBorderSettings = (CGFloat, UIColor)
	
	func applyGeometryMask(type: GeometryMaskType, border: MaskBorderSettings? = nil) {
		let maskLayer = CAShapeLayer()
		maskLayer.frame = bounds
		
		maskLayer.path = {
			let path = CGMutablePath()
			
			switch type {
			case .circle:
				path.addArc(center: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: bounds.width / 2, startAngle: -(CGFloat.pi / 2.0), endAngle: 3.0 * CGFloat.pi / 2, clockwise: false)
			}
			
			return path
		}()
		
		layer.mask = maskLayer
		
		layer.sublayers?.filter({ $0.zPosition == 9999 }).first?.removeFromSuperlayer()
		
		if let (width, color) = border {
			let strokeLayer = CAShapeLayer()
			strokeLayer.frame = bounds
			strokeLayer.path = maskLayer.path
			strokeLayer.lineWidth = width * 2
			strokeLayer.strokeColor = color.cgColor
			strokeLayer.fillColor = UIColor.clear.cgColor
			strokeLayer.zPosition = 9999
			layer.addSublayer(strokeLayer)
		}
	}
	
	// Constraints
	
	enum IndentConstraintType {
		case left, top, right, bottom
	}
	
	private func removeConstraints(_ cs: [NSLayoutConstraint]) {
		cs.forEach {
			$0.isActive = false
			superview?.removeConstraint($0)
		}
	}
	
	func removeAllConstraints() {
		removeConstraints(superview?.constraints.filter({ ($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self }) ?? [])
		removeConstraints(constraints.filter({ ($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self }))
	}
	
	var widthConstraint: CGFloat? {
		set(value) {
			(constraints.flatMap({ return (($0.firstItem as? UIView) == self && $0.firstAttribute == .width) ? $0 : nil }).first)?.constant = value ?? 0.0
		}
		
		get {
			return (constraints.flatMap({ return (($0.firstItem as? UIView) == self && $0.firstAttribute == .width) ? $0 : nil }).first)?.constant
		}
	}
	
	var heightConstraint: CGFloat? {
		set(value) {
			let constraint = constraints.flatMap({ return (($0.firstItem as? UIView) == self && $0.firstAttribute == .height) ? $0 : nil }).first
			constraint?.constant = value ?? 0.0
		}
		
		get {
			let constraint = constraints.flatMap({ return (($0.firstItem as? UIView) == self && $0.firstAttribute == .height) ? $0 : nil }).first
			return constraint?.constant
		}
	}
	
	var indendationConstraints: (CGFloat?, CGFloat?, CGFloat?, CGFloat?) {
		set(value) {
			setConstraintConstant(value.0 ?? 0, for: .leading)
			setConstraintConstant(value.1 ?? 0, for: .top)
			setConstraintConstant(value.2 ?? 0, for: .trailing)
			setConstraintConstant(value.3 ?? 0, for: .bottom)
		}
		
		get {
			return (
				constraintConstant(describing: .leading),
				constraintConstant(describing: .top),
				constraintConstant(describing: .trailing),
				constraintConstant(describing: .bottom)
			)
		}
	}
	
	private func constraintConstant(describing attribute: NSLayoutAttribute) -> CGFloat? {
		return superview?.constraints.filter({ (($0.firstItem as? UIView) == self && $0.firstAttribute == attribute) || (($0.secondItem as? UIView) == self && $0.secondAttribute == attribute) }).first?.constant
	}
	
	private func setConstraintConstant(_ c: CGFloat, for attribute: NSLayoutAttribute){
		superview?.constraints.filter({ (($0.firstItem as? UIView) == self && $0.firstAttribute == attribute) || (($0.secondItem as? UIView) == self && $0.secondAttribute == attribute) }).first?.constant = c
	}
	
	// Convenient calculators for dynamic size
	
	var widthToFit: CGFloat {
		return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: heightConstraint ?? bounds.height)).width
	}
	
	var heightToFit: CGFloat {
		return sizeThatFits(CGSize(width: widthConstraint ?? bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
	}
}

public extension UIImageView {
	public convenience init(frame: CGRect, image: UIImage?, contentMode: UIViewContentMode = .scaleAspectFit) {
		
		self.init(frame: frame)
		self.image = image
		self.contentMode = contentMode
	}
}

public extension UITableView {
	func dequeueCell<CellType>(_ type: CellType.Type) -> CellType {
		return dequeueReusableCell(withIdentifier: String(describing: type)) as! CellType
	}
}

public extension UICollectionView {
	func dequeueCell<CellType>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
		return dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as! CellType
	}
}

public extension UIViewController {
	enum NavigationBarZone {
		case left, right
	}
	
	func setNavigationViews(_ views: [UIView], on zone: NavigationBarZone) {
		var barButtonItems = [UIBarButtonItem]()
		
		for view in views {
			let barItem = UIBarButtonItem(customView: view)
			
			if zone == .left, views.first != view {
				barButtonItems.append({
					let space = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
					space.width = 10.0
					
					return space
					}()
				)
			}
			
			barButtonItems.append(barItem)
		}
		
		if zone == .left {
			navigationItem.leftBarButtonItems = barButtonItems
		} else {
			navigationItem.rightBarButtonItems = barButtonItems
		}
	}
	
	func makeKeyboardHidableByTapAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}

public extension UINavigationController {
	typealias PopCompletion = () -> ()
	
	func pushFromRootViewController(_ vc: UIViewController, animated: Bool) {
		guard let rootVC = viewControllers.first else {
			setViewControllers([vc], animated: animated)
			return
		}
		
		setViewControllers([rootVC, vc], animated: animated)
	}
	
	func popToRootViewController(animated: Bool, completion: PopCompletion? = nil) {
		CATransaction.begin()
		CATransaction.setCompletionBlock(completion)
		
		_ = popToRootViewController(animated: animated)
		
		CATransaction.commit()
	}
}
