// Douglas Hill, March 2020

import UIKit

class DemoViewController: UIViewController {

    let scrollView = UIScrollView()

    var buttonStack1: DynamicButtonStack?
    var buttonStack2: DynamicButtonStack?
    var buttonStack3: DynamicButtonStack?
    var buttonStack4: DynamicButtonStack?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        view.backgroundColor = .systemBackground_

        let makeButton: (String?, String?) -> UIButton = { imageName, title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.label_, for: .normal)
            button.titleLabel!.font = UIFont.preferredFont(forTextStyle: .body)
            if let imageName = imageName {
                button.setImage(UIImage.createWithSystemName(imageName, font: button.titleLabel!.font), for: .normal)
            }
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            button.backgroundColor = .secondarySystemBackground_
            return button
        }

        buttonStack1 = DynamicButtonStack(buttons: [
            makeButton("wand.and.stars", "Auto"),
            makeButton("bold.italic.underline", "Style"),
            makeButton("paperplane", "Send"),
        ])

        buttonStack2 = DynamicButtonStack(buttons: [
            makeButton("arrowshape.turn.up.right", "回覆"),
            makeButton("gear", "設定"),
            makeButton("square.and.arrow.up", "分享"),
            makeButton("square.and.pencil", "編寫"),
            makeButton("trash", "刪除"),
        ])

        buttonStack3 = DynamicButtonStack(buttons: [
            makeButton("plus", "Hinzufügen"),
            makeButton("folder", "Organisieren"),
            makeButton("arrow.clockwise", "Aktualisieren"),
        ])

        buttonStack4 = DynamicButtonStack(buttons: [
            makeButton("person.3", "Collaborate on This Document With Some People"),
            makeButton("waveform.path.badge.plus", "Signal Boost"),
            makeButton("dot.radiowaves.left.and.right", "Broadcast"),
        ])

        for subview in [buttonStack1!, buttonStack2!, buttonStack3!, buttonStack4!] {
            scrollView.addSubview(subview)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let bounds = view.bounds

        let availableSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)

        var size1 = buttonStack1!.sizeThatFits(availableSize)
        var size2 = buttonStack2!.sizeThatFits(availableSize)
        var size3 = buttonStack3!.sizeThatFits(availableSize)
        var size4 = buttonStack4!.sizeThatFits(availableSize)

        let useFullWidth = true
        if useFullWidth {
            size1.width = availableSize.width
            size2.width = availableSize.width
            size3.width = availableSize.width
            size4.width = availableSize.width
        }

        buttonStack1!.frame = CGRect(x: 0, y: 60, width: size1.width, height: size1.height)
        buttonStack2!.frame = CGRect(x: 0, y: buttonStack1!.frame.maxY + 50, width: size2.width, height: size2.height)
        buttonStack3!.frame = CGRect(x: 0, y: buttonStack2!.frame.maxY + 50, width: size3.width, height: size3.height)
        buttonStack4!.frame = CGRect(x: 0, y: buttonStack3!.frame.maxY + 50, width: size4.width, height: size4.height)

        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: bounds.width, height: buttonStack4!.frame.maxY + 50)
    }
}
