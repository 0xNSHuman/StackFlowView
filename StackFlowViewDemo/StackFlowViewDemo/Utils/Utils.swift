//
//  Utils.swift
//  StackFlowViewDemo
//
//  Created by Vladislav Averin on 19/01/2018.
//  Copyright © 2018 Vlad Averin. All rights reserved.
//

import Foundation
import UIKit

// MARK: Shortcuts

var appWindow: UIWindow? {
	guard let window = appDelegate?.window else {
		log(message: "[WARNING] Trying to access app window, which doesn't exist!", from: #function)
		return nil
	}
	
	return window
}

var appDelegate: AppDelegate? { return UIApplication.shared.delegate as? AppDelegate }

struct Utils {
	
}

extension Utils {
	static func controllerFromStoryboard<T>(_ type: T.Type) -> T {
		return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: type)) as! T
	}
}

// MARK: Global heirarchy

extension Utils {
	static func setRootViewController(_ rootVC: UIViewController) {
		appDelegate?.window?.subviews.forEach { $0.removeFromSuperview() }
		appDelegate?.window = UIWindow(frame: UIScreen.main.bounds)
		
		appWindow?.backgroundColor = .white
		appWindow?.rootViewController = rootVC
		appWindow?.makeKeyAndVisible()
	}
}

// MARK: Threads

extension Utils {
	static func mainQueueTask(_ task: @escaping () -> (), after interval: TimeInterval = 0.0) {
		DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: task)
	}
	
	static func bgQueueTask(_ task: @escaping () -> (), after interval: TimeInterval = 0.0) {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + interval, execute: task)
	}
}

// MARK: UIKit Routines

extension Utils {
	static func alert(title: String?, text: String?, handler: (() -> Void)? = nil) -> UIAlertController {
		let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("button.ok", value: "Ok", comment: "Alert OK Button"), style: .default, handler: {_ in handler?() }))
		return alert
	}
	
	static func animateBlock(_ block: @escaping () -> Void, duration: Double = 0.25, delay: Double = 0.0) {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
			UIView.animate(withDuration: duration, animations: {
				block()
			})
		})
	}
}

// MARK: UI Appearance

extension Utils {
	static func randomPastelColor() -> UIColor {
		let randomColorGenerator = { ()-> CGFloat in
			CGFloat(arc4random() % 256 ) / 256
		}
		
		let red: CGFloat = randomColorGenerator()
		let green: CGFloat = randomColorGenerator()
		let blue: CGFloat = randomColorGenerator()
		
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}

// MARK: Feedback

extension Utils {
	static func throwAlert(title: String?, text: String?, completion: (() -> ())? = nil) {
		appWindow?.rootViewController?.present(alert(title: title, text: text), animated: true, completion: completion)
	}
}

// MARK: Debug

func log(message: String, from sender: Any) {
	print("[\(sender)]: \(message)")
}
