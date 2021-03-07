//
//  Message.swift
//  ChatWithMessageKit
//
//  Created by Apple on 07/03/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import MessageKit
import UIKit

private struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage()
    }

    init(imageURL: URL) {
        url = imageURL
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    private init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }

    init(sender: SenderType, messageId: String, sentDate: Date, text: String) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(text))
    }

    init(sender: SenderType, messageId: String, sentDate: Date, image: UIImage) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .photo(mediaItem))
    }
}
