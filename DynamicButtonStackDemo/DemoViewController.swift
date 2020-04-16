// Douglas Hill, March 2020

import UIKit

class DemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let makeButton: (String?, String?) -> UIButton = { imageName, title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.titleLabel!.font = UIFont.preferredFont(forTextStyle: .body)
            if let imageName = imageName {
                button.setImage(UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(font: button.titleLabel!.font)), for: .normal)
            }
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            button.backgroundColor = .secondarySystemBackground
            return button
        }

        let buttonStack1 = DynamicButtonStack(buttons: [
            makeButton("wand.and.stars", "Auto"),
            makeButton("bold.italic.underline", "Style"),
            makeButton("paperplane", "Send"),
        ])

        let buttonStack2 = DynamicButtonStack(buttons: [
            makeButton("arrowshape.turn.up.right", "回覆"),
            makeButton("gear", "設定"),
            makeButton("square.and.arrow.up", "分享"),
            makeButton("square.and.pencil", "編寫"),
            makeButton("trash", "刪除"),
        ])

        let buttonStack3 = DynamicButtonStack(buttons: [
            makeButton("plus", "Hinzufügen"),
            makeButton("folder", "Organisieren"),
            makeButton("arrow.clockwise", "Aktualisieren"),
        ])

        let buttonStack4 = DynamicButtonStack(buttons: [
            makeButton("person.3", "Collaborate on This Document With Some People"),
            makeButton("waveform.path.badge.plus", "Signal Boost"),
            makeButton("dot.radiowaves.left.and.right", "Broadcast"),
        ])

        let stackView = UIStackView(arrangedSubviews: [buttonStack1, buttonStack2, buttonStack3, buttonStack4])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.widthAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 60),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),

            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
}
