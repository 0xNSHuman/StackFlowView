//
//  ViewController.swift
//  StackFlowViewDemo
//
//  Created by 0xNSHuman on 19/01/2018.
//  Copyright © 2018 0xNSHuman. All rights reserved.
//

import UIKit

// Helper function to stick StackFlowView's bounds to its container. You can play with values to test different layouts.

private func pinBounds(of stackView: StackFlowView, to container: UIView, withInsets insets: (CGFloat, CGFloat, CGFloat, CGFloat)) {
	container.constraints.forEach {
		guard ($0.firstItem as? UIView) == stackView || ($0.secondItem as? UIView) == stackView else {
			return
		}
		
		$0.isActive = false
		container.removeConstraint($0)
	}
	
	var stackFlowConstraints: [NSLayoutConstraint]
	stackView.translatesAutoresizingMaskIntoConstraints = false
	
	stackFlowConstraints = [
		NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: insets.1),
		NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: -(insets.3)),
		NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: insets.0),
		NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: -(insets.2))
	]
	
	stackFlowConstraints.forEach { $0.isActive = true }
	
	container.setNeedsLayout()
	container.layoutIfNeeded()
}

class ViewController: UIViewController {
	// MARK: - Outlets -
	
	@IBOutlet weak var demoLayoutOne: UIView!
	@IBOutlet weak var demoLayoutTwo: UIView!
	
	// MARK: - Properties -
	
	private let stackView = CustomStackFlowView()
	
	// MARK: - Life cycle -

	override func viewDidLoad() {
		super.viewDidLoad()
		setUp()
	}
	
	// MARK: - Setup -
	
	private func setUp() {
		/* — Here is everything you need to present working StackFlowView — */
		
		view.addSubview(stackView)
		
		/* — In this demo we prefer StackFlowView subclassing over composition, so delegate is set inside CustomStackFlowView initialization flow — */
		//stackView.delegate = self
		
		/* — It's probably nice to set up some constraints though if you plan to change layout dynamically — */
		
		pinBounds(of: stackView, to: view, withInsets: (0, 0, 0, 0))
		
		/* — Now, OPTIONAL customization time! — */
		
		// How big should padding next to the stack head be?
		stackView.headPadding = 0
		
		// Which direction should new items be pushed in?
		stackView.growthDirection = .down
		
		// Separate by lines or padding?
		stackView.separationStyle = .line(thikness: 2.0, color: .black)
								 // .padding(size: 20.0)
								 // .none
		
		// If you want your stack gradually fade away, you can pick any of the styles, or combine them!
		stackView.fadingStyle = .combined(styles:
			[
				.tint(color: .white, preLastAlpha: 0.9, alphaDecrement: 0.1),
				.gradientMask(effectDistance: stackView.bounds.height * 0.7)
			]
		) // Or just .none
		
		// You can swipe up-down or left-right to control your flow, and/or also tap inactive stack area to pop any number of items (depends on where you tap)
		stackView.userNavigationOptions = [.swipe, .tap]
		
		// Fast hops or sloooooow animation?
		stackView.transitionDuration = 0.25
		
		// Set to false if you don't need automatic safe area detection/adoption
		stackView.isSeekingSafeArea = true
		
		// Set to false to turn off stretch-out behaviour for your content items during autolayout updates
		stackView.isAutoresizingItems = true
		
		/* — ——— — */
		
		/* — Now let's kick off the flow — */
		
		// This is not necessary, we could just use any available controls (like swipe gesture) on StackFlowView to present the first flow item.
		stackView.resetFlow()
		
		/* — Ok, that was to get you onboard with all the features. Now we're going to discard this stackView, and instead of it try a set of predefined demo cases (if you wish) — */
		
		let weWantToSeeMoreDemos = false
		guard weWantToSeeMoreDemos else {
			return
		}
		
		stackView.removeFromSuperview()
		
		/* — Change to play with different demo cases — */
		
		let demoLayoutToUse = demoLayoutOne
		
		for subview in view.subviews {
			guard !subview.isKind(of: UIImageView.self) else { continue }
			
			guard subview != demoLayoutToUse else { subview.isHidden = false; continue }
			subview.isHidden = true
		}
		
		for layoutContainer in demoLayoutToUse!.subviews {
			let stackFlowView = CustomStackFlowView()
			
			let caseToTest: DemoCase = {
				// Return any case you want. Note, you may get weird behaviour here, since there are lots of parameters to play with in this or other demo files — it's just a playground. Please refer documentation if you want clear instructions.
				
				return .verticalCardsStack
				
				return .pageStack(direction: {
					return layoutContainer.bounds.width < layoutContainer.bounds.height ? .down : .right
				}())
				
				return .stackOfStacks

				return .feedFallingDown

				return .pageStack(direction: .right)
			}()
			
			layoutContainer.addSubview(stackFlowView)
			
			configure(stackView: stackFlowView, inside: layoutContainer, as: caseToTest)
			//stackFlowView.resetFlow()
		}
	}
}

extension ViewController {
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	}
}

// MARK: - Demo cases -

extension ViewController {
	enum DemoCase {
		case verticalCardsStack
		case pageStack(direction: StackFlowView.Direction)
		case feedFallingDown
		case stackOfStacks
	}
	
	func configure(stackView: StackFlowView, inside container: UIView, as case: DemoCase) {
		switch `case` {
		case .verticalCardsStack:
			pinBounds(of: stackView, to: container, withInsets: (20, 0, 20, 0))
			
			stackView.headPadding = 20
			stackView.growthDirection = .down
			stackView.separationStyle = .padding(size: 20)
			stackView.fadingStyle = .combined(styles:
				[
					.tint(color: .white, preLastAlpha: 0.9, alphaDecrement: 0.1),
					.gradientMask(effectDistance: stackView.bounds.height * 0.7)
				]
			)
			
			stackView.userNavigationOptions = [.swipe, .tap]
			stackView.transitionDuration = 0.25
			stackView.isSeekingSafeArea = true
			stackView.isAutoresizingItems = true
			
		case .pageStack(let direction):
			pinBounds(of: stackView, to: container, withInsets: (0, 0, 0, 0))
			
			stackView.headPadding = 0
			stackView.growthDirection = direction
			stackView.separationStyle = .line(thikness: 2, color: .white)
			stackView.fadingStyle = .combined(styles:
				[
					.tint(color: .white, preLastAlpha: 0.9, alphaDecrement: 0.1)
				]
			)
			
			stackView.userNavigationOptions = [.swipe, .tap]
			stackView.transitionDuration = 0.10
			stackView.isSeekingSafeArea = true
			stackView.isAutoresizingItems = true
			
		case .feedFallingDown:
			pinBounds(of: stackView, to: container, withInsets: (10, 0, 10, 10))
			
			stackView.headPadding = 20
			stackView.growthDirection = .up
			stackView.separationStyle = .line(thikness: 6, color: .white)
			stackView.fadingStyle = .tint(color: .white, preLastAlpha: 0.8, alphaDecrement: 0.15)
			
			stackView.userNavigationOptions = [.swipe, .tap]
			stackView.transitionDuration = 0.20
			stackView.isSeekingSafeArea = true
			stackView.isAutoresizingItems = true
			
			var timePassed: TimeInterval = 0
			
			for _ in 0 ..< 24 {
				timePassed += 0.05
				
				Utils.mainQueueTask({
					(stackView as? CustomStackFlowView)?.pushNextItem(to: stackView)
				}, after: timePassed)
			}
			
		case .stackOfStacks:
			pinBounds(of: stackView, to: container, withInsets: (0, 0, 0, 0))
			
			stackView.headPadding = 0
			stackView.growthDirection = .right
			stackView.separationStyle = .padding(size: 10)
			stackView.fadingStyle = .none
			
			stackView.userNavigationOptions = [.swipe, .tap]
			stackView.transitionDuration = 0.4
			stackView.isSeekingSafeArea = false
			stackView.isAutoresizingItems = true
			
			if let customStack = stackView as? CustomStackFlowView {
				customStack.customPushFunction = {
					customStack.push(
						{
							let substacksPerScreen: CGFloat = 3
							let itemTint = Utils.randomPastelColor()
							
							let substackWidth: CGFloat = {
								if case .padding(let size) = stackView.separationStyle {
									return ((customStack.safeSize.width - (size * (substacksPerScreen - 1))) / substacksPerScreen)
								}
								
								return 0
							}()
							
							let itemView = UIView(frame: CGRect(x: 0, y: 0, width: substackWidth, height: customStack.safeSize.height))
							itemView.layer.borderWidth = 2.0
							itemView.layer.borderColor = itemTint.cgColor
							
							let subStack = CustomStackFlowView()
							itemView.addSubview(subStack)
							pinBounds(of: subStack, to: itemView, withInsets: (0, 0, 0, 0))
							
							subStack.headPadding = 0
							subStack.growthDirection = stackView.numberOfItems % 2 > 0 ? .down : .up
							subStack.separationStyle = .line(thikness: 2, color: itemTint)
							subStack.fadingStyle = .none
							
							subStack.userNavigationOptions = [.swipe, .tap]
							subStack.transitionDuration = 0.20
							subStack.isSeekingSafeArea = true
							subStack.isAutoresizingItems = true
							
							return itemView
						}()
					)
				}
			}
		}
	}
}
