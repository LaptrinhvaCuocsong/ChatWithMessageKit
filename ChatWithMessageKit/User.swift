//
//  User.swift
//  ChatWithMessageKit
//
//  Created by Apple on 07/03/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import MessageKit

struct User: SenderType {
    var senderId: String
    var displayName: String
}
