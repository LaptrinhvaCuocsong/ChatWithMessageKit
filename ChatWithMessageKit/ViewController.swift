//
//  ViewController.swift
//  ChatWithMessageKit
//
//  Created by Apple on 07/03/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import MessageKit
import UIKit

class ViewController: UIViewController {
    private lazy var messageController: MessageController = {
        let vc = MessageController()
        vc.viewController = self
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Message Kit"

        addChild(messageController)
        messageController.view.frame = view.bounds
        view.addSubview(messageController.view)
    }

    override var inputAccessoryView: UIView? {
        return messageController.slackInputBar
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}
