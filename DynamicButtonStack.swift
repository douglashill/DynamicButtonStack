// Douglas Hill, March 2020

import UIKit

/// A stack of buttons that dynamically adjusts the layout to fit the content in the available
/// width. The buttons are stacked either horizontally or vertically, and the image and label
/// within each button are also stacked either horizontally or vertically.
/// The height required should be found by calling sizeThatFits and passing in the width limit.
/// The height passed to sizeThatFits should be greatestFiniteMagnitude.
public class DynamicButtonStack: UIView {

    private let internalSpacing: CGFloat = 8

    @objc public var buttons: [UIButton] = [] {
        willSet {
            for button in buttons {
                button.removeFromSuperview()
            }
        }
        didSet {
            didSetButtons()
        }
    }

    /// didSet is not called in an initialiser so this has been extracted.
    private func didSetButtons() {
        for button in buttons {
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            addSubview(button)
        }
    }

    @objc public convenience init(buttons: [UIButton]) {
        self.init(frame: .zero)

        self.buttons = buttons
        didSetButtons()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func usualButtonLengthForContainerLength(_ containerLength: CGFloat) -> CGFloat {
        precondition(buttons.isEmpty == false)

        let unrounded = (containerLength - CGFloat(buttons.count - 1) * internalSpacing) / CGFloat(buttons.count)
        return roundToPixels(unrounded, function: floor)
    }

    private func lengthForButtonAtIndex(_ index: Int, withContainerLength containerLength: CGFloat) -> CGFloat {
        let usualButtonLength = usualButtonLengthForContainerLength(containerLength)

        // In case the width doesn’t divide cleanly, make the last button slightly bigger to fill the space.
        // Reasoning is the buttons are wider than the spacing so the difference will be least noticeable on the button.
        // It could be any button really. Choosing the last one is arbitrary, although it makes the implementation of frameForButtonAtIndex a bit simpler.
        if index == buttons.count - 1 {
            return containerLength - CGFloat(buttons.count - 1) * (usualButtonLength + internalSpacing)
        } else {
            return usualButtonLength
        }
    }

    /// Returns the frame where a button should be positioned.
    /// - Parameters:
    ///   - index: The index of the button in the buttons property.
    ///   - stackingOrientation: The stacking direction of the buttons outside themselves (not of the image and title in the button).
    private func frameForButtonAtIndex(_ index: Int, stackingOrientation: UIButton.StackingOrientation) -> CGRect {
        switch stackingOrientation {
        case .horizontal:
            let effectiveIndex = isEffectiveUserInterfaceLayoutDirectionRightToLeft ? buttons.count - (index + 1) : index
            return CGRect(x: CGFloat(effectiveIndex) * (usualButtonLengthForContainerLength(bounds.width) + internalSpacing), y: 0, width: lengthForButtonAtIndex(index, withContainerLength: bounds.width), height: bounds.height)
        case .vertical:
            return CGRect(x: 0, y: CGFloat(index) * (usualButtonLengthForContainerLength(bounds.height) + internalSpacing), width: bounds.width, height: lengthForButtonAtIndex(index, withContainerLength: bounds.height))
        }
    }

    public override var frame: CGRect {
        didSet {
            // It doesn’t work without this being async.
            DispatchQueue.main.async {
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    public override var bounds: CGRect {
        didSet {
            // It doesn’t work without this being async.
            DispatchQueue.main.async {
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    public override var intrinsicContentSize: CGSize {
        sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
    }

    public override func sizeThatFits(_ availableSize: CGSize) -> CGSize {
        precondition(availableSize.height == .greatestFiniteMagnitude, "\(DynamicButtonStack.self) does not support limiting the available height.")

        if buttons.isEmpty {
            return .zero
        }

        return requiredSizeForWidth(availableSize.width)
    }

    /// Returns the smallest height for a given width.
    private func requiredSizeForWidth(_ availableWidth: CGFloat) -> CGSize {
        precondition(buttons.isEmpty == false)

        /// Layout info for when the buttons are shown side-by-side, so each button width is a fraction of the container width.
        let layoutInfoForHorizontalStacking = buttons.enumerated().map { index, button -> UIButton.LayoutInfo in
            let buttonWidth = lengthForButtonAtIndex(index, withContainerLength: availableWidth)
            return button.layoutInfoForWidth(buttonWidth)
        }

        // (1) Try horizontal stacking of the buttons and horizontal stacking in the buttons.
        // If any button doesn’t fit, move on.
        let allFitHorizontally = layoutInfoForHorizontalStacking.allSatisfy {
            switch $0.stackingOrientation {
            case .horizontal: return true
            case .vertical: return false
            }
        }
        if allFitHorizontally {
            // Use the max width rather than the sum to get a more even layout.
            let maxWidth = layoutInfoForHorizontalStacking.max(by: { $0.buttonSize.width < $1.buttonSize.width} )!.buttonSize.width
            let maxHeight = layoutInfoForHorizontalStacking.max(by: { $0.buttonSize.height < $1.buttonSize.height} )!.buttonSize.height
            return CGSize(
                width: maxWidth * CGFloat(buttons.count) + internalSpacing * CGFloat(buttons.count - 1),
                height: maxHeight
            )
        }

        // (2) Try horizontal stacking of the buttons and vertical stacking in the buttons.
        let allFitVerticallyWithoutWrapping = layoutInfoForHorizontalStacking.allSatisfy {
            switch $0.stackingOrientation {
            case .horizontal: return true
            case .vertical: return $0.requiresWrapping == false
            }
        }
        if allFitVerticallyWithoutWrapping {
            // This is inefficiently recalculating things that may have just been calculated already. This could be addressed if performance is a problem.
            let sizes = buttons.enumerated().map { index, button -> CGSize in
                return button.sizeForVerticalStackingForWidth(nil)
            }
            let maxWidth = sizes.max(by: { $0.width < $1.width} )!.width
            let maxHeight = sizes.max(by: { $0.height < $1.height} )!.height
            return CGSize(
                width: maxWidth * CGFloat(buttons.count) + internalSpacing * CGFloat(buttons.count - 1),
                height: maxHeight
            )
        }

        /// Layout info for when the buttons are shown top-to-bottom, so each button has the full width of the container.
        let layoutInfoForVerticalStacking = buttons.enumerated().map { index, button -> UIButton.LayoutInfo in
            return button.layoutInfoForWidth(availableWidth)
        }

        // (3) Try vertical stacking of the buttons and horizontal stacking in the buttons.
        let allFitHorizontallyWithVerticalStacking = layoutInfoForVerticalStacking.allSatisfy {
            switch $0.stackingOrientation {
            case .horizontal: return true
            case .vertical: return false
            }
        }
        if allFitHorizontallyWithVerticalStacking {
            let maxWidth = layoutInfoForVerticalStacking.max(by: { $0.buttonSize.width < $1.buttonSize.width} )!.buttonSize.width
            let maxHeight = layoutInfoForVerticalStacking.max(by: { $0.buttonSize.height < $1.buttonSize.height} )!.buttonSize.height
            return CGSize(
                width: maxWidth,
                height: maxHeight * CGFloat(buttons.count) + internalSpacing * CGFloat(buttons.count - 1)
            )
        }

        // (4) Go for vertical stacking of the buttons and vertical stacking in the buttons. This is the only case where the labels may use multiple lines.
        return buttons.enumerated().map { index, button -> CGSize in
            return button.sizeForVerticalStackingForWidth(availableWidth)
        }.reduce(CGSize(width: 0, height: -internalSpacing)) { buttonSize, accumulator -> CGSize in
            CGSize(
                width: max(accumulator.width, buttonSize.width),
                height: accumulator.height + internalSpacing + buttonSize.height
            )
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if buttons.isEmpty {
            return
        }

        // Try layouts in this order: (3) (4) (2) (1).
        // Mostly it makes sense to try from the more expanded layouts to the more compact because when given
        // more space than needed it looks best to fill it.
        // However (3) looks more balanced than (4) when there is loads of space, so try that first.

        // No attempt is made to fit within the width.
        // It is assumed that sizeThatFits was used correctly and sufficient space has been given.

        // First try stacking the buttons vertically and the image and title within each button horizontally (3).
        switch layoutVerticalHorizontal() {
        case .fits:
            return
        case .notEnoughWidth:
            // Use fully vertical stacking (4).
            layoutVerticalVertical()
            return
        case .notEnoughHeight:
            // Go on to (2) and (1).
            break
        }

        // (2)
        if layoutHorizontalVertical() {
            return
        }

        // (1)
        layoutHorizontalHorizontal()
    }

    /// This does not check if the buttons fit in the bounds height. They will be proportionally scaled to fit if needed.
    private func layoutVerticalVertical() {
        // In this mode, each button label can use multiple lines so each button will be as tall as it needs to be.

        let allInternalSizes = buttons.map { button -> UIButton.InternalSizes in
            button.internalSizesForVerticalStackingForWidth(bounds.width)
        }

        let fittingHeights = zip(buttons, allInternalSizes).map { (button, internalSizes) -> CGFloat in
            button.buttonSizeForContentSize(internalSizes.contentSize).height
        }

        let totalFittingHeightOfButtons = fittingHeights.reduce(0) { $0 + $1 }

        let availableHeightForButtons = bounds.height - internalSpacing * CGFloat(buttons.count - 1)

        /// Used to scale up the height of each button proportionally when the space available is more or less than the space needed.
        let heightScale = availableHeightForButtons / totalFittingHeightOfButtons

        var unroundedOriginY: CGFloat = 0
        for ((button, internalSizes), fittingHeight) in zip(zip(buttons, allInternalSizes), fittingHeights) {
            let originY = roundToPixels(unroundedOriginY)
            let unroundedHeight = fittingHeight * heightScale
            let height: CGFloat

            if button === buttons.last {
                // Ensure the last one ends exactly at the bottom of the container just in case.
                height = bounds.height - originY
            } else {
                height = roundToPixels(unroundedHeight)
            }

            button.frame = CGRect(x: 0, y: originY, width: bounds.width, height: height)

            button.updateEdgeInsetsForStackingOrientation(.vertical, imageSize: internalSizes.imageSize, titleSize: internalSizes.titleSize, largestImageLength: nil, largestTitleLength: nil)

            unroundedOriginY += unroundedHeight + internalSpacing
        }
    }

    private enum LayoutFitting {
        case notEnoughWidth
        case notEnoughHeight
        case fits
    }

    private func layoutVerticalHorizontal() -> LayoutFitting {
        /// Info for the buttons being stacked vertically.
        let layoutInfoForOuterVerticalStacking = buttons.enumerated().map { index, button -> UIButton.LayoutInfo in
            return button.layoutInfoForWidth(bounds.width)
        }

        let allFitHorizontallyWithVerticalStacking = layoutInfoForOuterVerticalStacking.allSatisfy {
            switch $0.stackingOrientation {
            case .horizontal: return true
            case .vertical: return false
            }
        }
        if allFitHorizontallyWithVerticalStacking == false {
            return .notEnoughWidth
        }

        let totalFittingHeightOfButtons = layoutInfoForOuterVerticalStacking.reduce(0) { $0 + $1.buttonSize.height }
        let availableHeightForButtons = bounds.height - internalSpacing * CGFloat(buttons.count - 1)

        guard totalFittingHeightOfButtons <= availableHeightForButtons else {
            return .notEnoughHeight
        }

        let widestImageWidth = layoutInfoForOuterVerticalStacking.max(by: { $0.internalSizes.imageSize.width < $1.internalSizes.imageSize.width} )!.internalSizes.imageSize.width
        let widestTitleWidth = layoutInfoForOuterVerticalStacking.max(by: { $0.internalSizes.titleSize.width < $1.internalSizes.titleSize.width} )!.internalSizes.titleSize.width

        for (index, button) in buttons.enumerated() {
            button.frame = frameForButtonAtIndex(index, stackingOrientation: .vertical)
            let info = layoutInfoForOuterVerticalStacking[index]
            button.updateEdgeInsetsForStackingOrientation(.horizontal, imageSize: info.internalSizes.imageSize, titleSize: info.internalSizes.titleSize, largestImageLength: widestImageWidth, largestTitleLength: widestTitleWidth)
        }

        return .fits
    }

    /// Returns true if the buttons fit in the bounds height.
    private func layoutHorizontalVertical() -> Bool {
        let allInternalSizes = buttons.enumerated().map { index, button -> UIButton.InternalSizes in
            let buttonWidth = lengthForButtonAtIndex(index, withContainerLength: bounds.width)
            return button.internalSizesForVerticalStackingForWidth(buttonWidth)
        }

        let fittingHeights = zip(buttons, allInternalSizes).map { (button, internalSizes) -> CGFloat in
            button.buttonSizeForContentSize(internalSizes.contentSize).height
        }

        let allFitVertically = fittingHeights.allSatisfy { fittingHeight -> Bool in
            fittingHeight <= bounds.height
        }

        guard allFitVertically else {
            return false
        }

        let tallestImageHeight = allInternalSizes.max(by: { $0.imageSize.height < $1.imageSize.height} )!.imageSize.height
        let tallestTitleHeight = allInternalSizes.max(by: { $0.titleSize.height < $1.titleSize.height} )!.titleSize.height

        for (index, button) in buttons.enumerated() {
            button.frame = frameForButtonAtIndex(index, stackingOrientation: .horizontal)
            let internalSizes = allInternalSizes[index]
            button.updateEdgeInsetsForStackingOrientation(.vertical, imageSize: internalSizes.imageSize, titleSize: internalSizes.titleSize, largestImageLength: tallestImageHeight, largestTitleLength: tallestTitleHeight)
        }

        return  true
    }

    private func layoutHorizontalHorizontal() {
        for (index, button) in buttons.enumerated() {
            button.frame = frameForButtonAtIndex(index, stackingOrientation: .horizontal)
            let internalSizes = button.internalSizesForHorizontalStacking
            button.updateEdgeInsetsForStackingOrientation(.horizontal, imageSize: internalSizes.imageSize, titleSize: internalSizes.titleSize, largestImageLength: nil, largestTitleLength: nil)
        }
    }
}

private extension UIButton {

    enum StackingOrientation {
        case horizontal
        case vertical
    }

    struct InternalSizes {
        let contentSize: CGSize
        let imageSize: CGSize
        let titleSize: CGSize
    }

    struct LayoutInfo {
        let stackingOrientation: StackingOrientation
        let requiresWrapping: Bool
        let buttonSize: CGSize
        let internalSizes: InternalSizes
    }

    private var halfInternalSpacing: CGFloat {
        round(0.3 * (titleLabel?.font.pointSize ?? 0))
    }

    func availableContentWidthForAvailableWidth(_ availableWidth: CGFloat) -> CGFloat {
        availableWidth - (contentEdgeInsets.left + contentEdgeInsets.right)
    }

    func layoutInfoForWidth(_ availableWidth: CGFloat) -> LayoutInfo {
        let internalSizes = internalSizesForHorizontalStacking
        let requiredContentSizeForHorizontalStacking = internalSizes.contentSize
        let imageSize = internalSizes.imageSize
        var titleSize = internalSizes.titleSize

        let availableContentWidth = availableContentWidthForAvailableWidth(availableWidth)

        let stackingOrientation: StackingOrientation
        let requiresWrapping: Bool
        let requiredContentSize: CGSize

        if requiredContentSizeForHorizontalStacking.width <= availableContentWidth {
            stackingOrientation = .horizontal
            requiresWrapping = false
            requiredContentSize = requiredContentSizeForHorizontalStacking
        } else if titleSize.width <= availableContentWidth {
            stackingOrientation = .vertical
            requiresWrapping = false
            // Below it’s duplicating code to avoid repeating the measurements. Should be the same as from
            // internalSizesForVerticalStackingForWidth since we know the title fits without wrapping.
            requiredContentSize = CGSize(
                width: max(imageSize.width, titleSize.height),
                height: imageSize.height + 2 * halfInternalSpacing + titleSize.height
            )
        } else {
            stackingOrientation = .vertical
            requiresWrapping = true
            let internalSizesForVerticalStacking = internalSizesForVerticalStackingForWidth(availableWidth)
            requiredContentSize = internalSizesForVerticalStacking.contentSize
            titleSize = internalSizesForVerticalStacking.titleSize
        }

        return LayoutInfo(
            stackingOrientation: stackingOrientation,
            requiresWrapping: requiresWrapping,
            buttonSize: buttonSizeForContentSize(requiredContentSize),
            internalSizes: InternalSizes(
                contentSize: requiredContentSize,
                imageSize: imageSize,
                titleSize: titleSize
            )
        )
    }

    /// The size required for the image view, title label, and combination of the two (content size) when the image and title are stacked horizontally (title right of image).
    var internalSizesForHorizontalStacking: InternalSizes {
        let unlimitedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let imageSize = imageView?.sizeThatFits(unlimitedSize) ?? .zero
        let titleSize = titleLabel?.sizeThatFits(unlimitedSize) ?? .zero

        return InternalSizes(
            contentSize: CGSize(
                width: imageSize.width + 2 * halfInternalSpacing + titleSize.width,
                height: max(imageSize.height, titleSize.height)
            ),
            imageSize: imageSize,
            titleSize: titleSize
        )
    }

    /// The size required for the image view, title label, and combination of the two (content size) when the image and title are stacked vertically (image above title).
    func internalSizesForVerticalStackingForWidth(_ availableWidth: CGFloat?) -> InternalSizes {
        let availableContentWidth = availableWidth != nil ? availableContentWidthForAvailableWidth(availableWidth!) : CGFloat.greatestFiniteMagnitude

        let restrictedSize = CGSize(width: availableContentWidth, height: CGFloat.greatestFiniteMagnitude)
        let titleSizeWithWrapping = titleLabel?.sizeThatFits(restrictedSize) ?? .zero

        let unlimitedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let imageSize = imageView?.sizeThatFits(unlimitedSize) ?? .zero

        return InternalSizes(
            contentSize: CGSize(
                width: max(imageSize.width, titleSizeWithWrapping.width),
                height: imageSize.height + 2 * halfInternalSpacing + titleSizeWithWrapping.height
            ),
            imageSize: imageSize,
            titleSize: titleSizeWithWrapping
        )
    }

    /// The minimum size for the button for the given content size. Content size is the size of the union of the image and title frames.
    func buttonSizeForContentSize(_ contentSize: CGSize) -> CGSize {
        /// Minimum recommend touch target size.
        let minLength: CGFloat = 44
        return CGSize(
            width: max(minLength, contentSize.width + contentEdgeInsets.left + contentEdgeInsets.right),
            height: max(minLength, contentSize.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
        )
    }

    /// The minimum size for the button fitting within the given width when the image and title are stacked vertically (image above title).
    func sizeForVerticalStackingForWidth(_ availableWidth: CGFloat?) -> CGSize {
        let internalSizes = internalSizesForVerticalStackingForWidth(availableWidth)
        return buttonSizeForContentSize(internalSizes.contentSize)
    }

    func updateEdgeInsetsForStackingOrientation(_ stackingOrientation: StackingOrientation, imageSize: CGSize, titleSize: CGSize, largestImageLength: CGFloat?, largestTitleLength: CGFloat?) {
        switch stackingOrientation {

        case .horizontal:
            let extraImageShift: CGFloat
            let extraTitleShift: CGFloat
            if let largestTitleLength = largestTitleLength, let largestImageLength = largestImageLength {
                extraImageShift = 0.5 * (largestTitleLength - titleSize.width)
                extraTitleShift = 0.5 * (largestTitleLength - titleSize.width - largestImageLength + imageSize.width)
            } else {
                extraImageShift = 0
                extraTitleShift = 0
            }

            imageEdgeInsets = UIEdgeInsets(view: self, top: 0, leading: -extraImageShift, bottom: 0, trailing: halfInternalSpacing + extraImageShift)
            titleEdgeInsets = UIEdgeInsets(view: self, top: 0, leading: halfInternalSpacing - extraTitleShift, bottom: 0, trailing: extraTitleShift)

        case .vertical:
            let extraImageShift: CGFloat
            let extraTitleShift: CGFloat
            if let largestTitleLength = largestTitleLength, let largestImageLength = largestImageLength {
                extraImageShift = 0.5 * (largestTitleLength - titleSize.height)
                extraTitleShift = 0.5 * (largestTitleLength - titleSize.height - largestImageLength + imageSize.height)
            } else {
                extraImageShift = 0
                extraTitleShift = 0
            }

            imageEdgeInsets = UIEdgeInsets(view: self, top: -extraImageShift, leading: 0, bottom: titleSize.height + halfInternalSpacing + extraImageShift, trailing: -titleSize.width)
            titleEdgeInsets = UIEdgeInsets(view: self, top: imageSize.height + halfInternalSpacing - extraTitleShift, leading: -imageSize.width, bottom: extraTitleShift, trailing: 0)
        }
    }
}

private extension UIEdgeInsets {
    /// Maps leading and trailing to right and left for right-to-left layout.
    init(view: UIView, top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        let left: CGFloat
        let right: CGFloat

        if view.isEffectiveUserInterfaceLayoutDirectionRightToLeft {
            left = trailing
            right = leading
        } else {
            left = leading
            right = trailing
        }

        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}

private extension UIView {
    var isEffectiveUserInterfaceLayoutDirectionRightToLeft: Bool {
        switch effectiveUserInterfaceLayoutDirection {
        case .rightToLeft:
            return true
        case .leftToRight: fallthrough @unknown default:
            return false
        }
    }

    func roundToPixels(_ unrounded: CGFloat, function: (CGFloat) -> CGFloat = round) -> CGFloat {
        let scale = window?.screen.scale ?? 1
        return roundToPrecision(unrounded, precision: 1 / scale, function: function)
    }
}

private func roundToPrecision<T>(_ unrounded: T, precision: T, function: (T) -> T) -> T where T : FloatingPoint {
    function(unrounded / precision) * precision
}
