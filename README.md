# DynamicButtonStack

DynamicButtonStack lays out a collection of buttons in either a column or a row. It dynamically adjusts the layout to suit the button content and the available space.

[Read more about the problems solved by DynamicButtonStack and the design principles behind it.](https://douglashill.co/dynamic-button-stack/)

## Requirements

DynamicButtonStack requires iOS 13. On older versions `UIButton` responds to `imageEdgeInsets` slightly differently in some cases. It has only been tested with Swift but should work with Objective-C apps too. The latest stable Xcode is expected.

## Installation

### Recommended

1. Clone this repository.
2. Drag `DynamicButtonStack.swift` into your Xcode project and add it to your target.

### CocoaPods

1. Add the following to your `Podfile`:
    
    ```ruby
    pod 'DynamicButtonStack'
    ```
    
2. Run the following command:
    
    ```
    pod install
    ```

The module name when using CocoaPods is `DynamicButtonStackKit`.

## Usage

Your app provides a DynamicButtonStack with buttons and a maximum width. The DynamicButtonStack then provides your app the a minimum width and height it requires. You app then gives the DynamicButtonStack at least that amount of space and the buttons will be nicely stacked within it.

You can supply as many buttons as you like. Their titles can be as long as you like, and the font can be as large as you like. In exchange, give the button stack the height it needs. This means the button stack is typically best placed in a vertically scrolling view.

Create a `DynamicButtonStack` and give it an array of buttons that each have both an image and a title. Add the button stack to your view hierarchy.

```swift
let buttonStack = ...
```

The button stack should be laid out using `sizeThatFits` and `layoutSubviews`. Layout using constraints is not supported.

The frame should be set with a size at least as large as the size returned from `sizeThatFits` (in both dimensions).

Measure the minimum size using `sizeThatFits`. Pass your container’s width limit and an unlimited height. An assertion will fail if the height is not unlimited. This is a reminder that handling restricted heights is not currently supported.

```swift
override func layoutSubviews...

let sizeLimit = (bounds.width, .greatestFiniteMagnitude)
let size = sizeThatFits...

buttonStack.frame = CGRect(origin: .zero, size: size)
```

The buttons can be styled however you like. Colour, font, shadow, highlight state etc.

- Do set an image.
- Do set a title.
- Don’t modify the image or title insets because DynamicButtonStack needs to adjust these to set the stacking and alignment inside the buttons.
- Do customise any other properties however you like. Setting `contentEdgeInsets` is recommended.

## Status

DynamicButtonStack is considered ready for use in production.

There is no private API use or interference with private subviews.

## Q & A

### Does DynamicButtonStack support being laid out with constraints?

No. It must be measured using `sizeThatFits`. It does not supply an `intrinsicContentSize` because like with text, the intrinsic height depends on the width.

### Does DynamicButtonStack use modern layout API like constraints, UIStackView or SwiftUI?

No.

### Would this be easier with SwiftUI?

Maybe. If you think so I’d love to see how this would look.

## Credits

DynamicButtonStack is a project from [Douglas Hill](https://douglashill.co/) and was developed for my [reading app](https://douglashill.co/reading-app/).

## Licence

MIT license — see License.txt
