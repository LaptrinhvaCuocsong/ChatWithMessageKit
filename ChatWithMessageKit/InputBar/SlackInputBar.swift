//
//  SlackInputBar.swift
//  ChatWithMessageKit
//
//  Created by Apple on 07/03/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import InputBarAccessoryView
import UIKit

protocol SlackInputBarDelegate: class {
    func slackInputBar(_ view: SlackInputBar, didTapCameraButton button: InputBarButtonItem)
    func slackinputBar(_ view: SlackInputBar, didTapLibraryButton button: InputBarButtonItem)
}

final class SlackInputBar: InputBarAccessoryView {
    weak var slackDelegate: SlackInputBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        let items = [
            makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
            }.onSelected { [weak self] item in
                guard let self = self else { return }
                item.tintColor = .systemBlue
                self.slackDelegate?.slackInputBar(self, didTapCameraButton: item)
            },
            .flexibleSpace,
            makeButton(named: "ic_library")
                .onSelected { [weak self] item in
                    guard let self = self else { return }
                    item.tintColor = .systemBlue
                    self.slackDelegate?.slackinputBar(self, didTapLibraryButton: item)
                },
            sendButton
                .configure {
                    $0.layer.cornerRadius = 8
                    $0.layer.borderWidth = 1.5
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.setTitleColor(.white, for: .normal)
                    $0.setTitleColor(.white, for: .highlighted)
                    $0.setSize(CGSize(width: 52, height: 30), animated: false)
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .clear
                }.onEnabled {
                    $0.backgroundColor = .systemBlue
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform because changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
                },
        ]
        items.forEach { $0.tintColor = .lightGray }

        // We can change the container insets if we want
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)

        let maxSizeItem = InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate)
                $0.tintColor = .darkGray
                $0.setSize(CGSize(width: 20, height: 20), animated: false)
            }.onSelected {
                let oldValue = $0.inputBarAccessoryView?.shouldForceTextViewMaxHeight ?? false
                $0.image = oldValue ? UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "icons8-collapse")?.withRenderingMode(.alwaysTemplate)
                self.setShouldForceMaxTextViewHeight(to: !oldValue, animated: true)
            }
        rightStackView.alignment = .top
        setStackViewItems([maxSizeItem], forStack: .right, animated: false)
        setRightStackViewWidthConstant(to: 20, animated: false)

        // Finally set the items
        setStackViewItems(items, forStack: .bottom, animated: false)

        shouldAnimateTextDidChangeLayout = true
    }

    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }
    }
}
