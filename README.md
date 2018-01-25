<h1 align="center"> StackFlowView </h1>
<p align="center">
<a href="https://opensource.org/licenses/MIT"><img alt="Licence" src="https://img.shields.io/badge/license-MIT-green.svg" /></a>
<a href=""><img alt="Version" src="https://img.shields.io/badge/version-1.0.0-blue.svg" /></a>
<a href=""><img alt="Swift Version" src="https://img.shields.io/badge/swift_versions-3.2|4.0-orange.svg" /></a>
<a href="https://cocoapods.org/pods/StackFlowView"><img alt="StackFlowView" src="https://img.shields.io/badge/pod-StackFlowView-red.svg" /></a>
</p>

<p align="center">
📥 Ordered custom UI flow elements controlled as stack 📤
</p>
<p align="center">
🗂 Enforce sequential interaction | Focus user attention on one flow step at a time 🗂
</p>

<p align="center">
<img width="30%" height="auto" alt="Multiple stacks at once" src="https://raw.githubusercontent.com/vladaverin24/StackFlowView/master/Screenshots/two_stacks.gif" />
<img width="30%" height="auto" alt="Cards stack" src="https://github.com/vladaverin24/StackFlowView/raw/master/Screenshots/cards_stack.gif" />
<img width="30%" height="auto" alt="Stack of pages" src="https://github.com/vladaverin24/StackFlowView/raw/master/Screenshots/paging_stack.gif" />
</p>

<p align="center">
<img width="90%" height="auto" alt="Stack of stacks" src="https://raw.githubusercontent.com/vladaverin24/StackFlowView/master/Screenshots/stack_of_stacks.gif" />
</p>

<hr>

## How does it work?

**StackFlowView** is a high-level view capable of hosting a collection of custom `UIView`s. Which is, well, not unique behaviour.. The special thing about though, is that it *enforces stack flow* behaviour (as the name suggests), which means:
1. Only the last view in stack allows user interaction. There is no way to affect past or future state of the UI flow;

2. No view properties can be pre-determined until the moment before putting one into stack (**push** action). This way, every next stack item considers previous state and can be adjusted to reflect particular flow step;

3. It is not possible to go **N** items back without dismissing/destroying those items (**pop** action). This way, going back in time and changing state enforces subsequent flow steps to be revisited.

> During development, various state-dependent UX cases were kept in mind. For example, this solution perfectly works for all kinds of dynamic input forms where every next set of options depends on previous choices made by user.

## Installation
### CocoaPods
1. Add `pod 'StackFlowView'` to your `Podfile`;
2. Run `pod install` or `pod update` in Terminal;
3. Re-open your project using `.xcworkspace`, put `import StackFlowView` in the swift files you plan to use stack flow in (or use bridging in Obj-C projects);
4. Rebuild and enjoy.

### Old School Way
Drop folder with `.swift` source files to your project and you're done.

## Usage

### Creation

Creating `StackFlowView` takes a few lines of code. Basically, you need to:
- Initialize it with any frame (not necessery);
- Add it to superview;
- Set delegate;
- Optionally set up constraints if you want to enjoy autolayout-ready behaviour;

```Swift
let stackView = StackFlowView()
stackView.delegate = self

view.addSubview(stackView)

/* — Optional constraints — */

([
		NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
		NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0),
		NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
		NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
]).forEach { $0.isActive = true }

view.setNeedsLayout()
view.layoutIfNeeded()
```

### Customization

There are some nice options to define desired behaviour of your stack flow, including its direction of growth, the way it separates items, gestures user can use to move back and forth, and more. Please see the comments below, as well as property references in Xcode.

```Swift
// How big should padding next to the stack's last item be?
stackView.headPadding = 0

// Which direction should new items be pushed in?
stackView.growthDirection = .down

// Separate by lines, padding or nothing at all?
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
```

### Push and Pop items

> **NOTE**: There is no items reusability mechanism in current version, so whatever you push to `StackFlowView` increments memory usage until you pop it. Therefore, the weak place of this library is a large number of flow steps. It's in TODO list to address this feature.

#### Push

There is only one straight-forward to use method to push your view into Stack Flow, but it lets you customize things to the degree you want.

You can stick to using the same style for all items, or use custom approach for each one.

###### Just push the view itself

Send the view to stack without showing anything else.

<p align="left">
<img width="40%" height="auto" alt="Item without header" src="https://raw.githubusercontent.com/vladaverin24/StackFlowView/master/Screenshots/item_title_none.jpg" />
</p>

```Swift
stackView.push(myCustomView)
```

###### Push with header bar (standard appearance)

Display item's title along with standard-looking buttons navigation, which is a good alternative to gestures in case you need it (for example, as an Accessibility option for users).

<p align="left">
<img width="40%" height="auto" alt="Item with stanrard header" src="https://raw.githubusercontent.com/vladaverin24/StackFlowView/master/Screenshots/item_title_standard.jpg" />
</p>

```Swift
stackView.push(myCustomView, title: "Step ♦️")
```

###### Push with customised header bar

Define custom appearance for the item's container, including its header bar background color, title font and color, and navigation buttons appearance.

<p align="left">
<img width="40%" height="auto" alt="Item with custom appearance" src="https://raw.githubusercontent.com/vladaverin24/StackFlowView/master/Screenshots/item_title_custom.jpg" />
</p>

```Swift
// Define custom top bar appearance

let topBarAppearance: StackItemAppearance.TopBar = {
	let popButtonAppearance: StackItemAppearance.TopBar.Button
	let pushButtonAppearance: StackItemAppearance.TopBar.Button

	// You can use images or attributed text for navigation buttons

	let preferIconsOverText = false

	if preferIconsOverText { // Use icons
		popButtonAppearance = StackItemAppearance.TopBar.Button(icon: UIImage(named: "back")!)
		pushButtonAppearance = StackItemAppearance.TopBar.Button(icon: UIImage(named: "forth")!)
	} else { // Use text
		let popButtonTitle = NSAttributedString(string: "\(currentStep.prevStep?.shortSymbol ?? "❌")⬅️", attributes: [.foregroundColor : UIColor.blue])
		popButtonAppearance = StackItemAppearance.TopBar.Button(title: popButtonTitle)

		let pushButtonTitle = NSAttributedString(string: "➡️\(currentStep.nextStep?.shortSymbol ?? "❌")", attributes: [.foregroundColor : UIColor.blue])
		pushButtonAppearance = StackItemAppearance.TopBar.Button(title: pushButtonTitle)
	}

	let customBarAppearance = StackItemAppearance.TopBar(backgroundColor: Utils.randomPastelColor(), titleFont: .italicSystemFont(ofSize: 17.0), titleTextColor: .white, popButtonIdentity: popButtonAppearance, pushButtonIdentity: pushButtonAppearance)

	return customBarAppearance
}()

// Set appearence for the whole item, including previously created top bar appearance

let customAppearance = StackItemAppearance(backgroundColor: Utils.randomPastelColor(), topBarAppearance: topBarAppearance)

// Push it all to the stack!

stackView.push(myCustomView, title: "Step ♦️", customAppearance: customAppearance)
```

#### Pop

Pop N items from stack by calling one of the `pop(_:)` method variations.

###### Pop one item

```Swift
stackView.pop()
```

###### Pop multiple items

```Swift
stackView.pop(numberOfItems)
```

### Delegate methods

`StackFlowDelegate` protocol enables control over stack flow by the object implementing it. For example, it delivers **push** and **pop** intention events triggered by user gestures, and letting you decide if StackFlowView should proceed or ignore this action. It also reports about the corresponding actions that are upcoming or just passed.

```Swift
func stackFlowViewDidRequestPop(_ stackView: StackFlowView, numberOfItems: Int) {
	log(message: "Requested to go \(numberOfItems) steps back", from: self)
	stackView.pop(numberOfItems)
}

func stackFlowViewDidRequestPush(_ stackView: StackFlowView) {
	log(message: "Requested next item", from: self)
	goToNextStep()
}

func stackFlowViewWillPop(_ stackView: StackFlowView) {
	log(message: "About to go one item back", from: self)
}

func stackFlowViewDidPop(_ stackView: StackFlowView) {
	log(message: "Went one item back", from: self)
}

func stackFlowView(_ stackView: StackFlowView, willPush view: UIView) {
	log(message: "About to to go to the next step", from: self)
}

func stackFlowView(_ stackView: StackFlowView, didPush view: UIView) {
	log(message: "Went to next step with view: \(view)", from: self)
}
```

## [Optional] Simplest flow logic example

There are mainly two suggested options to create and use StackFlowView: **subclassing** or **composition**. Choosing particular one may depend on your style or purposes, but generally it's about where do you want to define your custom flow control logic.

### Subclassing

You can encapsulate all flow state related operations in your `StackFlowView` subclass. This is ok for relatively simple flows, but might be bad idea for something

```Swift
class MyFlowController: UIViewController {
	// MARK: - Flow definition -

	enum MyFlowStep: Int {
		case none = -1
		case one = 0, two, three, four

		static var count: Int { return 6 }

		var title: String {
			switch self {
			default:
				return "Step \(shortSymbol)"
			}
		}

		var shortSymbol: String {
			switch self {
			case .one:
				return "♦️"

			case .two:
				return "♠️"

			case .three:
				return "💎"

			case .four:
				return "🔮"

			case .none:
				return "❌"
			}
		}

		var prevStep: FlowStep? {
			let prevValue = rawValue - 1
			return prevValue >= 0 ? FlowStep(rawValue: prevValue) : nil
		}

		var nextStep: FlowStep? {
			let nextValue = rawValue + 1
			return nextValue < FlowStep.count ? FlowStep(rawValue: nextValue) : nil
		}
	}

    // MARK: - Properties -

    private let stackView = StackFlowView()

    /* — Whenever this property is set, you can prepare the next view to push — */

    private var currentStep: MyFlowStep = .none {
		didSet {
			// Get identity of the current step, as well as its bounding neighbor steps

			let itemTitle = currentStep.title

			let prevItemSymbol = currentStep.prevStep?.shortSymbol
			let nextItemSymbol = currentStep.nextStep?.shortSymbol

			// Here you should construct your custom UIView considering purposes of this particular step

			let itemView = stepView(for: currentStep)

			// Now you can push your custom view using superclass `push()` method!

            stackView.push(itemView, title: itemTitle)
		}
	}

    // MARK: - View constructor -

    private func stepView(for step: MyFlowStep) -> UIView {
    	let stepView: UIView

    	// Note this `safeSize` property of StackFlowView. You should use it to get info about its available content area, not blocked by any views outside of safe area

		let safeStackFlowViewWidth = stackView.safeSize.width

       	switch step {
        case .one:
        	stepView = UIView(frame: CGRect(x: 0, y: 0, width: safeStackFlowViewWidth, height: 100.0))

       	case .two:
        	stepView = UIView(frame: CGRect(x: 0, y: 0, width: safeStackFlowViewWidth, height: 200.0))

        // Build custom view for any given step
        }

        return stepView
	}
}
```

## TODO

- [ ] Think about views reusability mechanism

## Contact Author
Feel free to send pull requests or propose changes.

Email: [hello@vladaverin.me](mailto:?to=hello@vladaverin.me)

Reach me on [Facebook](https://facebook.com/vaverin)

Have troubles integrating it? [![Contact me on Codementor](https://cdn.codementor.io/badges/contact_me_github.svg)](https://www.codementor.io/vladaverin24?utm_source=github&utm_medium=button&utm_term=vladaverin24&utm_campaign=github)

Or check other ways to contact me at [vladaverin.me](http://vladaverin.me).

## License
StackFlowView is released under an MIT license. See the [LICENSE](https://raw.githubusercontent.com/vladaverin24/TimelineCards/master/LICENSE.md) file.
