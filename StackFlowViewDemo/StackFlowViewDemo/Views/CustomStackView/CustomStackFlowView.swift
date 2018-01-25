//
//  CustomStackFlowView.swift
//  StackFlowViewDemo
//
//  Created by Vladislav Averin on 19/01/2018.
//  Copyright © 2018 Vlad Averin. All rights reserved.
//

import UIKit

/// This is a subclass of StackFlowView, which is one of the possible ways to use it. It lets you build custom behaviour and flow control while enjoying basic navigation features. Another possible way would be making a composition, i.e. using StackFlowView object as a property of another class. It's up tou you and your case which way is better, but for this demo purposes I ended up with subclassing.

class CustomStackFlowView: StackFlowView {
	// MARK: - Types -
	
	enum FlowStep: Int {
		case none = -1
		case stepOne = 0, stepTwo, stepThree, stepFour, stepFive, stepSix
		
		static var count: Int { return 6 }
		
		var title: String {
			switch self {
			default:
				return "Step \(shortSymbol)"
			}
		}
		
		var shortSymbol: String {
			switch self {
			case .stepOne:
				return "♦️"
				
			case .stepTwo:
				return "♠️"
				
			case .stepThree:
				return "💎"
				
			case .stepFour:
				return "🔮"
				
			case .stepFive:
				return "🎁"
				
			case .stepSix:
				return "📖"
				
			case .none:
				return "❌"
			}
		}
		
		func prevStep() -> FlowStep? {
			let prevValue = rawValue - 1
			return prevValue >= 0 ? FlowStep(rawValue: prevValue) : nil
		}
		
		func nextStep() -> FlowStep? {
			let nextValue = rawValue + 1
			return nextValue < FlowStep.count ? FlowStep(rawValue: nextValue) : nil
		}
	}
	
	// MARK: - Properties -
	
	/* — You can play with finite/infinite stack variations — */
	var isEndlessMode = false
	
	var customPushFunction: (() -> ())? = nil
	
	// MARK: - State control -
	
	private var currentStep: FlowStep = .none {
		didSet {
			let itemTitle = currentStep.title
			
			let prevItemSymbol = currentStep.prevStep()?.shortSymbol
			let nextItemSymbol = currentStep.nextStep()?.shortSymbol
			
			let itemView = stepView(for: currentStep)
			
			// Subfunction to explain possible ways of pushing new item + customization
			
			func pushStep() {
				/* — You can choose how far you want to go in terms of customization of evety item — */
				
				let chosenWay = 3
				
				switch chosenWay {
				case 1:
					// 1. Push your custom view "as is". This way it's just sent to stack flow, and navigaton (push next/pop to previous) is available either through StackFlowView's swipes/taps, or whatever you set yourself in your custom view (the idea is to push/pop after user achieves some goal in your view, such as setting text, picking options, pressing buttons, etc.)
					push(view: itemView)
					
				case 2:
					// 2. Same as above, plus a standard navigation bar on top, showing the title you set, as well as button controls for pop/push. Not much but still nice feature to have in case you don't like gestures, or as part of Accessibility implementation for some users.
					push(view: itemView, title: itemTitle)
					
				case 3:
					// 3. Same as above, but now you have options to customize item's navigation bar appearance properties, such as background and foreground color, title font, pop/push icons text or icons.
					
					
					let topBarAppearance: StackItemAppearance.TopBar = {
						/* — Change to see different button appearance example: 0 - icon or 1 - text/emoji. See switch below for details — */
						
						let buttonsTestOption = 1
						
						let popButtonAppearance: StackItemAppearance.TopBar.Button
						let pushButtonAppearance: StackItemAppearance.TopBar.Button
						
						if buttonsTestOption == 0 { // Navigation icons playground
							popButtonAppearance = StackItemAppearance.TopBar.Button(icon: Images.Navigation.back)
							pushButtonAppearance = StackItemAppearance.TopBar.Button(icon: Images.Navigation.forward)
						} else { // Navigation text playground
							let popButtonTitle = NSAttributedString(string: "\(currentStep.prevStep()?.shortSymbol ?? "❌")⬅️", attributes: [.foregroundColor : UIColor.blue])
							popButtonAppearance = StackItemAppearance.TopBar.Button(title: popButtonTitle)
							
							let pushButtonTitle = NSAttributedString(string: "➡️\(currentStep.nextStep()?.shortSymbol ?? "❌")", attributes: [.foregroundColor : UIColor.blue])
							pushButtonAppearance = StackItemAppearance.TopBar.Button(title: pushButtonTitle)
						}
						
						// Setting StackItemAppearance for the item to insert
						
						let customBarAppearance = StackItemAppearance.TopBar(backgroundColor: Utils.randomPastelColor(), titleFont: .italicSystemFont(ofSize: 17.0), titleTextColor: .white, popButtonIdentity: popButtonAppearance, pushButtonIdentity: pushButtonAppearance)
						return customBarAppearance
					}()
					
					let customAppearance = StackItemAppearance(backgroundColor: Utils.randomPastelColor(), topBarAppearance: topBarAppearance)

					push(view: itemView, title: itemTitle, customAppearance: customAppearance)
					
				default:
					push(view: itemView)
				}
			}
			
			let delta = currentStep.rawValue - oldValue.rawValue
			
			if delta < 0 {
				for _ in 0 ..< abs(delta) {
					pop()
				}
			} else if delta > 0 {
				pushStep()
			} else {
				pop()
				pushStep()
			}
		}
	}
	
	// MARK: Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.delegate = self // Don't forget to set delegate!
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Goal creation flow
	
	func resetFlow() {
		guard !isEndlessMode else {
			return
		}
		
		setStep(FlowStep(rawValue: 0)!, animated: true)
		clean()
		setStep(FlowStep(rawValue: 0)!, animated: true)
	}
	
	// MARK: Transitions
	
	private func goToPrevStep() {
		guard let prevStep = currentStep.prevStep() else {
			return
		}
		
		setStep(prevStep, animated: true)
	}
	
	private func goToNextStep() {
		guard let nextStep = currentStep.nextStep() else {
			return
		}
		
		setStep(nextStep, animated: true)
	}
	
	private func setStep(_ step: FlowStep, animated: Bool) {
		self.transitionDuration = animated ? 0.25 : 0.0
		self.currentStep = step
	}
	
	// MARK: FlowStep views construction
	
	private func stepView(for step: FlowStep) -> UIView {
		let stepView: DemoItemView
		
		// Here we don't really care but for a real state control we could create different necessary unique views for evety step
		
		switch step {
		default:
			// Please look into DemoItemView.bounds(for:) static method to learn more about defining the best frames for your stack flow item views
			
			stepView = DemoItemView.stackItem(bounds: DemoItemView.bounds(for: self))
			stepView.identityLabel.text = "Any UI"//"Custom UIView #" + String(step.rawValue + 1)
			
			stepView.popHandler = {
				self.goToPrevStep()
			}
			
			stepView.pushHandler = {
				self.goToNextStep()
			}
		}
		
		return stepView
	}
}

// MARK: - Delegate -

extension CustomStackFlowView: StackFlowDelegate {
	func pushNextItem(to stackView: StackFlowView) {
		if let customPush = customPushFunction {
			customPush()
			return
		}
		
		stackView.push(view:
			{
				let item = DemoItemView.stackItem(bounds: DemoItemView.bounds(for: stackView))
				item.identityLabel.text = "Custom UI"//"Custom UIView #" + String(stackView.numberOfItems + 1)
				
				item.popHandler = {
					stackView.pop()
				}
				
				item.pushHandler = {
					self.pushNextItem(to: stackView)
				}
				
				return item
			}()
		)
	}
	
	func stackFlowViewDidRequestPop(_ stackView: StackFlowView, numberOfItems: Int) {
		log(message: "Requested to go \(numberOfItems) steps back", from: self)
		
		if isEndlessMode {
			stackView.pop(numberOfItems)
		} else {
			for _ in 0 ..< numberOfItems {
				goToPrevStep()
			}
		}
	}
	
	func stackFlowViewDidRequestPush(_ stackView: StackFlowView) {
		log(message: "Requested next item", from: self)
		
		if isEndlessMode {
			pushNextItem(to: stackView)
		} else {
			goToNextStep()
		}
	}
	
	func stackFlowViewWillPop(_ stackView: StackFlowView) {
		log(message: "About to go one item back", from: self)
	}
	
	func stackFlowViewDidPop(_ stackView: StackFlowView) {
		log(message: "Went one item back", from: self)
		
		if let demoItem = stackView.lastItemContent as? DemoItemView {
			demoItem.becameActive()
		}
	}
	
	func stackFlowView(_ stackView: StackFlowView, willPush view: UIView) {
		log(message: "About to to go to the next step", from: self)
		
		if let lastItem = stackView.lastItemContent as? DemoItemView {
			lastItem.becameInactive()
		}
	}
	
	func stackFlowView(_ stackView: StackFlowView, didPush view: UIView) {
		log(message: "Went to next step with view: \(view)", from: self)
	}
}
